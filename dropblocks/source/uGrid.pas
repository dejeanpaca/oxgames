{$INCLUDE oxdefines.inc}
UNIT uGrid;

INTERFACE

   USES
      uStd, uColors, StringUtils,
      {oX}
      oxuMaterial, oxuScene, oxuEntity,
      oxuComponent, oxuComponentDescriptors, oxuProjectionType,
      oxuCameraComponent,
      oxumPrimitive, oxuPrimitiveModelComponent, oxuPrimitiveModelEntities,
      {game}
      uBase, uGame;

TYPE
   { TGridComponent }

   TGridComponent = class(oxTComponent)
      public

      procedure Load(); override;
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

VAR
   gridEntity,
   gridBackground: oxTEntity;

   Materials: record
      GridBackground,
      DefaultBlock: oxTMaterial;
   end;

function getElementMesh(x, y: loopint; out mesh: oxTPrimitiveModelComponent): PGridElement;
begin
   mesh := nil;
   Result := game.Grid.GetPoint(x, y);

   if(Result <> nil) and (Result^.Entity <> nil) then
      mesh := oxTPrimitiveModelComponent(Result^.Entity.GetComponent('oxTPrimitiveModelComponent'));
end;

{ TGridComponent }

function CreateMaterial(const name: string; color: TColor4ub): oxTMaterial;
begin
   Result := oxMaterial.Make();
   Result.Name := name;
   Result.SetColor('color', color);
end;

procedure TGridComponent.Load();
begin
   Materials.GridBackground := CreateMaterial('Background', cBlack4ub);
   Materials.DefaultBlock := CreateMaterial('DefaultBlock', cWhite4ub);
end;

procedure TGridComponent.Update();
var
   x,
   y: loopint;

   mesh: oxTPrimitiveModelComponent;
   element: PGridElement;

begin
   if(game.Grid.Dirty) then begin
      for x := 0 to GRID_WIDTH - 1 do begin
         for y := 0 to GRID_HEIGHT - 1 do begin
            element := getElementMesh(x, y, mesh);

            if element^.IsDirty() and (mesh <> nil) then
               mesh.Model.SetMaterial(Materials.DefaultBlock);
         end;
      end;

      game.Grid.Dirty := false;
   end;
end;

function TGridComponent.GetDescriptor(): oxPComponentDescriptor;
begin
   Result := @grid.Descriptor;
end;

procedure gridInitialize();
var
   i,
   j,
   gridSize: loopint;

   element: PGridElement;

   camera: oxTCameraComponent;
   projection: oxPProjection;
   w,
   h,
   halfGridW,
   halfGridH: single;

begin
   if(gridEntity = nil) then
      exit;

   gridEntity.EmptyChildren();

   camera := oxTCameraComponent(oxScene.GetComponentInChildren('oxTCameraComponent'));
   projection := camera.GetProjection();

   gridSize := GRID_WIDTH;
   if(gridSize > GRID_HEIGHT) then
      gridSize := GRID_HEIGHT;

   if(projection^.p.GetWidth() >= projection^.p.GetHeight()) then begin
      w := projection^.p.GetHeight() / gridSize / 2;
      h := w;
   end else begin
      w := projection^.p.GetWidth() / gridSize / 2;
      h := w;
   end;

   halfGridW := w * GRID_WIDTH - w;
   halfGridH := h * GRID_HEIGHT - h;

   for i := 0 to GRID_WIDTH - 1 do begin
      for j := 0 to GRID_HEIGHT - 1 do begin
         element := game.Grid.GetPoint(i, j);

         element^.Entity := oxPrimitiveModelEntities.Plane();

         element^.Entity.Name := sf(i) + 'x' + sf(j);
         element^.Entity.SetPosition(i * (w * 2)  - halfGridW , j * (h * 2) - halfGridH, 0);
         element^.Entity.SetScale(w, h, 1);

         gridEntity.Add(element^.Entity);
      end;
   end;

   gridBackground := oxPrimitiveModelEntities.Plane();

   gridBackground.SetPosition(0, 0, -0.5);
   gridBackground.SetScale(GRID_WIDTH * halfGridW, GRID_HEIGHT * halfGridH, -0.5);
   oxTPrimitiveModelComponent(gridBackground.GetComponent('oxTPrimitiveModelComponent')).Model.SetMaterial(Materials.GridBackground);
   gridBackground.Name := 'Background';;
end;

{ TGridGlobal }

procedure TGridGlobal.Initialize();
begin
   grid.Descriptor.Create('grid', TGridComponent);
   grid.Descriptor.Name := 'Grid';

   gridEntity := oxEntity.New('Grid');
   gridEntity.Add(TGridComponent.Create());

   gridEntity.LoadComponentsInChildren();

   gridInitialize();

   oxScene.Add(gridEntity);
   oxScene.Add(gridBackground);
end;

procedure onNew();
begin
end;

INITIALIZATION
   game.OnNew.Add(@onNew);

END.
