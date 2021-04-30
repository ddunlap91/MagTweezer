function MultiMT_closeCustomExperiment(hMain,hCE)

handles = guidata(hMain);

if (handles.CustomExperiment_OfflineModeRunning ||...
        handles.CustomExperiment_LiveModeRunning ||...
        handles.CustomExperiment_paused)
    warndlg('Experiment is running or paused. Reset experiment then close');
    return;
end

cehandles = guidata(hCE);


%% save comments
handles.CustomExperiment_Comments = get(cehandles.hEdt_Comments,'string');

%% close figure
delete(hCE);

%% uncheck menu
set(handles.hMenu_CustomExperiment,'checked','off');

%% save data
handles.hFig_CustomExperiment = [];
guidata(hMain,handles)