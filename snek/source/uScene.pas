{$INCLUDE oxdefines.inc}
UNIT uScene;

INTERFACE

   USES
      oxuScene, oxuSceneLoader, oxuProjectionType, oxuProjection,
      oxuCameraComponent, oxuCameraEntity;

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
end;

INITIALIZATION
   oxSceneLoader.OnLoaded.Add(@init);

END.
