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
      uiWidgets, uiuWindow, uiuTypes, uiuPointer,
      wdguSceneRender,
      {game}
      uMain, uChess, uMenubar, uScene, uBoard2D, uGame, uAI;

TYPE

   { wdgTChessSceneRender }

   wdgTChessSceneRender = class(wdgTSceneRender)
      procedure Point(var e: appTMouseEvent; x, y: longint); override;
      procedure Update(); override;
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
   SceneView.Move(oxPoint(0, ChessMenubar.menu.BelowOf(0)));
   SceneView.Resize(oxWindow.Current.Dimensions.w, ChessMenubar.menu.BelowOf(0) + 1);

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
   if(not e.IsReleased()) then
      exit;

   if(not main.Board3D) and (game.IsInputControllable(chess.CurrentPlayer)) then begin
      p := @uScene.scene.Camera.Projection;
      p^.Unproject(x, y, Camera.Matrix, world);

      {convert projection coordinates into tile coordinates}
      tile.x := trunc((world[0] - (BOARD_2D_SIZE / 2)) / BOARD_2D_TILE_SIZE) + 7;
      tile.y := trunc((world[1] - (BOARD_2D_SIZE / 2)) / BOARD_2D_TILE_SIZE) + 7;

      {make sure the tile is not out of bounds}
      if(chess.Valid(tile.x, tile.y)) then
         game.SelectTile(tile);
   end;
end;

procedure wdgTChessSceneRender.Update();
begin
   inherited Update();

   if(AI.ComputeTask = nil) or (AI.ComputeTask.IsFinished()) then
      SetCursorType(uiCURSOR_TYPE_DEFAULT)
   else
      SetCursorType(uiCURSOR_TYPE_BUSY);
end;

INITIALIZATION
   main.Init.Add('menubar', @initialize, @deinitialize);
   scene.OnInitialize.Add(@sceneInitialize);

END.
