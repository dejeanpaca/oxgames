{
   chess options windows
   TODO: Save these options
}

{$INCLUDE oxdefines.inc}
UNIT uwndOptions;

INTERFACE

   USES
      uStd,
      {oX}
      oxuTypes, oxuConsoleBackend,
      {wnd}
      oxuwndSettingsBase,
      {ui}
      uiuControl, uiuWindow, uiWidgets, uiuMessageBox, uiuTypes, uiuWidget,
      {wdg}
      wdguList, wdguButton, wdguDivisor, wdguLabel, wdguDropDownList, wdguCheckbox,
      {game}
      uMain, uChess, uGame, uAI, uSimpleAI, uRandomAI, uOptions;

TYPE

   { wdgTChessAIDropDownList }

   wdgTChessAIDropDownList = class(wdgTDropDownList)
      protected
         procedure SelectedItemChanged(); override;
   end;

   { wndTOptions }

   wndTOptions = object(oxTSettingsWindowBase)
      widgets: record
         AI,
         AIMoveDepth,
         BlackPlayer,
         WhitePlayer,
         StartingPlayer: wdgTDropDownList;
         InvertSides: wdgTCheckbox;
         AIMoveDepthLabel: wdgTLabel;
      end;

      constructor Create();

      protected
      procedure AddWidgets(); virtual;

      procedure Revert(); virtual;
      procedure Save(); virtual;

      procedure AISelected();
   end;

VAR
   wndOptions: wndTOptions;

IMPLEMENTATION

procedure closeSettingsWindow();
begin
   wndOptions.Close();
end;

{ wdgTChessAIDropDownList }

procedure wdgTChessAIDropDownList.SelectedItemChanged();
begin
   wndOptions.AISelected();
end;

{ oxedTOptionsWindow }

procedure wndTOptions.AddWidgets();

   procedure addSection(const caption: StdString);
   begin
      wdgDivisor.Add(caption);
      uiWidget.LastRect.GoLeft();
   end;

function addPlayer(const name: StdString): wdgTDropDownList;
begin
   wdgLabel.Add(name + ' player:');
   Result := wdgDropDownList.Add(uiWidget.LastRect.RightOf(), oxNullDimensions);
   Result.Add('Human');
   Result.Add('AI');

   Result.AutoSetDimensions(true);
   uiWidget.LastRect.GoLeft();
end;

begin
   addSection('Players');

   wdgLabel.Add('Starting player: ');

   widgets.StartingPlayer := wdgDropDownList.Add(uiWidget.LastRect.RightOf(), oxNullDimensions);
   widgets.StartingPlayer.Add('White');
   widgets.StartingPlayer.Add('Black');

   widgets.StartingPlayer.AutoSetDimensions(true);
   uiWidget.LastRect.GoLeft();

   widgets.BlackPlayer := addPlayer('Black');
   widgets.WhitePlayer := addPlayer('White');

   widgets.InvertSides := wdgCheckbox.Add('Invert player sides on board');

   addSection('AI');

   wdgLabel.Add('AI Type: ');

   uiWidget.Create.Instance := wdgTChessAIDropDownList;
   widgets.AI := wdgDropDownList.Add(uiWidget.LastRect.RightOf(), oxNullDimensions);

   widgets.AI.Add('Simple');
   widgets.AI.Add('Random');

   widgets.AI.AutoSetDimensions(true);

   uiWidget.LastRect.GoLeft();

   widgets.AIMoveDepthLabel := wdgLabel.Add('AI Move Depth');
   widgets.AIMoveDepthLabel.SetHint('Up to 4 is recommended depending on your CPU performance.'#13 +
      'Each higher value requires exponentially more time (and may not finish in reasonable time).');

   widgets.AIMoveDepth := wdgDropDownList.Add(uiWidget.LastRect.RightOf(), oxNullDimensions);

   widgets.AIMoveDepth.Add('1');
   widgets.AIMoveDepth.Add('2');
   widgets.AIMoveDepth.Add('3');
   widgets.AIMoveDepth.Add('4');
   widgets.AIMoveDepth.Add('5');
   widgets.AIMoveDepth.Add('6');
   widgets.AIMoveDepth.Add('7');
   widgets.AIMoveDepth.AutoSetDimensions(true);

   addSection('Note');
   wdgLabel.Add('Saving will reset your game');

   {TODO: Apply changes without resetting the game. Will require reversing the board if players are inverted}

   AddCancelSaveButtons();
   AddRevertButton();
   AddDivisor();
end;

procedure wndTOptions.Revert();

   procedure setPlayerControl(p: wdgTDropDownList; control: TPlayerControlType);
   begin
      if(control = PLAYER_CONTROL_INPUT) then
         p.SelectItem(0)
      else
         p.SelectItem(1);
   end;

begin
   if(options.AIId = 'random') then begin
      widgets.AI.SelectItem(0)
   end else
      widgets.AI.SelectItem(1);

   widgets.AIMoveDepth.SelectItem(options.AISearchDepth - 1);

   setPlayerControl(widgets.BlackPlayer, options.BlackControl);
   setPlayerControl(widgets.WhitePlayer, options.WhiteControl);

   if(options.StartingPlayer = PLAYER_WHITE) then
      widgets.StartingPlayer.SelectItem(0)
   else
      widgets.StartingPlayer.SelectItem(1);

   widgets.InvertSides.Check(options.InvertSides);
end;

procedure wndTOptions.Save();

   function getControl(p: wdgTDropDownList): TPlayerControlType;
   begin
      if(p.CurrentItem = 0) then
         Result := PLAYER_CONTROL_INPUT
      else
         Result := PLAYER_CONTROL_AI;
   end;

begin
   options.InvertSides := widgets.InvertSides.Checked();

   options.BlackControl := getControl(widgets.BlackPlayer);
   options.WhiteControl := getControl(widgets.WhitePlayer);

   if(widgets.AIMoveDepth.CurrentItem > -1) then
      options.AISearchDepth := widgets.AIMoveDepth.CurrentItem + 1;

   if(widgets.AI.CurrentItem = 0) then
      options.AIId := SimpleAI.Id
   else if(widgets.AI.CurrentItem = 1) then
      options.AIId := RandomAI.Id;

   if(widgets.StartingPlayer.CurrentItem = 0) then
      options.StartingPlayer := PLAYER_WHITE
   else
      options.StartingPlayer := PLAYER_BLACK;

   Close();
end;

procedure wndTOptions.AISelected();
var
   enabled: boolean;

begin
   enabled := widgets.AI.CurrentItem = 0;

   widgets.AIMoveDepth.Enable(enabled);
   widgets.AIMoveDepthLabel.Enable(enabled);
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
