{$INCLUDE oxdefines.inc}
UNIT uGrid;

INTERFACE

   USES
      uStd, uLog, uColors, StringUtils,
      {oX}
      oxuPaths,
      oxuMaterial, oxuTexture, oxuTextureGenerate,
      oxuScene, oxuEntity,
      oxuComponent, oxuComponentDescriptors,
      oxuCameraComponent,
      oxumPrimitive, oxuPrimitiveModelComponent, oxuPrimitiveModelEntities,
      {game}
      uBase, uGame, uDropBlocks, uBlocks, uShared;

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
      GridBackground: oxTMaterial;
   end;

{ TGridComponent }

procedure TGridComponent.Load();
var
   tex: oxTTexture;

begin
   oxTextureGenerate.Generate(oxPaths.Find('textures' + DirectorySeparator + 'grid.png'), tex);

   if(tex = nil) then
      log.w('Failed loading grid texture');

   Materials.GridBackground := CreateMaterial('Background', TColor4ub.Create(64, 64, 64, 255), tex);
end;

function TGridComponent.GetDescriptor(): oxPComponentDescriptor;
begin
   Result := @grid.Descriptor;
end;

procedure gridInitialize();
var
   i,
   j: loopint;

   gridSize: TGridElementsSize;
   element: PGridElement;
   camera: oxTCameraComponent;

begin
   if(gridEntity = nil) then
      exit;

   gridEntity.EmptyChildren();

   camera := oxTCameraComponent(oxScene.GetComponentInChildren('oxTCameraComponent'));

   TGridElementsSize.Initialize(gridSize);
   gridSize.Get(camera, GRID_WIDTH, GRID_HEIGHT);

   for i := 0 to GRID_WIDTH - 1 do begin
      for j := 0 to GRID_HEIGHT - 1 do begin
         element := game.Grid.GetPoint(i, j);

         element^.Entity := oxPrimitiveModelEntities.Plane();
         element^.Mesh := oxTPrimitiveModelComponent(element^.Entity.GetComponent('oxTPrimitiveModelComponent'));

         element^.Entity.Name := sf(i) + 'x' + sf(j);
         element^.Entity.SetPosition(i * gridSize.d * 2  - gridSize.halfW , j * gridSize.d * 2 - gridSize.halfH, 0);
         element^.Entity.SetScale(gridSize.d, gridSize.d, 1);

         gridEntity.Add(element^.Entity);
      end;
   end;

   gridBackground := oxPrimitiveModelEntities.Plane();

   gridBackground.SetPosition(0, 0, -0.5);
   gridBackground.SetScale(GRID_WIDTH * gridSize.d, GRID_HEIGHT * gridSize.d, 0);

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

procedure beforeMoveShape({%H-}x, {%H-}y: loopint; element: PGridElement);
begin
   if(not element^.IsShape()) then
      exit;

   Exclude(element^.Flags, GRID_ELEMENT_SHAPE);
   ClearMaterial(element^);
   element^.Shape := game.CurrentShape;
end;

procedure beforeMove();
begin
   game.WalkShape(@beforeMoveShape);
end;

procedure afterMoveShape({%H-}x, {%H-}y: loopint; element: PGridElement);
begin
   Include(element^.Flags, GRID_ELEMENT_SHAPE);
   SetMaterial(element^, blocks.Materials[game.CurrentShape]);

   element^.Shape := game.CurrentShape;
end;

procedure afterMove();
begin
   game.WalkShape(@afterMoveShape);
end;

procedure lockShape({%H-}x, {%H-}y: loopint; element: PGridElement);
begin
   SetMaterial(element^, blocks.Materials[element^.Shape]);
end;

procedure onLock();
begin
   game.WalkShape(@lockShape);
end;

INITIALIZATION
   game.OnBeforeMove.Add(@beforeMove);
   game.OnMove.Add(@afterMove);
   game.OnLock.Add(@onLock);

END.
