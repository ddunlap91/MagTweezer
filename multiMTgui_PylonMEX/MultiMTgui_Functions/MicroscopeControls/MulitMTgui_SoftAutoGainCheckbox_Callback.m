function MulitMTgui_SoftAutoGainCheckbox_Callback(hObject,~)

handles = guidata(hObject);

v = logical(get(hObject,'value'));

setCameraSoftAutoGainEnable(handles.hMainWindow,v);