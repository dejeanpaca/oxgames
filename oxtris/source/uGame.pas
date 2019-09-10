{$INCLUDE oxdefines.inc}
UNIT uGame;

INTERFACE

   USES
      uStd, uLog, oxuTimer,
      oxuEntity;

CONST
   GRID_WIDTH = 50;
   GRID_HEIGHT = 50;

   GRID_MAX_WIDTH = 1000;
   GRID_MAX_HEIGHT = 1000;

TYPE

   { TGame }

   TGame = record
      OnNew: TProcedures;

      procedure New();
   end;

VAR
   game: TGame;

IMPLEMENTATION

{ TGame }

procedure TGame.New();
begin
   oxTime.Resume();

   OnNew.Call();
end;

INITIALIZATION
   game.OnNew.Initialize(game.OnNew);

END.
