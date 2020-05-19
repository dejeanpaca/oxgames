{$INCLUDE oxdefines.inc}
UNIT uScene;

INTERFACE

   USES
      uStd, uColors,
      {ox}
      oxuProjection,
      oxuCameraComponent, oxuCameraEntity,
      oxuScene, oxuSceneLoader, oxuWorld,
      {game}
      uGame, uOptions;

TYPE
   TScene = record
      OnInitialize: TProcedures;
      Camera: oxTCameraComponent;
   end;

VAR
   scene: TScene;

IMPLEMENTATION

procedure init();
begin
   oxScene.Empty();
   oxScene.World.ClearColor.Assign(0.075, 0.1, 0.125, 1.0);

   scene.Camera := oxCameraEntity.CreateInScene();
   scene.OnInitialize.Call();

   options.Apply();
   game.New();
end;

INITIALIZATION
   oxSceneLoader.OnLoaded.Add(@init);
   TProcedures.Initialize(scene.OnInitialize);

END.
