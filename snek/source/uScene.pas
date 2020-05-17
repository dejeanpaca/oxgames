{$INCLUDE oxdefines.inc}
UNIT uScene;

INTERFACE

   USES
      oxuScene, oxuSceneLoader, oxuProjection,
      oxuCameraComponent, oxuCameraEntity,
      {game}
      uGrid, uGame, uSnakeComponent;

IMPLEMENTATION

procedure init();
var
   camera: oxTCameraComponent;

begin
   oxScene.Empty();

   camera := oxCameraEntity.CreateInScene();

   camera.Projection.DefaultOrtho();

   grid.Initialize();
   snakeComponent.Initialize();

   game.New();
end;

INITIALIZATION
   oxSceneLoader.OnLoaded.Add(@init);

END.
