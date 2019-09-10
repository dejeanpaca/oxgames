{$INCLUDE oxdefines.inc}
UNIT uTrisComponent;

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
   { TTrisComponent }

   TTrisComponent = class(oxTComponent)
      public

      procedure Start(); override;
      procedure Update(); override;

      function GetDescriptor(): oxPComponentDescriptor; override;

      private
      lastUpdate: Single;
   end;

   { TTrisComponentGlobal }

  TTrisComponentGlobal = record
      Descriptor: oxTComponentDescriptor;

      procedure Initialize();
   end;

VAR
   trisComponent: TTrisComponentGlobal;

IMPLEMENTATION

VAR
   trisEntity: oxTEntity;

{ TTrisComponentGlobal }

procedure TTrisComponent.Start();
begin
   lastUpdate := 0;
end;

procedure TTrisComponent.Update();
begin
   if appk.JustPressed(kcP) then
      oxTime.TogglePause();

   if appk.JustPressed(kcF2) then
      game.New();
end;

function TTrisComponent.GetDescriptor(): oxPComponentDescriptor;
begin
   Result := @trisComponent.Descriptor;
end;

{ TGridGlobal }

procedure TTrisComponentGlobal.Initialize();
begin
   trisComponent.Descriptor.Create('tris', TTrisComponent);
   trisComponent.Descriptor.Name := 'Tris';

   trisEntity := oxEntity.New('Tris');
   trisEntity.Add(TTrisComponent.Create());

   oxScene.Add(trisEntity);
end;

END.
