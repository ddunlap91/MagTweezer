function MultiMT_ExpUpdateTableData(hTbl,ExperimentScheme)

%% Build Experiment Scheme Table
%================================
%make list of column names
col_names = fieldnames(ExperimentScheme.ExperimentSteps);

FrameCount_idx = find(strcmp(col_names,'FrameCount'));
Duration_idx = find(strcmp(col_names,'Duration'));

col_names = reshape(col_names,1,[]);
col_names([FrameCount_idx,Duration_idx]) = [];


SchemeData = struct2cell(ExperimentScheme.ExperimentSteps);
SchemeData = permute(SchemeData,[1,3,2]);

FrameData = SchemeData(FrameCount_idx,:)';
DurationData = SchemeData(Duration_idx,:)';

SchemeData([FrameCount_idx,Duration_idx],:) = [];
SchemeData = SchemeData';

if ExperimentScheme.FixedDuration
    col_names = ['Duration',col_names];
    
    SchemeData = [DurationData,SchemeData];
    
else
    col_names = ['FrameCount',col_names];
    
    SchemeData = [FrameData,SchemeData];
end

nSteps = size(SchemeData,1);

%% Set table data
col_names = ['Step',col_names];
col_edit = [false,true(1,numel(col_names)-1)];
col_format = ['integer',repmat({''},1,numel(col_names)-1)];
data = [num2cell((1:nSteps)'),SchemeData];

hTbl.ColumnName = col_names; %must update first
hTbl.Data = data;
hTbl.ColumnEditable =col_edit;
hTbl.ColumnFormat = col_format;
hTbl.ColumnMinWidth = [40,zeros(1,numel(col_names)-1)];
hTbl.ColumnMaxWidth =[40,1000*ones(1,numel(col_names)-1)];
hTbl.ColumnPreferredWidth = [40,80*ones(1,numel(col_names)-1)];



%hTbl.sizeColumnsToData();

