function MulitMTgui_BrightnessSlider_Callback(hObject,~)

handles = guidata(hObject);

v = get(hObject,'value');
setCameraBrightness(handles.hMainWindow,v);
