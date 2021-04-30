function MulitMTgui_SoftAutoGain_Callback(hObject,~)

handles = guidata(hObject);
val = str2double(get(hObject,'string'));

if ~isnan(val)
    setCameraSoftAutoGainIntensity(handles.hMainWindow,val);
else
    getCameraSoftAutoGainIntensity(handles.hMainWindow);
end
