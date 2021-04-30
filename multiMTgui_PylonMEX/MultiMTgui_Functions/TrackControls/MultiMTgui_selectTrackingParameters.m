function MultiMTgui_selectTrackingParameters(hTable,event,hMain)

handles = guidata(hMain);

handles.current_track_selection = event.Indices;

guidata(hMain,handles);
