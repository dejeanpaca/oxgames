{$INCLUDE oxdefines.inc}
UNIT uBoard;

INTERFACE

   USES
      uStd,
      {ox}
      oxuEntity,
      {game}
      uGame, uGameComponent;

TYPE
   PBoard = ^TBoard;

   { TBoard }

   TBoard = object
      Board,
      White,
      Black: oxTEntity;

      Reference: array[0..7, 0..7] of oxTEntity;

      constructor Create();

      procedure Empty(); virtual;
      procedure Activate(); virtual;
      procedure Reset(); virtual;

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

procedure TBoard.Reset();
begin
   gameComponent.Entity.Empty();
   Empty();
   Activate();
end;

procedure TBoard.SwitchTo();
begin
   Reset();
end;

procedure onNew();
begin
   CurrentBoard^.Reset();
end;

INITIALIZATION
   game.OnNew.Add(@onNew);

END.
