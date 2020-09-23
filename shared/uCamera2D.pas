{$INCLUDE oxdefines.inc}
UNIT uCamera2D;

INTERFACE

   USES
      oxuScene, oxuSceneLoader, oxuProjection,
      oxuCameraComponent, oxuCameraEntity,
      {game}
      uMain, uGrid, uGame, uDropBlocksComponent, uGameComponent;
VAR
   camera: oxTCameraComponent;

procedure InitializeCamera2D();

IMPLEMENTATION

procedure InitializeCamera2D();
begin
   camera := oxCameraEntity.CreateInScene();
   camera.Projection.DefaultOrtho();
end;

END.
