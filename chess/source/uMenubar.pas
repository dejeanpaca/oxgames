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
      uMain, uAbout,
      uBoardSwitch;

VAR
   menubar: wdgTMenubar;

IMPLEMENTATION

procedure initialize();
var
   menu: uiTContextMenu;

begin
   menubar := wdgMenubar.Add(oxWindow.Current);

   menu := menubar.Add('Game');
   menu.AddItem('New Game');
   menu.AddSeparator();
   menu.AddItem('Quit', appACTION_QUIT);

   menu := menubar.Add('View');
   menu.AddItem('2D', ACTION_SWITCH_2D);
   menu.AddItem('3D', ACTION_SWITCH_3D);

   menu := menubar.Add('Help');
   menu.AddItem('About', oxwndAbout.OpenWindowAction);
end;

procedure deinitialize();
begin

end;

INITIALIZATION
   main.Init.Add('menubar', @initialize, @deinitialize)

END.
