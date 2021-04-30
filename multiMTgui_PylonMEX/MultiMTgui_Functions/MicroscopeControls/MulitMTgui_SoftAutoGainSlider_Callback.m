function MulitMTgui_SoftAutoGainSlider_Callback(hObject,~)

handles = guidata(hObject);

v = get(hObject,'value');

if ~isnan(v)
    setCameraSoftAutoGainIntensity(handles.hMainWindow,v);
else
    getCameraSoftAutoGainIntensity(handles.hMainWindow);
end