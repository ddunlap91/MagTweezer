function MultiMT_ExpRemoveParameter(hMain,hTbl)

handles = guidata(hMain);

col_name = hTbl.ColumnName{hTbl.ClickColumn};

if any(strcmp(col_name,{'Step','Duration','FrameCount'}))
    return;
end


handles.ExperimentScheme.ExperimentSteps = ...
    rmfield(handles.ExperimentScheme.ExperimentSteps,col_name);

%update table data

MultiMT_ExpUpdateTableData(hTbl,handles.ExperimentScheme);

%save data
guidata(hMain,handles);

