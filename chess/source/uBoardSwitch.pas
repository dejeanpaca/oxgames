{$INCLUDE oxdefines.inc}
UNIT uBoardSwitch;

INTERFACE

   USES
      uLog,
      {app}
      appuEvents, appuActionEvents,
      {games}
      uMain,
      uGame,
      uGameComponent,
      uBoard,
      uBoard2D,
      uBoard3D,
      uScene;

VAR
   ACTION_SWITCH_2D,
   ACTION_SWITCH_3D: TEventID;

IMPLEMENTATION

procedure switch2d();
begin
   log.v('Switching board to 2d');
   main.Board3D := false;
   CurrentBoard := @board2d;
   CurrentBoard^.SwitchTo();
end;

procedure switch3d();
begin
   log.v('Switching board to 3d');
   main.Board3D := true;
   CurrentBoard := @board3d;
   CurrentBoard^.SwitchTo();
end;

procedure initialize();
begin
   if(main.Board3D) then
      switch3d()
   else
      switch2d();
end;

INITIALIZATION
   scene.OnInitialize.Add(@initialize);

   ACTION_SWITCH_2D := appActionEvents.SetCallback(@switch2d);
   ACTION_SWITCH_3D := appActionEvents.SetCallback(@switch3d);

END.
