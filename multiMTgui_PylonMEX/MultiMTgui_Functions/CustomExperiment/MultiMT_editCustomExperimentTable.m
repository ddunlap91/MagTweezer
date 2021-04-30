function MultiMT_editCustomExperimentTable(hTbl,event,hMain)

handles = guidata(hMain);
for n = 1:size(event.Indices,1)
    r = event.Indices(n,1);
    c = event.Indices(n,2);
    if c == 1 %step column do nothing
        continue;
    end
    col_name = hTbl.ColumnName{c};
    cell_data = hTbl.Data{r,c};
    if ischar(cell_data)
        cell_data = str2double(cell_data);
    end
    if numel(cell_data)==1
        [okflag,val] = MultiMT_ExpCheckVal(cell_data,col_name,hMain);
        if okflag
            handles.ExperimentScheme.ExperimentSteps(r).(col_name) = val;
            %Save data
            guidata(hMain,handles);
        end
    end
    hTbl.Data{r,c} = handles.ExperimentScheme.ExperimentSteps(r).(col_name);
end
