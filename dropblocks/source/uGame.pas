{$INCLUDE oxdefines.inc}
UNIT uGame;

INTERFACE

   USES
      uStd, uLog,
      {ox}
      oxuTypes, oxuTimer, oxuEntity,
      {nase}
      uBase;

TYPE
   TGridFlag = (
      GRID_ELEMENT_SOLID,
      GRID_ELEMENT_SHAPE,
      GRID_ELEMENT_DIRTY
   );

   TGridFlags = set of TGridFlag;

   PGridElement = ^TGridElement;

   { TGridElement }

   TGridElement = record
      Flags: TGridFlags;
      Shape: loopint;
      Entity: oxTEntity;

      function IsSolid(): boolean;
      function IsShape(): boolean;
      function IsEmpty(): boolean;
      function IsDirty(): boolean;
   end;


   TGridArea = array[0..GRID_HEIGHT - 1, 0..GRID_WIDTH - 1] of TGridElement;

   { TGrid }

   TGrid = record
      Area: TGridArea;

      {is the grid dirty}
      Dirty: boolean;

      procedure New();

      procedure SetPoint(x, y: loopint; what: TGridFlags);
      procedure MarkDirty(x, y: loopint);
      procedure MarkSolid(x, y: loopint);
      function GetPoint(x, y: loopint): PGridElement;
      function ValidPoint(x, y: loopint): boolean;
   end;

   { TGame }

   TGame = record
      OnNew,
      {called before the current shape is moved/rotated}
      OnBeforeMove,
      {called after current shape is moved/rotated}
      OnMove: TProcedures;

      Grid: TGrid;
      {index into the current shape}
      CurrentBlock,
      {current rotation of the shape}
      CurrentRotation: loopint;
      {current block position}
      BlockPosition: oxTPoint;

      LastUpdate: single;

      CurrentLevel: loopint;

      function GetSpeed(): single;

      {get a random block}
      function RandomizeBlock(): loopint;
      {get next block}
      procedure GetNextBlock();

      {get block empty vertical space for all of its configurations}
      function GetBlockVerticalOffset(): loopint;

      {get currently active shape}
      function GetShape(): PShapeConfigurations;
      function GetShapeGrid(): PShapeGrid;
      function GetShapeGrid(rotation: loopint): PShapeGrid;

      procedure MoveShapeLeft();
      procedure MoveShapeRight();
      procedure DropShape();
      procedure RotateLeft();
      procedure RotateRight();
      procedure MoveShapeDown();

      procedure SetShapePosition(x, y: loopint);
      procedure SetRotation(rotation: loopint);

      {checks if a shape can fit at the position and rotation}
      function CanFitShape(x, y, rotation: loopint): boolean;

      procedure Update(dT: single);

      procedure New();
   end;

VAR
   game: TGame;

IMPLEMENTATION

{ TGridElement }

function TGridElement.IsSolid(): boolean;
begin
   Result := GRID_ELEMENT_SOLID in Flags;
end;

function TGridElement.IsShape(): boolean;
begin
   Result := GRID_ELEMENT_SHAPE in Flags;
end;

function TGridElement.IsEmpty(): boolean;
begin
   Result := not ((GRID_ELEMENT_SOLID in Flags) or (GRID_ELEMENT_SHAPE in Flags));
end;

function TGridElement.IsDirty(): boolean;
begin
   Result := GRID_ELEMENT_DIRTY in Flags;
end;

{ TGrid }

procedure TGrid.New();
var
   i,
   j: loopint;

begin
   for i := 0 to GRID_HEIGHT - 1 do begin
      for j := 0 to GRID_WIDTH - 1 do begin
         Area[i][j].Flags := [GRID_ELEMENT_DIRTY];
      end;
   end;

   Dirty := true;
end;

procedure TGrid.SetPoint(x, y: loopint; what: TGridFlags);
begin
   Area[y][x].Flags := Area[y][x].Flags + what;
   Dirty := true;
end;

procedure TGrid.MarkDirty(x, y: loopint);
begin
   SetPoint(x, y, [GRID_ELEMENT_DIRTY]);
end;

procedure TGrid.MarkSolid(x, y: loopint);
begin
   SetPoint(x, y, [GRID_ELEMENT_SOLID]);
end;

function TGrid.GetPoint(x, y: loopint): PGridElement;
begin
   if(ValidPoint(x, y)) then
      Result := @Area[y][x]
   else
      Result := nil;
end;

function TGrid.ValidPoint(x, y: loopint): boolean;
begin
   Result := (x >= 0) and (y >= 0) and (x < GRID_WIDTH) and (y < GRID_HEIGHT);
end;

{ TGame }

function TGame.GetSpeed(): single;
begin
   Result := GameSpeeds[CurrentLevel];
