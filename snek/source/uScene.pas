{$INCLUDE oxdefines.inc}
UNIT uScene;

INTERFACE

   USES
      oxuScene, oxuSceneLoader, oxuProjectionType, oxuProjection,
      oxuCameraComponent, oxuCameraEntity,
      {game}
      uSnek, uGrid, uGame, uSnakeComponent;

IMPLEMENTATION

procedure init();
var
   projection: oxPProjection;
   camera: oxTCameraComponent;

begin
   oxScene.Empty();

   camera := oxCameraEntity.CreateInScene();

   projection := camera.GetProjection();
   projection^.DefaultOrtho();

   grid.Initialize();
   snakeComponent.Initialize();

   game.New();
end;

INITIALIZATION
   oxSceneLoader.OnLoaded.Add(@init);

END.
