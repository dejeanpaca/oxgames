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

   TMove = record
      From,
      Target: TPiecePosition;
      Piece: TPieceType;
      Action: TMoveAction;
   end;

   TMovesList = specialize TSimpleList<TMove>;

   { TChess }

   TChess = record
      Board: TBoard;
      StartingPlayer: TPlayer;

      {get allowed moves for the piece on the given coordinates}
      function GetMoves(x, y: loopint): TMovesList;
      {get all allowed moves for the entire board for a player}
      function GetAllMoves(player: TPlayer): TMovesList;

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

function TChess.GetMoves(x, y: loopint): TMovesList;
begin
   TMovesList.Initialize(Result);
end;

function TChess.GetAllMoves(player: TPlayer): TMovesList;
begin
   TMovesList.Initialize(Result);
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
