{$INCLUDE oxdefines.inc}
UNIT uChessComponent;

INTERFACE

   USES
      appuKeys,
      {oX}
      oxuScene, oxuEntity, oxuTimer,
      oxuComponent, oxuComponentDescriptors,
      oxuMaterial,
      {game}
      uGame;

TYPE
   { TChessComponent }

   TChessComponent = class(oxTComponent)
      public

      procedure Start(); override;
      procedure ControlChess();
      procedure ControlKeys();
      procedure Update(); override;

      function GetDescriptor(): oxPComponentDescriptor; override;

      private
      lastUpdate: Single;
   end;

   { TChessComponentGlobal }

   TChessComponentGlobal = record
      Descriptor: oxTComponentDescriptor;

      procedure Initialize();
   end;

VAR
   chessComponent: TChessComponentGlobal;

IMPLEMENTATION

VAR
   chessEntity: oxTEntity;

{ TChessComponentGlobal }

procedure TChessComponent.Start();
begin
   lastUpdate := 0;
end;

procedure TChessComponent.ControlChess();
begin
   if(oxTime.Paused()) then
      exit;

   lastUpdate := lastUpdate + oxTime.Flow;
end;

procedure TChessComponent.ControlKeys();
begin
   if(not oxTime.Paused()) then begin
   end;

   if appk.JustPressed(kcP) then
      oxTime.TogglePause();

{   if appk.JustPressed(kcF2) then
      game.New();}
end;

procedure TChessComponent.Update();
begin
   ControlChess();
   ControlKeys();
end;

function TChessComponent.GetDescriptor(): oxPComponentDescriptor;
begin
   Result := @chessComponent.Descriptor;
end;

{ TGridGlobal }

procedure TChessComponentGlobal.Initialize();
begin
   chessComponent.Descriptor.Create('chess', TChessComponent);
   chessComponent.Descriptor.Name := 'Chess';

   chessEntity := oxEntity.New('Chess');
   chessEntity.Add(TChessComponent.Create());

   oxScene.Add(chessEntity);
end;

END.
