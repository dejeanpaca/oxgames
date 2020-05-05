{$INCLUDE oxdefines.inc}
UNIT uSceneView;

INTERFACE

   USES
      uMain, vmVector,
      {app}
      appuMouse, appuMouseEvents,
      {ox}
      oxuTypes, oxuWindow, oxuSceneRender, oxuScene, oxuViewport,
      {ui}
      uiWidgets, uiuWindow, uiuTypes,
      wdguSceneRender,
      {game}
      uMenubar, uScene;

TYPE

   { wdgTChessSceneRender }

   wdgTChessSceneRender = class(wdgTSceneRender)
      procedure Point(var e: appTMouseEvent; x, y: longint); override;
   end;

VAR
   SceneView: wdgTSceneRender;

IMPLEMENTATION

procedure initialize();
begin
   {don't render any kind of background, since we draw over}
   oxWindow.Current.SetBackgroundType(uiwBACKGROUND_NONE);
   uiWidget.Create.Instance := wdgTChessSceneRender;
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

{ wdgTChessSceneRender }

procedure wdgTChessSceneRender.Point(var e: appTMouseEvent; x, y: longint);
var
   n: TVector2f;

begin
   Viewport.GetNormalizedPointerCoordinates(x, y, n);
end;

INITIALIZATION
   main.Init.Add('menubar', @initialize, @deinitialize);
   scene.OnInitialize.Add(@sceneInitialize);

END.
