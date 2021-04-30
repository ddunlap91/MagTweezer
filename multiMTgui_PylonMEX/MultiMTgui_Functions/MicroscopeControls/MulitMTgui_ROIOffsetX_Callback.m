function MulitMTgui_ROIOffsetX_Callback(hObject,~)
phandles = guidata(hObject);
hMain = phandles.hMainWindow;
handles = guidata(hMain);

x = str2double(get(hObject,'string'));

if ~isnan(x)&&x>0
    roi = handles.MMcam.ROI;
    handles.MMcam.ROI = [x,roi(2),roi(3),roi(4)];
end
set(hObject,'string',num2str(handles.MMcam.ROI(1)));