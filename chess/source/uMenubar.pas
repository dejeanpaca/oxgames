{$INCLUDE oxdefines.inc}
UNIT uMenubar;

INTERFACE

   USES
      appuActionEvents,
      {ox}
      oxuWindow, oxuwndAbout,
      {ui}
      uiWidgets,
      wdguMenubar, uiuContextMenu,
      {game}
      uMain, uAbout, uGame,
      uBoardSwitch;

VAR
   ChessMenubar: record
      menu: wdgTMenubar;
      undo: uiPContextMenuItem;
   end;

IMPLEMENTATION

procedure storedBoardChange();
begin
   ChessMenubar.undo^.Enable(game.HasStoredBoard);
end;

procedure initialize();
var
   menubar: wdgTMenubar;
   menu: uiTContextMenu;

begin
   menubar := wdgMenubar.Add(oxWindow.Current);
   ChessMenubar.menu := menubar;

   menu := menubar.Add('Game');
   ChessMenubar.undo := menu.AddItem('Undo', game.ACTION_UNDO);
   menu.AddSeparator();
   menu.AddItem('New Game', game.ACTION_NEW_GAME);
   menu.AddSeparator();
   menu.AddItem('Quit', appACTION_QUIT);

   menu := menubar.Add('View');
   menu.AddItem('2D', ACTION_SWITCH_2D);
   menu.AddItem('3D', ACTION_SWITCH_3D);

   menu := menubar.Add('Help');
   menu.AddItem('About', oxwndAbout.OpenWindowAction);

   storedBoardChange();
end;

INITIALIZATION
   main.Init.Add('menubar', @initialize);

   game.OnStoredBoard.Add(@storedBoardChange);

END.
