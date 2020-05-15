{$INCLUDE oxdefines.inc}
UNIT uGame;

INTERFACE

   USES
      sysutils, uStd, uLog,
      {app}
      appuEvents, appuActionEvents,
      {ox}
      oxuTypes,
      {game}
      uChess, uAI;

CONST
   {delay compute start by a small time, so that rendering can show the change on the board if we're not computing in a thread}
   AI_COMPUTE_DELAY_TIME = 0.1;
   {delay AI move time so it's more easily noticeable, instead of instant}
   AI_MOVE_DELAY_TIME = 0.5;

TYPE
   TPlayerControlType = (
      PLAYER_CONTROL_INPUT,
      PLAYER_CONTROL_AI
   );

   { TGameGlobal }

   TGameGlobal = record
      ACTION_NEW_GAME: TEventID;

      MoveStartTime: TDateTime;

      OnNew,
      OnSelectedTile,
      OnUnselectedTile,
      OnMovePlayed: TProcedures;

      SelectedTile: oxTPoint;
      PlayerControl: array[0..1] of TPlayerControlType;

      procedure New();
      {called when the player is switched}
      procedure SwitchedPlayer();

      {select a tile to play}
      procedure SelectTile(const tile: oxTPoint);
      {play a move}
      procedure PlayMove(const move: TChessMove);

      {is the given player controllable by input}
      function IsInputControllable(player: TPlayer): boolean;
      {control type for the current player}
      function PlayerControlType(): TPlayerControlType;
   end;

VAR
   game: TGameGlobal;

IMPLEMENTATION

{ TGameGlobal }

procedure TGameGlobal.New();
begin
   chess.New();

   {unselect tile}
   SelectedTile.x := -1;
   SelectedTile.y := -1;

   CurrentAI^.Reset();
   OnNew.Call();
   game.SwitchedPlayer();
end;

procedure TGameGlobal.SwitchedPlayer();
begin
   MoveStartTime := Now();
end;

procedure TGameGlobal.SelectTile(const tile: oxTPoint);
var
   move: TChessMove;
   previousTile: oxTPoint;

   procedure unselect();
   begin
      OnUnselectedTile.Call();

      SelectedTile.x := -1;
      SelectedTile.y := -1;
   end;

begin
   {can't do anything if game over}
   if(chess.GameOver()) then
      exit;

   {exit if input can't control the current player}
   if(not game.IsInputControllable(chess.CurrentPlayer)) then
      exit;

   {if a tile is already selected, play a move}
   if(SelectedTile.x >= 0) then begin
      previousTile := SelectedTile;
      unselect();

      {no move possible if selected own piece again}
      if(chess.Board[tile.y, tile.x].Player <> chess.CurrentPlayer) or
         (chess.Board[tile.y, tile.x].Piece = PIECE_NONE) then begin
         if chess.MovePossible(previousTile, tile, move) then
            PlayMove(move);
      end;

      exit;
   end;

   {if given tile was already selected, unselect it}
   if(SelectedTile = tile) then begin
      unselect();
   end else begin
      {select given tile, if it has a piece controlled by the current player}
      if(chess.Board[tile.y, tile.x].Player = chess.CurrentPlayer) and
         (chess.Board[tile.y, tile.x].Piece <> PIECE_NONE) then begin
         SelectedTile := tile;

         OnSelectedTile.Call();
      end;
   end;
end;

procedure TGameGlobal.PlayMove(const move: TChessMove);
begin
   if(not chess.PlayMove(move)) then begin
      log.e('Cannot play move: ' + move.GetDescription());
      exit;
   end;

   log.i(move.GetDescription());

   {switch to the other player, unless we've reached check mate}
   if(not chess.CheckMate) then begin
      {done with this player}
      chess.TogglePlayer();

      {reset AI on player toggle}
      CurrentAI^.Reset();

      game.SwitchedPlayer();
   end;

   OnMovePlayed.Call();
end;

function TGameGlobal.IsInputControllable(player: TPlayer): boolean;
begin
   Result := PlayerControl[loopint(player)] = PLAYER_CONTROL_INPUT;
end;

function TGameGlobal.PlayerControlType(): TPlayerControlType;
begin
  Result := PlayerControl[loopint(chess.CurrentPlayer)];
end;

procedure newGame();
begin
   game.New();
end;

INITIALIZATION
   TProcedures.Initialize(game.OnNew);
   TProcedures.Initialize(game.OnSelectedTile);
   TProcedures.Initialize(game.OnUnselectedTile);
   TProcedures.Initialize(game.OnMovePlayed);

   game.PlayerControl[loopint(PLAYER_BLACK)] := PLAYER_CONTROL_AI;
   game.PlayerControl[loopint(PLAYER_WHITE)] := PLAYER_CONTROL_INPUT;

   game.ACTION_NEW_GAME := appActionEvents.SetCallback(@newGame);

END.
