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
      uGame, uScene;

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
      Entity: oxTEntity;

      procedure Initialize();
   end;

VAR
   chessComponent: TChessComponentGlobal;

IMPLEMENTATION

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

   if appk.JustPressed(kcF2) then
      game.New();
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

   Entity := oxEntity.New('Chess');
   Entity.Add(TChessComponent.Create());

   oxScene.Add(Entity);
end;

procedure initialize();
begin
   chessComponent.Initialize();
end;

INITIALIZATION
   scene.OnInitialize.Add(@initialize);

END.
