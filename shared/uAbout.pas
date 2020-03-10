{$INCLUDE oxdefines.inc}
UNIT uAbout;

INTERFACE

   USES
      uMain,
      {ox}
      oxuwndAbout;

IMPLEMENTATION

procedure initialize();
begin
   oxwndAbout.ResetLinks();

   oxwndAbout.AddLink('=> Github', 'https://github.com/dejeanpaca/oxgames');
end;


INITIALIZATION
   main.Init.Add('about', @initialize)

END.
