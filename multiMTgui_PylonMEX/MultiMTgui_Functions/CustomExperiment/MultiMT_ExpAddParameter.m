function MultiMT_ExpAddParameter(hMain,hTbl)

handles = guidata(hMain);

%ExpSteps = handles.ExperimentScheme.ExperimentSteps;

%find list of currenly used parameters
AllExpParams = {'ObjectivePosition','MagnetHeight','MagnetRotation'};

found_params = false(size(AllExpParams));

params = fieldnames(handles.ExperimentScheme.ExperimentSteps);

for p = params'
    found_params = found_params | strcmp(p,AllExpParams);
end


if all(found_params)
  msgbox('No additional parameters to include.','Parameters','modal');
  return;
end
ParamOpts = AllExpParams(~found_params);
[Selection,ok] = listdlg('ListString',ParamOpts,...
    'SelectionMode','multiple',...
    'PromptString','Select Parameters to add',...
    'Name','Parameters');

if ok==0 || isempty(Selection)
    return;
end

%add parameters to list

for p = ParamOpts(Selection)
    [handles.ExperimentScheme.ExperimentSteps.(p{1})] = deal([]);
end

%update table data
MultiMT_ExpUpdateTableData(hTbl,handles.ExperimentScheme);

%Save data
guidata(hMain,handles);

