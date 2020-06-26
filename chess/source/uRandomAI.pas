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

      procedure OnComputeMove(); virtual;
      procedure OnPlayMove(); virtual;
   end;

VAR
   RandomAI: TRandomAI;

IMPLEMENTATION

{ TRandomAI }

constructor TRandomAI.Create();
begin
   Name := 'Random';
   Id := 'random';

   inherited;
end;

procedure TRandomAI.OnComputeMove();
var
   index: loopint;

begin
   if(chess.Moves.n > 0) then begin
      index := Random(chess.Moves.n);
      Move := chess.Moves.List[index];
      ComputedMove := true;
   end;
end;

procedure TRandomAI.OnPlayMove();
begin
   game.PlayMove(Move);
end;

INITIALIZATION
   RandomAI.Create();
   CurrentAI := @RandomAI;

END.
