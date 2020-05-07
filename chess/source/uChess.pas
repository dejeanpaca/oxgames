{$INCLUDE oxdefines.inc}
UNIT uChess;

INTERFACE

   USES
      uStd,
      oxuTypes;

TYPE
   TPieceType = (
      PIECE_NONE,
      PIECE_PAWN,
      PIECE_KNIGHT,
      PIECE_BISHOP,
      PIECE_ROOK,
      PIECE_QUEEN,
      PIECE_KING
   );

   TPlayer = (
      PLAYER_WHITE,
      PLAYER_BLACK
   );

   TMoveAction = (
      ACTION_MOVE,
      ACTION_EAT
   );

   { TPiece }

   TPiece = record
      {type of piece}
      Piece: TPieceType;
      {what player the piece belongs to}
      Player: TPlayer;

      procedure Place(usePiece: TPieceType; usePlayer: TPlayer);
      procedure Clear();
   end;

   TBoard = array[0..7, 0..7] of TPiece;

   TPiecePosition = oxTPoint;

   { TChessMove }

   TChessMove = record
      From,
      Target: TPiecePosition;
      Piece: TPieceType;
      Player: TPlayer;
      Action: TMoveAction;

      {TODO: Store target piece and player for descriptive purposes}

      class procedure Initialize(out m: TChessMove); static;
   end;

   PMovesList = ^TMovesList;
   TMovesList = specialize TSimpleList<TChessMove>;

   TMovesBuilderContext = record
      x, y: loopint;
      Moves: PMovesList;
   end;

   { TChess }

   TChess = record
      Board: TBoard;
      StartingPlayer,
      CurrentPlayer: TPlayer;

      procedure New();

      {switch the current player to opposing}
      procedure TogglePlayer();

      procedure AddMove(toX, toY: loopint; var context: TMovesBuilderContext);
      {get allowed moves for the piece on the given coordinates}
      procedure GetPawnMoves(x, y: loopint; var context: TMovesBuilderContext);
      {get allowed moves for the piece on the given coordinates}
      function GetMoves(x, y: loopint): TMovesList;
      {get all allowed moves for the entire board for a player}
      function GetAllMoves(player: TPlayer): TMovesList;

      {is the given position occupied on the board}
      function Occupied(x, y: loopint): boolean;
      {is the given position valid on the board}
      function Valid(x, y: loopint): boolean;

      {checks if a move is possible}
      function MovePossible(const from, target: oxTPoint; out move: TChessMove): boolean;
      {plays a move from to}
      function PlayMove(const move: TChessMove): boolean;

      procedure ResetBoard();
   end;

CONST
   PIECE_TYPE_MAX = loopint(PIECE_KING);

   PIECE_NAMES: array[0..PIECE_TYPE_MAX] of StdString = (
      'None',
      'Pawn',
      'Knight',
      'Bishop',
      'Rook',
      'Queen',
      'King'
   );

   PIECE_IDS: array[0..PIECE_TYPE_MAX] of StdString = (
      'none',
      'pawn',
      'knight',
      'bishop',
      'rook',
      'queen',
      'king'
   );

   PIECE_PLACEMENT: array[0..7] of TPieceType = (
      PIECE_ROOK,
      PIECE_KNIGHT,
      PIECE_BISHOP,
      PIECE_QUEEN,
      PIECe_KING,
      PIECE_BISHOP,
      PIECE_KNIGHT,
      PIECE_ROOK
   );

VAR
   chess: TChess;

IMPLEMENTATION

{ TChessMove }

class procedure TChessMove.Initialize(out m: TChessMove);
begin
   ZeroOut(m, SizeOf(m));
end;

{ TPiece }

procedure TPiece.Place(usePiece: TPieceType; usePlayer: TPlayer);
begin
   Piece := usePiece;
   Player := usePlayer;
end;

procedure TPiece.Clear();
begin
   Piece := PIECE_NONE;
   Player := PLAYER_BLACK;
end;

{ TChess }

procedure TChess.New();
begin
   CurrentPlayer := StartingPlayer;
   ResetBoard();
end;

procedure TChess.TogglePlayer();
begin
   if(CurrentPlayer = PLAYER_BLACK) then
      CurrentPlayer := PLAYER_WHITE
   else
      CurrentPlayer := PLAYER_BLACK;
end;

procedure TChess.AddMove(toX, toY: loopint; var context: TMovesBuilderContext);
var
   pieceType: TPieceType;
   move: TChessMove;

