function setMagnetZSpeed(hMain,speed)
%sets the position of the piezo
% Inputs:
%   hMain = handle to main gui figure (hFigure_Main)
%   speed = a double specifying speed
%       If speed is outside the limits it will default to the
%       closest limit.
% Note: This function will update the guidata

%get gui data
handles = guidata(hMain);

speed = max(0.1,speed);
speed = min(handles.mag_maxzvel,speed);
disp(handles.mag_maxzvel);
handles.MotorObj.Axis(handles.magzaxis).setVelocity(speed);

%update the variable
handles.mag_zspeed = speed;

%update gui
if handles.controls_open
    set(handles.hEdt_MagnetHeightSpeed,'String',...
        num2str(handles.mag_zspeed,'%0.02f'));
end

%update guidata
guidata(hMain,handles);
end