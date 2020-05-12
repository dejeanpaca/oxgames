{$INCLUDE oxdefines.inc}
UNIT uAI;

INTERFACE

   USES
      uStd;

TYPE

   { TAI }

   TAI = object
      public
      Name: StdString;

      constructor Create();

      procedure Reset(); virtual;
      procedure PlayMove(); virtual;
   end;

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
