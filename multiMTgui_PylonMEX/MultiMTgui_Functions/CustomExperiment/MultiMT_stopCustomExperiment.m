function MultiMT_stopCustomExperiment(hMain)
handles = guidata(hMain);
cehandles = guidata(handles.hFig_CustomExperiment);

set(cehandles.hEdt_Dir,'enable','on');
set(cehandles.hEdt_FileName,'enable','on');
set(cehandles.hChk_AutoName,'enable','on');
set(cehandles.hEdt_Comments,'enable','on');
set(cehandles.hRad_FixedFrameCount,'enable','on');
set(cehandles.hRad_FixedDuration,'enable','on');
set(cehandles.hBtn_ClearAll,'enable','on');
set(cehandles.hChk_CaptureOffline,'enable','on');
set(cehandles.hChk_MinimizeROI,'enable','on');
set(cehandles.hChk_OutputX,'enable','on');
set(cehandles.hChk_OutputY,'enable','on');
set(cehandles.hChk_OutputZ,'enable','on');
% set(cehandles.hChk_OutputZrel,'enable','on');
% set(cehandles.hChk_OutputZabs,'enable','on');

set(cehandles.hBtn_StartPause,'String','START','ForegroundColor',[0,.5,0]);

handles = MultiMT_updateCustomExperimentFileName(handles,cehandles);

try
fclose(handles.CustomExperiment_FileID);
catch
end

handles.MMcam.ROI = handles.ROI_PreCustomExperiment;

handles.CustomExperiment_OfflineModeRunning = false;
handles.CustomExperiment_paused = false;
handles.CustomExperiment_LiveModeRunning = false;

try
    delete(handles.CustExp_hWaitbar)
catch
end

guidata(hMain,handles);
setInFunctionFlag(hMain,false);
startCamera(hMain);