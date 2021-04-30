function MultiMTgui_stopRecording(hMain)

handles = guidata(hMain);
rechandles = guidata(handles.hFig_RecordXYZ);

handles.RecXYZ_Recording = false;
%Save Data
guidata(hMain,handles);

%close Data File
fclose(handles.RecXYZ_FileID);

try
    set(rechandles.hBtn_RecXYZ_StartStopRecord,'ForegroundColor',[0,0.5,0],'String','Start');
catch
end

