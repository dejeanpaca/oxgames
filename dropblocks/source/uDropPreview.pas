{$INCLUDE oxdefines.inc}
UNIT uDropPreview;

INTERFACE

   USES
      uStd, StringUtils, uColors,
      {ox}
      oxuMaterial, oxuPrimitiveModelComponent,
      {game}
      uBase, uGame, uDropBlocks, uGrid, uBlocks;

IMPLEMENTATION

VAR
   PreviewMaterials: array[0..MAX_SHAPES - 1] of oxTMaterial;
   previousY: loopint = GRID_HEIGHT;

procedure init();
var
   i: loopint;
   color: TColor4ub;

begin
   for i := 0 to MAX_SHAPES - 1 do begin
      color := Shapes.Colors[i];
      color[3] := 191;

      PreviewMaterials[i] := CreateMaterial('preview_' + sf(i), color, nil);
   end;
end;

procedure unmarkPreview({%H-}x, {%H-}y: loopint; element: PGridElement);
var
   mesh: oxTPrimitiveModelComponent;

begin
   if(not element^.IsPreview()) then
      exit;

   mesh := grid.GetElementMesh(element^);

   if(mesh <> nil) then begin
      element^.Flags := [GRID_ELEMENT_DIRTY];
      element^.Entity.SetEnabled(false);
      mesh.Model.SetMaterial(nil);
   end;
end;

procedure beforeMove();
begin
   if(previousY >= GRID_HEIGHT) then
      exit;

   grid.WalkShape(game.ShapePosition.x, previousY, @unmarkPreview);
end;

procedure markPreview({%H-}x, {%H-}y: loopint; element: PGridElement);
var
   mesh: oxTPrimitiveModelComponent;

begin
   if(element^.IsSolid()) then
      exit;

   mesh := grid.GetElementMesh(element^);

   if(mesh <> nil) then begin
      if(element^.IsPreview()) then
         exit;

      element^.Flags := [GRID_ELEMENT_PREVIEW];
      element^.Entity.SetEnabled(true);
      mesh.Model.SetMaterial(PreviewMaterials[game.CurrentShape]);
   end;
end;

procedure onMove();
var
   y: loopint;

begin
   {figure out the lowest position}
   y := game.FindShapeLowestPosition();

   if(y = game.ShapePosition.y) then
      exit;

   grid.WalkShape(game.ShapePosition.x, y, @markPreview);

   previousY := y;
end;

procedure onNew();
begin
   previousY := GRID_HEIGHT;
end;

INITIALIZATION
   DropBlocks.OnInitScene.Add('drop_preview', @init);
   game.OnNew.Add(@onNew);
   game.OnBeforeMove.Add(@beforeMove);
   game.OnMove.Add(@onMove);

END.
