{$INCLUDE oxdefines.inc}
UNIT uOptions;

INTERFACE

   USES
      uStd, udvars,
      {ox}
      uOX, oxuProgramConfig,
      {game}
      uChess, uMain, uAI, uSimpleAI, uGame;

TYPE

   { TChessOptions }

   TChessOptions = record
      {starting player}
      StartingPlayer: TPlayer;
      {player control types}
      WhiteControl,
      BlackControl: TPlayerControlType;
      {id of the used AI}
      AIId: StdString;
      {ai move search depth}
      AISearchDepth: loopint;

      {swap player sides on the board}
      InvertSides: boolean;

      {options have been changed and applying should be made}

      PendingOptions: boolean;

      {apply options}
      procedure Apply();
   end;

VAR
   options: TChessOptions;

IMPLEMENTATION

VAR
   dvBoard3D,
   dvStartingPlayer,
   dvAIId,
   dvWhiteControl,
   dvBlackControl,
   dvSearchDepth: TDVar;

{ TChessOptions }

procedure TChessOptions.Apply();
var
   selectedAI: PAI;

begin
   PendingOptions := false;

   { validate options in case they were set to weird values in the config file }

   {validate starting type}
   if(loopint(StartingPlayer) > loopint(PLAYER_WHITE)) then
      StartingPlayer := PLAYER_WHITE;

   {validate control types}

   if(loopint(BlackControl) > loopint(PLAYER_CONTROL_AI)) then
      BlackControl := PLAYER_CONTROL_AI;

   if(loopint(WhiteControl) > loopint(PLAYER_CONTROL_AI)) then
         BlackControl := PLAYER_CONTROL_INPUT;

   {validate AI search depth}
   if(AISearchDepth <= 1) or (AISearchDepth > 7) then
      AISearchDepth := 4;

   {validate AI}

   selectedAI := AI.FindById(AIId);
   if(selectedAI = nil) then begin
      selectedAI := @SimpleAI;
      AIId := SimpleAI.Id;
   end;

   { apply options }

   chess.InvertSides := InvertSides;
   chess.StartingPlayer := StartingPlayer;

   game.PlayerControl[loopint(PLAYER_BLACK)] := BlackControl;
   game.PlayerControl[loopint(PLAYER_WHITE)] := WhiteControl;

   SimpleAI.SearchDepth := AISearchDepth;
   CurrentAI := selectedAI;
end;

procedure beforeNewGame();
begin
   if(options.PendingOptions) then
      options.Apply();
end;

INITIALIZATION
   options.StartingPlayer := chess.StartingPlayer;
   options.BlackControl := game.PlayerControl[loopint(PLAYER_BLACK)];
   options.WhiteControl := game.PlayerControl[loopint(PLAYER_WHITE)];
   options.InvertSides := chess.InvertSides;
   options.AIId := CurrentAI^.Id;
   options.AISearchDepth := SimpleAI.SearchDepth;

   ox.ProgramDvar.Add(dvBoard3D, 'board3d', dtcBOOL, @main.Board3D);
   ox.ProgramDvar.Add(dvStartingPlayer, 'starting_player', dtcENUM, @options.StartingPlayer);
   ox.ProgramDvar.Add(dvAIId, 'ai_id', dtcSTRING, @options.AIId);
   ox.ProgramDvar.Add(dvBlackControl, 'black_control', dtcENUM, @options.BlackControl);
   ox.ProgramDvar.Add(dvWhiteControl, 'white_control', dtcENUM, @options.WhiteControl);
   ox.ProgramDvar.Add(dvSearchDepth, 'ai_search_depth', dtcSIZEINT, @options.AISearchDepth);

   oxProgramDvarFile.FileName := 'chess.options';

   game.OnBeforeNew.Add(@beforeNewGame);

END.
