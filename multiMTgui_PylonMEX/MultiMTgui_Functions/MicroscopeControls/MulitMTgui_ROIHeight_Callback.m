function MulitMTgui_ROIHeight_Callback(hObject,~)

phandles = guidata(hObject);
hMain = phandles.hMainWindow;
handles = guidata(hMain);

h = str2double(get(hObject,'string'));

if ~isnan(h)&&h>0
    roi = handles.MMcam.ROI;
    handles.MMcam.ROI = [roi(1),roi(2),roi(3),h];
end
set(hObject,'string',num2str(handles.MMcam.ROI(4)));