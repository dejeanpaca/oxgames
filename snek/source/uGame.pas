{$INCLUDE oxdefines.inc}
UNIT uGame;

INTERFACE

   USES
      uStd;

CONST
   GRID_MAX_WIDTH = 1000;
   GRID_MAX_HEIGHT = 1000;

   GRID_ELEMENT_SOLID   = $01;
   GRID_ELEMENT_NIBBLE  = $02;

TYPE
   TGridElement = TBitSet;

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
   end;

   TSnakePart = record
      x,
      y: loopint;
   end;

   TSnakeBody = array[0..1023] of TSnakePart;

   TSnake = record
      {snake}
      Body: TSnakeBody;
      {snake head}
      Head,
      {snake tail}
      Tail,
      {snake length}
      Length: loopint;
   end;

   TGame = record
      Grid: TGrid;
      Snake: TSnake;
   end;

IMPLEMENTATION

{ TGrid }

procedure TGrid.Create(w, h: loopint);
begin
   ZeroPtr(@Area, SizeOf(Area));


   Width := w;
   Height := h;
end;

procedure TGrid.CreateWalls();
var
   i: loopint;

begin
   for i := 0 to Width - 1 do
      SetPoint(i, 0, GRID_ELEMENT_SOLID);
end;

procedure TGrid.SetPoint(x, y: loopint; what: TBitSet);
begin
   Area[y][x].Prop(what);
end;

END.
