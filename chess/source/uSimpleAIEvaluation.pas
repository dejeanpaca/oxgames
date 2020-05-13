{
   Simple chess AI evaluation data

   NOTE: PIECE_VALUES values differ than freecodecamp example, as we use integer values,
   and piece board evaluation was also multiplied by two to be rounded to integer value.
}

{$INCLUDE oxdefines.inc}
UNIT uSimpleAIEvaluation;

INTERFACE

   USES
      uStd, uChess;

TYPE
   TBoardEvaluation = array[0..7, 0..7] of loopint;

CONST
   PIECE_VALUES: array[0..6] of loopint = (
      0,
      20, {pawn}
      60, {knight}
      60, {bishop}
      100, {rook}
      180, {queen}
      1800 {king}
   );

   PawnBoardEvaluation: TBoardEvaluation = (
      ( 0,  0,  0,  2,  2,  0,  0,  0),
      ( 2,  2,  2, -4, -4,  2,  2,  2),
      ( 2, -2, -2,  0,  0, -2, -2,  2),
      ( 0,  0,  0,  4,  4,  0,  0,  0),
      ( 3,  2,  2,  5,  5,  2,  2,  2),
      ( 2,  2,  4,  6,  6,  4,  2,  2),
      (10, 10, 10, 10, 10, 10, 10, 10),
      {TODO: Promotion may affect this top one}
      ( 0,  0,  0,  0,  0,  0,  0,  0)
   );

   KnightBoardEvaluation: TBoardEvaluation = (
      (-10, -8, -6, -6, -6, -6, -8,-10),
      ( -8, -4,  0,  2,  2,  0, -4, -8),
      ( -6,  2,  2,  3,  3,  2,  0, -6),
      ( -7,  0,  3,  4,  4,  3,  2, -7),
      ( -7,  2,  3,  4,  4,  3,  0, -7),
      ( -7,  0,  2,  3,  3,  2,  2, -7),
      ( -8, -4,  0,  0,  0,  0, -4, -8),
      (-10, -8, -6, -6, -6, -6, -8,-10)
   );

   BishopBoardEvaluation: TBoardEvaluation = (
      (-4, -2, -2, -2, -2, -2, -2, -4),
      (-2,  2,  0,  0,  0,  0,  2, -2),
      (-2,  2,  2,  2,  2,  2,  2, -2),
      (-2,  0,  2,  2,  2,  2,  0, -2),
      (-2,  2,  2,  2,  2,  2,  2, -2),
      (-2,  0,  2,  2,  2,  2,  0, -2),
      (-2,  0,  0,  0,  0,  0,  0, -2),
      (-4, -2, -2, -2, -2, -2, -2, -4)
   );

   RookBoardEvaluation: TBoardEvaluation = (
      ( 0,  0,  0,  2,  2,  0,  0,  0),
      (-2,  0,  0,  0,  0,  0,  0, -2),
      (-2,  0,  0,  0,  0,  0,  0, -2),
      (-2,  0,  0,  0,  0,  0,  0, -2),
      (-2,  0,  0,  0,  0,  0,  0, -2),
      (-2,  0,  0,  0,  0,  0,  0, -2),
      ( 2,  2,  2,  2,  2,  2,  2,  2),
      ( 0,  0,  0,  0,  0,  0,  0,  0)
   );

   QueenBoardEvaluation: TBoardEvaluation = (
      (-4, -2, -2, -2, -2, -2, -2, -4),
      (-2,  0,  2,  0,  0,  0,  0, -2),
      (-2,  2,  2,  2,  2,  2,  2, -2),
      ( 0,  0,  2,  2,  2,  2,  0, -2),
      (-2,  0,  2,  2,  2,  2,  0, -2),
      (-2,  0,  2,  2,  2,  2,  0, -2),
      (-2,  0,  0,  0,  0,  0,  0, -2),
      (-4, -2, -2, -2, -2, -2, -2, -4)
   );

   KingBoardEvaluation: TBoardEvaluation = (
      ( 4,  6,  2,  0,  0,  2,  6,  4),
      ( 4,  4,  0,  0,  0,  0,  4,  4),
      (-2, -4, -4, -4, -4, -4, -4, -2),
      (-4, -6, -6, -8, -8, -6, -6, -4),
      (-6, -8, -8,-10,-10, -8, -8, -6),
      (-6, -8, -8,-10,-10, -8, -8, -6),
      (-6, -8, -8,-10,-10, -8, -8, -6),
      (-6, -8, -8,-10,-10, -8, -8, -6)
   );

function GetBoardEval(const piece: TPiece; p: TPlayer; x, y: loopint; opposite: boolean): loopint;

IMPLEMENTATION

function GetBoardEval(const piece: TPiece; p: TPlayer; x, y: loopint; opposite: boolean): loopint;
begin
   Result := 0;

   {flip board vertical for black player}
   if(p = PLAYER_BLACK) then
      y := 7 - y;

   {flip again if players are on opposite sides (black is down instead of up)}
   if(opposite) then
      y := 7 - y;

   if(piece.Piece = PIECE_PAWN) then
      Result := PawnBoardEvaluation[y, x]
   else if(piece.Piece = PIECE_KNIGHT) then
      Result := KnightBoardEvaluation[y, x]
   else if(piece.Piece = PIECE_BISHOP) then
      Result := BishopBoardEvaluation[y, x]
   else if(piece.Piece = PIECE_ROOK) then
      Result := RookBoardEvaluation[y, x]
   else if(piece.Piece = PIECE_QUEEN) then
      Result := QueenBoardEvaluation[y, x]
   else if(piece.Piece = PIECE_KING) then
      Result := KingBoardEvaluation[y, x];
end;

END.
