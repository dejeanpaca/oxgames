{$INCLUDE oxdefines.inc}
UNIT uMenubar;

INTERFACE

   USES
      uMain, appuActionEvents,
      {ox}
      oxuWindow, oxuwndAbout,
      {ui}
      uiWidgets,
      wdguMenubar, uiuContextMenu,
      {game}
      uAbout;

VAR
   menubar: wdgTMenubar;

IMPLEMENTATION

procedure initialize();
var
   menu: uiTContextMenu;

begin
   uiWidget.SetTarget(oxWindow.Current);
   menubar := wdgMenubar.Add(oxWindow.Current);

   menu := menubar.Add('Game');
   menu.AddItem('New Game');
   menu.AddSeparator();
   menu.AddItem('Quit', appACTION_QUIT);

   menu := menubar.Add('Help');
   menu.AddItem('About', oxwndAbout.OpenWindowAction);
end;

procedure deinitialize();
begin

end;

INITIALIZATION
   main.Init.Add('menubar', @initialize, @deinitialize)

END.
