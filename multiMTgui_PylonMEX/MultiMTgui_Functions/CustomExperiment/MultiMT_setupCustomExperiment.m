function MultiMT_setupCustomExperiment(hCE)

%% get data from handles
cehandles = guidata(hCE);
hMain = cehandles.hMainWindow;
handles = guidata(hMain);

handles.hFig_CustomExperiment = hCE;

if ~isfield(handles,'CustomExperiment_AutoName')
    handles.CustomExperiment_AutoName = true;
end

if ~isfield(handles,'CustomExperiment_FileName')
    handles.CustomExperiment_FileName = '';
end

if ~isfield(handles,'ExperimentScheme')
    handles.ExperimentScheme.OutputX = true;
    handles.ExperimentScheme.OutputY = true;
    handles.ExperimentScheme.OutputZ = true;
   % handles.ExperimentScheme.OutputZabs = true;
    %handles.ExperimentScheme.OutputZrel = true;
    handles.ExperimentScheme.CaptureOffline = true;
    handles.ExperimentScheme.MinimizeROI = true;
    handles.ExperimentScheme.FixedDuration = true;
    handles.ExperimentScheme.ExperimentSteps = struct('FrameCount',{},'Duration',{});
end

if ~isfield(handles,'CustomExperiment_Comments')
    handles.CustomExperiment_Comments = '';
end

%% Build Experiment Scheme Table
%================================
%make list of column names
cehandles.hTbl_ExperimentScheme = ...
    uiextras.jTable.Table(...
        'parent',cehandles.hPnl_ExperimentScheme,...
        'SelectionMode','discontiguous',...
        'CellEditCallback',{@MultiMT_editCustomExperimentTable,hMain});
%set table data and columns
MultiMT_ExpUpdateTableData(cehandles.hTbl_ExperimentScheme,handles.ExperimentScheme);
    
%% Context menu for table
%create context menu
cehandles.hTbl_ExperimentScheme.UIContextMenu = uicontextmenu(hCE);
ctx_menu = cehandles.hTbl_ExperimentScheme.UIContextMenu;

%insert row
uimenu(ctx_menu,'Label','Insert Step','Callback',...
@(src,event)MultiMT_ExpInsertRow(hMain,cehandles.hTbl_ExperimentScheme));
%delete row
uimenu(ctx_menu,'Label','Delete Step','Callback',...
@(src,event)MultiMT_ExpDeleteRow(hMain,cehandles.hTbl_ExperimentScheme));
%replicate N Rows
uimenu(ctx_menu,'Label','Replicate Step','Callback',...
@(src,event)MultiMT_ReplicateRow(hMain,cehandles.hTbl_ExperimentScheme));

%% Context menu for header
cehandles.hTbl_ExperimentScheme.HeaderUIContextMenu = uicontextmenu(hCE);
head_menu = cehandles.hTbl_ExperimentScheme.HeaderUIContextMenu;

%insert column
uimenu(head_menu,'Label','Add Parameter','Callback',...
@(~,~)MultiMT_ExpAddParameter(hMain,cehandles.hTbl_ExperimentScheme));

%remove column
uimenu(head_menu,'Label','Remove Parameter','Callback',...
@(~,~)MultiMT_ExpRemoveParameter(hMain,cehandles.hTbl_ExperimentScheme));

%set values 
uimenu(head_menu,'Label','Set value for selected','callback',...
@(~,~)MultiMT_ExpSetParamValueSelected(hMain,cehandles.hTbl_ExperimentScheme));   

uimenu(head_menu,'Label','Set values using range','callback',...
@(~,~)MultiMT_ExpSetParamValueRange(hMain,cehandles.hTbl_ExperimentScheme));
        
%% Other GUI Elements
%=============================

%% Data File Name
%==========================
set(cehandles.hEdt_Dir,'String',handles.data_dir);
[handles,cehandles] = MultiMT_updateCustomExperimentFileName(handles,cehandles);

%% Comments
set(cehandles.hEdt_Comments,'string',handles.CustomExperiment_Comments);

%% Capture Offline
set(cehandles.hChk_CaptureOffline,'value',handles.ExperimentScheme.CaptureOffline);

%% Minimize ROI
set(cehandles.hChk_MinimizeROI,'value',handles.ExperimentScheme.MinimizeROI);

%% Fixed Duration/FrameCount
set(cehandles.hRad_FixedFrameCount,'value',~handles.ExperimentScheme.FixedDuration);
set(cehandles.hRad_FixedDuration,'value',handles.ExperimentScheme.FixedDuration);

%% Output Data
set(cehandles.hChk_OutputX,'value',handles.ExperimentScheme.OutputX);
set(cehandles.hChk_OutputY,'value',handles.ExperimentScheme.OutputY);
set(cehandles.hChk_OutputZ,'value',handles.ExperimentScheme.OutputZ);
%set(cehandles.hChk_OutputZrel,'value',handles.ExperimentScheme.OutputZrel);

%% Plot List
set(cehandles.hLst_DataPlots,'String',...
   {'Length v. Mag. Height',...
    'Length v. Mag. Rotation',...
    'Force v. Mag. Height',...
    'Force v. Mag. Rotation',...
    'Force v. Length'});

%% Checkbox on main menu
set(handles.hMenu_CustomExperiment,'checked','on');

%% Save GUIDATA
guidata(hMain,handles);
guidata(hCE,cehandles);

    