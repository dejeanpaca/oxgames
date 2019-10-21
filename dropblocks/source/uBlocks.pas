{$INCLUDE oxdefines.inc}
UNIT uBlocks;

INTERFACE

   USES
      uLog, uColors, uStd,
      {ox}
      oxuPaths, oxuMaterial, oxuTexture, oxuTextureGenerate,
      oxuPrimitiveModelComponent,
      {game}
      uDropBlocks, uBase;

TYPE
   TBlocks = record
      Materials: array[0..MAX_SHAPES - 1] of oxTMaterial;
      DefaultMaterial: oxTMaterial;
   end;

VAR
   blocks: TBlocks;

IMPLEMENTATION

procedure init();
var
   i: loopint;
   tex: oxTTexture;
   material: oxTMaterial;

begin
   oxTextureGenerate.Generate(oxPaths.Find('textures' + DirectorySeparator + 'block.png'), tex);

   if(tex = nil) then
      log.w('Failed loading block texture');

   for i := 0 to MAX_SHAPES - 1 do begin
     material := CreateMaterial('background', Shapes.Colors[i]);
     material.SetTexture('texture', tex);

     blocks.Materials[i] := material;
   end;

   blocks.DefaultMaterial := CreateMaterial('default',  cWhite4ub);
end;

INITIALIZATION
   DropBlocks.OnInitScene.Add('dropblocks.blocks', @init);

END.
