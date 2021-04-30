function setMagnetRotSpeed(hMain,speed)
%sets the position of the piezo
% Inputs:
%   hMain = handle to main gui figure (hFigure_Main)
%   speed = a double specifying speed
%       If speed is outside the limits it will default to the
%       closest limit.
% Note: This function will update the guidata

%get gui data
handles = guidata(hMain);

if speed<=0
    speed = 0.01;
end
speed = min(speed,handles.mag_maxrotvel);
disp(handles.mag_maxrotvel)
handles.MotorObj.Axis(handles.magraxis).setVelocity(speed*handles.mag_rotscale);

handles.mag_rotspeed = speed;

if handles.controls_open
    set(handles.hEdt_MagnetRotationSpeed,'String',...
        num2str(handles.mag_rotspeed,'%0.02f'));
end

%update guidata
guidata(hMain,handles);
end