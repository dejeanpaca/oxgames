{$INCLUDE oxdefines.inc}
UNIT uResources;

INTERFACE

   USES
      uStd, uColors,
      {ox}
      oxuResourcePool, oxuPaths, oxuTexture,
      oxuModel, oxuModelFile, oxuMaterial,
      oxuGlyphs,
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

   { TPiece2DMaterial }

   TPiece2DMaterial = record
      Black,
      White: oxTMaterial;
   end;

   { TResources }

   TResources = record
      Models: array[0..PIECE_TYPE_MAX] of TPieceModel;
      Icons: array[0..PIECE_TYPE_MAX] of TPieceIcon;
      Board: oxTModel;

      Materials: record
         Background,
         WhiteTile,
         BlackTile,
         WhiteTileSelected,
         BlackTileSelected: oxTMaterial;

         Pieces2D: array[0..PIECE_TYPE_MAX] of TPiece2DMaterial;
      end;

      procedure Initialize();
      procedure Deinitialize();

      function GetModel(piece: TPieceType; player: TPlayer): oxTModel;
      function GetPieceMaterial2D(piece: TPieceType; player: TPlayer): oxTMaterial;
   end;

VAR
   resources: TResources;

IMPLEMENTATION

CONST
   MODEL_SCALE = 4.0;

function loadPieceModel(const base, name: StdString): oxTModel;

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
   Board :=
      oxfModel.Read(oxPaths.Find('models' + DirectorySeparator + 'board' + DirectorySeparator + 'board.obj'));

   {load models for all piece types}
   for i := 1 to PIECE_TYPE_MAX do begin
      pieceName := PIECE_IDS[i];

      Models[i].Black := loadPieceModel('black', pieceName);
      Models[i].White := loadPieceModel('white', pieceName);
   end;

   {board materials}

   Materials.Background := CreateMaterial('board_background', TColor4ub.Create(32, 64, 64, 255));
   Materials.BlackTile := CreateMaterial('black_tile', TColor4ub.Create(115, 115, 115, 255));
   Materials.WhiteTile := CreateMaterial('white_tile', TColor4ub.Create(175, 175, 175, 255));
   Materials.BlackTileSelected := CreateMaterial('black_tile_selected', TColor4ub.Create(115, 115, 255, 255));
   Materials.WhiteTileSelected := CreateMaterial('white_tile_selected', TColor4ub.Create(175, 175, 255, 255));

   {2d icons}
   for i := 1 to PIECE_TYPE_MAX do begin
      Icons[i] := oxGlyphs.Load(PIECE_2D_ICONS[i], 64);
   end;

   {create 2d materials}
   for i := 1 to PIECE_TYPE_MAX do begin
      Materials.Pieces2D[i].Black := CreateMaterial(PIECE_IDS[i] + '_black',
         TColor4ub.Create(0, 0, 0, 255), Icons[i]);

      Materials.Pieces2D[i].White := CreateMaterial(PIECE_IDS[i] + '_white',
         TColor4ub.Create(255, 255, 255, 255), Icons[i]);
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

function TResources.GetPieceMaterial2D(piece: TPieceType; player: TPlayer): oxTMaterial;
begin
   if(player = PLAYER_BLACK) then
      Result := Materials.Pieces2D[loopint(piece)].Black
   else begin
      Result := Materials.Pieces2D[loopint(piece)].White
   end;
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
