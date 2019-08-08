{$INCLUDE oxdefines.inc}
UNIT uGrid;

INTERFACE

   USES
      uStd, StringUtils,
      {oX}
      oxuScene, oxuEntity,
      oxuComponent, oxuComponentDescriptors, oxuPrimitiveModelEntities,
      oxuCameraComponent, oxuProjectionType,
      {game}
      uGame;

TYPE
   { TGridComponent }

   TGridComponent = class(oxTComponent)
      procedure Load(); override;
      procedure Start(); override;
      procedure Update(); override;

      function GetDescriptor(): oxPComponentDescriptor; override;
   end;

   { TGridGlobal }

   TGridGlobal = record
      Descriptor: oxTComponentDescriptor;

      procedure Initialize();
   end;

VAR
   grid: TGridGlobal;

IMPLEMENTATION

{ TGridComponent }

procedure TGridComponent.Load();
begin
end;

procedure TGridComponent.Start();
begin
end;

procedure TGridComponent.Update();
begin
end;

function TGridComponent.GetDescriptor(): oxPComponentDescriptor;
begin
   Result := @grid.Descriptor;
end;

VAR
   gridEntity: oxTEntity;

{ TGridGlobal }

procedure TGridGlobal.Initialize();
begin
   grid.Descriptor.Create('grid', TGridComponent);
   grid.Descriptor.Name := 'Grid';

   gridEntity := oxEntity.New('Grid');
   gridEntity.Add(TGridComponent.Create());

   oxScene.Add(gridEntity);
end;

procedure onNew();
var
   i,
   j: loopint;

   entity: oxTEntity;

   camera: oxTCameraComponent;
   projection: oxPProjection;
   w,
   h,
   halfGridW,
   halfGridH: single;

begin
   if(gridEntity = nil) then
      exit;

   gridEntity.Empty();

   camera := oxTCameraComponent(oxScene.GetComponentInChildren('oxTCameraComponent'));
   projection := camera.GetProjection();

   w := projection^.p.r / (game.Grid.Width / 2);
   h := projection^.p.t / (game.Grid.Height / 2);

   halfGridW := w * game.Grid.Width / 2;
   halfGridH := h * game.Grid.Height / 2;

   for i := 0 to game.Grid.Width - 1 do begin
      for j := 0 to game.Grid.Height - 1 do begin
         entity := oxPrimitiveModelEntities.Plane();
         entity.Name := sf(i) + 'x' + sf(j);
         game.Grid.GetPoint(i, j)^.Entity := entity;
         entity.SetPosition(i * w  - halfGridW, j * h - halfGridH, 0);
         entity.SetScale(w, h, 1);

         gridEntity.Add(entity);
      end;
   end;
end;

INITIALIZATION
   game.OnNew.Add(@onNew);

END.
