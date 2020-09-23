{$INCLUDE oxdefines.inc}
UNIT uScene;

INTERFACE

   USES
      oxuScene, oxuSceneLoader, oxuProjection,
      oxuCameraComponent,
      {game}
      uMain, uGrid, uGame, uDropBlocksComponent, uGameComponent, uCamera2D;

IMPLEMENTATION

procedure init();
begin
   oxScene.Empty();

   InitializeCamera2D();

   GameComponent.Initialize();
   grid.Initialize();

   main.OnInitScene.Call();

   game.New();
end;

INITIALIZATION
   oxSceneLoader.OnLoaded.Add(@init);

END.
