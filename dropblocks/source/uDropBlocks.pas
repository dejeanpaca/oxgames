{$INCLUDE oxdefines.inc}
UNIT uDropBlocks;

INTERFACE

   USES
      udvars, uLog, uColors,
      {ox}
      uOX, oxuRunRoutines, oxuMaterial, oxuTexture;

TYPE
   TDropBlocks = record
      dv: TDVarGroup;
      Init,
      OnInitScene: oxTRunRoutines;
   end;

VAR
   DropBlocks: TDropBlocks;

procedure dbInitialize();
procedure dbDeinitialize();

IMPLEMENTATION

procedure dbInitialize();
begin
   DropBlocks.Init.iCall();
   log.i('DropBlocks > initialized');
end;

procedure dbDeinitialize();
begin
   DropBlocks.Init.dCall();
   log.i('db > deinitialized');
end;

INITIALIZATION
   dvar.Add('dropblocks', DropBlocks.dv);
   ox.OnInitialize.Add('dropblocks.initialize', @dbInitialize, @dbDeinitialize)

END.
