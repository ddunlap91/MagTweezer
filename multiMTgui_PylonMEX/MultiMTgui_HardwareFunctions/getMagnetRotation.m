function pos= getMagnetRotation(hMain)
%sets the position of the piezo
% Inputs:
%   hMain = handle to main gui figure (hFigure_Main)
%   turns = a double specifying number of turns to set motor to 
% Note: This function will update the guidata

%get gui data
handles = guidata(hMain);

turns = handles.MotorObj.Axis(handles.magraxis).Position;

%update the objective position variable
handles.mag_rotpos = turns/handles.mag_rotscale;

%update contols if needed
if handles.controls_open
    set(handles.hEdt_MagnetRotation,'String',num2str(handles.mag_rotpos,'%0.02f'));
end

%update guidata
guidata(hMain,handles);
pos = handles.mag_rotpos;
end