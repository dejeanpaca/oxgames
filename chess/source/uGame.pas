{$INCLUDE oxdefines.inc}
UNIT uGame;

INTERFACE

   USES
      uStd, uLog,
      {app}
      appuEvents, appuActionEvents,
      {ox}
      oxuTypes,
      {game}
      uChess, uAI;

TYPE
   TPlayerControlType = (
      PLAYER_CONTROL_INPUT,
      PLAYER_CONTROL_AI
   );

   { TGameGlobal }

   TGameGlobal = record
      ACTION_NEW_GAME: TEventID;

      OnNew,
      OnSelectedTile,
      OnUnselectedTile,
      OnMovePlayed: TProcedures;

      SelectedTile: oxTPoint;
      PlayerControl: array[0..1] of TPlayerControlType;
      LastMove: TChessMove;

      procedure New();

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
   {exit if input can't control the current player}
   if(not game.IsInputControllable(chess.CurrentPlayer)) then
      exit;

   {can't do anything if checkmate}
   if(chess.CheckMate) then
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

   LastMove := move;

   log.i(move.GetDescription());

   {switch to the other player, unless we've reached check mate}
   if(not chess.CheckMate) then begin
      {done with this player}
      chess.TogglePlayer();
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
