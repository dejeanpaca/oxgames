{$INCLUDE oxdefines.inc}
UNIT uAI;

INTERFACE

   USES
      uStd, uChess, oxuThreadTask;

TYPE
   PAI = ^TAI;

   { TAIThreadTask }

   TAIThreadTask = class(oxTThreadTask)
      constructor Create(); override;
      procedure Run(); override;
   end;

   { TAI }

   TAI = object
      public
      Name,
      {identification string}
      Id: StdString;

      Move: TChessMove;

      ComputedMove: boolean;

      constructor Create();

      procedure Reset();
      procedure ComputeMove();
      procedure PlayMove();

      protected
         procedure OnComputeMove(); virtual;
         procedure OnPlayMove(); virtual;
   end;

   TAIList = specialize TSimpleList<PAI>;

   { TAIGlobal }

   TAIGlobal = record
      List: TAIList;
      ComputeTask: TAIThreadTask;

      function FindById(const id: StdString): PAI;
      procedure Compute();
   end;

VAR
   AI: TAIGlobal;
   CurrentAI: PAI;

IMPLEMENTATION

{ TAIThreadTask }

constructor TAIThreadTask.Create();
begin
   inherited Create();
   SingleRun := true;
end;

procedure TAIThreadTask.Run();
begin
   CurrentAI^.ComputeMove();
end;

{ TAIGlobal }

function TAIGlobal.FindById(const id: StdString): PAI;
var
   i: loopint;

begin
   for i := 0 to List.n - 1 do begin
      if(List.List[i]^.Id = id) then
         exit(List.List[i]);
   end;

   Result := nil;
end;

procedure TAIGlobal.Compute();
begin
   If(ComputeTask = nil) then
      ComputeTask := TAIThreadTask.Create();

   ComputeTask.Start();
end;

{ TAI }

constructor TAI.Create();
begin
   Name := 'Unknown';

   AI.List.Add(@Self);
end;

procedure TAI.Reset();
begin
   ComputedMove := false;
end;

procedure TAI.ComputeMove();
begin
   if(not ComputedMove) then begin
      OnComputeMove();
      ComputedMove := true;
   end;
end;

procedure TAI.PlayMove();
begin
   if(ComputedMove) then
      OnPlayMove();
end;

procedure TAI.OnComputeMove();
begin

end;

procedure TAI.OnPlayMove();
begin
end;

INITIALIZATION
   TAIList.Initialize(AI.List, 8);

END.
