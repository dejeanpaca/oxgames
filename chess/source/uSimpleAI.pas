{
   A simple chess AI
   Built from example of https://www.freecodecamp.org/news/simple-chess-ai-step-by-step-1d55a9266977/
}

{$INCLUDE oxdefines.inc}
UNIT uSimpleAI;

INTERFACE

   USES
      sysutils,
      uStd, uLog, StringUtils, uTiming,
      {game}
      uAI, uChess, uGame, uSimpleAIEvaluation;

TYPE
   { TSimpleAI }

   TSimpleAI = object(TAI)
      SearchDepth,
      {number of searched positions to find a move}
      SearchedPositionCount: loopint;

      constructor Create();

      procedure OnComputeMove(); virtual;
      procedure OnPlayMove(); virtual;

      function GetPieceValue(p: TPlayer; const piece: TPiece; x, y: loopint): loopint;

      function GetBestMove(): TChessMove;
      function EvaluateBoard(p: TPlayer; const board: TBoard): loopint;

      function MinMaxRoot(): TChessMove;
      function MinMax(depth, alpha, beta: loopint; var b: TChess): loopint;
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

procedure TSimpleAI.OnComputeMove();
begin
   Move := GetBestMove();
   ComputedMove := true;
end;

procedure TSimpleAI.OnPlayMove();
begin
   game.PlayMove(Move);
end;

function TSimpleAI.GetPieceValue(p: TPlayer; const piece: TPiece; x, y: loopint): loopint;
var
   value: loopint;

begin
   value := PIECE_VALUES[loopint(piece.Piece)] + GetBoardEval(piece, p, x, y, chess.InvertSides);

   if(piece.Player <> p) then
      Result := value
   else
      {our piece has a negative value}
      Result := -value;
end;

function TSimpleAI.GetBestMove(): TChessMove;
begin
   Result := MinMaxRoot();
end;

function TSimpleAI.EvaluateBoard(p: TPlayer; const board: TBoard): loopint;
var
   i,
   j: loopint;

begin
   Result := 0;

   for i := 0 to 7 do begin
      for j := 0 to 7 do begin
         inc(Result, GetPieceValue(p, board[i, j], i, j));
      end;
   end;
end;

function TSimpleAI.MinMaxRoot(): TChessMove;
var
   i,
   currentEvaluation,
   bestEvaluation: loopint;
   start: TDateTime;
   c: TChess;

begin
   start := Now();

   bestEvaluation := -99999;
   SearchedPositionCount := 0;
   Result := chess.Moves.List[0];

   chess.Copy(c);

   for i := 0 to chess.Moves.n - 1 do begin
      c.PlayMove(chess.Moves.List[i]);

      currentEvaluation := MinMax(SearchDepth - 1, -100000, 100000, c);

      if(currentEvaluation > bestEvaluation) then begin
         bestEvaluation := currentEvaluation;
         Result := chess.Moves.List[i];
      end;

      c.Board := chess.Board;
   end;

   log.i('Searched: ' + sf(SearchedPositionCount) + ', Elapsed: ' + start.ElapsedfToString(4) + 's');
end;

function TSimpleAI.MinMax(depth, alpha, beta: loopint; var b: TChess): loopint;
var
   i,
   currentEvaluation,
   bestEvaluation: loopint;

   c: TChess;

begin
   inc(SearchedPositionCount);

   if(depth = 0) then
      exit(EvaluateBoard(b.CurrentPlayer, b.Board));

   b.Copy(c);
   c.TogglePlayer();
   c.GetAllMoves();

   if(c.CurrentPlayer = chess.CurrentPlayer) then begin
      bestEvaluation := -99999;

      for i := 0 to c.Moves.n - 1 do begin
         c.PlayMove(c.Moves.List[i]);
         currentEvaluation := MinMax(depth - 1, alpha, beta, c);

         if(currentEvaluation > bestEvaluation) then
            bestEvaluation := currentEvaluation;

         if(bestEvaluation > alpha) then
            alpha := bestEvaluation;

         if(beta <= alpha) then begin
            c.Destroy();
            exit(bestEvaluation);
         end;

         c.Board := b.Board;
      end;
   end else begin
      bestEvaluation := 99999;

      for i := 0 to c.Moves.n - 1 do begin
         c.PlayMove(c.Moves.List[i]);
         currentEvaluation := MinMax(depth - 1, alpha, beta, c);

         if(currentEvaluation < bestEvaluation) then
            bestEvaluation := currentEvaluation;

         if(bestEvaluation < beta) then
            beta := bestEvaluation;

         if(beta <= alpha) then begin
            c.Destroy();
            exit(bestEvaluation);
         end;

         c.Board := b.Board;
      end;
   end;

   c.Destroy();
   Result := bestEvaluation;
end;

INITIALIZATION
   SimpleAI.Create();
   CurrentAI := @SimpleAI;

END.
