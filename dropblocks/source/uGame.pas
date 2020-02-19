{$INCLUDE oxdefines.inc}
UNIT uGame;

INTERFACE

   USES
      uStd, uLog,
      {ox}
      oxuTypes, oxuTimer, oxuEntity,
      oxuPrimitiveModelComponent, oxuMaterial,
      {nase}
      uBase;

TYPE
   TGridFlag = (
      GRID_ELEMENT_SOLID,
      GRID_ELEMENT_SHAPE
   );

   TGridFlags = set of TGridFlag;

   PGridElement = ^TGridElement;

   { TGridElement }

   TGridElement = record
      Flags: TGridFlags;
      Shape: loopint;
      Entity: oxTEntity;
      Mesh: oxTPrimitiveModelComponent;

      function IsSolid(): boolean;
      function IsShape(): boolean;
      function IsEmpty(): boolean;
   end;

   TGridArea = array[0..GRID_HEIGHT - 1, 0..GRID_WIDTH - 1] of TGridElement;

   { TGrid }

   TGrid = record
      Area: TGridArea;

      procedure New();

      procedure SetPoint(x, y: loopint; what: TGridFlags);
      function GetPoint(x, y: loopint): PGridElement;
      function ValidPoint(x, y: loopint): boolean;
   end;

   {method which goes through current shape points in the grid}
   TGridShapeWalker = procedure(x, y: loopint; element: PGridElement);

   TGameState = (
      GAME_BLOCK_DROPPING,
      GAME_LR
   );

   { TGame }

   TGame = record
      State: TGameState;

      OnNew,
      {called before the current shape is moved/rotated}
      OnBeforeMove,
      {called after current shape is moved/rotated}
      OnMove,
      OnLock,
      OnStateChange,
      OnUpdate: TProcedures;

      Grid: TGrid;
      {index into the current shape}
      CurrentShape,
      {current rotation of the shape}
      CurrentRotation: loopint;
      {current shape position}
      ShapePosition: oxTPoint;

      LastUpdate,
      ShapeLockTime: single;

      CurrentLevel: loopint;

      LineRemoval: record
         {start and end line}
         s,
         e: loopint;

         {elapsed animation time}
         Elapsed: single;
      end;

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
      procedure MoveShapeDown();
      procedure DropShape();
      procedure RotateLeft();
      procedure RotateRight();

      function FindShapeLowestPosition(): loopint;

      procedure LockShape();

      procedure SetShapePosition(x, y: loopint);
      procedure SetRotation(rotation: loopint);

      {checks if a shape can fit at the position and rotation}
      function CanFitShape(x, y, rotation: loopint): boolean;
      {checks if the specified line is full}
      function IsLineFull(y: loopint): boolean;

      procedure Update(dT: single);

      procedure New();

      procedure WalkShape(walker: TGridShapeWalker);
      procedure WalkShape(atX, atY: loopint; walker: TGridShapeWalker);

      procedure SetState(newState: TGameState);
   end;

VAR
   game: TGame;

procedure SetMaterial(var element: TGridElement; material: oxTMaterial = nil);
procedure ClearMaterial(var element: TGridElement);

IMPLEMENTATION

procedure SetMaterial(var element: TGridElement; material: oxTMaterial = nil);
begin
   if(element.Mesh <> nil) then begin
      if(material <> nil) then begin
         element.Mesh.Model.SetMaterial(material);
         element.Entity.SetEnabled(true);
      end else
         element.Entity.SetEnabled(false);
   end;
end;

procedure ClearMaterial(var element: TGridElement);
begin
   SetMaterial(element);
end;


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

{ TGrid }

procedure TGrid.New();
var
   i,
   j: loopint;

begin
   for i := 0 to GRID_WIDTH - 1 do begin
      for j := 0 to GRID_HEIGHT - 1 do begin
         Area[j][i].Flags := [];
         Area[j][i].Shape := -1;

         ClearMaterial(Area[j][i]);
      end;
   end;
end;

procedure TGrid.SetPoint(x, y: loopint; what: TGridFlags);
begin
   Area[y][x].Flags := Area[y][x].Flags + what;
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

   CurrentShape := RandomizeBlock();

   ShapePosition.x := BLOCK_START_POSITION_X;
   ShapePosition.y := BLOCK_START_POSITION_Y;

   OnMove.Call();
end;

function TGame.GetBlockVerticalOffset(): loopint;
begin
   Result := Shapes.Shapes[CurrentShape]^.GetBlockVerticalOffset();
end;

function TGame.GetShape(): PShapeConfigurations;
begin
   Result := Shapes.Shapes[CurrentShape];
end;

function TGame.GetShapeGrid(): PShapeGrid;
begin
   Result := @Shapes.Shapes[CurrentShape]^[CurrentRotation];
end;

function TGame.GetShapeGrid(rotation: loopint): PShapeGrid;
begin
   Result := @Shapes.Shapes[CurrentShape]^[rotation];
end;

procedure TGame.MoveShapeLeft();
begin
   if CanFitShape(ShapePosition.x - 1, ShapePosition.y, CurrentRotation) then
      SetShapePosition(ShapePosition.x - 1, ShapePosition.y);
