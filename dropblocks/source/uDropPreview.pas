{$INCLUDE oxdefines.inc}
UNIT uDropPreview;

INTERFACE

   USES
      uStd, StringUtils, uColors,
      oxuMaterial,
      {game}
      uBase, uGame, uDropBlocks;

IMPLEMENTATION

VAR
   PreviewMaterials: array[0..MAX_SHAPES - 1] of oxTMaterial;

procedure init();
var
   i: loopint;
   color: TColor4ub;

begin
   for i := 0 to MAX_SHAPES - 1 do begin
      color := Shapes.Colors[i];
      color[3] := 127;

      PreviewMaterials[i] := CreateMaterial('preview_' + sf(i), color, nil);
   end;
end;

procedure beforeMove();
begin

end;

procedure onMove();
var
   y: loopint;
   i, j,
   px, py: loopint;

begin
   {figure out the lowest position}
   y := game.ShapePosition.y;

   repeat
      dec(y);
   until not game.CanFitShape(game.ShapePosition.x, y, game.CurrentRotation);

   if(y = game.ShapePosition.y) or (y <= 0) then
      exit;


end;

INITIALIZATION
   DropBlocks.OnInitScene.Add('drop_preview', @init);
   game.OnBeforeMove.Add(@beforeMove);
   game.OnMove.Add(@onMove);

END.
