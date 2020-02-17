{$INCLUDE oxdefines.inc}
UNIT uBlocks;

INTERFACE

   USES
      uLog, uColors, uStd, StringUtils,
      {ox}
      oxuPaths, oxuMaterial, oxuTexture, oxuTextureGenerate,
      oxuPrimitiveModelComponent,
      {game}
      uMain, uBase, uShared;

TYPE

   { TBlocks }

   TBlocks = record
      BlockTexture: oxTTexture;

      Materials: array[0..MAX_SHAPES - 1] of oxTMaterial;
      LRAnimationMaterial: oxTMaterial;
      {material for inserted lines}
      Rock,
      {default block material}
      DefaultMaterial: oxTMaterial;
   end;

VAR
   blocks: TBlocks;

IMPLEMENTATION

procedure init();
var
   i: loopint;

begin
   oxTextureGenerate.Generate(oxPaths.Find('textures' + DirectorySeparator + 'block.png'), blocks.BlockTexture);

   if(blocks.BlockTexture = nil) then
      log.w('Failed loading block texture');

   for i := 0 to MAX_SHAPES - 1 do begin
     blocks.Materials[i] := CreateMaterial('shape_' + sf(i), Shapes.Colors[i], blocks.BlockTexture);
   end;

   blocks.Rock := CreateMaterial('default',  TColor4ub.Create(127, 127, 127, 255), blocks.BlockTexture);
   blocks.DefaultMaterial := CreateMaterial('default', cWhite4ub, blocks.BlockTexture);

   blocks.LRAnimationMaterial := CreateMaterial('lr_animation', cWhite4ub, blocks.BlockTexture);
end;

INITIALIZATION
   main.OnInitScene.Add('dropblocks.blocks', @init);

END.