end;

function TGame.RandomizeBlock(): loopint;
begin
   Result := Random(MAX_SHAPES);
end;

procedure TGame.GetNextBlock();
begin
   OnBeforeMove.Call();

   CurrentBlock := RandomizeBlock();

   BlockPosition.x := BLOCK_START_POSITION_X;
   BlockPosition.y := BLOCK_START_POSITION_Y;

   OnMove.Call();
end;

function TGame.GetBlockVerticalOffset(): loopint;
begin
   Result := Shapes.Shapes[CurrentBlock]^.GetBlockVerticalOffset();
end;

function TGame.GetShape(): PShapeConfigurations;
begin
   Result := Shapes.Shapes[CurrentBlock];
end;

function TGame.GetShapeGrid(): PShapeGrid;
begin
   Result := @Shapes.Shapes[CurrentBlock]^[CurrentRotation];
end;

function TGame.GetShapeGrid(rotation: loopint): PShapeGrid;
begin
   Result := @Shapes.Shapes[CurrentBlock]^[rotation];
end;

procedure TGame.MoveShapeLeft();
begin
   if CanFitShape(BlockPosition.x - 1, BlockPosition.y, CurrentRotation) then
      SetShapePosition(BlockPosition.x - 1, BlockPosition.y);
end;

procedure TGame.MoveShapeRight();
begin
   if CanFitShape(BlockPosition.x + 1, BlockPosition.y, CurrentRotation) then
      SetShapePosition(BlockPosition.x + 1, BlockPosition.y);
end;

procedure TGame.DropShape();
var
   y: loopint;

begin
   y := BlockPosition.y;

   repeat
     dec(y);

   until (not CanFitShape(BlockPosition.x, y, CurrentRotation));

   inc(y);

   if(y <> BlockPosition.y) then
      SetShapePosition(BlockPosition.x, y);
end;

procedure TGame.RotateLeft();
var
   rotation: loopint;

begin
   rotation := CurrentRotation;
   dec(rotation);

   if(rotation < 0) then
      rotation := 3;

   if CanFitShape(BlockPosition.x + 1, BlockPosition.y, rotation) then
      SetRotation(rotation);
end;

procedure TGame.RotateRight();
var
   rotation: loopint;

begin
   rotation := CurrentRotation;
   inc(rotation);

   if(rotation > 3) then
      rotation := 0;

   if CanFitShape(BlockPosition.x + 1, BlockPosition.y, rotation) then
      SetRotation(rotation);
end;

procedure TGame.MoveShapeDown();
begin
   if(BlockPosition.y > 0) then begin
      if CanFitShape(BlockPosition.x, BlockPosition.y - 1, CurrentRotation) then
         SetShapePosition(BlockPosition.x, BlockPosition.y - 1);
   end;
end;

procedure TGame.SetShapePosition(x, y: loopint);
begin
   OnBeforeMove.Call();

   BlockPosition.x := x;
   BlockPosition.y := y;

   OnMove.Call();
end;

procedure TGame.SetRotation(rotation: loopint);
begin
   OnBeforeMove.Call();

   CurrentRotation := rotation;

   OnMove.Call();
end;

function TGame.CanFitShape(x, y, rotation: loopint): boolean;
var
   i,
   j,
   px,
   py: loopint;
   shapeGrid: PShapeGrid;
   element: PGridElement;

begin
   Result := true;
   shapeGrid := GetShapeGrid(rotation);

   for i := 0 to 3 do begin
      for j := 0 to 3 do begin
         py := y + i;
         px := x + j;

         {empty element, we do not check it}
         if(shapeGrid^.GetValue(j, i) = 0) then
            continue;

         {we're going out of bounds, we cannot fit}
         if(py < 0) or (px < 0) or (px >= GRID_WIDTH) then
            exit(false);

         {out of bounds on top, but this is allowed since the pieces come from top}
         if(py >= GRID_HEIGHT) then
            continue;

         element := game.Grid.GetPoint(px, py);

         {element blocks, cannot fit shape}
         if(element^.IsSolid()) then
            exit(false);
      end;
   end;
end;

procedure TGame.Update(dT: single);
begin
   LastUpdate := LastUpdate + dT;

   if(LastUpdate > GetSpeed()) then begin
      LastUpdate := LastUpdate - GetSpeed();

      MoveShapeDown();
   end;
end;

procedure TGame.New();
begin
   LastUpdate := 0;
   oxTime.Resume();
   game.Grid.New();
   GetNextBlock();

   OnNew.Call();
end;

INITIALIZATION
   game.OnNew.Initialize(game.OnNew);
   game.OnBeforeMove.Initialize(game.OnBeforeMove);
   game.OnMove.Initialize(game.OnMove);

END.
