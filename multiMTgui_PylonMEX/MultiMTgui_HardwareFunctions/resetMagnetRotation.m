function resetMagnetRotation(hMain)

handles = guidata(hMain);

handles.MotorObj.Axis(handles.magraxis).Reference();

getMagnetRotation(hMain);

