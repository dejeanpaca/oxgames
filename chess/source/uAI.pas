{$INCLUDE oxdefines.inc}
UNIT uAI;

INTERFACE

   USES
      uStd, uChess;

TYPE
   PAI = ^TAI;

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

VAR
   CurrentAI: PAI;

IMPLEMENTATION

{ TAI }

constructor TAI.Create();
begin
   Name := 'Unknown';
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

END.
