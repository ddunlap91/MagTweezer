function MultiMT_ExpSetParamValueSelected(hMain,hTbl)

handles = guidata(hMain);

col_name = hTbl.ColumnName{hTbl.ClickColumn};
sel_rows = hTbl.SelectedRows;
if any(strcmp(col_name,{'Step'}))
    return;
end

%% Dialog
while true
    answer = inputdlg(col_name,'New value for selected rows',1,{''});

    if isempty(answer)
        return;
    end
    
    new_val = str2double(answer{1});
    [val_ok,new_val] = MultiMT_ExpCheckVal(new_val,col_name,hMain);
    if val_ok
        break;
    end     
end

%% set value
[handles.ExperimentScheme.ExperimentSteps(sel_rows).(col_name)] = deal(new_val);


%% update table & data
%update table data
MultiMT_ExpUpdateTableData(hTbl,handles.ExperimentScheme);
%update data
guidata(hMain,handles);



    