function MulitMTgui_ROIWidth_Callback(hObject,~)

phandles = guidata(hObject);
hMain = phandles.hMainWindow;
handles = guidata(hMain);

w = str2double(get(hObject,'string'));

if ~isnan(w)&&w>0
    roi = handles.MMcam.ROI;
    handles.MMcam.ROI = [roi(1),roi(2),w,roi(4)];
end
set(hObject,'string',num2str(handles.MMcam.ROI(3)));