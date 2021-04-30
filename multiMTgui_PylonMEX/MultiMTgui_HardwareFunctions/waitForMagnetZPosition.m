function waitForMagnetZPosition(hMain)

%get gui data
handles = guidata(hMain);
handles.MotorObj.Axis(handles.magzaxis).WaitForOnTarget();

