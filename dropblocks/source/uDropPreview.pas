{$INCLUDE oxdefines.inc}
UNIT uDropPreview;

INTERFACE

   USES
      uStd, StringUtils, uColors,
      {ox}
      oxuMaterial,
      {game}
      uBase, uGame, uDropBlocks, uGrid, uBlocks;

IMPLEMENTATION

VAR
   PreviewMaterials: array[0..MAX_SHAPES - 1] of oxTMaterial;
   previousX: loopint;
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
begin
   if(element^.IsPreview()) then begin
      Exclude(element^.Flags, GRID_ELEMENT_PREVIEW);
      ClearMaterial(element^);
   end;
end;

procedure beforeMove();
begin
   if(previousY >= GRID_HEIGHT) then
      exit;

   grid.WalkShape(previousX, previousY, @unmarkPreview);
end;

procedure markPreview({%H-}x, {%H-}y: loopint; element: PGridElement);
begin
   if(element^.IsPreview() or element^.IsShape()) then
      exit;

   element^.Flags := [GRID_ELEMENT_PREVIEW];

   SetMaterial(element^, PreviewMaterials[game.CurrentShape]);
end;

procedure onMove();
var
   y: loopint;

begin
   {figure out the lowest position}
   y := game.FindShapeLowestPosition();

   if(y = game.ShapePosition.y) then
      exit;

   previousX := game.ShapePosition.x;
   previousY := y;

   grid.WalkShape(previousX, y, @markPreview);
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
