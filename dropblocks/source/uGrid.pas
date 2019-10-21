{$INCLUDE oxdefines.inc}
UNIT uGrid;

INTERFACE

   USES
      uStd, uLog, uColors, StringUtils,
      {oX}
      oxuPaths,
      oxuMaterial, oxuTexture, oxuTextureGenerate,
      oxuScene, oxuEntity,
      oxuComponent, oxuComponentDescriptors, oxuProjectionType,
      oxuCameraComponent,
      oxumPrimitive, oxuPrimitiveModelComponent, oxuPrimitiveModelEntities,
      {game}
      uBase, uGame, uDropBlocks, uBlocks;

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
   backgroundComponent: oxTPrimitiveModelComponent;

   Materials: record
      GridBackground: oxTMaterial;
   end;

function getElementMesh(x, y: loopint; out mesh: oxTPrimitiveModelComponent): PGridElement;
begin
   mesh := nil;
   Result := game.Grid.GetPoint(x, y);

   if(Result <> nil) and (Result^.Entity <> nil) then
      mesh := oxTPrimitiveModelComponent(Result^.Entity.GetComponent('oxTPrimitiveModelComponent'));
end;

{ TGridComponent }

procedure TGridComponent.Load();
var
   tex: oxTTexture;

begin
   oxTextureGenerate.Generate(oxPaths.Find('textures' + DirectorySeparator + 'grid.png'), tex);

   if(tex = nil) then
      log.w('Failed loading grid texture');

   Materials.GridBackground := CreateMaterial('Background', cWhite4ub);
   Materials.GridBackground.SetTexture('texture', tex);
end;

function getMaterial(const element: TGridElement): oxTMaterial;
begin
   if element.IsSolid() then
      Result := blocks.Materials[element.Shape]
   else
      Result := blocks.DefaultMaterial;
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

            if element^.IsDirty() then begin
               if element^.IsSolid()  then begin
                  element^.Entity.SetEnabled(true);

                  if(mesh <> nil) then
                     mesh.Model.SetMaterial(getMaterial(element^));
               end else
                  element^.Entity.SetEnabled(false);
            end;
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
   d,
   halfGridW,
   halfGridH: single;

begin
   if(gridEntity = nil) then
      exit;

   gridEntity.EmptyChildren();

   camera := oxTCameraComponent(oxScene.GetComponentInChildren('oxTCameraComponent'));
   projection := camera.GetProjection();

   if(projection^.p.GetWidth() <= projection^.p.GetHeight()) then begin
      gridSize := GRID_WIDTH;
      d := projection^.p.GetWidth();
   end else begin
      gridSize := GRID_HEIGHT;
      d := projection^.p.GetHeight();
   end;

   d := d / gridSize / 2;

   halfGridW := d * GRID_WIDTH - d;
   halfGridH := d * GRID_HEIGHT - d;

   for i := 0 to GRID_WIDTH - 1 do begin
      for j := 0 to GRID_HEIGHT - 1 do begin
         element := game.Grid.GetPoint(i, j);

         element^.Entity := oxPrimitiveModelEntities.Plane();

         element^.Entity.Name := sf(i) + 'x' + sf(j);
         element^.Entity.SetPosition(i * d * 2  - halfGridW , j * d * 2 - halfGridH, 0);
         element^.Entity.SetScale(d, d, 1);

         gridEntity.Add(element^.Entity);
      end;
   end;

   game.Grid.Dirty := true;

   gridBackground := oxPrimitiveModelEntities.Plane();

   gridBackground.SetPosition(0, 0, -0.5);
   gridBackground.SetScale(GRID_WIDTH * d, GRID_HEIGHT * d, 0);

   backgroundComponent := oxTPrimitiveModelComponent(gridBackground.GetComponent('oxTPrimitiveModelComponent'));

   backgroundComponent.Model.SetMaterial(Materials.GridBackground);
   backgroundComponent.Model.ScaleTexture(GRID_WIDTH, GRID_HEIGHT);

   gridBackground.Name := 'Background';
   gridEntity.Add(gridBackground);
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
end;

procedure onNew();
begin
end;

INITIALIZATION
   game.OnNew.Add(@onNew);

END.
