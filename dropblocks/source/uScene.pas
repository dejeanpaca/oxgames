{$INCLUDE oxdefines.inc}
UNIT uScene;

INTERFACE

   USES
      oxuScene, oxuSceneLoader, oxuProjectionType, oxuProjection,
      oxuCameraComponent, oxuCameraEntity,
      {game}
      uMain, uGrid, uGame, uDropBlocksComponent, uGameComponent;

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

   GameComponent.Initialize();
   grid.Initialize();

   main.OnInitScene.Call();

   game.New();
end;

INITIALIZATION
   oxSceneLoader.OnLoaded.Add(@init);

END.
