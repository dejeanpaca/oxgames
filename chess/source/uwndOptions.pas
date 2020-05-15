{
   chess options windows
}

{$INCLUDE oxdefines.inc}
UNIT uwndOptions;

INTERFACE

   USES
      uStd,
      {oX}
      oxuTypes, oxuConsoleBackend,
      {wnd}
      oxuwndBase, oxuwndSettingsBase,
      {ui}
      uiuControl, uiuWidget, uiWidgets, uiuMessageBox, uiuTypes,
      {wdg}
      wdguList, wdguButton, wdguDivisor, wdguLabel,
      {game}
      uMain;

TYPE
   { wndTOptions }

   wndTOptions = object(oxTSettingsWindowBase)
      widgets: record
      end;

      constructor Create();
      procedure Open(); virtual;

      protected
      procedure AddWidgets(); virtual;

      procedure Revert(); virtual;
      procedure Save(); virtual;
   end;

VAR
   wndOptions: oxedTOptionsWindow;

IMPLEMENTATION

procedure closeSettingsWindow();
begin
   wndOptions.Close();
end;

{ oxedTOptionsWindow }

procedure oxedTOptionsWindow.AddWidgets();
begin
end;

procedure oxedTOptionsWindow.Revert();
begin
end;

procedure oxedTOptionsWindow.Save();
begin
end;

{$IFDEF OX_FEATURE_CONSOLE}
procedure consoleCallback({%H-}con: conPConsole);
begin
   wndOptions.Open();
end;
{$ENDIF}

constructor oxedTOptionsWindow.Create();
begin
   Name := 'project_features';
   Title := 'Project Features';

   {$IFDEF OX_FEATURE_CONSOLE}
   if(console.Selected <> nil) then
      console.Selected^.AddCommand('wnd:project_features', @consoleCallback);
   {$ENDIF}

   inherited Create;
end;

procedure oxedTOptionsWindow.Open();
begin
   inherited Open;
end;

procedure init();
begin
   wndOptions.Create();
end;

procedure deinit();
begin
   wndOptions.Destroy();
end;

INITIALIZATION
   main.Init.Add('options_window', @init, @deinit);

END.
