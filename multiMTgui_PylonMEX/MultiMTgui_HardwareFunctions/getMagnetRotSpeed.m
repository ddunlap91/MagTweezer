function speed = getMagnetRotSpeed(hMain)
%sets the position of the piezo
% Inputs:
%   hMain = handle to main gui figure (hFigure_Main)
% Note: This function will update the guidata

%get gui data
handles = guidata(hMain);

speed = handles.MotorObj.Axis(handles.magraxis).Velocity;

%update the variable
handles.mag_rotspeed = speed/handles.mag_rotscale;

%update gui
if handles.controls_open
    set(handles.hEdt_MagnetRotationSpeed,'String',...
        num2str(handles.mag_rotspeed,'%0.02f'));
end

%update guidata
guidata(hMain,handles);
speed = handles.mag_rotspeed;
end