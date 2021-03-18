{
   TODO: Implement check and check mate properly
   TODO: Implement promotion
   TODO: Implement castling
   TODO: Implement en passant
   TODO: Implement proper half move and full move count

   NOTE: Forsyth-Edwards notation is abbreviated as FE notation (FEN) throughout code.
}

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
      ACTION_CAPTURE
   );

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

   {piece characters for FE notation}
   PIECE_CHARACTERS: array[0..PIECE_TYPE_MAX] of char = (
      'x', {should not be used as it's for NONE piece}
      'p',
      'n',
      'b',
      'r',
      'q',
      'k'
   );

   {white piece characters for FE notation}
   PIECE_CHARACTERS_WHITE: array[0..PIECE_TYPE_MAX] of char = (
      'X', {should not be used as it's for NONE piece}
      'P',
      'N',
      'B',
      'R',
      'Q',
      'K'
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

TYPE

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
   TBoardLinear = array[0..63] of TPiece;

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
      x,
      y: loopint;
      Moves: PMovesList;
   end;

   TCapturedPieces = record
      Count: loopint;
      Pieces: array[0..63] of TPieceType;
   end;

   { TChess }

   TChess = record
      Board: TBoard;

      StartingPlayer,
      CurrentPlayer: TPlayer;

      {does the current player have a check}
      Check,
      {have we achieved a check mate}
      CheckMate,
      {sides are inverted}
      InvertSides: boolean;

      {how many moves we made so far}
      MoveCount: loopint;

      {list of moves for the current player}
      Moves: TMovesList;
      {last played moves for each player}
      LastMoves: array[0..1] of TChessMove;

      Captured: array[0..1] of TCapturedPieces;

      procedure New();

      class procedure Initialize(out c: TChess); static;

      {switch the current player to opposing}
      procedure TogglePlayer();
      {set player as current}
      procedure SetPlayer(p: TPlayer);
      {get the opposite player to specified one}
      class function OppositePlayer(p: TPlayer): TPlayer; static;

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
      procedure GetRookMoves(var context: TMovesBuilderContext);
      {get allowed moves for the queen on the given coordinates}
      procedure GetQueenMoves(var context: TMovesBuilderContext);
      {get allowed moves for the king on the given coordinates}
      procedure GetKingMoves(x, y: loopint; var context: TMovesBuilderContext);

      {get allowed moves for the piece on the given coordinates}
      function GetMoves(x, y: loopint): TMovesList;
      {get allowed moves for the piece on the given coordinates}
      procedure GetMoves(x, y: loopint; var where: TMovesList);
      {get all allowed moves for the entire board for a player}
      procedure GetAllMoves(player: TPlayer; var where: TMovesList);
      {get all allowed moves for the entire board for a player}
      function GetAllMoves(player: TPlayer): TMovesList;
      {get all allowed moves for the entire board for the current player}
      procedure GetAllMoves();

      {is the given position occupied on the board}
      function Occupied(x, y: loopint): boolean;
      {is the given position valid on the board}
      function Valid(x, y: loopint): boolean;

      {checks if a move is possible}
      function MovePossible(const from, target: oxTPoint; out move: TChessMove): boolean;
      {plays a move}
      function PlayMove(const move: TChessMove): boolean;
      {plays a move on the specified board}
      function PlayMove(const move: TChessMove; var b: TBoard): boolean;

      function GameOver(): boolean;

      procedure ResetBoard();

      class function HorizontalCoordinate(index: loopint): StdString; static;
      class function GetBoardPosition(const p: oxTPoint): StdString; static;

      {checks if a move is valid in this board current state}
      function IsMoveValid(const move: TChessMove): boolean;

      procedure Copy(var newC: TChess);
      {dispose of all resources}
      procedure Destroy();

      {undo last move}
      procedure Undo();

      {get last move made (by previous player)}
      function GetLastMove(): TChessMove;

      {create board from FE notation (and return if it was succesful)}
      function FromFEN(const fen: StdString): boolean;
      {create FE notation from current board}
      function ToFEN(): StdString;
   end;

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
         ' captures ' + targetPlayer + ' ' + PIECE_IDS[loopint(Target.Piece)] + ' at ' + chess.GetBoardPosition(pTo);
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
var
   upPlayer: boolean;

begin
   upPlayer := Player = PLAYER_BLACK;

   if(chess.InvertSides) then
      upPlayer := not upPlayer;

   if(upPlayer) then
      Result := PLAYER_UP
   else
      Result := PLAYER_BOTTOM;
end;

{ TChess }

procedure TChess.New();
begin
   ResetBoard();
   SetPlayer(StartingPlayer);
end;

class procedure TChess.Initialize(out c: TChess);
begin
   ZeroPtr(@c, SizeOf(TChess));
   TMovesList.InitializeValues(c.Moves, 128);
end;

procedure TChess.TogglePlayer();
begin
   SetPlayer(OppositePlayer(CurrentPlayer));
end;

procedure TChess.SetPlayer(p: TPlayer);
begin
   CurrentPlayer := p;
   GetAllMoves();
end;

class function TChess.OppositePlayer(p: TPlayer): TPlayer;
begin
   if(p = PLAYER_BLACK) then
      Result := PLAYER_WHITE
   else
      Result := PLAYER_BLACK;
end;

function TChess.AddMove(toX, toY: loopint; var context: TMovesBuilderContext): boolean;
var
   move: TChessMove;

begin
   {can't move outside the chess board}
   if(not Valid(toX, toY)) then
      exit(False);

   {can't capture or move into ourselves}
   if(Board[toY, toX].Player = Board[context.y, context.x].Player)
      and(Board[toY, toX].Piece <> PIECE_NONE) then
      exit(false);

   TChessMove.Initialize(move);

   if(not Occupied(toX, toY)) then
      move.Action := ACTION_MOVE
   else
      move.Action := ACTION_CAPTURE;

   move.Source := Board[context.y, context.x];
   move.pFrom.x := context.x;
   move.pFrom.y := context.y;

   move.Target := Board[toY, toX];
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
      if(not Occupied(x, y - 1)) then begin
         AddMove(x, y - 1, context);

         {move by two positions from starting position}
         if(y = 6) and (not Occupied(x, y - 2)) then
            AddMove(x, y - 2, context);
      end;

      if(Occupied(x + 1, y - 1)) then
         AddMove(x + 1, y - 1, context);

      if(Occupied(x - 1, y - 1)) then
         AddMove(x - 1, y - 1, context);
   end else begin
      if(not Occupied(x, y + 1)) then begin
         AddMove(x, y + 1, context);

         {move by two positions from starting position}
         if(y = 1) and (not Occupied(x, y + 2)) then
            AddMove(x, y + 2, context);
      end;

      if(Occupied(x + 1, y + 1)) then
         AddMove(x + 1, y + 1, context);

      if(Occupied(x - 1, y + 1)) then
         AddMove(x - 1, y + 1, context);
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

procedure TChess.GetRookMoves(var context: TMovesBuilderContext);
begin
   AddLineMoves(1,  0, context);
   AddLineMoves(-1, 0, context);
   AddLineMoves(0,  1, context);
   AddLineMoves(0, -1, context);
end;

procedure TChess.GetQueenMoves(var context: TMovesBuilderContext);
begin
   {diagonal}
   AddLineMoves(1,  1, context);
   AddLineMoves(1,  -1, context);
   AddLineMoves(-1, 1, context);
   AddLineMoves(-1, -1, context);

   {rank and file}
   AddLineMoves(1,  0, context);
   AddLineMoves(-1, 0, context);
   AddLineMoves(0,  1, context);
   AddLineMoves(0, -1, context);
end;

procedure TChess.GetKingMoves(x, y: loopint; var context: TMovesBuilderContext);
begin
   // diagonal
   AddMove(x + 1, y + 1, context);
   AddMove(x - 1, y + 1, context);
   AddMove(x + 1, y - 1, context);
   AddMove(x - 1, y - 1, context);

   // rank and file
   AddMove(x + 1, y, context);
   AddMove(x - 1, y, context);
   AddMove(x, y + 1, context);
   AddMove(x, y - 1, context);
end;

function TChess.GetMoves(x, y: loopint): TMovesList;
begin
   TMovesList.Initialize(Result, 128);

   GetMoves(x, y, Result);
end;

procedure TChess.GetMoves(x, y: loopint; var where: TMovesList);
var
   pieceType: TPieceType;
   context: TMovesBuilderContext;

begin
   context.x := x;
   context.y := y;
   context.Moves := @where;

   pieceType := Board[y, x].Piece;

   if(pieceType = PIECE_PAWN) then
      GetPawnMoves(x, y, context)
   else if(pieceType = PIECE_KNIGHT) then
      GetKnightMoves(x, y, context)
   else if(pieceType = PIECE_BISHOP) then
      GetBishopMoves(context)
   else if(pieceType = PIECE_ROOK) then
      GetRookMoves(context)
   else if(pieceType = PIECE_QUEEN) then
      GetQueenMoves(context)
   else if(pieceType = PIECE_KING) then
      GetKingMoves(x, y, context);
end;

procedure TChess.GetAllMoves(player: TPlayer; var where: TMovesList);
var
   x,
   y: loopint;

begin
   {no moves can be had}
   if(GameOver()) then
      exit;

   for y := 0 to 7 do begin
      for x := 0 to 7 do begin
         if(Board[y, x].Player = player) then begin
            {get moves for a specific piece}
            GetMoves(x, y, where);
         end;
      end;
   end;
end;

function TChess.GetAllMoves(player: TPlayer): TMovesList;
begin
   TMovesList.Initialize(Result, 128);
   GetAllMoves(player, Result);
end;

procedure TChess.GetAllMoves();
begin
   Moves.RemoveAll();
   GetAllMoves(CurrentPlayer, Moves);
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
   current: TMovesList;

begin
   Result := false;

   {can't do any moves if game over}
   if(chess.GameOver()) then
      exit(false);

   {get all possible moves for given piece}
   current := GetMoves(from.x, from.y);

   if(current.n > 0) then begin
      for i := 0 to current.n - 1 do begin
         if(current.List[i].pTo = target) then begin
            move := current.List[i];
            exit(true);
         end;
      end;
   end;
end;

function TChess.PlayMove(const move: TChessMove): boolean;
var
   {player}
   p: loopint;

begin
   Result := PlayMove(move, Board);

   LastMoves[loopint(move.Source.Player)] := move;

   if(move.Action = ACTION_CAPTURE) then begin
      p := loopint(move.Source.Player);
      inc(Captured[p].Count);
      Captured[p].Pieces[Captured[p].Count - 1] := move.Target.Piece;

      if(move.Target.Piece = PIECE_KING) then
         CheckMate := true;
   end;

   inc(MoveCount);
end;

function TChess.PlayMove(const move: TChessMove; var b: TBoard): boolean;
var
   source: TPiece;

begin
   source := b[move.pFrom.y, move.pFrom.x];

   if(IsMoveValid(move)) then
      exit;

   { perform move }

   {clear existing piece}
   b[move.pFrom.y, move.pFrom.x].Piece := PIECE_NONE;

   {move to target location}
   b[move.pTo.y, move.pTo.x] := source;

   Result := true;
end;

function TChess.GameOver(): boolean;
begin
   Result := chess.CheckMate;
end;

procedure TChess.ResetBoard();
var
   i,
   j: loopint;
   playerBottom,
   playerUp: TPlayer;

begin
   CheckMate := false;
   Check := false;

   for i := 0 to 7 do begin
      for j := 0 to 7 do begin
         Board[i][j].Clear();
      end;
   end;

   if(not InvertSides) then begin
      playerBottom := PLAYER_WHITE;
      playerUp := PLAYER_BLACK;
   end else begin
      playerBottom := PLAYER_BLACK;
      playerUp := PLAYER_WHITE;
   end;

   {place pawns}
   for j := 0 to 7 do begin
      Board[6][j].Place(PIECE_PAWN, playerUp);
      Board[1][j].Place(PIECE_PAWN, playerBottom);
   end;

   {place other pieces}
   for j := 0 to 7 do begin
      Board[7][7 - j].Place(PIECE_PLACEMENT[7 - j], playerUp);
      Board[0][j].Place(PIECE_PLACEMENT[j], playerBottom);
   end;
end;

class function TChess.HorizontalCoordinate(index: loopint): StdString;
const
   horizontal: array[0..7] of char = ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H');

begin
   Result := horizontal[index];
end;

class function TChess.GetBoardPosition(const p: oxTPoint): StdString;
begin
   Result := HorizontalCoordinate(p.x) + 'x' + sf(p.y + 1);
end;

function TChess.IsMoveValid(const move: TChessMove): boolean;
begin
   Result := true;

   if move.Source.Piece = PIECE_NONE then
      exit(false);

   if move.pFrom = move.pTo then
      exit(false);

   if Valid(move.pFrom.x, move.pFrom.y) then
      exit(false);

   if move.Action = ACTION_CAPTURE then begin
      {can't capture your own pieces}
      if move.Source.Player = move.Target.Player then
         exit(false);

      {can't capture non-existent piece}
      if move.Target.Piece = PIECE_NONE then
         exit(false);
   end;
end;

procedure TChess.Copy(var newC: TChess);
begin
   newC.Board := Board;

   newC.StartingPlayer := StartingPlayer;
   newC.CurrentPlayer := CurrentPlayer;

   {does the current player have a check}
   newC.Check := Check;
   {have we achieved a check mate}
   newC.CheckMate := CheckMate;

   newC.LastMoves := LastMoves;
   newC.Captured := Captured;
end;

procedure TChess.Destroy();
begin
   Moves.Dispose();
end;

procedure TChess.Undo();
var
   move: TChessMove;

begin
   move := GetLastMove();
   CurrentPlayer := move.Source.Player;

   Board[move.pFrom.y, move.pFrom.x] := move.Source;
   Board[move.pTo.y, move.pTo.x] := move.Target;

   {TODO: Also have to undo last moves}

   dec(MoveCount);
end;

function TChess.GetLastMove(): TChessMove;
begin
   Result := LastMoves[loopint(OppositePlayer(CurrentPlayer))];
end;

function TChess.FromFEN(const fen: StdString): boolean;
var
   c: char;
   i,
   index,
   p: loopint;

   linearBoard: TBoardLinear absolute Board;

   {temporary row for swapping }
   tempRow: array[0..7] of TPiece;

begin
   p := 0;
   Result := false;

   { read piece placement }

   for index := 1 to Length(fen) do begin
      c := fen[index];

      if(c = '') then
         break;

      if c in ['1', '2', '3', '4', '5', '6', '7', '8'] then begin
         inc(p, Ord(c) - 48);
      end else begin
         if(c = 'p') then begin
            linearBoard[p].Piece := PIECE_PAWN;
            linearBoard[p].Player := PLAYER_BLACK;
         end else if(c = 'n') then begin
            linearBoard[p].Piece := PIECE_KNIGHT;
            linearBoard[p].Player := PLAYER_BLACK;
         end else if(c = 'b') then begin
            linearBoard[p].Piece := PIECE_BISHOP;
            linearBoard[p].Player := PLAYER_BLACK;
         end else if(c = 'r') then begin
            linearBoard[p].Piece := PIECE_ROOK;
            linearBoard[p].Player := PLAYER_BLACK;
         end else if(c = 'q') then begin
            linearBoard[p].Piece := PIECE_QUEEN;
            linearBoard[p].Player := PLAYER_BLACK;
         end else if(c = 'k') then begin
            linearBoard[p].Piece := PIECE_KING;
            linearBoard[p].Player := PLAYER_BLACK;
         end else if(c = 'P') then begin
            linearBoard[p].Piece := PIECE_PAWN;
            linearBoard[p].Player := PLAYER_BLACK;
         end else if(c = 'N') then begin
            linearBoard[p].Piece := PIECE_KNIGHT;
            linearBoard[p].Player := PLAYER_WHITE;
         end else if(c = 'B') then begin
            linearBoard[p].Piece := PIECE_BISHOP;
            linearBoard[p].Player := PLAYER_WHITE;
         end else if(c = 'R') then begin
            linearBoard[p].Piece := PIECE_ROOK;
            linearBoard[p].Player := PLAYER_WHITE;
         end else if(c = 'Q') then begin
            linearBoard[p].Piece := PIECE_QUEEN;
            linearBoard[p].Player := PLAYER_WHITE;
         end else if(c = 'K') then begin
            linearBoard[p].Piece := PIECE_KING;
            linearBoard[p].Player := PLAYER_WHITE;
         end else begin
            exit(false);
         end;

         inc(p);
      end;
   end;

   {move from row placement}
   inc(index);

   { swap rows, since we read rank 1 to 8 for simplicity and memory layout, but FEN is rank 8 to 1 }

   for i := 0 to 3 do begin
      tempRow := Board[7 - i];
      Board[7 - i] := Board[i];
      Board[i] := tempRow;
   end;

   { read starting position }

   if(fen[index] = 'b') then
      CurrentPlayer := PLAYER_BLACK
   else if(fen[index] = 'w') then
      CurrentPlayer := PLAYER_WHITE
   else
      exit(False);

   { TODO: Read castling availability }
   { TODO: Read en passant target square }
   { TODO: Read halfmove clock }
   { TODO: Read fullmove clock }

   Result := true;
end;

function TChess.ToFEN(): StdString;
var
   fen: shortstring;
   i,
   j,
   emptyCount: loopint;

begin
   fen := '';

   { build piece positions }

   for i := 0 to 7 do begin
      emptyCount := 0;

      for j := 0 to 7 do begin
         if(Board[i][j].Piece = PIECE_NONE) then
            inc(emptyCount)
         else begin
            if(emptyCount > 0) then begin
               fen := fen + sf(emptyCount);
               emptyCount := 0;
            end;

            if(Board[i][j].Player = PLAYER_BLACK) then
               fen := fen + PIECE_CHARACTERS[loopint(Board[i][j].Piece)]
            else
               fen := fen + PIECE_CHARACTERS_WHITE[loopint(Board[i][j].Piece)];
         end;
      end;

      if(emptyCount > 0) then
         fen := fen + sf(emptyCount);

      if(i < 7) then
         fen := fen + '/';
   end;

   { player to move }

   if(CurrentPlayer = PLAYER_BLACK) then
      fen := fen + ' b '
   else
      fen := fen + ' w ';

   { TODO: castling availability }
   fen := fen + ' KQkq ';

   { TODO: en passant target square }

   fen := fen + ' - ';

   { TODO: halfmove clock }

   fen := fen + sf(MoveCount);

   { TODO: fullmove clock }

   fen := fen + sf(MoveCount div 2 + 1);

   Result := fen;
end;

INITIALIZATION
   TChess.Initialize(chess);

   chess.StartingPlayer := PLAYER_WHITE;
   chess.CurrentPlayer := chess.StartingPlayer;
   chess.ResetBoard();

   {get a new seed}
   Randomize();

END.

