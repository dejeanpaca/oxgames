{$INCLUDE oxdefines.inc}
UNIT uSnakeComponent;

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
   { TSnakeComponent }

   TSnakeComponent = class(oxTComponent)
      public

      procedure Start(); override;
      procedure ControlSnake();
      procedure ControlKeys();
      procedure Update(); override;

      function GetDescriptor(): oxPComponentDescriptor; override;

      private
      lastUpdate: Single;
   end;

   { TSnakeComponentGlobal }

   TSnakeComponentGlobal = record
      Descriptor: oxTComponentDescriptor;

      procedure Initialize();
   end;

VAR
   snakeComponent: TSnakeComponentGlobal;

IMPLEMENTATION

VAR
   snakeEntity: oxTEntity;

{ TSnakeComponentGlobal }

procedure TSnakeComponent.Start();
begin
   lastUpdate := 0;
end;

procedure TSnakeComponent.ControlSnake();
begin
   if(oxTime.Paused()) then
      exit;

   lastUpdate := lastUpdate + oxTime.Flow;

   if(lastUpdate >= game.Snake.UpdateTime) then begin
      game.Snake.Move();

      lastUpdate := lastUpdate - game.Snake.UpdateTime;
   end;
end;

procedure TSnakeComponent.ControlKeys();
begin
   if(not oxTime.Paused()) then begin
      if appk.IsPressed(kcUP) or appk.IsPressed(kcW) then begin
         if(game.Snake.Direction <> SNAKE_DIRECTION_DOWN) then
            game.Snake.Direction := SNAKE_DIRECTION_UP;
      end else if appk.IsPressed(kcDOWN) or appk.IsPressed(kcS) then begin
         if(game.Snake.Direction <> SNAKE_DIRECTION_UP) then
            game.Snake.Direction := SNAKE_DIRECTION_DOWN;
      end else if appk.IsPressed(kcLEFT) or appk.IsPressed(kcA) then begin
         if(game.Snake.Direction <> SNAKE_DIRECTION_RIGHT) then
            game.Snake.Direction := SNAKE_DIRECTION_LEFT;
      end else if appk.IsPressed(kcRIGHT) or appk.IsPressed(kcD) then begin
         if(game.Snake.Direction <> SNAKE_DIRECTION_LEFT) then
            game.Snake.Direction := SNAKE_DIRECTION_RIGHT;
      end;
   end;

   if appk.JustPressed(kcP) then
      oxTime.TogglePause();

   if appk.JustPressed(kcF2) then
      game.New();
end;

procedure TSnakeComponent.Update();
begin
   ControlSnake();
   ControlKeys();
end;

function TSnakeComponent.GetDescriptor(): oxPComponentDescriptor;
begin
   Result := @snakeComponent.Descriptor;
end;

{ TGridGlobal }

procedure TSnakeComponentGlobal.Initialize();
begin
   snakeComponent.Descriptor.Create('snake', TSnakeComponent);
   snakeComponent.Descriptor.Name := 'Snake';

   snakeEntity := oxEntity.New('Snake');
   snakeEntity.Add(TsnakeComponent.Create());

   oxScene.Add(snakeEntity);
end;

END.
