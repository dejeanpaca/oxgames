{$INCLUDE oxdefines.inc}
UNIT uBoard3D;

INTERFACE

   USES
      uStd, uLog,
      {ox}
      oxuProjectionType, oxuProjection,
      oxuCameraComponent, oxuModelComponent,
      oxuEntity, oxuModel,
      {game}
      uChess, uScene, uGameComponent, uResources;

TYPE
   { TBoard3D }

   TBoard3D = record
      Board,
      White,
      Black: oxTEntity;

      Reference: array[0..7, 0..7] of oxTEntity;

      Pieces: record
         Black,
         White: array[0..15] of oxTEntity;
      end;

      procedure Activate();
   end;

VAR
   board3d: TBoard3D;

IMPLEMENTATION

{create entities from the chess board state}
procedure createPiece(where: oxTEntity; x, y: loopint; player: TPlayer);
var
   component: oxTModelComponent;
   useModel: oxTModel;
   reference: oxTEntity;

begin
   useModel := resources.GetModel(chess.Board[y][x].Piece, player);

   // we have no piece here, so remove the entity
   if(useModel = nil) then begin
     if(board3d.Reference[y][x] <> nil) then
        oxEntity.Remove(board3d.Reference[y][x]);

     exit;
   end;

   // existing piece does not match the player
   if(chess.Board[y][x].Player <> player) then
      exit;

   // create a piece entity
   if(board3d.Reference[y][x] = nil) then begin
      reference := oxTModelComponent.GetEntity(component);
      board3d.Reference[y][x] := reference;
   end else begin
      reference := board3d.Reference[y][x];
      component := oxTModelComponent(reference.GetComponent('oxTModelComponent'));
   end;

   reference.Name := PIECE_NAMES[loopint(chess.Board[y][x].Piece)];
   if(component.Model <> useModel) then
      component.Model := useModel;

   where.Add(board3d.Reference[y][x]);
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

{ TBoard3D }

procedure TBoard3D.Activate();
var
   projection: oxPProjection;
   boardModel: oxTModelComponent;

begin
   projection := scene.Camera.GetProjection();
   projection^.DefaultPerspective();

   {setup board}
   Board := oxTModelComponent.GetEntity(boardModel);
   Board.Name := 'Board';
   boardModel.Model := resources.Board;

   { black and white pieces }
   Black := oxEntity.New('Black');
   createPieces(Black, PLAYER_BLACK);

   White := oxEntity.New('White');
   createPieces(White, PLAYER_WHITE);

   { add all to main board entity}
   gameComponent.Entity.Add(Board);
   gameComponent.Entity.Add(Black);
   gameComponent.Entity.Add(White);
end;

END.
