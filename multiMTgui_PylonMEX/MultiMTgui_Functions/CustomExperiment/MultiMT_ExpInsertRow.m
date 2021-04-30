function MultiMT_ExpInsertRow(hMain,hTbl)

handles = guidata(hMain);

sel_row = min(hTbl.SelectedRows);

if isempty(sel_row) %after table
    sel_row = numel(handles.ExperimentScheme.ExperimentSteps)+1;
end

fields = fieldnames(handles.ExperimentScheme.ExperimentSteps);
fields = [fields,cell(size(fields))]';
new_row = struct(fields{:});

%insert row above lowest selected position
handles.ExperimentScheme.ExperimentSteps = ...
[handles.ExperimentScheme.ExperimentSteps(1:sel_row-1),...
    new_row,...
    handles.ExperimentScheme.ExperimentSteps(sel_row:end)];

%update table data
MultiMT_ExpUpdateTableData(hTbl,handles.ExperimentScheme);

%set selected row to the inserted row
hTbl.SelectedRows = sel_row;



%Save data
guidata(hMain,handles);