{$INCLUDE oxdefines.inc}
UNIT uGameComponent;

INTERFACE

   USES
      sysutils,
      uStd, uLog, uColors, uTiming,
      {oX}
      oxuPaths, oxuTexture, oxuTextureGenerate,
      oxuScene, oxuEntity,
      oxuComponent, oxuComponentDescriptors,
      oxuCameraComponent,
      oxuMaterial, oxumPrimitive, oxuPrimitiveModelComponent,
      {game}
      uScene, uChess, uGame, uAI, uSimpleAI;

TYPE
   { TGameComponent }

   TGameComponent = class(oxTComponent)
      public

      procedure Update(); override;

      function GetDescriptor(): oxPComponentDescriptor; override;
   end;

   { TGameComponentGlobal }

   TGameComponentGlobal = record
      Descriptor: oxTComponentDescriptor;
      Entity: oxTEntity;

      procedure Initialize();
   end;

VAR
   gameComponent: TGameComponentGlobal;

IMPLEMENTATION

procedure TGameComponent.Update();
begin
   if(game.PlayerControlType() = PLAYER_CONTROL_AI) then begin
      if(not chess.GameOver()) then begin
         CurrentAI^.ComputeMove();

         if(game.MoveStartTime.Elapsedf() > AI_MOVE_DELAY_TIME) then
            CurrentAI^.PlayMove();
      end;
   end;
end;

function TGameComponent.GetDescriptor(): oxPComponentDescriptor;
begin
   Result := @gameComponent.Descriptor;
end;

{ TGameComponentGlobal }

procedure TGameComponentGlobal.Initialize();
begin
   CurrentAI := @SimpleAI;
   gameComponent.Descriptor.Create('game', TGameComponent);

   Entity := oxEntity.New('Game', TGameComponent.Create());

   Entity.LoadComponentsInChildren();

   oxScene.Add(Entity);
end;

procedure initialize();
begin
   gameComponent.Initialize();
end;

INITIALIZATION
   scene.OnInitialize.Add(@initialize);

END.
