{$INCLUDE oxdefines.inc}
UNIT uDropBlocksComponent;

INTERFACE

   USES
      appuKeys,
      {oX}
      oxuScene, oxuEntity, oxuTimer,
      oxuComponent, oxuComponentDescriptors,
      oxuMaterial,
      {game}
      uGame, uDropBlocks;

TYPE
   { TDropBlocksComponent }

   TDropBlocksComponent = class(oxTComponent)
      public

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

procedure TDropBlocksComponent.UpdateKeys();
begin
   if appk.JustPressed(kcLEFT) then
      game.MoveShapeLeft();

   if appk.JustPressed(kcRIGHT) then
      game.MoveShapeRight();

   if appk.JustPressed(kcDOWN) then
      game.MoveShapeDown();

   if appk.JustPressed(kcUP) or appk.JustPressed(kcC) then
      game.DropShape();

   if appk.JustPressed(kcY) or appk.JustPressed(kcZ) then
      game.RotateLeft();

   if appk.JustPressed(kcX) then
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
   DropBlocks.OnInitScene.Add('dropblocks.component', @init);

END.
