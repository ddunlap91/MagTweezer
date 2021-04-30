function MulitMTgui_FrameRate_Callback(hObject,eventdata)

handles = guidata(hObject);
if strcmpi(get(handles.hCtrl_FrameRate,'style'),'popupmenu')
    %find closest val in popup strings
    s = get(handles.hCtrl_FrameRate,'string');
    ind = get(handles.hCtrl_FrameRate,'value');
    fps = s{ind};
else
    fps = str2double(get(handles.hCtrl_FrameRate,'string'));
end

if ischar(fps)||~isnan(fps)
    setCameraFrameRate(handles.hMainWindow,fps);
else
    getCameraFrameRate(handles.hMainWindow);
end