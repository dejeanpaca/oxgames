{$INCLUDE oxdefines.inc}
UNIT uBoard2D;

INTERFACE

   USES
      uStd, StringUtils,
      {ox}
      oxuProjection,
      oxuCameraComponent, oxuEntity,
      oxuMaterial,
      oxuPrimitiveModelComponent,
      {game}
      uChess, uGame, uScene, uShared, uResources, uGameComponent, uBoard;

CONST
   BOARD_2D_RATIO = 0.9;
   PIECE_2D_RATIO = 0.8;

   BOARD_2D_PROJECTION_SIZE = 10;
   BOARD_2D_SIZE = BOARD_2D_PROJECTION_SIZE * BOARD_2D_RATIO;
   BOARD_2D_TILE_SIZE = BOARD_2D_SIZE / 8;

TYPE
   { TBoard2D }

   TBoard2D = object(TBoard)
      GridSize: TGridElementsSize;

      TileReference: array[0..7, 0..7] of oxTEntity;

      {position a piece on the board}
      procedure PositionPiece(entity: oxTEntity; x, y: loopint);

      procedure Empty(); virtual;
      procedure BuildBoard();
      procedure Activate(); virtual;
   end;

VAR
   board2d: TBoard2D;

IMPLEMENTATION

{create entities from the chess board state}
procedure createPiece(where: oxTEntity; x, y: loopint; player: TPlayer);
var
   component: oxTPrimitiveModelComponent;
   useMaterial: oxTMaterial;
   reference: oxTEntity;

begin
   useMaterial := resources.GetPieceMaterial2D(chess.Board[y][x].Piece, player);

   {we have no piece here, so remove the entity}
   if(useMaterial = nil) then begin
      if(board2d.Reference[y][x] <> nil) then
         oxEntity.Remove(board2d.Reference[y][x]);

      exit;
   end;

   {existing piece does not match the player}
   if(chess.Board[y][x].Player <> player) then
      exit;

   {create a piece entity}
   if(board2d.Reference[y][x] = nil) then begin
      reference := oxTPrimitiveModelComponent.GetEntity(component);
      component.Plane();
      board2d.Reference[y][x] := reference;
   end else begin
      reference := board2d.Reference[y][x];
      component := oxTPrimitiveModelComponent(reference.GetComponent('oxTPrimitiveModelComponent'));
   end;

   reference.Name := PIECE_NAMES[loopint(chess.Board[y][x].Piece)];

   if(component.Model.Material <> useMaterial) then
      component.Model.Material := useMaterial;

   board2d.PositionPiece(reference, x, y);

   where.Add(board2d.Reference[y][x]);
end;

{create entities from the chess board state}
procedure createPieces(where: oxTEntity; player: TPlayer);
var
   i, j: loopint;

begin
   for i := 0 to 7 do begin
      for j := 0 to 7 do begin
         createPiece(where, j, i, player);
      end;
   end;
end;

{ TBoard2D }

procedure TBoard2D.PositionPiece(entity: oxTEntity; x, y: loopint);
begin
   y := 7 - y;

   entity.SetPosition(x * GridSize.d * 2 - GridSize.HalfW, -y * GridSize.d * 2 + GridSize.halfH, 0.5);
   entity.SetScale(GridSize.d * PIECE_2D_RATIO, GridSize.d * PIECE_2D_RATIO, 1.0);
end;

procedure TBoard2D.Empty();
begin
   inherited;

   ZeroOut(TileReference, SizeOf(TileReference));
end;

function createBoard(): oxTEntity;
var
   entity: oxTEntity;
   component: oxTPrimitiveModelComponent;
   i, j: loopint;

begin
   Result := oxEntity.New('Board');

   {create a background}
   entity := oxTPrimitiveModelComponent.GetEntity(component);
   component.Plane();
   entity.Name := 'Background';
   entity.SetScale(board2d.GridSize.halfW * 1.25, board2d.GridSize.halfH * 1.25, 1);
   entity.SetPosition(0, 0, -0.5);
   component.Model.SetMaterial(resources.Materials.Background);
   Result.Add(entity);

   {create tiles}
   for i := 0 to 7 do begin
      for j := 0 to 7 do begin
         entity := oxTPrimitiveModelComponent.GetEntity(component);
         component.Plane();

         entity.Name := sf(i) + 'x' + sf(j);

         entity.SetPosition(i * board2d.GridSize.d * 2 - board2d.GridSize.halfW,
            j * board2d.GridSize.d * 2 - board2d.GridSize.halfH, 0);

         entity.SetScale(board2d.GridSize.d, board2d.GridSize.d, 1);

         if((i * 7 + j) mod 2 = 0) then
            component.Model.SetMaterial(resources.Materials.BlackTile)
         else
            component.Model.SetMaterial(resources.Materials.WhiteTile);

         board2d.TileReference[i, j] := entity;
         Result.Add(entity);
      end;
   end;
end;

procedure TBoard2D.BuildBoard();
begin
   TGridElementsSize.Initialize(gridSize);
   GridSize.Get(scene.Camera, 8, 8);
   GridSize.Mul(BOARD_2D_RATIO);

   {setup board}
   Board := createBoard();

   { black and white pieces }
   Black := oxEntity.New('Black');
   createPieces(Black, PLAYER_BLACK);

   White := oxEntity.New('White');
   createPieces(White, PLAYER_WHITE);

   gameComponent.Entity.Add(Board);
   gameComponent.Entity.Add(Black);
   gameComponent.Entity.Add(White);
end;

procedure TBoard2D.Activate();
begin
   scene.Camera.Projection.Ortho(10, -1.0, 1.0);
   scene.Camera.Camera.Initialize();
   scene.Camera.Camera.Reset();

   BuildBoard();
end;

procedure selectedTile();
var
   tile: oxTEntity;
   component: oxTPrimitiveModelComponent;

begin
   tile := board2d.TileReference[game.SelectedTile.y, game.SelectedTile.x];
   component := oxTPrimitiveModelComponent(tile.GetComponent('oxTPrimitiveModelComponent'));

   if(component.Model.Material = resources.Materials.BlackTile) then
      component.Model.SetMaterial(resources.Materials.Selected.BlackTile)
   else
      component.Model.SetMaterial(resources.Materials.Selected.WhiteTile);
end;

procedure unselectedTile();
var
   tile: oxTEntity;
   component: oxTPrimitiveModelComponent;

begin
   tile := board2d.TileReference[game.SelectedTile.y, game.SelectedTile.x];
   component := oxTPrimitiveModelComponent(tile.GetComponent('oxTPrimitiveModelComponent'));

   if(component.Model.Material = resources.Materials.Selected.BlackTile) then
      component.Model.SetMaterial(resources.Materials.BlackTile)
   else
      component.Model.SetMaterial(resources.Materials.WhiteTile);
end;

INITIALIZATION
   board2d.Create();
   game.OnSelectedTile.Add(@selectedTile);
   game.OnUnselectedTile.Add(@unselectedTile);

END.
