{$INCLUDE oxdefines.inc}
UNIT uDropBlocksComponent;

INTERFACE

   USES
      uStd, appuKeys,
      {oX}
      oxuScene, oxuEntity, oxuTimer,
      oxuComponent, oxuComponentDescriptors,
      oxuMaterial,
      {game}
      uGame, uMain;

CONST
   FIRST_KEY_TIMING = 0.350;
   KEY_TIMING = 0.080;

TYPE

   { TKeyTimingInfo }

   TKeyTimingInfo = record
       Time,
       FirstTimer: single;
       FirstFired: boolean;

       procedure Reset();
   end;

   { TDropBlocksComponent }

   TDropBlocksComponent = class(oxTComponent)
      public
         Keys: record
             Timers: record
                 {when was the key last pressed}
                 Left,
                 Right,
                 RotateLeft,
                 RotateRight,
                 Down,
                 FirstPressRotateDown: TKeyTimingInfo;
             end;
         end;

      procedure Start(); override;
      procedure Update(); override;

      procedure UpdateKeys();

      function GetDescriptor(): oxPComponentDescriptor; override;
   end;

   { TDropBlocksComponentGlobal }

  TDropBlocksComponentGlobal = record
      Descriptor: oxTComponentDescriptor;

      procedure Initialize();
   end;

VAR
   DropBlocksComponent: TDropBlocksComponentGlobal;

IMPLEMENTATION

VAR
   DropBlocksEntity: oxTEntity;

{ TKeyTimingInfo }

procedure TKeyTimingInfo.Reset();
begin
   FirstTimer := 0;
   Time := 0;
   FirstFired := false;
end;

{ TDropBlocksComponentGlobal }

procedure TDropBlocksComponent.Start();
begin
end;

procedure TDropBlocksComponent.Update();
begin
   UpdateKeys();

   if(not oxTime.Paused()) then begin
      game.Update(oxTime.Flow);
   end;
end;

function UpdateKeyTimer(kc: TKeyCode; var timer: TKeyTimingInfo): boolean;
begin
   Result := false;

   if(appk.JustPressed(kc)) then begin
      timer.Reset();
      exit(true);
   end;

   if(appk.IsPressed(kc)) then begin
      timer.FirstTimer := timer.FirstTimer + oxTime.Flow;

      if(timer.FirstTimer >= FIRST_KEY_TIMING) then begin
         if(not timer.FirstFired) then begin
            timer.FirstFired := true;
            timer.Time := timer.FirstTimer - FIRST_KEY_TIMING;
            exit(true);
         end;

         timer.Time := timer.Time + oxTime.Flow;

         if(timer.Time >= KEY_TIMING) then begin
            timer.Time := timer.Time - KEY_TIMING;
            Result := true;
         end;
      end;
   end;
end;

procedure TDropBlocksComponent.UpdateKeys();
begin
   if(UpdateKeyTimer(kcLEFT, Keys.Timers.Left)) then
      game.MoveShapeLeft();

   if(UpdateKeyTimer(kcRIGHT, Keys.Timers.Right)) then
      game.MoveShapeRight();

   if(UpdateKeyTimer(kcDOWN, Keys.Timers.Down)) then
      game.MoveShapeDown();

   if appk.JustPressed(kcUP) or appk.JustPressed(kcC) then
      game.DropShape();

   if(appk.JustPressed(kcY)) then
      game.RotateLeft();

   if(appk.JustPressed(kcZ)) then
      game.RotateLeft();

   if(appk.JustPressed(kcX)) then
      game.RotateRight();
end;

function TDropBlocksComponent.GetDescriptor(): oxPComponentDescriptor;
begin
   Result := @DropBlocksComponent.Descriptor;
end;

{ TGridGlobal }

procedure TDropBlocksComponentGlobal.Initialize();
begin
   DropBlocksComponent.Descriptor.Create('DropBlocks', TDropBlocksComponent);
   DropBlocksComponent.Descriptor.Name := 'DropBlocks';

   DropBlocksEntity := oxEntity.New('DropBlocks');
   DropBlocksEntity.Add(TDropBlocksComponent.Create());

   oxScene.Add(DropBlocksEntity);
end;

procedure init();
begin
   DropBlocksComponent.Initialize();
end;

INITIALIZATION
   main.OnInitScene.Add('dropblocks.component', @init);

END.
