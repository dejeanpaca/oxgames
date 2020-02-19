{$INCLUDE oxdefines.inc}
UNIT uClearLines;

INTERFACE

   USES
      uStd, uColors,
      {game}
      uBase, uGame, uGrid, uBlocks;

TYPE

   { TClearLines }

   TClearLines = record
      fStart,
      fEnd,
      fCount: loopint;

      {we can clear maximum of 4 lines, and they don't need to be in sequence}
      Lines: array[0..3] of loopint;

      procedure Check();
      procedure Clear();
   end;

VAR
   ClearLines: TClearLines;

IMPLEMENTATION

procedure animateMaterial(elapsed: single = 0);
var
   color: TColor4ub;

begin
   color := cWhite4ub;
   color[3] := 255 - round(255 * elapsed);

   blocks.LRAnimationMaterial.SetColor('color', color);
end;

procedure onStateChange();
var
   i,
   y,
   x: loopint;

begin
   if(game.State = GAME_BLOCK_DROPPING) then begin
      animateMaterial(0);
   end else if(game.State = GAME_LR) then begin
      for i := 0 to 3 do begin
         y := ClearLines.Lines[i];

         if(y < 0) then
            continue;

         for x := 0 to GRID_WIDTH -1  do begin
            SetMaterial(game.Grid.GetPoint(x, y)^, blocks.LRAnimationMaterial);
         end;
      end;
   end;
end;

procedure onUpdate();
begin
   if(game.State <> GAME_LR) then
      exit;

   if(game.LastUpdate >= LINE_CLEAR_ANIMATION_TIME) then begin
      ClearLines.Clear();
      game.SetState(GAME_BLOCK_DROPPING);
      game.GetNextBlock();
   end;

   animateMaterial(game.LastUpdate);
end;

procedure onLock();
begin
   {check if any lines can be cleared}
   ClearLines.Check();
end;

{ TClearLines }

procedure TClearLines.Check();
var
   y: loopint;

begin
   for y := 0 to 3 do
      Lines[y] := -1;

   fCount := 0;
   fStart := -1;
   fEnd := -1;

   {determine above values}
   for y := 0 to GRID_HEIGHT - 1 do begin
      if(game.IsLineFull(y)) then begin
         Lines[fCount] := y;
         inc(fCount);

         if(fStart = -1) then
            fStart := y;

         fEnd := y;
      end;
   end;

   if(fCount <= 0) then begin
      game.GetNextBlock();
      exit;
   end;

   game.SetState(GAME_LR);
end;

procedure TClearLines.Clear();
var
   i,
   x,
   y,
   prevY,
   startY: loopint;
   prevElement,
   element: PGridElement;

begin
   if(fCount <= 0) then
      exit;

   {clear lines}
   for i := 0 to 3 do begin
      startY := Lines[i];

      if(startY <= -1) then
         continue;

      { lower other lines }
      for y := i to 3 do
         dec(Lines[y]);

      for y := startY to GRID_HEIGHT - 1 do begin
         for x := 0 to GRID_WIDTH -1 do begin
            element := game.Grid.GetPoint(x, y);
            prevY := y + 1;

            if(prevY < GRID_HEIGHT) then
               prevElement := game.Grid.GetPoint(x, prevY)
            else
               prevElement := nil;

            if(prevElement <> nil) then begin
               element^.Flags := prevElement^.Flags;
               element^.Shape := prevElement^.Shape;

               if(prevElement^.Entity.Enabled) then
                  SetMaterial(element^, prevElement^.Mesh.Model.Material)
               else
                  ClearMaterial(element^);
            end else begin
               ClearMaterial(element^);
               element^.Flags := [];
               element^.Shape := -1;
            end;
         end;
      end;
   end;
end;

INITIALIZATION
   game.OnStateChange.Add(@onStateChange);
   game.OnUpdate.Add(@onUpdate);
   game.OnLock.Add(@onLock);

END.
