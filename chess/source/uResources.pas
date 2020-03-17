{$INCLUDE oxdefines.inc}
UNIT uResources;

INTERFACE

   USES
      uStd,
      {ox}
      oxuModel, oxuModelFile, oxuPaths,
      {game}
      uChess, uMain;

TYPE
   TPieceModel = record
      Black,
      White: oxTModel;
   end;

   TResources = record
      Models: array[0..PIECE_TYPE_MAX] of TPieceModel;
   end;

VAR
   resources: TResources;

IMPLEMENTATION

procedure initialize();
var
   i: loopint;
   pieceName: StdString;

begin
   {piece type none has no model}
   resources.Models[0].Black := nil;
   resources.Models[1].White := nil;

   {load models for all piece types}
   for i := 1 to PIECE_TYPE_MAX do begin
      pieceName := PIECE_NAMES[i];

      resources.Models[i].Black :=
         oxfModel.Read(oxPaths.Find('models' + DirectorySeparator + 'black' + DirectorySeparator + pieceName + '.obj'));

      resources.Models[i].White :=
         oxfModel.Read(oxPaths.Find('models' + DirectorySeparator + 'white' + DirectorySeparator + pieceName + '.obj'));
   end;
end;

procedure deinitialize();
begin

end;

INITIALIZATION
   main.Init.Add('menubar', @initialize, @deinitialize)

END.
