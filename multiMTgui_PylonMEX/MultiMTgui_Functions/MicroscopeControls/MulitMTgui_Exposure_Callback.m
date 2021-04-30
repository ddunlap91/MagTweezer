function MulitMTgui_Exposure_Callback(hObject,eventdata)

handles = guidata(hObject);

v = get(hObject,'string');
v = str2double(v);

if ~isnan(v)
    setCameraExposure(handles.hMainWindow,v);
else
    getCameraExposure(handles.hMainWindow);
end