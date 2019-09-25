{$INCLUDE oxdefines.inc}
UNIT uDropBlocksComponent;

INTERFACE

   USES
      appuKeys,
      {oX}
      oxuScene, oxuEntity, oxuTimer,
      oxuComponent, oxuComponentDescriptors,
      oxuMaterial,
      {game}
      uGame;

TYPE
   { TDropBlocksComponent }

   TDropBlocksComponent = class(oxTComponent)
      public

      procedure Start(); override;
      procedure Update(); override;

      function GetDescriptor(): oxPComponentDescriptor; override;

      private
      lastUpdate: Single;
   end;

   { TDropBlocksComponentGlobal }

  TDropBlocksComponentGlobal = record
      Descriptor: oxTComponentDescriptor;

      procedure Initialize();
   end;

VAR
   DropBlocksComponent: TDropBlocksComponentGlobal;

IMPLEMENTATION

VAR
   DropBlocksEntity: oxTEntity;

{ TDropBlocksComponentGlobal }

procedure TDropBlocksComponent.Start();
begin
   lastUpdate := 0;
end;

procedure TDropBlocksComponent.Update();
begin
   if appk.JustPressed(kcP) then
      oxTime.TogglePause();

   if appk.JustPressed(kcF2) then
      game.New();
end;

function TDropBlocksComponent.GetDescriptor(): oxPComponentDescriptor;
begin
   Result := @DropBlocksComponent.Descriptor;
end;

{ TGridGlobal }

procedure TDropBlocksComponentGlobal.Initialize();
begin
   DropBlocksComponent.Descriptor.Create('DropBlocks', TDropBlocksComponent);
   DropBlocksComponent.Descriptor.Name := 'DropBlocks';

   DropBlocksEntity := oxEntity.New('DropBlocks');
   DropBlocksEntity.Add(TDropBlocksComponent.Create());

   oxScene.Add(DropBlocksEntity);
end;

END.
