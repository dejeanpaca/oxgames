{$INCLUDE oxdefines.inc}
UNIT uBoardSwitch;

INTERFACE

   USES
      {app}
      appuEvents, appuActionEvents,
      {games}
      uMain,
      uGameComponent,
      uBoard2D,
      uBoard3D,
      uScene;

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
   gameComponent.Entity.Empty();
end;

procedure switch3d();
begin
   main.Board3D := true;
   gameComponent.Entity.Empty();
end;

INITIALIZATION
   scene.OnInitialize.Add(@initialize);

   ACTION_SWITCH_2D := appActionEvents.SetCallback(@switch2d);
   ACTION_SWITCH_3D := appActionEvents.SetCallback(@switch3d);

END.
