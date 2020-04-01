{$INCLUDE oxdefines.inc}
UNIT uGameComponent;

INTERFACE

   USES
      uStd, uLog, uColors,
      {oX}
      oxuPaths, oxuTexture, oxuTextureGenerate,
      oxuScene, oxuEntity,
      oxuComponent, oxuComponentDescriptors,
      oxuCameraComponent,
      oxuMaterial, oxumPrimitive, oxuPrimitiveModelComponent,
      {game}
      uGame, uScene;

TYPE
   { TGameComponent }

   TGameComponent = class(oxTComponent)
      public

      procedure Load(); override;
      procedure Update(); override;

      function GetDescriptor(): oxPComponentDescriptor; override;
   end;

   { TGameComponentGlobal }

   TGameComponentGlobal = record
      Descriptor: oxTComponentDescriptor;
      Entity: oxTEntity;

      procedure Initialize();
   end;

VAR
   gameComponent: TGameComponentGlobal;

IMPLEMENTATION

procedure TGameComponent.Load();
begin
   {TODO: Load materials}
end;

procedure TGameComponent.Update();
begin
end;

function TGameComponent.GetDescriptor(): oxPComponentDescriptor;
begin
   Result := @gameComponent.Descriptor;
end;

{ TGameComponentGlobal }

procedure TGameComponentGlobal.Initialize();
begin
   gameComponent.Descriptor.Create('game', TGameComponent);
   gameComponent.Descriptor.Name := 'Game';

   Entity := oxEntity.New('Game');
   Entity.Add(TGameComponent.Create());

   Entity.LoadComponentsInChildren();

   oxScene.Add(Entity);
end;

procedure initialize();
begin
   gameComponent.Initialize();
end;

INITIALIZATION
   scene.OnInitialize.Add(@initialize);

END.
