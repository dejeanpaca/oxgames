{$INCLUDE oxdefines.inc}
UNIT uBoard2D;

INTERFACE

   USES
      uStd, StringUtils,
      {ox}
      oxuProjection,
      oxuCameraComponent, oxuEntity,
      oxuMaterial,
      oxuPrimitiveModelComponent, oxuTextComponent,
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

      procedure SelectedTile(); virtual;
      procedure UnselectedTile(); virtual;
      procedure MovePlayed(); virtual;
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
   reference := oxTPrimitiveModelComponent.GetEntity(component);
   component.Plane();
   board2d.Reference[y][x] := reference;

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

function getTextPosition(i: loopint): single;
begin
   Result := i * BOARD_2D_TILE_SIZE - BOARD_2D_SIZE / 2 + BOARD_2D_TILE_SIZE / 2;
end;

function createBoard(): oxTEntity;
var
   parent,
   entity: oxTEntity;
   component: oxTPrimitiveModelComponent;
   text: oxTTextComponent;
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

   parent := oxEntity.New('Tiles');

   {create tiles}
   for i := 0 to 7 do begin
      for j := 0 to 7 do begin
         entity := oxTPrimitiveModelComponent.GetEntity(component);
         component.Plane();

         entity.Name := sf(j) + 'x' + sf(i);

         entity.SetPosition(j * board2d.GridSize.d * 2 - board2d.GridSize.halfW,
            i * board2d.GridSize.d * 2 - board2d.GridSize.halfH, 0);

         entity.SetScale(board2d.GridSize.d, board2d.GridSize.d, 1);

         if((i * 7 + j) mod 2 = 0) then
            component.Model.SetMaterial(resources.Materials.Tile.Black)
         else
            component.Model.SetMaterial(resources.Materials.Tile.White);

         board2d.TileReference[i, j] := entity;
         parent.Add(entity);
      end;
   end;

   Result.Add(parent);

   {add text to board}

   parent := oxEntity.New('Text');

   for i := 0 to 7 do begin
      entity := oxTTextComponent.GetEntity(sf(i + 1), text);
      text.SetFont(resources.Font);
      entity.Name := sf(i + 1);
      entity.SetPosition(-4.7, GetTextPosition(i), 0.0);
      entity.SetScale(0.3, 0.3, 0.3);

      parent.Add(entity);

      entity := oxTTextComponent.GetEntity(chess.HorizontalCoordinate(i), text);
      text.SetFont(resources.Font);
      entity.Name := chess.HorizontalCoordinate(i);
      entity.SetPosition(getTextPosition(i), 4.7, 0.0);
      entity.SetScale(0.3, 0.3, 0.3);

      parent.Add(entity);
   end;

   Result.Add(parent);
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

procedure TBoard2D.SelectedTile();
var
   tile: oxTEntity;
   component: oxTPrimitiveModelComponent;

begin
   tile := TileReference[game.SelectedTile.y, game.SelectedTile.x];
   component := oxTPrimitiveModelComponent(tile.GetComponent('oxTPrimitiveModelComponent'));

   if(component.Model.Material = resources.Materials.Tile.Black) then
      component.Model.SetMaterial(resources.Materials.SelectedTile.Black)
   else
      component.Model.SetMaterial(resources.Materials.SelectedTile.White);
end;

procedure TBoard2D.UnselectedTile();
var
   tile: oxTEntity;
   component: oxTPrimitiveModelComponent;

begin
   tile := TileReference[game.SelectedTile.y, game.SelectedTile.x];
   component := oxTPrimitiveModelComponent(tile.GetComponent('oxTPrimitiveModelComponent'));

   if(component.Model.Material = resources.Materials.SelectedTile.Black) then
      component.Model.SetMaterial(resources.Materials.Tile.Black)
   else
      component.Model.SetMaterial(resources.Materials.Tile.White);
end;

procedure TBoard2D.MovePlayed();
var
   move: TChessMove;
   sourceReference,
   targetReference: oxTEntity;

begin
   move := chess.GetLastMove();

   {destroy target piece entity}
   targetReference := Reference[move.pTo.y, move.pTo.x];
   sourceReference := Reference[move.pFrom.y, move.pFrom.x];

   {sanity check if we've been fed invalid state}
   if(sourceReference = nil) then
      exit;

   if(targetReference <> nil) then
      oxEntity.Remove(targetReference);

   {replace target entity with old}
   Reference[move.pTo.y, move.pTo.x] := sourceReference;
   PositionPiece(sourceReference, move.pTo.x, move.pTo.y);

   {should nothing be left at old one}
   Reference[move.pFrom.y, move.pFrom.x] := nil;
end;

INITIALIZATION
   board2d.Create();

END.
