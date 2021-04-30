function MulitMTgui_ExposureAuto_Callback(hObject,eventdata)

handles = guidata(hObject);

v = get(hObject,'value');

if ~isnan(v)
    setCameraExposureAuto(handles.hMainWindow,v);
else
    getCameraExposureAuto(handles.hMainWindow);
end