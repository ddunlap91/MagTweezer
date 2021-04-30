function getMagnetZSpeed(hMain)
%sets the position of the piezo
% Inputs:
%   hMain = handle to main gui figure (hFigure_Main)
% Note: This function will update the guidata

%get gui data
handles = guidata(hMain);

speed = handles.MotorObj.Axis(handles.magzaxis).Velocity;

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