function MultiMTgui_pause(hMain)

handles = guidata(hMain);
set(handles.hTxt_PauseStatus,'String','Paused');
set(handles.hMenu_PauseResume,'Label','Resume');
handles.PauseSystem = true;

guidata(hMain,handles);