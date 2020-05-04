{$INCLUDE oxdefines.inc}
UNIT uChess;

INTERFACE

   USES
      uStd;

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

   TPiecePosition = record
      x,
      y: loopint;
   end;

   { TMove }

   TMove = record
      From,
      Target: TPiecePosition;
      Piece: TPieceType;
      Player: TPlayer;
      Action: TMoveAction;

      class procedure Initialize(out m: TMove); static;
   end;

   PMovesList = ^TMovesList;
   TMovesList = specialize TSimpleList<TMove>;

   TMovesBuilderContext = record
      x, y: loopint;
      Moves: PMovesList;
   end;

   { TChess }

   TChess = record
      Board: TBoard;
      StartingPlayer,
      CurrentPlayer: TPlayer;

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

{ TMove }

class procedure TMove.Initialize(out m: TMove);
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

procedure TChess.AddMove(toX, toY: loopint; var context: TMovesBuilderContext);
var
   pieceType: TPieceType;
   move: TMove;

begin
   {can't move outside the chess board}
   if(not Valid(toX, toY)) then
      exit;

   pieceType := Board[context.y, context.x].Piece;

   TMove.Initialize(move);

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
   chess.ResetBoard();

END.
