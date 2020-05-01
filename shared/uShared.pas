{$INCLUDE oxdefines.inc}
UNIT uShared;

INTERFACE

   USES
      uStd, uLog, uColors,
      {ox}
      oxuCameraComponent, oxuCamera, oxuProjectionType,
      oxuTexture, oxuMaterial;

TYPE

   { TGridElementsSize }

   TGridElementsSize = record
      size: loopint;

      d,
      halfW,
      halfH: single;

      class procedure Initialize(out t: TGridElementsSize); static;
      {get grid elements size for the set width and height}
      procedure Get(var camera: oxTCameraComponent; width, height: loopint);
   end;

function CreateMaterial(const name: string; color: TColor4ub; tex: oxTTexture = nil): oxTMaterial;

IMPLEMENTATION

function CreateMaterial(const name: string; color: TColor4ub; tex: oxTTexture): oxTMaterial;
begin
   Result := oxMaterial.Make();
   Result.Name := name;
   Result.SetColor('color', color);

   if(tex <> nil) then
      Result.SetTexture('texture', tex);
end;

{ TGridElementsSize }

class procedure TGridElementsSize.Initialize(out t: TGridElementsSize);
begin
   ZeroOut(t, SizeOf(t));
end;

procedure TGridElementsSize.Get(var camera: oxTCameraComponent; width, height: loopint);
var
   projection: oxPProjection;

begin
   projection := @camera.Projection;;

   if(projection^.p.GetWidth() <= projection^.p.GetHeight()) then begin
     size := width;
     d := projection^.p.GetWidth();
   end else begin
     size := height;
     d := projection^.p.GetHeight();
   end;

   d := d / size / 2;

   halfW := d * width - d;
   halfH := d * height - d;
end;

END.
