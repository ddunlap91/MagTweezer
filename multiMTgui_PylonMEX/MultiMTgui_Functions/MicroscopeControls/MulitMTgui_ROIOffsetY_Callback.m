function MulitMTgui_ROIOffsetY_Callback(hObject,~)

phandles = guidata(hObject);
hMain = phandles.hMainWindow;
handles = guidata(hMain);

y = str2double(get(hObject,'string'));

if ~isnan(y)&&y>0
    roi = handles.MMcam.ROI;
    handles.MMcam.ROI = [roi(1),y,roi(3),roi(4)];
end
set(hObject,'string',num2str(handles.MMcam.ROI(2)));