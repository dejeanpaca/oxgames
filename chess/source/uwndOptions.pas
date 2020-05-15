{
   chess options windows
}

{$INCLUDE oxdefines.inc}
UNIT uwndOptions;

INTERFACE

   USES
      uStd,
      {oX}
      oxuConsoleBackend,
      {wnd}
      oxuwndBase, oxuwndSettingsBase,
      {ui}
      uiuControl, uiWidgets, uiuMessageBox, uiuTypes,
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

      protected
      procedure AddWidgets(); virtual;

      procedure Revert(); virtual;
      procedure Save(); virtual;
   end;

VAR
   wndOptions: wndTOptions;

IMPLEMENTATION

procedure closeSettingsWindow();
begin
   wndOptions.Close();
end;

{ oxedTOptionsWindow }

procedure wndTOptions.AddWidgets();
begin
end;

procedure wndTOptions.Revert();
begin
end;

procedure wndTOptions.Save();
begin
end;

{$IFDEF OX_FEATURE_CONSOLE}
procedure consoleCallback({%H-}con: conPConsole);
begin
   wndOptions.Open();
end;
{$ENDIF}

constructor wndTOptions.Create();
begin
   Name := 'options';
   Title := 'Chess Options';

   {$IFDEF OX_FEATURE_CONSOLE}
   if(console.Selected <> nil) then
      console.Selected^.AddCommand('wnd:options', @consoleCallback);
   {$ENDIF}

   inherited Create;
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
