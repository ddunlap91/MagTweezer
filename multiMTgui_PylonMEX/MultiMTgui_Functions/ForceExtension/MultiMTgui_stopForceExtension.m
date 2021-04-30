function MultiMTgui_stopForceExtension(hMain)
%stopCamera(hMain)

handles = guidata(hMain);

%stop experiment flag
handles.ExperimentRunning = false;
handles.ExperimentType = '';

try
delete(handles.FE_hWaitbar);
catch
end

%Files
%===========
%close files
try
fclose(handles.FE_FileID);
catch
end


%reset button text
fehandles = guidata(handles.hFig_ForceExtension);
set(fehandles.hBtn_FE_RunStop,'String','Run');
set(fehandles.hBtn_FE_RunStop,'ForegroundColor',[0,0.5,0]);
title(handles.hAx_CameraImageAxes,'');

%save data
guidata(hMain,handles);

%startCamera(hMain)