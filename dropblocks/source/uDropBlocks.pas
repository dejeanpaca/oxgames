{$INCLUDE oxdefines.inc}
UNIT uDropBlocks;

INTERFACE

   USES
      udvars, uLog,
      uOX, oxuRunRoutines;

TYPE
   TDropBlocks = record
      dv: TDVarGroup;
      Init: oxTRunRoutines;
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

VAR
   initRoutines: oxTRunRoutine;

INITIALIZATION
   dvar.Add('dropblocks', DropBlocks.dv);
   ox.OnInitialize.Add(initRoutines, 'dropblocks.initialize', @dbInitialize, @dbDeinitialize)

END.
