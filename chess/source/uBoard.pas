{$INCLUDE oxdefines.inc}
UNIT uBoard;

INTERFACE

   USES
      uStd,
      {ox}
      oxuEntity,
      {game}
      uGameComponent;

TYPE
   PBoard = ^TBoard;

   { TBoard }

   TBoard = object
      Board,
      White,
      Black: oxTEntity;

      Reference: array[0..7, 0..7] of oxTEntity;

      Pieces: record
         Black,
         White: array[0..15] of oxTEntity;
      end;

      constructor Create();

      procedure Empty(); virtual;
      procedure Activate(); virtual;

      procedure SwitchTo();
   end;

VAR
   CurrentBoard: PBoard;

IMPLEMENTATION

{ TBoard }

constructor TBoard.Create();
begin

end;

procedure TBoard.Empty();
begin
  ZeroOut(Reference, SizeOf(Reference));
end;

procedure TBoard.Activate();
begin

end;

procedure TBoard.SwitchTo();
begin
   gameComponent.Entity.Empty();
   Empty();
   Activate();
end;

END.
