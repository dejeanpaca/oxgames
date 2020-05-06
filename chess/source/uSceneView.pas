{$INCLUDE oxdefines.inc}
UNIT uSceneView;

INTERFACE

   USES
      vmVector,
      {app}
      appuMouse, appuMouseEvents,
      {ox}
      oxuTypes, oxuWindow, oxuSceneRender, oxuScene,
      oxuProjectionType, oxuProjection,
      {ui}
      uiWidgets, uiuWindow, uiuTypes,
      wdguSceneRender,
      {game}
      uMain, uChess, uMenubar, uScene, uBoard2D, uGame;

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
   p: oxPProjection;
   world: TVector2f;
   tile: oxTPoint;

begin
   p := @uScene.scene.Camera.Projection;

   if(not main.Board3D) then begin
      p^.Unproject(x, y, Camera.Matrix, world);

      {convert projection coordinates into tile coordinates}
      tile.x := trunc((world[0] - (BOARD_2D_SIZE / 2)) / BOARD_2D_TILE_SIZE) + 7;
      tile.y := trunc((world[1] - (BOARD_2D_SIZE / 2)) / BOARD_2D_TILE_SIZE) + 7;

      {make sure the tile is not out of bounds}
      if(chess.Valid(tile.x, tile.y)) then begin
         game.SelectTile(tile.y, tile.x);
      end;
   end;
end;

INITIALIZATION
   main.Init.Add('menubar', @initialize, @deinitialize);
   scene.OnInitialize.Add(@sceneInitialize);

END.
