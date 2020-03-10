{$INCLUDE oxdefines.inc}
UNIT uSceneView;

INTERFACE

   USES
      uMain,
      {ox}
      oxuTypes, oxuWindow, oxuSceneRender,
      {ui}
      uiWidgets, uiuWindow, uiuTypes,
      wdguSceneRender,
      {game}
      uMenubar;

VAR
   SceneView: wdgTSceneRender;

IMPLEMENTATION

procedure initialize();
begin
   {don't render any kind of background, since we draw over}
   oxWindow.Current.SetBackgroundType(uiwBACKGROUND_NONE);
   uiWidget.SetTarget(oxWindow.Current);

   SceneView := wdgSceneRender.Add();

   {move}
   SceneView.Move(oxPoint(0, menubar.BelowOf()));
   SceneView.Resize(oxWindow.Current.Dimensions.w, menubar.BelowOf() + 1);

   {render via scene view, not window renderer}
   oxSceneRender.RenderAutomatically := false;
end;

procedure deinitialize();
begin

end;

INITIALIZATION
   main.Init.Add('menubar', @initialize, @deinitialize)

END.
