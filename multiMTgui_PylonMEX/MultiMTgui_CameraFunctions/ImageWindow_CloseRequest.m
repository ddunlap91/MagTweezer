function ImageWindow_CloseRequest(~,~,hMain)

handles = guidata(hMain);

handles.MMcam.setDrawImage(false);

delete(handles.hFig_ImageWindow);
set(handles.hMenu_ImagePreview,'checked','off');
handles.imagefig_open = false;


%clear text labels
handles.track_xyzlabel = [];

guidata(hMain,handles);
