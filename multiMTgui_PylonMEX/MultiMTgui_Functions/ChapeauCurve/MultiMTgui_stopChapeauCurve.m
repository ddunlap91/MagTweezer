function MultiMTgui_stopChapeauCurve(hMain)
stopCamera(hMain)

handles = guidata(hMain);

%stop experiment flag
handles.ExperimentRunning = false;
handles.ExperimentType = '';

try
    delete(handles.CC_hWaitbar);
catch
end

%Files
%===========
%close files
try
fclose(handles.CC_FileID);
if handles.CC_WriteXYZ
    fclose(handles.CC_XY_FileID);
    fclose(handles.CC_Z_FileID);
end
catch
end

%reset button text
cchandles = guidata(handles.hFig_ChapeauCurve);
set(cchandles.hBtn_CC_RunStop,'String','Run');
set(cchandles.hBtn_CC_RunStop,'ForegroundColor',[0,0.5,0]);
title(handles.hAx_CameraImageAxes,'');

%save data
guidata(hMain,handles);

startCamera(hMain)