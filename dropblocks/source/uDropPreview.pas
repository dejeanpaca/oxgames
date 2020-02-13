{$INCLUDE oxdefines.inc}
UNIT uDropPreview;

INTERFACE

   USES
      uStd, StringUtils, uColors,
      {ox}
      oxuMaterial,
      {game}
      uShared, uBase, uGame, uDropBlocks, uGrid, uBlocks;

IMPLEMENTATION

VAR
   PreviewMaterials: array[0..MAX_SHAPES - 1] of oxTMaterial;
   previousX,
   previousY: loopint;

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
   if(not element^.IsSolid()) then
      ClearMaterial(element^);
end;

procedure beforeMove();
begin
   if(previousY >= GRID_HEIGHT) then
      exit;

   game.WalkShape(previousX, previousY, @unmarkPreview);
end;

procedure markPreview({%H-}x, {%H-}y: loopint; element: PGridElement);
begin
   if(element^.IsShape()) then
      exit;

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

   game.WalkShape(game.ShapePosition.x, y, @markPreview);

   previousX := game.ShapePosition.x;
   previousY := y;
end;

INITIALIZATION
   DropBlocks.OnInitScene.Add('drop_preview', @init);
   game.OnBeforeMove.Add(@beforeMove);
   game.OnMove.Add(@onMove);

END.
