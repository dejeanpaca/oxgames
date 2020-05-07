{$INCLUDE oxdefines.inc}
UNIT uChess;

INTERFACE

   USES
      uStd, uLog, StringUtils,
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
      PLAYER_BLACK,
      PLAYER_WHITE
   );

   TPlayerSide = (
      PLAYER_UP,
      PLAYER_BOTTOM
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
      function GetPlayerSide(): TPlayerSide;
   end;

   TBoard = array[0..7, 0..7] of TPiece;

   TPiecePosition = oxTPoint;

   { TChessMove }

   TChessMove = record
      pFrom,
      pTo: TPiecePosition;
      Source,
      Target: TPiece;
      Action: TMoveAction;

      class procedure Initialize(out m: TChessMove); static;

      {get a description of this move}
      function GetDescription(): StdString;
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
      StartingPlayerSide: TPlayerSide;
      PlayerSides: array[0..1] of TPlayer;

      procedure New();

      {switch the current player to opposing}
      procedure TogglePlayer();

      {add a piece move/eat action to the given position}
      function AddMove(toX, toY: loopint; var context: TMovesBuilderContext): boolean;
      {add moves by line (diagonal, rank or file)}
      procedure AddLineMoves(xmul, ymul: loopint; var context: TMovesBuilderContext);

      {get allowed moves for the pawn on the given coordinates}
      procedure GetPawnMoves(x, y: loopint; var context: TMovesBuilderContext);
      {get allowed moves for the knight on the given coordinates}
      procedure GetKnightMoves(x, y: loopint; var context: TMovesBuilderContext);
      {get allowed moves for the bishop on the given coordinates}
      procedure GetBishopMoves(var context: TMovesBuilderContext);
      {get allowed moves for the rook on the given coordinates}
      procedure GetRookMoves(x, y: loopint; var context: TMovesBuilderContext);

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

      class function GetBoardPosition(const p: oxTPoint): StdString; static;
   end;

CONST
   PLAYER_IDS: array[0..1] of StdString = (
      'black',
      'white'
   );

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

function TChessMove.GetDescription(): StdString;
var
   sourcePlayer,
   targetPlayer: StdString;

begin
   Result := '';

   sourcePlayer := PLAYER_IDS[loopint(Source.Player)];
   targetPlayer := PLAYER_IDS[loopint(Target.Player)];

   if(Action = ACTION_MOVE) then begin
      Result := sourcePlayer + ' ' + PIECE_IDS[loopint(Source.Piece)] + ' from ' + chess.GetBoardPosition(pFrom) +
         ' moves to ' + chess.GetBoardPosition(pTo);
   end else
      Result := sourcePlayer + ' ' + PIECE_IDS[loopint(Source.Piece)] + ' from ' + chess.GetBoardPosition(pFrom) +
         ' eats ' + targetPlayer + ' ' + PIECE_IDS[loopint(Target.Piece)] + ' at ' + chess.GetBoardPosition(pTo);
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

function TPiece.GetPlayerSide(): TPlayerSide;
begin
  if(chess.PlayerSides[loopint(PLAYER_UP)] = Player) then
     Result := PLAYER_UP
  else
     Result := PLAYER_BOTTOM;
end;

{ TChess }

procedure TChess.New();
begin
   CurrentPlayer := StartingPlayer;

   if((StartingPlayerSide = PLAYER_BOTTOM) and (StartingPlayer = PLAYER_WHITE)) or
      (StartingPlayerSide = PLAYER_UP) and (StartingPlayer = PLAYER_BLACK) then begin
     PlayerSides[loopint(PLAYER_UP)] := PLAYER_BLACK;
     PlayerSides[loopint(PLAYER_BOTTOM)] := PLAYER_WHITE;
   end else begin
      PlayerSides[loopint(PLAYER_UP)] := PLAYER_WHITE;
      PlayerSides[loopint(PLAYER_BOTTOM)] := PLAYER_BLACK;
   end;

   ResetBoard();
end;

procedure TChess.TogglePlayer();
begin
   if(CurrentPlayer = PLAYER_BLACK) then
      CurrentPlayer := PLAYER_WHITE
   else
      CurrentPlayer := PLAYER_BLACK;
end;

function TChess.AddMove(toX, toY: loopint; var context: TMovesBuilderContext): boolean;
var
   pieceType: TPieceType;
   move: TChessMove;

begin
   {can't move outside the chess board}
   if(not Valid(toX, toY)) then
      exit(False);

   {can't eat or move into ourselves}
   if(Board[toY, toX].Player = Board[context.y, context.x].Player)
      and(Board[toY, toX].Piece <> PIECE_NONE) then
      exit(false);

   pieceType := Board[context.y, context.x].Piece;

   TChessMove.Initialize(move);

   if(not Occupied(toX, toY)) then
      move.Action := ACTION_MOVE
   else
      move.Action := ACTION_EAT;

   move.Source.Piece := pieceType;
   move.Source.Player := Board[context.y, context.x].Player;
   move.pFrom.x := context.x;
   move.pFrom.y := context.y;

   move.Target.Piece := Board[toY, toX].Piece;
   move.Target.Player := Board[toY, toX].Player;
   move.pTo.x := toX;
   move.pTo.y := toY;

   context.Moves^.Add(move);

   Result := true;
end;

procedure TChess.AddLineMoves(xmul, ymul: loopint; var context: TMovesBuilderContext);
var
   x,
   y,
   i: loopint;

begin
   x := context.x;
   y := context.y;

   for i := 1 to 7 do begin
      AddMove(x + (i * xmul), y + (i * ymul), context);

      {stop when we hit something}
      if(Occupied(x + (i * xmul), y + (i * ymul))) then
         break;
   end;
end;

procedure TChess.GetPawnMoves(x, y: loopint; var context: TMovesBuilderContext);
begin
   if(Board[y, x].GetPlayerSide() = PLAYER_UP) then begin
      if(not Occupied(x, y - 1)) then
         AddMove(x, y - 1, context);

      if(Occupied(x + 1, y - 1)) then
         AddMove(x + 1, y - 1, context);

      if(Occupied(x - 1, y - 1)) then
         AddMove(x - 1, y - 1, context);

      {move by two positions from starting position}
      if(y = 6) then
         AddMove(x, y - 2, context);
   end else begin
      if(not Occupied(x, y + 1)) then
         AddMove(x, y + 1, context);

      if(Occupied(x + 1, y + 1)) then
         AddMove(x + 1, y + 1, context);

      if(Occupied(x - 1, y + 1)) then
         AddMove(x - 1, y + 1, context);

      {move by two positions from starting position}
      if(y = 1) then
         AddMove(x, y + 2, context);
   end;
end;

procedure TChess.GetKnightMoves(x, y: loopint; var context: TMovesBuilderContext);
begin
   AddMove(x + 2, y + 1, context);
   AddMove(x + 2, y - 1, context);
   AddMove(x - 2, y - 1, context);
   AddMove(x - 2, y + 1, context);

   AddMove(x + 1, y + 2, context);
   AddMove(x - 1, y + 2, context);
   AddMove(x + 1, y - 2, context);
   AddMove(x - 1, y - 2, context);
end;

procedure TChess.GetBishopMoves(var context: TMovesBuilderContext);
begin
   AddLineMoves(1,  1, context);
   AddLineMoves(1,  -1, context);
   AddLineMoves(-1, 1, context);
   AddLineMoves(-1, -1, context);
end;

procedure TChess.GetRookMoves(x, y: loopint; var context: TMovesBuilderContext);
begin
   AddLineMoves(1,  0, context);
   AddLineMoves(-1, 0, context);
   AddLineMoves(0,  1, context);
   AddLineMoves(0, -1, context);
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
      GetPawnMoves(x, y, context)
   else if(pieceType = PIECE_KNIGHT) then
      GetKnightMoves(x, y, context)
   else if(pieceType = PIECE_BISHOP) then
      GetBishopMoves(context)
   else if(pieceType = PIECE_ROOK) then
      GetRookMoves(x, y, context);
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
         if(moves.List[i].pTo = target) then begin
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
   source := Board[move.pFrom.y, move.pFrom.x];
   target := Board[move.pTo.y, move.pTo.x];

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
   Board[move.pFrom.y, move.pFrom.x].Piece := PIECE_NONE;

   { TODO: Store eaten pieces }

   {move to target location}
   Board[move.pTo.y, move.pTo.x] := source;

   log.i(move.GetDescription());

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
      playerFirst := PlayerSides[loopint(PLAYER_UP)];
      playerSecond := PlayerSides[loopint(PLAYER_BOTTOM)];
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

class function TChess.GetBoardPosition(const p: oxTPoint): StdString;
const
   horizontal: array[0..7] of char = ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H');

begin
   Result := horizontal[p.x] + 'x' + sf(p.y + 1);
end;

INITIALIZATION
   chess.StartingPlayer := PLAYER_WHITE;
   chess.StartingPlayerSide := PLAYER_BOTTOM;
   chess.CurrentPlayer := chess.StartingPlayer;
   chess.ResetBoard();

END.

