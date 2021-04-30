function MultiMTgui_resume(hMain)

handles = guidata(hMain);
set(handles.hTxt_PauseStatus,'String','');
set(handles.hMenu_PauseResume,'Label','Pause');
handles.PauseSystem = false;

guidata(hMain,handles);