begin
   {can't move outside the chess board}
   if(not Valid(toX, toY)) then
      exit;

   pieceType := Board[context.y, context.x].Piece;

   TChessMove.Initialize(move);

   if(not Occupied(toX, toY)) then
      move.Action := ACTION_MOVE
   else
      move.Action := ACTION_EAT;

   move.Piece := pieceType;
   move.Player := Board[context.y, context.x].Player;
   move.From.x := context.x;
   move.From.y := context.y;
   move.Target.x := toX;
   move.Target.y := toY;

   context.Moves^.Add(move);
end;

procedure TChess.GetPawnMoves(x, y: loopint; var context: TMovesBuilderContext);
begin
   if(Board[y, x].Player = PLAYER_BLACK) then begin
      if(not Occupied(x, y - 1)) then
         AddMove(x, y - 1, context);

      if(Occupied(x + 1, y - 1)) then
         AddMove(x + 1, y - 1, context);

      if(Occupied(x - 1, y - 1)) then
         AddMove(x - 1, y - 1, context);
   end else begin
      if(not Occupied(x, y + 1)) then
         AddMove(x, y + 1, context);

      if(not Occupied(x + 1, y + 1)) then
         AddMove(x + 1, y + 1, context);

      if(not Occupied(x - 1, y + 1)) then
         AddMove(x - 1, y + 1, context);
   end;
end;

function TChess.GetMoves(x, y: loopint): TMovesList;
var
   pieceType: TPieceType;
   context: TMovesBuilderContext;

begin
   TMovesList.Initialize(Result);

   context.x := x;
   context.y := y;
   context.Moves := @Result;

   pieceType := Board[y, x].Piece;

   if(pieceType = PIECE_PAWN) then
      GetPawnMoves(x, y, context);
end;

function TChess.GetAllMoves(player: TPlayer): TMovesList;
var
   x, y, i: loopint;
   moves: TMovesList;

begin
   TMovesList.Initialize(Result);

   for y := 0 to 7 do begin
      for x := 0 to 7 do begin
         if(Board[y, x].Player = player) then begin
            {get moves for a specific piece}
            moves := GetMoves(x, y);

            {copy piece moves to all moves list, if any}
            if(moves.n > 0) then begin
               for i := 0 to moves.n - 1 do begin
                  Result.Add(moves.List[i]);
               end;
            end;

            moves.Dispose();
         end;
      end;
   end;
end;

function TChess.Occupied(x, y: loopint): boolean;
begin
   Result := false;

   if(Valid(x, y)) then
      Result := Board[y, x].Piece <> PIECE_NONE;
end;

function TChess.Valid(x, y: loopint): boolean;
begin
   Result := (x >= 0) and (x < 8) and (y >= 0) and (y < 8);
end;

function TChess.MovePossible(const from, target: oxTPoint; out move: TChessMove): boolean;
var
   i: loopint;
   moves: TMovesList;

begin
   Result := false;

   {get all possible moves for given piece}
   moves := GetMoves(from.x, from.y);

   if(moves.n > 0) then begin
      for i := 0 to moves.n - 1 do begin
         if(moves.List[i].Target = target) then begin
            move := moves.List[i];
            exit(true);
         end;
      end;
   end;
end;

function TChess.PlayMove(const move: TChessMove): boolean;
var
   source,
   target: TPiece;

begin
   source := Board[move.From.y, move.From.y];
   target := Board[move.Target.y, move.Target.y];

   { do some sanity checks }

   if(move.Action = ACTION_EAT) then begin
      {can't eat your own pieces}
      if(source.Player = target.Player) then
         exit(false);

      {can't eat non-existent piece}
      if(target.Piece = PIECE_NONE) then
         exit(false);
   end;

   { perform move }

   {clear existing piece}
   Board[move.From.y, move.From.x].Piece := PIECE_NONE;

   { TODO: Store eaten pieces }

   {move to target location}
   Board[move.From.y, move.From.x] := source;

   Result := true;
end;

procedure TChess.ResetBoard();
var
   i,
   j: loopint;
   playerFirst,
   playerSecond: TPlayer;

begin
   for i := 0 to 7 do begin
      for j := 0 to 7 do begin
         Board[i][j].Clear();
      end;
   end;

   if(StartingPlayer = PLAYER_BLACK) then begin
      playerFirst := PLAYER_BLACK;
      playerSecond := PLAYER_WHITE;
   end else begin
      playerFirst := PLAYER_WHITE;
      playerSecond := PLAYER_BLACK;
   end;

   {place pawns}
   for j := 0 to 7 do begin
      Board[6][j].Place(PIECE_PAWN, playerSecond);
      Board[1][j].Place(PIECE_PAWN, playerFirst);
   end;

   {place other pieces}
   for j := 0 to 7 do begin
      Board[7][7 - j].Place(PIECE_PLACEMENT[7 - j], playerSecond);
      Board[0][j].Place(PIECE_PLACEMENT[j], playerFirst);
   end;
end;

INITIALIZATION
   chess.StartingPlayer := PLAYER_WHITE;
   chess.CurrentPlayer := chess.StartingPlayer;
   chess.ResetBoard();

END.
