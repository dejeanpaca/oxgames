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

      procedure SelectedTile(); virtual;
      procedure UnselectedTile(); virtual;
      procedure MovePlayed(); virtual;
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
   gameComponent.Entity.EmptyChildren();
   Empty();
   Activate();
end;

procedure TBoard.SwitchTo();
begin
   Reset();
end;

procedure TBoard.SelectedTile();
begin

end;

procedure TBoard.UnselectedTile();
begin

end;

procedure TBoard.MovePlayed();
begin

end;

procedure onNew();
begin
   CurrentBoard^.Reset();
end;

procedure selectedTile();
begin
   CurrentBoard^.SelectedTile();
end;

procedure unselectedTile();
begin
   CurrentBoard^.UnselectedTile();
end;

procedure movePlayed();
begin
   CurrentBoard^.MovePlayed();
end;

INITIALIZATION
   game.OnNew.Add(@onNew);

   game.OnSelectedTile.Add(@selectedTile);
   game.OnUnselectedTile.Add(@unselectedTile);
   game.OnMovePlayed.Add(@movePlayed);

END.
