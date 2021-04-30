function MulitMTgui_ExposureSlider_Callback(hObject,eventdata)

handles = guidata(hObject);
v = get(hObject,'value');
setCameraExposure(handles.hMainWindow,v);