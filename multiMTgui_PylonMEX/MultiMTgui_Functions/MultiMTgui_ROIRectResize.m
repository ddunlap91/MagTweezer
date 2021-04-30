function MultiMTgui_ROIRectResize(hrect,hMain)
stopCamera(hMain);
pause(0.01);
handles = guidata(hMain);
handles.MMcam.ROI = get(hrect,'position');
set(hrect,'position',handles.MMcam.ROI);
handles.ROI_lastpos = handles.MMcam.ROI;

guidata(hMain,handles);
startCamera(hMain);
pause(0.01);