{$INCLUDE oxdefines.inc}
UNIT uGame;

INTERFACE

   USES
      uStd, uLog,
      oxuEntity;

CONST
   GRID_WIDTH = 50;
   GRID_HEIGHT = 50;

   GRID_MAX_WIDTH = 1000;
   GRID_MAX_HEIGHT = 1000;

   GRID_ELEMENT_SOLID   = $01;
   GRID_ELEMENT_NIBBLE  = $02;
   {is this element dirty and needs to have it's materials updated}
   GRID_ELEMENT_DIRTY  = $02;

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
      procedure CheckCollision();
      function GetHead(): PSnakePart;
   end;

   { TGame }

   TGame = record
      Grid: TGrid;
      Snake: TSnake;

      OnNew,
      OnCollision: TProcedures;

      procedure New();
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

   game.Snake.Dirty := true;

   // check for collision

   CheckCollision();
end;

procedure TSnake.CheckCollision();
var
   head: PSnakePart;
   element: PGridElement;

begin
   head := GetHead();
   element := game.Grid.GetPoint(head^.x, head^.y);

   if element^.IsSolid() then begin
      Alive := false;

      game.OnCollision.Call();
   end;
end;

function TSnake.GetHead(): PSnakePart;
begin
   Result := @Body[Length - 1];
end;

{ TGridElement }

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

   OnNew.Call();
   Snake.Initialize();
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

INITIALIZATION
   game.OnNew.Initialize(game.OnNew);
   game.Snake.UpdateTime := 0.2;

END.
