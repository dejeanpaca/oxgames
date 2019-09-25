{$INCLUDE oxdefines.inc}
UNIT uGameComponent;

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
   { TGameComponent }

   TGameComponent = class(oxTComponent)
      public

      procedure Start(); override;
      procedure Update(); override;

      function GetDescriptor(): oxPComponentDescriptor; override;

      private
      lastUpdate: Single;
   end;

   { TGameComponentGlobal }

  TGameComponentGlobal = record
      Descriptor: oxTComponentDescriptor;

      procedure Initialize();
   end;

VAR
   GameComponent: TGameComponentGlobal;

IMPLEMENTATION

VAR
   GameEntity: oxTEntity;

{ TGameComponentGlobal }

procedure TGameComponent.Start();
begin
   lastUpdate := 0;
end;

procedure TGameComponent.Update();
begin
   if appk.JustPressed(kcP) then
      oxTime.TogglePause();

   if appk.JustPressed(kcF2) then
      game.New();
end;

function TGameComponent.GetDescriptor(): oxPComponentDescriptor;
begin
   Result := @GameComponent.Descriptor;
end;

{ TGridGlobal }

procedure TGameComponentGlobal.Initialize();
begin
   GameComponent.Descriptor.Create('Game', TGameComponent);
   GameComponent.Descriptor.Name := 'Game';

   GameEntity := oxEntity.New('Game');
   GameEntity.Add(TGameComponent.Create());

   oxScene.Add(GameEntity);
end;

END.
