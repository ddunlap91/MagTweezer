function MultiMT_ExpDeleteRow(hMain,hTbl)

if isempty(hTbl.SelectedRows)
    return;
end

handles = guidata(hMain);

handles.ExperimentScheme.ExperimentSteps(hTbl.SelectedRows) = [];

%update table data
MultiMT_ExpUpdateTableData(hTbl,handles.ExperimentScheme);

hTbl.SelectedRows = [];

%update data
guidata(hMain,handles);

