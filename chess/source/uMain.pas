{$INCLUDE oxdefines.inc}
UNIT uMain;

INTERFACE

   USES
      udvars, uLog, uStd,
      {ox}
      uOX, oxuRunRoutines;

TYPE
   TMain = record
      dv: TDVarGroup;
      Init: oxTRunRoutines;

      Board3D: boolean;
   end;

VAR
   main: TMain;

IMPLEMENTATION

VAR
   dvBoard3D: TDVar;

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
   main.dv.Add(dvBoard3D, 'board3d', dtcBOOL, @main.Board3D);

   ox.OnInitialize.Add('chess.initialize', @initialize, @deinitialize);

END.
