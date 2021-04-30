function status = setMagnetZPosition(hMain,pos)
%sets the position of the piezo
% Inputs:
%   hMain = handle to main gui figure (hFigure_Main)
%   pos = a double specifying absolute piezo position (in µm)
%       If pos is outside the limits of the piezo it will default to the
%       closest limit.
% Note: This function will update the guidata

%get gui data
handles = guidata(hMain);

pos = min(pos,handles.mag_zlim(2));
pos = max(pos,handles.mag_zlim(1));

handles.MotorObj.Axis(handles.magzaxis).setPosition(pos);

handles.mag_zpos = pos;

%update gui
if handles.controls_open
    set(handles.hEdt_MagnetHeight,'String',...
        num2str(handles.mag_zpos,'%0.02f'));
    set(handles.hSld_MagnetHeight,'value',handles.mag_zpos);
end

%update guidata
guidata(hMain,handles);
end