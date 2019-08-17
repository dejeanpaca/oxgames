{$INCLUDE oxdefines.inc}
UNIT uGame;

INTERFACE

   USES
      uStd,
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
      procedure SetNibble(x, y: loopint);
      procedure MarkSolid(x, y: loopint);
      function GetPoint(x, y: loopint): PGridElement;
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
      {snake head}
      Head,
      {snake tail}
      Tail,
      {snake length}
      Length: loopint;

      Dirty: boolean;

      procedure Initialize();
   end;

   { TGame }

   TGame = record
      Grid: TGrid;
      Snake: TSnake;

      OnNew: TProcedures;

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
   x := game.Grid.Width div 2;
   y := game.Grid.Width div 2;

   Body[0].Assign(x, y);
   Body[1].Assign(x - 1, y);
   Body[2].Assign(x - 2, y);

   Head := 0;
   Tail := 2;

   Dirty := true;
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

procedure TGrid.SetNibble(x, y: loopint);
begin
   SetPoint(x, y, GRID_ELEMENT_NIBBLE);
end;

procedure TGrid.MarkSolid(x, y: loopint);
begin
   SetPoint(x, y, GRID_ELEMENT_SOLID);
end;

function TGrid.GetPoint(x, y: loopint): PGridElement;
begin
   Result := @Area[y][x];
end;

INITIALIZATION
   game.OnNew.Initialize(game.OnNew);

END.
