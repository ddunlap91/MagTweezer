function MulitMTgui_Brightness_Callback(hObject,eventdata)

handles = guidata(hObject);
if strcmpi(get(hObject,'style'),'popupmenu')
    %find closest val in popup strings
    s = get(hObject,'string');
    ind = get(hObject,'value');
    val = s{ind};
else
    val = str2double(get(hObject,'string'));
end


if ischar(val)||~isnan(val)
    setCameraBrightness(handles.hMainWindow,val);
else
    getCameraFrameRate(handles.hMainWindow);
end