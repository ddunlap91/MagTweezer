function MultiMTgui_closeTrackingControls(hMain)

handles=guidata(hMain);

try
    delete(handles.hFig_TrackingControls);
catch
end
handles.tracking_open = false;
set(handles.hMenu_TrackingControls,'Checked','off');
guidata(hMain,handles);