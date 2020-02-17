{$INCLUDE oxdefines.inc}
UNIT uGrid;

INTERFACE

   USES
      uStd, uLog, StringUtils, uColors,
      {oX}
      oxuPaths, oxuTexture, oxuTextureGenerate,
      oxuScene, oxuEntity,
      oxuComponent, oxuComponentDescriptors, oxuPrimitiveModelEntities,
      oxuCameraComponent,
      oxuMaterial, oxumPrimitive, oxuPrimitiveModelComponent,
      {game}
      uGame, uShared;

TYPE
   { TGridComponent }

   TGridComponent = class(oxTComponent)
      public

      procedure Load(); override;

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
      Background,
      Solid,
      Nibble,
      Snake: oxTMaterial;
   end;

procedure TGridComponent.Load();
var
   tex: oxTTexture;

begin
   oxTextureGenerate.Generate(oxPaths.Find('textures' + DirectorySeparator + 'grid.png'), tex);

   if(tex = nil) then
      log.w('Failed loading background texture');

   Materials.Background := CreateMaterial('Background', cBlack4ub);
   Materials.Background.SetTexture('texture', tex);

   Materials.Solid := CreateMaterial('Solid', cWhite4ub);
   Materials.Nibble := CreateMaterial('Nibble', TColor4ub.Create(255, 255, 0, 255));
   Materials.Snake := CreateMaterial('Solid', cBlue4ub);
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
   j: loopint;

   element: PGridElement;

   camera: oxTCameraComponent;
   gridSize: TGridElementsSize;

begin
   if(gridEntity = nil) then
      exit;

   gridEntity.EmptyChildren();

   camera := oxTCameraComponent(oxScene.GetComponentInChildren('oxTCameraComponent'));
   TGridElementsSize.Initialize(gridSize);
   gridSize.Get(camera, game.Grid.Width, game.Grid.Height);

   for i := 0 to game.Grid.Width - 1 do begin
      for j := 0 to game.Grid.Height - 1 do begin
         element := game.Grid.GetPoint(i, j);

         element^.Entity := oxPrimitiveModelEntities.Plane();

         element^.Entity.Name := sf(i) + 'x' + sf(j);
         element^.Entity.SetPosition(i * gridSize.d * 2  - gridSize.halfW , j * gridSize.d * 2 - gridSize.halfH, 0);
         element^.Entity.SetScale(gridSize.d, gridSize.d, 1);

         element^.Mesh := oxTPrimitiveModelComponent(element^.Entity.GetComponent('oxTPrimitiveModelComponent'));

         if(element^.IsSolid()) then
            SetMaterial(element^, Materials.Solid)
         else if(element^.IsNibble()) then
            SetMaterial(element^, Materials.Nibble)
         else
            ClearMaterial(element^);

         gridEntity.Add(element^.Entity);
      end;
   end;

   gridBackground := oxPrimitiveModelEntities.Plane();

   gridBackground.SetPosition(0, 0, -0.5);
   gridBackground.SetScale(GRID_WIDTH * gridSize.d, GRID_HEIGHT * gridSize.d, 0);

   backgroundComponent := oxTPrimitiveModelComponent(gridBackground.GetComponent('oxTPrimitiveModelComponent'));

   backgroundComponent.Model.SetMaterial(Materials.Background);
   backgroundComponent.Model.ScaleTexture(GRID_WIDTH, GRID_HEIGHT);

   gridEntity.Add(gridBackground);
end;

procedure onBeforeMove();
var
   i: loopint;
   x, y: loopint;
   point: PGridElement;

begin
   for i := 0 to game.Snake.Length -1 do begin
      x := game.Snake.Body[i].x;
      y := game.Snake.Body[i].y;

      point := game.Grid.GetPoint(x, y);
      ClearMaterial(point^);
   end;
end;

procedure onAfterMove();
var
   i: loopint;
   x, y: loopint;
   point: PGridElement;

begin
   for i := 0 to game.Snake.Length -1 do begin
      x := game.Snake.Body[i].x;
      y := game.Snake.Body[i].y;

      point := game.Grid.GetPoint(x, y);
      SetMaterial(point^, Materials.Snake);
   end;
end;

procedure createNibble();
var
  point: PGridElement;

begin
   point := game.Grid.GetPoint(game.LastNibble.x, game.LastNibble.y);

   SetMaterial(point^, Materials.Nibble);
end;

INITIALIZATION
   game.OnNew.Add(@onNew);
   game.OnCreateNibble.Add(@createNibble);
   game.OnBeforeMove.Add(@onBeforeMove);
   game.OnAfterMove.Add(@onAfterMove);

END.
