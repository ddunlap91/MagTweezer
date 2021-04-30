function MulitMTgui_ROICenterX_Callback(hObject,~)

phandles = guidata(hObject);
hMain = phandles.hMainWindow;
handles = guidata(hMain);

v = str2double(get(hObject,'value'));


set(hObject,'value',0);
