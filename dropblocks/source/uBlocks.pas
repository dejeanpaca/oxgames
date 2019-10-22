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
   tex: oxTTexture;

begin
   oxTextureGenerate.Generate(oxPaths.Find('textures' + DirectorySeparator + 'block.png'), tex);

   if(tex = nil) then
      log.w('Failed loading block texture');

   for i := 0 to MAX_SHAPES - 1 do begin
     blocks.Materials[i] := CreateMaterial('background', Shapes.Colors[i], tex);
   end;

   blocks.Rock := CreateMaterial('default',  TColor4ub.Create(127, 127, 127, 255), tex);
   blocks.DefaultMaterial := CreateMaterial('default',  cWhite4ub, tex);
end;

INITIALIZATION
   DropBlocks.OnInitScene.Add('dropblocks.blocks', @init);

END.