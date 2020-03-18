{$INCLUDE oxdefines.inc}
UNIT uBoardSwitch;

INTERFACE

   USES
      {app}
      appuEvents, appuActionEvents,
      {games}
      uMain,
      uBoard2D,
      uBoard3D;

VAR
   ACTION_SWITCH_2D,
   ACTION_SWITCH_3D: TEventID;

IMPLEMENTATION

procedure initialize();
begin
   if(main.Board3D) then
      board3d.Activate()
   else
      board2d.Activate();
end;

procedure switch2d();
begin
   main.Board3D := false;
end;

procedure switch3d();
begin
   main.Board3D := true;
end;

INITIALIZATION
   main.Init.Add('board.switch', @initialize);

   ACTION_SWITCH_2D := appActionEvents.SetCallback(@switch2d);
   ACTION_SWITCH_3D := appActionEvents.SetCallback(@switch3d);

END.
