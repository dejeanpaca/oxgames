{$INCLUDE oxdefines.inc}
UNIT uScene;

INTERFACE

   USES
      uStd, uColors,
      {ox}
      oxuProjectionType, oxuProjection,
      oxuCameraComponent, oxuCameraEntity,
      oxuScene, oxuSceneLoader, oxuWorld,
      {game}
      uGame;

TYPE
   TScene = record
      OnInitialize: TProcedures;
      Camera: oxTCameraComponent;
   end;

VAR
   scene: TScene;

IMPLEMENTATION

procedure init();
var
   projection: oxPProjection;

begin
   oxScene.Empty();
   oxScene.World.ClearColor.Assign(64, 64, 64, 255);

   scene.Camera := oxCameraEntity.CreateInScene();
   scene.OnInitialize.Call();

   game.New();
end;

INITIALIZATION
   oxSceneLoader.OnLoaded.Add(@init);
   TProcedures.Initialize(scene.OnInitialize);

END.
