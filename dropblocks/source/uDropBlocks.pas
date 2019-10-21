{$INCLUDE oxdefines.inc}
UNIT uDropBlocks;

INTERFACE

   USES
      udvars, uLog, uColors,
      {ox}
      uOX, oxuRunRoutines, oxuMaterial;

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

function CreateMaterial(const name: string; color: TColor4ub): oxTMaterial;

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

function CreateMaterial(const name: string; color: TColor4ub): oxTMaterial;
begin
   Result := oxMaterial.Make();
   Result.Name := name;
   Result.SetColor('color', color);
end;

INITIALIZATION
   dvar.Add('dropblocks', DropBlocks.dv);
   ox.OnInitialize.Add('dropblocks.initialize', @dbInitialize, @dbDeinitialize)

END.
