{
   A simple chess AI
   Built from example of https://www.freecodecamp.org/news/simple-chess-ai-step-by-step-1d55a9266977/
}

{$INCLUDE oxdefines.inc}
UNIT uSimpleAI;

INTERFACE

   USES
      uStd, uLog,
      {game}
      uAI, uChess, uGame;

CONST
   PIECE_VALUES: array[0..6] of loopint = (
      0,
      10, {pawn}
      30, {knight}
      30, {bishop}
      50, {rook}
      90, {queen}
      900 {king}
   );


TYPE
   { TSimpleAI }

   TSimpleAI = object(TAI)
      constructor Create();

      procedure Reset(); virtual;
      procedure PlayMove(); virtual;

      function GetPieceValue(const piece: TPiece): loopint;
      function GetPieceValue(piece: TPieceType): loopint;

      function GetBestMove(): TChessMove;
      function EvaluateBoard(const board: TBoard): loopint;
   end;

VAR
   SimpleAI: TSimpleAI;

IMPLEMENTATION

{ TSimpleAI }

constructor TSimpleAI.Create();
begin
   Name := 'Simple';
end;

procedure TSimpleAI.Reset();
begin

end;

procedure TSimpleAI.PlayMove();
var
   move: TChessMove;

begin
   if(chess.Moves.n > 0) then begin
      move := GetBestMove();
      game.PlayMove(move);
   end else
      log.w('Simple AI can''t play any more moves');
end;

function TSimpleAI.GetPieceValue(const piece: TPiece): loopint;
begin
   if(piece.Player <> chess.CurrentPlayer) then
      Result := GetPieceValue(piece.Piece)
   else
      {our piece has a negative value}
      Result := -GetPieceValue(piece.Piece);
end;

function TSimpleAI.GetPieceValue(piece: TPieceType): loopint;
begin
   Result := PIECE_VALUES[loopint(piece)];
end;

function TSimpleAI.GetBestMove(): TChessMove;
var
   i,
   bestEvaluation,
   currentEvalutation,
   bestMoveIndex: loopint;

   testBoard: TBoard;

begin
   Result := chess.Moves.List[Random(chess.Moves.n)];

   bestEvaluation := -99999;
   bestMoveIndex := 0;

   for i := 0 to chess.Moves.n - 1 do begin
      testBoard := chess.Board;

      chess.PlayMove(chess.Moves.List[i], testBoard);
      currentEvalutation := -EvaluateBoard(testBoard);

      if(currentEvalutation > bestEvaluation) then begin
         bestEvaluation := currentEvalutation;
         bestMoveIndex := i;
      end;
   end;

   Result := chess.Moves[bestMoveIndex];
end;

function TSimpleAI.EvaluateBoard(const board: TBoard): loopint;
var
   i,
   j: loopint;

begin
   Result := 0;

   for i := 0 to 7 do begin
      for j := 0 to 7 do begin
         inc(Result, GetPieceValue(board[i, j]));
      end;
   end;
end;

INITIALIZATION
   SimpleAI.Create();
   CurrentAI := @SimpleAI;

END.
