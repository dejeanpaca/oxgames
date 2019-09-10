{$INCLUDE oxdefines.inc}
UNIT uSnek;

INTERFACE

   USES
      udvars, uLog,
      uOX, oxuRunRoutines;

TYPE
   TSnek = record
      dv: TDVarGroup;
      Init: oxTRunRoutines;
   end;

VAR
   snek: TSnek;

procedure snekInitialize();
procedure snekDeinitialize();

IMPLEMENTATION

procedure snekInitialize();
begin
   snek.Init.iCall();
   log.i('snek > initialized');
end;

procedure snekDeinitialize();
begin
   snek.Init.dCall();
   log.i('snek > deinitialized');
end;

VAR
   initRoutines: oxTRunRoutine;

INITIALIZATION
   dvar.Add('snek', snek.dv);
   ox.OnInitialize.Add(initRoutines, 'snek.initialize', @snekInitialize, @snekDeinitialize)

END.
