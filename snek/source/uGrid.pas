{$INCLUDE oxdefines.inc}
UNIT uGrid;

INTERFACE

   USES
      uStd, StringUtils, uColors,
      {oX}
      oxuScene, oxuEntity,
      oxuComponent, oxuComponentDescriptors, oxuPrimitiveModelEntities,
      oxuCameraComponent, oxuProjectionType,
      oxuMaterial, oxumPrimitive, oxuPrimitiveModelComponent,
      {game}
      uGame;

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
   gridEntity: oxTEntity;

   Materials: record
      Solid,
      NonSolid,
      Nibble,
      Snake: oxTMaterial;
   end;

function GetMaterial(x, y: loopint): oxTMaterial;
begin
   if(not game.Grid.GetPoint(x, y)^.IsNibble()) then begin
      if(game.Grid.GetPoint(x, y)^.IsSolid()) then
         Result := Materials.Solid
      else
         Result := Materials.NonSolid;
   end else
      Result := Materials.Nibble;

   if(Result = nil) then
      Result := oxMaterial.Default;
end;

{ TGridComponent }

function CreateMaterial(const name: string; color: TColor4ub): oxTMaterial;
begin
   Result := oxMaterial.Make();
   Result.MarkPermanent();
   Result.Name := name;
   Result.SetColor('color', color);
end;

procedure TGridComponent.Load();
begin
   Materials.Solid := CreateMaterial('Solid', cWhite4ub);
   Materials.NonSolid := CreateMaterial('NonSolid', cBlack4ub);
   Materials.Nibble := CreateMaterial('Nibble', TColor4ub.Create(255, 255, 0, 255));
   Materials.Snake := CreateMaterial('Solid', cBlue4ub);
end;

function getElementMesh(x, y: loopint; out mesh: oxTPrimitiveModelComponent): PGridElement;
begin
   mesh := nil;
   Result := game.Grid.GetPoint(x, y);

   if(Result <> nil) and (Result^.Entity <> nil) then
      mesh := oxTPrimitiveModelComponent(Result^.Entity.GetComponent('oxTPrimitiveModelComponent'));
end;

procedure TGridComponent.Update();
var
   x,
   y: loopint;

   mesh: oxTPrimitiveModelComponent;
   element: PGridElement;

begin
   if(game.Grid.Dirty) then begin
      for x := 0 to game.Grid.Width - 1 do begin
         for y := 0 to game.Grid.Height - 1 do begin
            element := getElementMesh(x, y, mesh);

            if element^.IsDirty() and (mesh <> nil) then
               mesh.Model.SetMaterial(GetMaterial(x, y));
         end;
      end;

      game.Grid.Dirty := false;
   end;

   if(game.Snake.Dirty) then begin
      for x := 0 to game.Snake.Length - 1 do begin
         element := getElementMesh(game.Snake.Body[x].x, game.Snake.Body[x].y, mesh);

         if(element <> nil) and (mesh <> nil) then
            mesh.Model.SetMaterial(Materials.Snake);
      end;

      game.Snake.Dirty := false;
   end;
end;

function TGridComponent.GetDescriptor(): oxPComponentDescriptor;
begin
   Result := @grid.Descriptor;
end;

{ TGridGlobal }

procedure TGridGlobal.Initialize();
begin
   grid.Descriptor.Create('grid', TGridComponent);
   grid.Descriptor.Name := 'Grid';

   gridEntity := oxEntity.New('Grid');
   gridEntity.Add(TGridComponent.Create());

   gridEntity.LoadComponentsInChildren();

   oxScene.Add(gridEntity);
end;

procedure onNew();
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
      gridSize := game.Grid.Width;
      d := projection^.p.GetWidth()
   end else begin
      gridSize := game.Grid.Height;
      d := projection^.p.GetHeight();
   end;

   d := d / gridSize / 2;

   halfGridW := d * game.Grid.Width - d;
   halfGridH := d * game.Grid.Height - d;

   for i := 0 to game.Grid.Width - 1 do begin
      for j := 0 to game.Grid.Height - 1 do begin
         element := game.Grid.GetPoint(i, j);

         element^.Entity := oxPrimitiveModelEntities.Plane();

         element^.Entity.Name := sf(i) + 'x' + sf(j);
         element^.Entity.SetPosition(i * d * 2  - halfGridW , j * d * 2 - halfGridH, 0);
         element^.Entity.SetScale(d, d, 1);

         gridEntity.Add(element^.Entity);
      end;
   end;
end;

INITIALIZATION
   game.OnNew.Add(@onNew);

END.
