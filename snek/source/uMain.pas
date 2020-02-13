{$INCLUDE oxdefines.inc}
UNIT uMain;

INTERFACE

   USES
      udvars, uLog,
      uOX, oxuRunRoutines;

TYPE
   TMain = record
      dv: TDVarGroup;
      Init: oxTRunRoutines;
   end;

VAR
   main: TMain;

IMPLEMENTATION

procedure initialize();
begin
   main.Init.iCall();
   log.i('snek > initialized');
end;

procedure deinitialize();
begin
   main.Init.dCall();
   log.i('snek > deinitialized');
end;

INITIALIZATION
   dvar.Add('snek', main.dv);
   ox.OnInitialize.Add('snek.initialize', @initialize, @deinitialize)

END.
