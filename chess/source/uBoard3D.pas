{$INCLUDE oxdefines.inc}
UNIT uBoard3D;

INTERFACE

   USES
      oxuProjectionType, oxuProjection,
      oxuCameraComponent,
      uScene;

TYPE
   { TBoard3D }

   TBoard3D = record
      procedure Activate();
   end;

VAR
   board3d: TBoard3D;

IMPLEMENTATION

{ TBoard3D }

procedure TBoard3D.Activate();
var
   projection: oxPProjection;

begin
   projection := scene.Camera.GetProjection();
   projection^.DefaultPerspective();
end;

END.
