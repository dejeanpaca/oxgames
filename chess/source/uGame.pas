{$INCLUDE oxdefines.inc}
UNIT uGame;

INTERFACE

   USES
      uStd,
      {ox}
      oxuTypes,
      {game}
      uChess;

TYPE

   { TGameGlobal }

   TGameGlobal = record
      OnNew,
      OnSelectedTile,
      OnUnselectedTile: TProcedures;

      SelectedTile: oxTPoint;

      procedure New();

      {select a tile to play}
      procedure SelectTile(x, y: loopint);
   end;

VAR
   game: TGameGlobal;

IMPLEMENTATION

{ TGameGlobal }

procedure TGameGlobal.New();
begin
   chess.CurrentPlayer := chess.StartingPlayer;
   chess.ResetBoard();

   {unselect tile}
   SelectedTile.x := -1;
   SelectedTile.y := -1;

   OnNew.Call();
end;

procedure TGameGlobal.SelectTile(x, y: loopint);
begin
   {if given tile was already selected, unselect it}
   if(SelectedTile.x = x) and (SelectedTile.y = y) then begin
      OnUnselectedTile.Call();

      SelectedTile.x := -1;
      SelectedTile.y := -1;
   end else begin
      {unselect given tile}
      SelectedTile.x := x;
      SelectedTile.y := y;

      OnSelectedTile.Call();
   end;
end;

INITIALIZATION
   TProcedures.Initialize(game.OnNew);
   TProcedures.Initialize(game.OnSelectedTile);
   TProcedures.Initialize(game.OnUnselectedTile);

END.
