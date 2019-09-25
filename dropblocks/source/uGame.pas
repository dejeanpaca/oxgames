{$INCLUDE oxdefines.inc}
UNIT uGame;

INTERFACE

   USES
      uStd, uLog,
      {ox}
      oxuTimer, oxuEntity,
      {nase}
      uBase;

TYPE
   TGridFlag = (
      GRID_ELEMENT_SOLID,
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
      function IsDirty(): boolean;
   end;


   TGridArea = array[0..GRID_HEIGHT - 1, 0..GRID_WIDTH - 1] of TGridElement;

   { TGrid }

   TGrid = record
      Area: TGridArea;
      {is the grid dirty}
      Dirty: boolean;

      procedure SetPoint(x, y: loopint; what: TGridFlags);
      procedure MarkDirty(x, y: loopint);
      procedure MarkSolid(x, y: loopint);
      function GetPoint(x, y: loopint): PGridElement;
      function ValidPoint(x, y: loopint): boolean;
   end;

   { TGame }

   TGame = record
      OnNew: TProcedures;

      Grid: TGrid;

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

function TGridElement.IsDirty(): boolean;
begin
   Result := GRID_ELEMENT_DIRTY in Flags;
end;

{ TGrid }

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

procedure TGame.New();
begin
   oxTime.Resume();

   OnNew.Call();
end;

INITIALIZATION
   game.OnNew.Initialize(game.OnNew);

END.
