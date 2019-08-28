{$INCLUDE oxdefines.inc}
UNIT uGame;

INTERFACE

   USES
      uStd, uLog, oxuTimer,
      oxuEntity;

CONST
   GRID_WIDTH = 50;
   GRID_HEIGHT = 50;

   GRID_MAX_WIDTH = 1000;
   GRID_MAX_HEIGHT = 1000;

   GRID_ELEMENT_SOLID   = $01;
   GRID_ELEMENT_NIBBLE  = $02;
   {is this element dirty and needs to have it's materials updated}
   GRID_ELEMENT_DIRTY  = $04;

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

      function IsNibble(): boolean;
      function IsSolid(): boolean;
      function IsDirty(): boolean;
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

      {mark the grid as dirty (if we moved a snake, or added a nibble or something else)}
      Dirty: boolean;

      procedure Create(w, h: loopint);
      procedure CreateWalls();

      procedure SetPoint(x, y: loopint; what: TBitSet);
      procedure MarkNibble(x, y: loopint);
      procedure MarkDirty(x, y: loopint);
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

      Alive: boolean;
      Direction: TSnakeDirection;
      Dirty: boolean;

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
      OnNibbleEaten: TProcedures;

      procedure New();

      procedure GenerateNibbles(count: loopint = 1);
      procedure EatNibble(x, y: loopint);
   end;

VAR
   game: TGame;

IMPLEMENTATION

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
   Direction := SNAKE_DIRECTION_RIGHT;

   Dirty := true;
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

   mX := 0;
   mY := 0;

   if(Direction = SNAKE_DIRECTION_RIGHT) then
      mX := 1
   else if(Direction = SNAKE_DIRECTION_LEFT) then
      mX := -1
   else if(Direction = SNAKE_DIRECTION_UP) then
      mY := 1
   else if(Direction = SNAKE_DIRECTION_DOWN) then
      mY := -1;

   head := Length - 1;

   if(Length > 1) then begin
      for i := 0 to head - 1 do begin
         Body[i] := Body[i + 1];
      end;
   end;

   game.Grid.MarkDirty(Body[0].x, Body[0].y);
   game.Grid.MarkDirty(Body[head].x, Body[head].y);

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

   game.Snake.Dirty := true;

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

function TGridElement.IsDirty(): boolean;
begin
   Result := Properties.IsSet(GRID_ELEMENT_DIRTY);
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
         Area[y][x].Properties.Prop(GRID_ELEMENT_DIRTY);
      end;
   end;

   Dirty := true;
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
   Dirty := true;
end;

procedure TGrid.MarkNibble(x, y: loopint);
begin
   SetPoint(x, y, GRID_ELEMENT_NIBBLE);
end;

procedure TGrid.MarkDirty(x, y: loopint);
begin
   SetPoint(x, y, GRID_ELEMENT_DIRTY);
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
   game.OnNew.Initialize(game.OnNew);
   game.OnCollision.Initialize(game.OnCollision);
   game.OnNibbleEaten.Initialize(game.OnNibbleEaten);

   game.OnNibbleEaten.Add(@nibbleEaten);

   game.Snake.UpdateTime := 0.2;

END.
