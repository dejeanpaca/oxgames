{$INCLUDE oxdefines.inc}
UNIT uGame;

INTERFACE

   USES
      uStd;

TYPE

   { TGameGlobal }

   TGameGlobal = record
      OnNew: TProcedures;

      procedure New();
   end;

VAR
   game: TGameGlobal;

IMPLEMENTATION

{ TGameGlobal }

procedure TGameGlobal.New();
begin

end;

INITIALIZATION
   TProcedures.Initialize(game.OnNew);

END.
