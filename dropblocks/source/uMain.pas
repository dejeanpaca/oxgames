{$INCLUDE oxdefines.inc}
UNIT uMain;

INTERFACE

   USES
      udvars, uLog, uColors,
      {ox}
      uOX, oxuRunRoutines, oxuMaterial, oxuTexture;

TYPE
   TMain = record
      dv: TDVarGroup;
      Init,
      OnInitScene: oxTRunRoutines;
   end;

VAR
   main: TMain;

IMPLEMENTATION

procedure initialize();
begin
   main.Init.iCall();
   log.i('DropBlocks > initialized');
end;

procedure deinitialize();
begin
   main.Init.dCall();
   log.i('db > deinitialized');
end;

INITIALIZATION
   dvar.Add('dropblocks', main.dv);
   ox.OnInitialize.Add('dropblocks.initialize', @initialize, @deinitialize)

END.
