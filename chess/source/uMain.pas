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
   log.i('chess > initialized');
end;

procedure deinitialize();
begin
   main.Init.dCall();
   log.i('chess > deinitialized');
end;

INITIALIZATION
   dvar.Add('chess', main.dv);
   ox.OnInitialize.Add('chess.initialize', @initialize, @deinitialize)

END.
