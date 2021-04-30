function MulitMTgui_GainAuto_Callback(hObject,~)

handles = guidata(hObject);

v = get(hObject,'value');

if ~isnan(v)
    setCameraGainAuto(handles.hMainWindow,v);
else
    getCameraGainAuto(handles.hMainWindow);
end