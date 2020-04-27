{$INCLUDE oxdefines.inc}
UNIT uSceneView;

INTERFACE

   USES
      uMain,
      {ox}
      oxuTypes, oxuWindow, oxuSceneRender, oxuScene,
      {ui}
      uiWidgets, uiuWindow, uiuTypes,
      wdguSceneRender,
      {game}
      uMenubar, uScene;

VAR
   SceneView: wdgTSceneRender;

IMPLEMENTATION

procedure initialize();
begin
   {don't render any kind of background, since we draw over}
   oxWindow.Current.SetBackgroundType(uiwBACKGROUND_NONE);
   SceneView := wdgSceneRender.Add();
   SceneView.SetCaption('Game');

   {move}
   SceneView.Move(oxPoint(0, menubar.BelowOf(0)));
   SceneView.Resize(oxWindow.Current.Dimensions.w, menubar.BelowOf(0) + 1);

   {render via scene view, not window renderer}
   oxSceneRender.RenderAutomatically := false;
end;

procedure deinitialize();
begin

end;

procedure sceneInitialize();
begin
   SceneView.Scene := oxScene;
end;

INITIALIZATION
   main.Init.Add('menubar', @initialize, @deinitialize);
   scene.OnInitialize.Add(@sceneInitialize);

END.
