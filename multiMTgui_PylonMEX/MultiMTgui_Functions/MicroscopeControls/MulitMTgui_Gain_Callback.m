function MulitMTgui_Gain_Callback(hObject,eventdata)

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
    setCameraGain(handles.hMainWindow,val);
else
    getCameraGain(handles.hMainWindow);
end