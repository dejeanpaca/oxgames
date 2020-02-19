{
   DropBlocks, game base
   Started On: 19.09.2019.
}

{$INCLUDE oxdefines.inc}
UNIT uBase;

INTERFACE

   USES
      uStd, uColors;

CONST
   {vertical and horizontal size of the playing field}
   GRID_HEIGHT = 22;
   GRID_WIDTH  = 10;

   MAX_SHAPES = 7;

   BLOCK_START_POSITION_X = 4;
   BLOCK_START_POSITION_Y = 22;

   MAX_SPEED = 9;

   SHAPE_LOCK_TIME = 1.0;
   LINE_CLEAR_ANIMATION_TIME = 1.0;

TYPE
   PShapeGrid = ^TShapeGrid;
   TShapeGrid = array[0..3, 0..3] of loopint;

   PShapeConfigurations = ^TShapeConfigurations;
   TShapeConfigurations = array[0..3] of TShapeGrid;

   { TShapeGridHelper }

   TShapeGridHelper = type helper for TShapeGrid
      {get value at the given coordinates (this assumes bottom left origin, unlike top-left of the array)}
      function GetValue(x, y: loopint): loopint;
   end;

   { TShapeConfigurationsHelper }

   TShapeConfigurationsHelper = type helper for TShapeConfigurations
      function GetBlockVerticalOffset(): loopint;
   end;

   TShapes = record
      Shapes: array[0..MAX_SHAPES - 1] of PShapeConfigurations;
      Colors: array[0..MAX_SHAPES - 1] of TColor4ub;
   end;

