{$INCLUDE oxdefines.inc}
UNIT uBoard2D;

INTERFACE

   USES
      oxuProjectionType, oxuProjection,
      oxuCameraComponent,
      uScene;

TYPE
   { TBoard2D }

   TBoard2D = record
      procedure Empty();
      procedure Activate();
   end;

VAR
   board2d: TBoard2D;

IMPLEMENTATION

{ TBoard2D }

procedure TBoard2D.Empty();
begin

end;

procedure TBoard2D.Activate();
var
   projection: oxPProjection;

begin
   projection := scene.Camera.GetProjection();
   projection^.DefaultOrtho();
end;

END.
