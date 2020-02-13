{$INCLUDE oxdefines.inc}
UNIT uBackground;

INTERFACE

   USES
      uLog, uColors,
      {ox}
      oxuPaths, oxuMaterial, oxuTexture, oxuTextureGenerate,
      oxuProjection, oxuProjectionType,
      oxuScene, oxuEntity, oxuPrimitiveModelComponent, oxuPrimitiveModelEntities,
      {game}
      uMain, uShared;

IMPLEMENTATION

VAR
   BackgroundMaterial: oxTMaterial;
   background: oxTEntity;
   component: oxTPrimitiveModelComponent;

procedure init();
var
   tex: oxTTexture;

begin
   oxTextureGenerate.Generate(oxPaths.Find('textures' + DirectorySeparator + 'background.png'), tex);

   if(tex = nil) then
      log.w('Failed loading background texture');

   BackgroundMaterial := CreateMaterial('background',  cWhite4ub);
   BackgroundMaterial.SetTexture('texture', tex);

   background := oxPrimitiveModelEntities.Plane();

   background.SetPosition(0, 0, -0.9);
   background.SetScale(oxProjection^.p.GetWidth() / 2, oxProjection^.p.GetHeight() / 2, 0);

   component := oxTPrimitiveModelComponent(background.GetComponent('oxTPrimitiveModelComponent'));

   component.Model.SetMaterial(BackgroundMaterial);

   background.Name := 'Background';
   oxScene.Add(background);
end;

INITIALIZATION
   main.OnInitScene.Add('dropblocks.background', @init);

END.
