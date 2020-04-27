{$INCLUDE oxdefines.inc}
UNIT uBoard2D;

INTERFACE

   USES
      uStd, StringUtils,
      {ox}
      oxuProjectionType, oxuProjection,
      oxuCameraComponent, oxuEntity,
      oxuPrimitiveModelEntities, oxuPrimitiveModelComponent,
      {game}
      uScene, uShared, uResources, uGameComponent;

TYPE
   { TBoard2D }

   TBoard2D = record
      Board: oxTEntity;

      procedure Empty();
      procedure BuildBoard();
      procedure Activate();
   end;

VAR
   board2d: TBoard2D;

IMPLEMENTATION

{ TBoard2D }

procedure TBoard2D.Empty();
begin

end;

procedure TBoard2D.BuildBoard();
var
   entity: oxTEntity;
   mesh: oxTPrimitiveModelComponent;
   gridSize: TGridElementsSize;
   i, j: loopint;

begin
   TGridElementsSize.Initialize(gridSize);
   gridSize.Get(scene.Camera, 8, 8);

   {setup board}
   Board := oxEntity.New('Board');

   for i := 0 to 7 do begin
      for j := 0 to 7 do begin
         entity := oxPrimitiveModelEntities.Plane();

         entity.Name := sf(i) + 'x' + sf(j);
         entity.SetPosition(i * gridSize.d * 2  - gridSize.halfW , j * gridSize.d * 2 - gridSize.halfH, 0);
         entity.SetScale(gridSize.d, gridSize.d, 1);

         mesh := oxTPrimitiveModelComponent(entity.GetComponent('oxTPrimitiveModelComponent'));

         if((i * 7 + j) mod 2 = 0) then
            mesh.Model.SetMaterial(resources.Materials.BlackTile)
         else
           mesh.Model.SetMaterial(resources.Materials.WhiteTile);

         Board.Add(entity);
      end;
   end;

   gameComponent.Entity.Add(Board);
end;

procedure TBoard2D.Activate();
var
   projection: oxPProjection;

begin
   projection := scene.Camera.GetProjection();
   projection^.DefaultOrtho();

   BuildBoard();
end;

END.
