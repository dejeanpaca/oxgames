{$INCLUDE oxdefines.inc}
UNIT uScene;

INTERFACE

   USES
      oxuScene, oxuSceneLoader, oxuProjectionType, oxuProjection,
      oxuCameraComponent, oxuCameraEntity,
      {game}
      uBoard, uGame, uChessComponent;

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

   board.Initialize();
   chessComponent.Initialize();

   game.New();
end;

INITIALIZATION
   oxSceneLoader.OnLoaded.Add(@init);

END.
