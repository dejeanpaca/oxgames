{$INCLUDE oxdefines.inc}
UNIT uBoard3D;

INTERFACE

   USES
      uStd, uLog, vmVector,
      {ox}
      oxuProjectionType, oxuProjection,
      oxuCameraComponent, oxuModelComponent,
      oxuEntity, oxuModel,
      {game}
      uChess, uScene, uGame, uGameComponent, uResources, uBoard;

TYPE
   { TBoard3D }

   TBoard3D = object(TBoard)
      {size of the squares on the board}
      SquareSize: single;

      {position a piece on the board}
      procedure PositionPiece(entity: oxTEntity; x, y: loopint);
      {activate this board}
      procedure Activate(); virtual;
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

   {we have no piece here, so remove the entity}
   if(useModel = nil) then begin
      if(board3d.Reference[y][x] <> nil) then
         oxEntity.Remove(board3d.Reference[y][x]);

      exit;
   end;

   {existing piece does not match the player}
   if(chess.Board[y][x].Player <> player) then
      exit;

   {create a piece entity}
   reference := oxTModelComponent.GetEntity(component);
   board3d.Reference[y][x] := reference;

   reference.Name := PIECE_NAMES[loopint(chess.Board[y][x].Piece)];

   if(component.Model <> useModel) then
      component.Model := useModel;

   board3d.PositionPiece(reference, x, y);

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

procedure TBoard3D.PositionPiece(entity: oxTEntity; x, y: loopint);
var
   ofs: Single;

begin
   ofs := SquareSize / 2 - 4 * SquareSize;
   entity.SetPosition(x * SquareSize + ofs,  0.0, -y * SquareSize - ofs);
end;


procedure TBoard3D.Activate();
var
   projection: oxPProjection;
   boardModel: oxTModelComponent;

begin
   projection := @scene.Camera.Projection;
   projection^.Perspective(75, 0.1, 100);

   scene.Camera.Camera.vPos.Assign(0.0, 8, 10);
   scene.Camera.Camera.PitchYaw(-45, 270);

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

procedure selectedTile();
begin
   if(CurrentBoard <> @board3d) then
      exit;
end;

procedure unselectedTile();
begin
   if(CurrentBoard <> @board3d) then
      exit;
end;

procedure movePlayed();
var
   move: TChessMove;
   sourceReference,
   targetReference: oxTEntity;

begin
   if(CurrentBoard <> @board3d) then
      exit;

   move := chess.GetLastMove();

   {destroy target piece entity}
   targetReference := board3d.Reference[move.pTo.y, move.pTo.x];
   sourceReference := board3d.Reference[move.pFrom.y, move.pFrom.x];

   {sanity check if we've been fed invalid state}
   if(sourceReference = nil) then
      exit;

   if(targetReference <> nil) then
      oxEntity.Remove(targetReference);

   {replace target entity with old}
   board3d.Reference[move.pTo.y, move.pTo.x] := sourceReference;
   board3d.PositionPiece(sourceReference, move.pTo.x, move.pTo.y);

   {should nothing be left at old one}
   board3d.Reference[move.pFrom.y, move.pFrom.x] := nil;
end;

INITIALIZATION
   board3d.Create();
   board3d.SquareSize := 2.0;

   game.OnSelectedTile.Add(@selectedTile);
   game.OnUnselectedTile.Add(@unselectedTile);
   game.OnMovePlayed.Add(@movePlayed);

END.
