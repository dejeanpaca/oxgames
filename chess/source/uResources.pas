{$INCLUDE oxdefines.inc}
UNIT uResources;

INTERFACE

   USES
      uStd, uColors,
      {ox}
      oxuPaths,
      oxuModel, oxuModelFile, oxuMaterial,
      {game}
      uChess, uMain, uShared;

TYPE
   TPieceModel = record
      Black,
      White: oxTModel;
   end;

   { TResources }

   TResources = record
      Models: array[0..PIECE_TYPE_MAX] of TPieceModel;

      Materials: record
         Board,
         WhiteTile,
         BlackTile: oxTMaterial;
      end;

      procedure Initialize();
   end;

VAR
   resources: TResources;

IMPLEMENTATION

{ TResources }

procedure TResources.Initialize();
var
   i: loopint;
   pieceName: StdString;

begin
   {piece type none has no model}
   Models[0].Black := nil;
   Models[1].White := nil;

   {load models for all piece types}
   for i := 1 to PIECE_TYPE_MAX do begin
      pieceName := PIECE_NAMES[i];

      Models[i].Black :=
         oxfModel.Read(oxPaths.Find('models' + DirectorySeparator + 'black' + DirectorySeparator + pieceName + '.obj'));

      Models[i].White :=
         oxfModel.Read(oxPaths.Find('models' + DirectorySeparator + 'white' + DirectorySeparator + pieceName + '.obj'));
   end;

   Materials.Board := CreateMaterial('black_tile', TColor4ub.Create(127, 127, 127, 255));
   Materials.BlackTile := CreateMaterial('black_tile', cBlack4ub);
   Materials.WhiteTile := CreateMaterial('white_tile', cWhite4ub);
end;

procedure initialize();
begin
   resources.Initialize();
end;

procedure deinitialize();
begin

end;

INITIALIZATION
   main.Init.Add('menubar', @initialize, @deinitialize)

END.
