function waitForMagnetRotation(hMain)

%get gui data
handles = guidata(hMain);
handles.MotorObj.Axis(handles.magraxis).WaitForOnTarget();

