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
      lastUpdate: Single;

      procedure Start(); override;
      procedure Update(); override;

      function GetDescriptor(): oxPComponentDescriptor; override;
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

procedure TSnakeComponent.Update();
begin
   lastUpdate := lastUpdate + oxTime.Flow;

   if(lastUpdate >= game.Snake.UpdateTime) then begin
      game.Snake.Move();

      lastUpdate := lastUpdate - game.Snake.UpdateTime;
   end;

   if appk.IsPressed(kcUP) or appk.IsPressed(kcA) then begin
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
