function setMagnetRotation(hMain,turns)
%sets the position of the piezo
% Inputs:
%   hMain = handle to main gui figure (hFigure_Main)
%   turns = a double specifying number of turns to set motor to 
% Note: This function will update the guidata

%get gui data
handles = guidata(hMain);

%update the objective position variable
handles.mag_rotpos = turns;

handles.MotorObj.Axis(handles.magraxis).setPosition(turns*handles.mag_rotscale);

if handles.controls_open
    set(handles.hEdt_MagnetRotation,'String',num2str(handles.mag_rotpos,'%0.02f'));
end

%update guidata
guidata(hMain,handles);
end