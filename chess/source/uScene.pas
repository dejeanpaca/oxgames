{$INCLUDE oxdefines.inc}
UNIT uScene;

INTERFACE

   USES
      uColors,
      {ox}
      oxuProjectionType, oxuProjection,
      oxuCameraComponent, oxuCameraEntity,
      oxuScene, oxuSceneLoader, oxuWorld,
      {game}
      uBoard, uGame, uChessComponent;

IMPLEMENTATION

procedure init();
var
   projection: oxPProjection;
   camera: oxTCameraComponent;

begin
   oxScene.Empty();
   oxScene.World.ClearColor.Assign(64, 64, 64, 255);

   camera := oxCameraEntity.CreateInScene();

   projection := camera.GetProjection();
   projection^.DefaultOrtho();

   board.Initialize();
   chessComponent.Initialize();

   game.New();
end;

INITIALIZATION
   oxSceneLoader.OnLoaded.Add(@init);

END.
