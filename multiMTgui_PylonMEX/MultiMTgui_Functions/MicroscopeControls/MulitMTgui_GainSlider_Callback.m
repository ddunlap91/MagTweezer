function MulitMTgui_GainSlider_Callback(hObject,~)

handles = guidata(hObject);

v = get(hObject,'value');

if ~isnan(v)
    setCameraGain(handles.hMainWindow,v);
else
    getCameraGain(handles.hMainWindow);
end