CONST
   GameSpeeds: array[0..MAX_SPEED - 1] of single = (
      1.0,
      0.9,
      0.8,
      0.7,
      0.6,
      0.5,
      0.4,
      0.3,
      0.2
   );

   IShape: TShapeConfigurations = (
      (  (0, 0, 0, 0),
         (0, 0, 0, 0),
         (1, 1, 1, 1),
         (0, 0, 0, 0)   ),
      (  (0, 1, 0, 0),
         (0, 1, 0, 0),
         (0, 1, 0, 0),
         (0, 1, 0, 0)   ),
      (  (0, 0, 0, 0),
         (0, 0, 0, 0),
         (1, 1, 1, 1),
         (0, 0, 0, 0)   ),
      (  (0, 1, 0, 0),
         (0, 1, 0, 0),
         (0, 1, 0, 0),
         (0, 1, 0, 0)   )
   );

   JShape: TShapeConfigurations = (
      (  (0, 0, 0, 0),
         (1, 0, 0, 0),
         (1, 1, 1, 0),
         (0, 0, 0, 0)   ),
      (  (1, 1, 0, 0),
         (1, 0, 0, 0),
         (1, 0, 0, 0),
         (0, 0, 0, 0)   ),
      (  (1, 1, 1, 0),
         (0, 0, 1, 0),
         (0, 0, 0, 0),
         (0, 0, 0, 0)   ),
      (  (0, 1, 0, 0),
         (0, 1, 0, 0),
         (1, 1, 0, 0),
         (0, 0, 0, 0)   )
   );

   LShape: TShapeConfigurations = (
      (  (0, 0, 0, 0),
         (0, 0, 1, 0),
         (1, 1, 1, 0),
         (0, 0, 0, 0)   ),
      (  (1, 0, 0, 0),
         (1, 0, 0, 0),
         (1, 1, 0, 0),
         (0, 0, 0, 0)   ),
      (  (1, 1, 1, 0),
         (1, 0, 0, 0),
         (0, 0, 0, 0),
         (0, 0, 0, 0)   ),
      (  (1, 1, 0, 0),
         (0, 1, 0, 0),
         (0, 1, 0, 0),
         (0, 0, 0, 0)   )
   );

   TShape: TShapeConfigurations = (
      (  (0, 0, 0, 0),
         (0, 1, 0, 0),
         (1, 1, 1, 0),
         (0, 0, 0, 0)   ),
      (  (1, 0, 0, 0),
         (1, 1, 0, 0),
         (1, 0, 0, 0),
         (0, 0, 0, 0)   ),
      (  (1, 1, 1, 0),
         (0, 1, 0, 0),
         (0, 0, 0, 0),
         (0, 0, 0, 0)   ),
      (  (0, 1, 0, 0),
         (1, 1, 0, 0),
         (0, 1, 0, 0),
         (0, 0, 0, 0)   )
   );

   SShape: TShapeConfigurations = (
      (  (0, 0, 0, 0),
         (0, 1, 1, 0),
         (1, 1, 0, 0),
         (0, 0, 0, 0)   ),
      (  (1, 0, 0, 0),
         (1, 1, 0, 0),
         (0, 1, 0, 0),
         (0, 0, 0, 0)   ),
      (  (0, 0, 0, 0),
         (0, 1, 1, 0),
         (1, 1, 0, 0),
         (0, 0, 0, 0)   ),
      (  (1, 0, 0, 0),
         (1, 1, 0, 0),
         (0, 1, 0, 0),
         (0, 0, 0, 0)   )
   );

   ZShape: TShapeConfigurations = (
      (  (0, 0, 0, 0),
         (1, 1, 0, 0),
         (0, 1, 1, 0),
         (0, 0, 0, 0)   ),
      (  (0, 1, 0, 0),
         (1, 1, 0, 0),
         (1, 0, 0, 0),
         (0, 0, 0, 0)   ),
      (  (0, 0, 0, 0),
         (1, 1, 0, 0),
         (0, 1, 1, 0),
         (0, 0, 0, 0)   ),
      (  (0, 1, 0, 0),
         (1, 1, 0, 0),
         (1, 0, 0, 0),
         (0, 0, 0, 0)   )
   );

   OShape: TShapeConfigurations = (
      (  (0, 0, 0, 0),
         (0, 1, 1, 0),
         (0, 1, 1, 0),
         (0, 0, 0, 0)   ),
      (  (0, 0, 0, 0),
         (0, 1, 1, 0),
         (0, 1, 1, 0),
         (0, 0, 0, 0)   ),
      (  (0, 0, 0, 0),
         (0, 1, 1, 0),
         (0, 1, 1, 0),
         (0, 0, 0, 0)   ),
      (  (0, 0, 0, 0),
         (0, 1, 1, 0),
         (0, 1, 1, 0),
         (0, 0, 0, 0)   )
   );

   TemplateShape: TShapeConfigurations = (
      (  (0, 0, 0, 0),
         (0, 0, 0, 0),
         (0, 0, 0, 0),
         (0, 0, 0, 0)   ),
      (  (0, 0, 0, 0),
         (0, 0, 0, 0),
         (0, 0, 0, 0),
         (0, 0, 0, 0)   ),
      (  (0, 0, 0, 0),
         (0, 0, 0, 0),
         (0, 0, 0, 0),
         (0, 0, 0, 0)   ),
      (  (0, 0, 0, 0),
         (0, 0, 0, 0),
         (0, 0, 0, 0),
         (0, 0, 0, 0)   )
   );

VAR
   Shapes: TShapes;

IMPLEMENTATION

{ TShapeGridHelper }

function TShapeGridHelper.GetValue(x, y: loopint): loopint;
begin
   Result := Self[3 - y][x];
end;

{ TShapeConfigurationsHelper }

function TShapeConfigurationsHelper.GetBlockVerticalOffset(): loopint;
begin
   Result := 0;
   {TODO: Implement this}
end;

INITIALIZATION
   Shapes.Shapes[0] := @IShape;
   Shapes.Shapes[1] := @JShape;
   Shapes.Shapes[2] := @LShape;
   Shapes.Shapes[3] := @TShape;
   Shapes.Shapes[4] := @SShape;
   Shapes.Shapes[5] := @ZShape;
   Shapes.Shapes[6] := @OShape;

   Shapes.Colors[0].Assign(32, 192, 255, 255); {IShape}
   Shapes.Colors[1].Assign(0, 0, 255, 255); {JShape}
   Shapes.Colors[2].Assign(192, 192, 64, 255); {LShape}
   Shapes.Colors[3].Assign(255, 0, 255, 255); {TShape}
   Shapes.Colors[4].Assign(0, 255, 0, 255); {SShape}
   Shapes.Colors[5].Assign(255, 32, 32, 255); {ZShape}
   Shapes.Colors[6].Assign(255, 255, 0, 255); {OShape}

END.