end;

procedure TGame.MoveShapeRight();
begin
   if CanFitShape(ShapePosition.x + 1, ShapePosition.y, CurrentRotation) then
      SetShapePosition(ShapePosition.x + 1, ShapePosition.y);
end;

procedure TGame.MoveShapeDown();
begin
   if CanFitShape(ShapePosition.x, ShapePosition.y - 1, CurrentRotation) then
      SetShapePosition(ShapePosition.x, ShapePosition.y - 1);
end;

procedure TGame.DropShape();
var
   y: loopint;

begin
   y := FindShapeLowestPosition();

   if(y <> ShapePosition.y) then
      SetShapePosition(ShapePosition.x, y);

   LockShape();
end;

procedure TGame.RotateLeft();
begin
   SetRotation(CurrentRotation - 1);
end;

procedure TGame.RotateRight();
begin
   SetRotation(CurrentRotation + 1);
end;

function TGame.FindShapeLowestPosition(): loopint;
begin
   Result := ShapePosition.y;

   repeat
     dec(Result);
   until (not CanFitShape(ShapePosition.x, Result, CurrentRotation));

   inc(Result);
end;

procedure TGame.LockShape();
var
   x,
   y,
   px,
   py: loopint;
   shapeGrid: PShapeGrid;

   element: PGridElement;

begin
   ShapeLockTime := 0;

   shapeGrid := GetShapeGrid();

   for y := 0 to 3 do begin
      for x := 0 to 3 do begin
         if(shapeGrid^.GetValue(x, y) = 0) then
            continue;

         px := ShapePosition.x + x;
         py := ShapePosition.y + y;

         element := Grid.GetPoint(px, py);

         if(element <> nil) then begin
            element^.Flags := [GRID_ELEMENT_SOLID];
            element^.Shape := CurrentShape;
            element^.Entity.SetEnabled();
         end;
      end;
   end;

   OnLock.Call();
end;

procedure TGame.SetShapePosition(x, y: loopint);
begin
   OnBeforeMove.Call();

   ShapePosition.x := x;
   ShapePosition.y := y;

   OnMove.Call();
end;

procedure TGame.SetRotation(rotation: loopint);
begin
   if(rotation < 0) then
      rotation := 3;

   if(rotation > 3) then
      rotation := 0;

   if (not CanFitShape(ShapePosition.x, ShapePosition.y, rotation)) then
      exit;

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
         {empty element, we do not check it}
         if(shapeGrid^.GetValue(j, i) = 0) then
            continue;

         py := y + i;
         px := x + j;

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

function TGame.IsLineFull(y: loopint): boolean;
var
   x: loopint;

begin
   Result := true;

   for x := 0 to GRID_WIDTH - 1 do begin
       if(not Grid.GetPoint(x, y)^.IsSolid()) then
          exit(false);
   end;
end;

procedure TGame.Update(dT: single);
begin
   LastUpdate := LastUpdate + dT;

   if(State = GAME_BLOCK_DROPPING) then begin
      if(LastUpdate > GetSpeed()) then begin
         LastUpdate := LastUpdate - GetSpeed();

         MoveShapeDown();
      end;

      {check if we can lock the shape}
      if(not CanFitShape(ShapePosition.x, ShapePosition.y - 1, CurrentRotation)) then begin
         ShapeLockTime := ShapeLockTime + dT;

         if(ShapeLockTime >= SHAPE_LOCK_TIME) then
            LockShape();
      end else
         {reset shape lock time since we're not hitting anything}
         ShapeLockTime := 0;
   end;

   OnUpdate.Call();
end;

procedure TGame.New();
begin
   LastUpdate := 0;
   oxTime.Resume();
   game.Grid.New();
   GetNextBlock();

   OnNew.Call();
end;

procedure TGame.WalkShape(walker: TGridShapeWalker);
begin
   WalkShape(game.ShapePosition.x, game.ShapePosition.y, walker);
end;

procedure TGame.WalkShape(atX, atY: loopint; walker: TGridShapeWalker);
var
   x,
   y,
   px,
   py: loopint;

   element: PGridElement;
   shapeGrid: PShapeGrid;

begin
   shapeGrid := game.GetShapeGrid();

   for y := 0 to 3 do begin
      for x := 0 to 3 do begin
         if(shapeGrid^.GetValue(x, y) = 0) then
            continue;

         px := atX + x;
         py := atY + y;

         if(py < GRID_HEIGHT) then begin
            element := game.Grid.GetPoint(px, py);

            if(element <> nil) then
               walker(px, py, element);
         end;
      end;
   end;
end;

procedure TGame.SetState(newState: TGameState);
begin
   State := newState;
   LastUpdate := 0.0;
   OnStateChange.Call();
end;

INITIALIZATION
   TProcedures.Initialize(game.OnNew);
   TProcedures.Initialize(game.OnBeforeMove);
   TProcedures.Initialize(game.OnMove);
   TProcedures.Initialize(game.OnLock);
   TProcedures.Initialize(game.OnStateChange);
   TProcedures.Initialize(game.OnUpdate);

END.
