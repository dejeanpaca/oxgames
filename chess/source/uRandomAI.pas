{$INCLUDE oxdefines.inc}
UNIT uRandomAI;

INTERFACE

   USES
      uAI;

TYPE

   { TRandomAI }

   TRandomAI = object(TAI)
      constructor Create();

      procedure Reset(); virtual;
      procedure PlayMove(); virtual;
   end;

VAR
   RandomAI: TRandomAI;

IMPLEMENTATION

{ TRandomAI }

constructor TRandomAI.Create();
begin
   Name := 'Random';
end;

procedure TRandomAI.Reset();
begin

end;

procedure TRandomAI.PlayMove();
begin

end;

INITIALIZATION
   RandomAI.Create();

END.
