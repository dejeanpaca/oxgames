{$INCLUDE oxdefines.inc}
UNIT uGame;

INTERFACE

   USES
      uStd, uLog, oxuTimer,
      {ox}
      oxuEntity, oxuPrimitiveModelComponent, oxuMaterial;

CONST
   GRID_WIDTH = 75;
   GRID_HEIGHT = 50;

   GRID_MAX_WIDTH = 1000;
   GRID_MAX_HEIGHT = 1000;

   GRID_ELEMENT_SOLID   = $01;
   GRID_ELEMENT_NIBBLE  = $02;

TYPE
   PGridElement = ^TGridElement;
   PSnakePart =  ^TSnakePart;

   TSnakeDirection = (
      SNAKE_DIRECTION_RIGHT,
      SNAKE_DIRECTION_LEFT,
      SNAKE_DIRECTION_UP,
      SNAKE_DIRECTION_DOWN
   );

   { TGridElement }

   TGridElement = record
      Properties: TBitSet;
      Entity: oxTEntity;
      Mesh: oxTPrimitiveModelComponent;

      function IsNibble(): boolean;
      function IsSolid(): boolean;
      function IsEmpty(): boolean;
   end;

   TGridArea = array[0..GRID_MAX_HEIGHT - 1, 0..GRID_MAX_WIDTH - 1] of TGridElement;

   { TGrid }

   TGrid = record
      {grid current width}
      Width,
      {grid current height}
      Height: loopint;

      {grid area}
      Area: TGridArea;

      procedure Create(w, h: loopint);
      procedure CreateWalls();

      procedure SetPoint(x, y: loopint; what: TBitSet);
      procedure MarkNibble(x, y: loopint);
      procedure MarkSolid(x, y: loopint);
      function GetPoint(x, y: loopint): PGridElement;
      function ValidPoint(x, y: loopint): boolean;
   end;

   { TSnakePart }

   TSnakePart = record
      x,
      y: loopint;

      procedure Assign(newX, newY: loopint);
   end;

   TSnakeBody = array[0..1023] of TSnakePart;

   { TSnake }

   TSnake = record
      {snake}
      Body: TSnakeBody;
      {snake length}
      Length: loopint;

      {is the snake still alive}
      Alive: boolean;

      {what direction the snake is currently going in}
      CurrentDirection,
      {next direction we'll turn the snake to}
      NextDirection: TSnakeDirection;

      {NOTE: The reasoning between two direction properties is, so we don't change the current direction multiple
      times before the snake actually is moved (during tick), and therefore allowing direction to be changed to the
      opposite direction, e.g. from DOWN to UP which would cause snake self-collide on the next move.}

      {current accumulated update time}
      UpdateTime: single;

      procedure Initialize();
      procedure Move();
      procedure Grow();

      procedure CheckCollision();
      procedure CheckEat();

      function GetHead(): PSnakePart;
      function InSnake(x, y: loopint; ignoreHead: boolean = false): boolean;
   end;

   { TGame }

   TGame = record
      Grid: TGrid;
      Snake: TSnake;

      {how many nibbles do we have on the screen currently}
      NibbleCount: loopint;

      OnNew,
      OnCollision,
      OnNibbleEaten,
      OnCreateNibble,
      OnBeforeMove,
      OnAfterMove: TProcedures;

      {where the last nibble was generated or eaten}
      LastNibble: record
         x,
         y: loopint;
      end;

      procedure New();

      procedure GenerateNibbles(count: loopint = 1);
      procedure EatNibble(x, y: loopint);
   end;

VAR
   game: TGame;

procedure SetMaterial(element: TGridElement; material: oxTMaterial);
procedure ClearMaterial(element: TGridElement);

IMPLEMENTATION

procedure SetMaterial(element: TGridElement; material: oxTMaterial);
begin
   if(element.Mesh <> nil) then begin
      if(material <> nil) then begin
         element.Mesh.Model.SetMaterial(material);
         element.Entity.SetEnabled(true);
      end else
         element.Entity.SetEnabled(false);
   end;
end;

procedure ClearMaterial(element: TGridElement);
begin
   SetMaterial(element, nil);
end;

{ TSnakePart }

procedure TSnakePart.Assign(newX, newY: loopint);
begin
   x := newX;
   y := newY;
end;

{ TSnake }

procedure TSnake.Initialize();
var
   x, y: loopint;

begin
   Alive := true;

   x := game.Grid.Width div 2;
   y := game.Grid.Width div 2;

   Body[2].Assign(x, y);
   Body[1].Assign(x - 1, y);
   Body[0].Assign(x - 2, y);

   Length := 3;
   CurrentDirection := SNAKE_DIRECTION_RIGHT;
   NextDirection := SNAKE_DIRECTION_RIGHT;
end;

procedure TSnake.Move();
var
   i,
   mX,
   my,
   head: loopint;
   pHead: PSnakePart;

begin
   if(not Alive) then
      exit;

   game.OnBeforeMove.Call();

   mX := 0;
   mY := 0;

   CurrentDirection := NextDirection;

   if(CurrentDirection = SNAKE_DIRECTION_RIGHT) then
      mX := 1
   else if(CurrentDirection = SNAKE_DIRECTION_LEFT) then
      mX := -1
   else if(CurrentDirection = SNAKE_DIRECTION_UP) then
      mY := 1
   else if(CurrentDirection = SNAKE_DIRECTION_DOWN) then
      mY := -1;

   head := Length - 1;

   if(Length > 1) then begin
      for i := 0 to head - 1 do begin
         Body[i] := Body[i + 1];
      end;
   end;

   inc(Body[Length - 1].x, mX);
   inc(Body[Length - 1].y, my);

   pHead := GetHead();

   {if we go out of game grid bounds, teleport onto the other side}

   if(pHead^.x < 0) then
      pHead^.x := game.Grid.Width - 1;

   if(pHead^.x >= game.Grid.Width) then
      pHead^.x := 0;

   if(pHead^.y < 0) then
      pHead^.y := game.Grid.Height - 1;

   if(pHead^.y >= game.Grid.Height) then
      pHead^.y := 0;

   game.OnAfterMove.Call();

   {checks new position}

   CheckCollision();
   CheckEat();
end;

procedure TSnake.Grow();
var
   i: loopint;

begin
   inc(Length);

   for i := Length - 1 downto 1 do begin
      Body[i] := Body[i - 1];
   end;
end;

procedure TSnake.CheckCollision();
var
   head: PSnakePart;
   element: PGridElement;

begin
   head := GetHead();
   element := game.Grid.GetPoint(head^.x, head^.y);

   if element^.IsSolid() or InSnake(head^.x, head^.y, true) then begin
      Alive := false;
      game.OnCollision.Call();
   end;
end;

procedure TSnake.CheckEat();
var
   head: PSnakePart;
   element: PGridElement;

begin
   head := GetHead();
   element := game.Grid.GetPoint(head^.x, head^.y);

   if element^.IsNibble() then begin
      game.EatNibble(head^.x, head^.y);
   end;
end;

function TSnake.GetHead(): PSnakePart;
begin
   Result := @Body[Length - 1];
end;

function TSnake.InSnake(x, y: loopint; ignoreHead: boolean): boolean;
var
   i,
   currentLength: loopint;

begin
   currentLength := Length - 1;

   if(ignoreHead) then
      dec(currentLength);

   for i := 0 to currentLength do begin
      if(x = Body[i].x) and (y = Body[i].y) then
         exit(true);
   end;

   Result := false;
end;

{ TGridElement }

function TGridElement.IsNibble(): boolean;
begin
   Result := Properties.IsSet(GRID_ELEMENT_NIBBLE);
end;

function TGridElement.IsSolid(): boolean;
begin
   Result := Properties.IsSet(GRID_ELEMENT_SOLID);
end;

function TGridElement.IsEmpty(): boolean;
begin
   Result := not (Properties.IsSet(GRID_ELEMENT_SOLID) or Properties.IsSet(GRID_ELEMENT_NIBBLE));
end;

{ TGame }

procedure TGame.New();
begin
   Grid.Create(GRID_WIDTH, GRID_HEIGHT);
   Grid.CreateWalls();

   Snake.Initialize();
   NibbleCount := 0;
   GenerateNibbles();

   oxTime.Resume();

   OnNew.Call();
end;

procedure TGame.GenerateNibbles(count: loopint);
var
   i: loopint;

   x,
   y: loopint;

begin
   for i := 0 to count - 1 do begin
      repeat
        x := Random(Grid.Width);
        y := Random(Grid.Height);

        if(Grid.GetPoint(x, y)^.IsSolid()) then
           continue;

        if(Snake.InSnake(x, y)) then
           continue;

        break;
      until false;

      Grid.MarkNibble(x, y);

      game.LastNibble.x := x;
      game.LastNibble.y := y;

      game.OnCreateNibble.Call();

      Inc(NibbleCount);
   end;
end;

procedure TGame.EatNibble(x, y: loopint);
var
   element: PGridElement;

begin
   element := Grid.GetPoint(x, y);

   if(element^.IsNibble()) then begin
      Dec(NibbleCount);
      element^.Properties.Clear(GRID_ELEMENT_NIBBLE);

      {grow snake}
      Snake.Grow();

      LastNibble.x := x;
      LastNibble.y := y;

      OnNibbleEaten.Call();
   end;
end;

{ TGrid }

procedure TGrid.Create(w, h: loopint);
var
   x, y: loopint;

begin
   ZeroPtr(@Area, SizeOf(Area));

   Width := w;
   Height := h;

   for y := 0 to h - 1 do begin
      for x := 0 to w - 1 do begin
         Area[y][x].Properties := 0;
      end;
   end;
end;

procedure TGrid.CreateWalls();
var
   i: loopint;

begin
   for i := 0 to Width - 1 do begin
      MarkSolid(i, 0);
      MarkSolid(i, Height - 1);
   end;

   for i := 1 to Height - 1 do begin
      MarkSolid(0, i);
      MarkSolid(Width - 1, i);
   end;
end;

procedure TGrid.SetPoint(x, y: loopint; what: TBitSet);
begin
   Area[y][x].Properties.Prop(what);
end;

procedure TGrid.MarkNibble(x, y: loopint);
begin
   SetPoint(x, y, GRID_ELEMENT_NIBBLE);
end;

procedure TGrid.MarkSolid(x, y: loopint);
begin
   SetPoint(x, y, GRID_ELEMENT_SOLID);
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
   Result := (x >= 0) and (y >= 0) and (x < game.Grid.Width) and (y < game.Grid.Height);
end;

procedure nibbleEaten();
begin
   game.GenerateNibbles();
end;

INITIALIZATION
   TProcedures.Initialize(game.OnNew);
   TProcedures.Initialize(game.OnCollision);
   TProcedures.Initialize(game.OnNibbleEaten);
   TProcedures.Initialize(game.OnCreateNibble);

   TProcedures.Initialize(game.OnBeforeMove);
   TProcedures.Initialize(game.OnAfterMove);

   game.OnNibbleEaten.Add(@nibbleEaten);

   game.Snake.UpdateTime := 0.2;

END.
