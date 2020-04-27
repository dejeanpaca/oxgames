{$INCLUDE oxdefines.inc}
UNIT uResources;

INTERFACE

   USES
      uStd, uColors,
      {ox}
      oxuResourcePool, oxuPaths, oxuTexture,
      oxuModel, oxuModelFile, oxuMaterial,
      oxuGlyph,
      {game}
      uChess, uMain, uShared;

CONST
   PIECE_2D_ICONS: array[0..PIECE_TYPE_MAX] of loopint = (
      0, {none}
      $f443, {Pawn}
      $f441, {Knight}
      $f43a, {bishop}
      $f447, {Rook}
      $f445, {Queen}
      $f43f {King}
   );

TYPE
   TPieceModel = record
      Black,
      White: oxTModel;
   end;

   TPieceIcon = oxTTexture;

   { TResources }

   TResources = record
      Models: array[0..PIECE_TYPE_MAX] of TPieceModel;
      Icons: array[0..PIECE_TYPE_MAX] of TPieceIcon;
      Board: oxTModel;

      Materials: record
         Board,
         WhiteTile,
         BlackTile: oxTMaterial;
      end;

      procedure Initialize();
      procedure Deinitialize();

      function GetModel(piece: TPieceType; player: TPlayer): oxTModel;
   end;

VAR
   resources: TResources;

IMPLEMENTATION

CONST
   MODEL_SCALE = 4.0;

function getPieceModel(const base, name: StdString): oxTModel;

begin
   Result := oxfModel.Read(oxPaths.Find('models' + DirectorySeparator + base + DirectorySeparator + name + '.obj'));

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

      Models[i].Black := getPieceModel('black', pieceName);
      Models[i].White := getPieceModel('white', pieceName);
   end;

   {board materials}

   Materials.Board := CreateMaterial('black_tile', TColor4ub.Create(127, 127, 127, 255));
   Materials.BlackTile := CreateMaterial('black_tile', cBlack4ub);
   Materials.WhiteTile := CreateMaterial('white_tile', cWhite4ub);

   {2d icons}
   Icons[0] := nil;
   for i := 1 to PIECE_TYPE_MAX do begin
      Icons[i] := oxGlyphs.Load(PIECE_2D_ICONS[i], 64);
   end;
end;

procedure TResources.Deinitialize();
var
   i: loopint;

begin
   for i := 1 to PIECE_TYPE_MAX do begin
      oxResource.Destroy(Models[i].Black);
      oxResource.Destroy(Models[i].White);
      oxResource.Destroy(resources.Icons[i]);
   end;
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
   resources.Deinitialize();
end;

INITIALIZATION
   main.Init.Add('menubar', @initialize, @deinitialize)

END.
