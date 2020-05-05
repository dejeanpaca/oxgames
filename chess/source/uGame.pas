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
      OnNew: TProcedures;

      SelectedTile: oxTPoint;

      procedure New();
   end;

VAR
   game: TGameGlobal;

IMPLEMENTATION

{ TGameGlobal }

procedure TGameGlobal.New();
begin
   chess.CurrentPlayer := chess.StartingPlayer;
   chess.ResetBoard();
end;

INITIALIZATION
   TProcedures.Initialize(game.OnNew);

END.
