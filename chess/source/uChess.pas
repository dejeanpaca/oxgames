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

   TPiece = record
      {type of piece}
      Piece: TPieceType;
      {what player the piece belongs to}
      Player: TPlayer;
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

      {get allowed moves for the piece on the given coordinates}
      function GetMoves(x, y: loopint): TMovesList;
      {get all allowed moves for the entire board for a player}
      function GetAllMoves(player: TPlayer): TMovesList;
   end;

VAR
   chess: TChess;

IMPLEMENTATION

{ TChess }

function TChess.GetMoves(x, y: loopint): TMovesList;
begin
   TMovesList.Initialize(Result);
end;

function TChess.GetAllMoves(player: TPlayer): TMovesList;
begin

end;

END.
