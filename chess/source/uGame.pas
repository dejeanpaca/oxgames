{$INCLUDE oxdefines.inc}
UNIT uGame;

INTERFACE

   USES
      uStd,
      {ox}
      oxuTypes,
      {game}
      uChess;

TYPE
   TPlayerControlType = (
      PLAYER_CONTROL_INPUT,
      PLAYER_CONTROL_AI
   );

   { TGameGlobal }

   TGameGlobal = record
      OnNew,
      OnSelectedTile,
      OnUnselectedTile: TProcedures;

      SelectedTile: oxTPoint;
      PlayerControl: array[0..1] of TPlayerControlType;

      procedure New();

      {select a tile to play}
      procedure SelectTile(x, y: loopint);

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

   OnNew.Call();
end;

procedure TGameGlobal.SelectTile(x, y: loopint);

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

   {if a tile is already selected, play a move}
   if(SelectedTile.x >= 0) then begin
      unselect();

      {no move possible if selected own piece again}
      if(chess.Board[y, x].Player <> chess.CurrentPlayer) then begin
         {TODO: Play a move, if possible}
         chess.TogglePlayer();
      end;

      exit;
   end;

   {if given tile was already selected, unselect it}
   if(SelectedTile.x = x) and (SelectedTile.y = y) then begin
      unselect();
   end else begin
      {select given tile, if it has a piece controlled by the current player}
      if(chess.Board[y, x].Player = chess.CurrentPlayer) and (chess.Board[y, x].Piece <> PIECE_NONE) then begin
        SelectedTile.x := x;
        SelectedTile.y := y;

        OnSelectedTile.Call();
      end;
   end;
end;

function TGameGlobal.IsInputControllable(player: TPlayer): boolean;
begin
   Result := PlayerControl[loopint(player)] = PLAYER_CONTROL_INPUT;
end;

function TGameGlobal.PlayerControlType(): TPlayerControlType;
begin
  Result := PlayerControl[loopint(chess.CurrentPlayer)];
end;

INITIALIZATION
   TProcedures.Initialize(game.OnNew);
   TProcedures.Initialize(game.OnSelectedTile);
   TProcedures.Initialize(game.OnUnselectedTile);

   game.PlayerControl[loopint(PLAYER_BLACK)] := PLAYER_CONTROL_INPUT;
   game.PlayerControl[loopint(PLAYER_WHITE)] := PLAYER_CONTROL_INPUT;

END.
