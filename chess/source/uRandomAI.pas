{$INCLUDE oxdefines.inc}
UNIT uRandomAI;

INTERFACE

   USES
      uStd, uLog,
      {game}
      uAI, uChess, uGame;

TYPE

   { TRandomAI }

   TRandomAI = object(TAI)
      constructor Create();

      procedure Reset(); virtual;
      procedure PlayMove(); virtual;
   end;

VAR
   RandomAI: TRandomAI;

IMPLEMENTATION

{ TRandomAI }

constructor TRandomAI.Create();
begin
   Name := 'Random';
end;

procedure TRandomAI.Reset();
begin

end;

procedure TRandomAI.PlayMove();
var
   index: loopint;

begin
   if(chess.Moves.n > 0) then begin
      index := Random(chess.Moves.n);
      game.PlayMove(chess.Moves.List[index]);
   end else
      log.w('Random AI can''t play any more moves');
end;

INITIALIZATION
   RandomAI.Create();
   CurrentAI := @RandomAI;

END.
