{
   A simple chess AI
   Built from example of https://www.freecodecamp.org/news/simple-chess-ai-step-by-step-1d55a9266977/
}

{$INCLUDE oxdefines.inc}
UNIT uSimpleAI;

INTERFACE

   USES
      uStd, uLog, StringUtils,
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
      SearchDepth,
      {number of searched positions to find a move}
      SearchedPositionCount: loopint;

      constructor Create();

      procedure Reset(); virtual;
      procedure PlayMove(); virtual;

      function GetPieceValue(currentPlayer: TPlayer; const piece: TPiece): loopint;
      function GetPieceValue(piece: TPieceType): loopint;

      function GetBestMove(): TChessMove;
      function EvaluateBoard(currentPlayer: TPlayer; const board: TBoard): loopint;

      function MinMaxRoot(): TChessMove;
      function MinMax(depth: loopint; var b: TBoard; isMaximising: boolean): loopint;
   end;

VAR
   SimpleAI: TSimpleAI;

IMPLEMENTATION

{ TSimpleAI }

constructor TSimpleAI.Create();
begin
   Name := 'Simple';
   SearchDepth := 4;
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

function TSimpleAI.GetPieceValue(currentPlayer: TPlayer; const piece: TPiece): loopint;
begin
   if(piece.Player <> currentPlayer) then
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
begin
   Result := MinMaxRoot();
end;

function TSimpleAI.EvaluateBoard(currentPlayer: TPlayer; const board: TBoard): loopint;
var
   i,
   j: loopint;

begin
   Result := 0;

   for i := 0 to 7 do begin
      for j := 0 to 7 do begin
         inc(Result, GetPieceValue(currentPlayer, board[i, j]));
      end;
   end;
end;

function TSimpleAI.MinMaxRoot(): TChessMove;
var
   i,
   currentEvaluation,
   bestEvaluation: loopint;
   testBoard: TBoard;

begin
   bestEvaluation := -99999;
   SearchedPositionCount := 0;
   Result := chess.Moves.List[0];

   for i := 0 to chess.Moves.n - 1 do begin
      testBoard := chess.Board;
      chess.PlayMove(chess.Moves.List[i], testBoard);

      currentEvaluation := MinMax(SearchDepth - 1, testBoard, true);

      if(currentEvaluation > bestEvaluation) then begin
         bestEvaluation := currentEvaluation;
         Result := chess.Moves.List[i];
      end;
   end;

   log.i('Searched: ' + sf(SearchedPositionCount));
end;

function TSimpleAI.MinMax(depth: loopint; var b: TBoard; isMaximising: boolean): loopint;
var
   i,
   currentEvaluation,
   bestEvaluation: loopint;

   c: TChess;

begin
   inc(SearchedPositionCount);

   if(depth = 0) then
      exit(-EvaluateBoard(chess.CurrentPlayer, b));

   chess.Copy(c);
   c.Board := b;
   c.GetAllMoves();

   if(isMaximising) then begin
      bestEvaluation := -99999;

      for i := 0 to c.Moves.n - 1 do begin
         c.PlayMove(c.Moves.List[i]);
         currentEvaluation := MinMax(depth - 1, c.Board, false);

         if(currentEvaluation > bestEvaluation) then
            bestEvaluation := currentEvaluation;

         c.Board := b;
      end;
   end else begin
      bestEvaluation := 99999;

      for i := 0 to c.Moves.n - 1 do begin
         c.PlayMove(c.Moves.List[i]);
         currentEvaluation := MinMax(depth - 1, c.Board, true);

         if(currentEvaluation < bestEvaluation) then
            bestEvaluation := currentEvaluation;

         c.Board := b;
      end;
   end;

   c.Destroy();
   Result := bestEvaluation;
end;

INITIALIZATION
   SimpleAI.Create();
   CurrentAI := @SimpleAI;

END.
