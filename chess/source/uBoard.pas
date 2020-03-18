{$INCLUDE oxdefines.inc}
UNIT uBoard;

INTERFACE

   USES
      uStd, uLog, uColors,
      {oX}
      oxuPaths, oxuTexture, oxuTextureGenerate,
      oxuScene, oxuEntity,
      oxuComponent, oxuComponentDescriptors,
      oxuCameraComponent,
      oxuMaterial, oxumPrimitive, oxuPrimitiveModelComponent,
      {game}
      uGame, uScene;

TYPE
   { TBoardComponent }

   TBoardComponent = class(oxTComponent)
      public

      procedure Load(); override;
      procedure Update(); override;

      function GetDescriptor(): oxPComponentDescriptor; override;
   end;

   { TBoardGlobal }

   TBoardGlobal = record
      Descriptor: oxTComponentDescriptor;
      Entity: oxTEntity;

      procedure Initialize();
   end;

VAR
   board: TBoardGlobal;

IMPLEMENTATION

procedure TBoardComponent.Load();
begin
   {TODO: Load materials}
end;

procedure TBoardComponent.Update();
begin
end;

function TBoardComponent.GetDescriptor(): oxPComponentDescriptor;
begin
   Result := @board.Descriptor;
end;

{ TBoardGlobal }

procedure TBoardGlobal.Initialize();
begin
   board.Descriptor.Create('board', TBoardComponent);
   board.Descriptor.Name := 'Board';

   Entity := oxEntity.New('Board');
   Entity.Add(TBoardComponent.Create());

   Entity.LoadComponentsInChildren();

   oxScene.Add(Entity);
end;

procedure initialize();
begin
   board.Initialize();
end;

INITIALIZATION
   scene.OnInitialize.Add(@initialize);

END.
