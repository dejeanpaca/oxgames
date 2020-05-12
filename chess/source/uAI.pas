{$INCLUDE oxdefines.inc}
UNIT uAI;

INTERFACE

   USES
      uStd;

TYPE
   PAI = ^TAI;

   { TAI }

   TAI = object
      public
      Name: StdString;

      constructor Create();

      procedure Reset(); virtual;
      procedure PlayMove(); virtual;
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

end;

procedure TAI.PlayMove();
begin

end;

END.
