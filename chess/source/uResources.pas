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
      Board: oxTModel;

      Materials: record
         Board,
         WhiteTile,
         BlackTile: oxTMaterial;
      end;

      procedure Initialize();
      function GetModel(piece: TPieceType; player: TPlayer): oxTModel;
   end;

VAR
   resources: TResources;

IMPLEMENTATION

CONST
   MODEL_SCALE = 4.0;

function getPieceModel(const name: string): oxTModel;

begin
   Result := oxfModel.Read(oxPaths.Find('models' + DirectorySeparator + 'black' + DirectorySeparator + name + '.obj'));

   if(Result <> nil) then
      Result.Scale(MODEL_SCALE, MODEL_SCALE, MODEL_SCALE);
end;

{ TResources }

procedure TResources.Initialize();
var
   i: loopint;
   pieceName: StdString;

begin
   {piece type none has no model}
   Models[0].Black := nil;
   Models[1].White := nil;

   Board :=
      oxfModel.Read(oxPaths.Find('models' + DirectorySeparator + 'board' + DirectorySeparator + 'board.obj'));

   {load models for all piece types}
   for i := 1 to PIECE_TYPE_MAX do begin
      pieceName := PIECE_IDS[i];

      Models[i].Black := getPieceModel(pieceName);

      Models[i].White := getPieceModel(pieceName);
   end;

   Materials.Board := CreateMaterial('black_tile', TColor4ub.Create(127, 127, 127, 255));
   Materials.BlackTile := CreateMaterial('black_tile', cBlack4ub);
   Materials.WhiteTile := CreateMaterial('white_tile', cWhite4ub);
end;

function TResources.GetModel(piece: TPieceType; player: TPlayer): oxTModel;
begin
   if(player = PLAYER_BLACK) then
      Result := Models[loopint(piece)].Black
   else
      Result := Models[loopint(piece)].White;
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
