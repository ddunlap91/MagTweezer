function MultiMTgui_ROIclearROI(hObject,~)

phandles = guidata(hObject);
hMain = phandles.hMainWindow;
handles = guidata(hMain);

handles.MMcam.ClearROI();
handles.ROI_lastpos = [];
try
    delete(handles.ROI_hrect)
catch
end
guidata(hMain,handles);