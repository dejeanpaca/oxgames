{$INCLUDE oxdefines.inc}
UNIT uScene;

INTERFACE

   USES
      oxuScene, oxuSceneLoader, oxuProjection,
      oxuCameraComponent, oxuCameraEntity,
      {game}
      uMain, uGrid, uGame, uDropBlocksComponent, uGameComponent;

IMPLEMENTATION

procedure init();
var
   camera: oxTCameraComponent;

begin
   oxScene.Empty();

   camera := oxCameraEntity.CreateInScene();
   camera.Projection.DefaultOrtho();

   GameComponent.Initialize();
   grid.Initialize();

   main.OnInitScene.Call();

   game.New();
end;

INITIALIZATION
   oxSceneLoader.OnLoaded.Add(@init);

END.
