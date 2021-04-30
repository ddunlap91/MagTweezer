function [handles,cehandles] = MultiMT_updateCustomExperimentFileName(handles,cehandles)

if ~isfield(handles,'CustomExperiment_FileName')||handles.CustomExperiment_AutoName||isempty(handles.CustomExperiment_FileName)
    handles.CustomExperiment_FileName = [datestr(now,'yyyy-mm-dd'),'_CustomExperiment'];
end

flist = dir(fullfile(handles.data_dir,[handles.CustomExperiment_FileName,'*.mtdat']));
if numel(flist)>0
    handles.CustomExperiment_FileName = [handles.CustomExperiment_FileName,sprintf('_%03.0f',numel(flist)+1)];
else
    if handles.CustomExperiment_AutoName
        handles.CustomExperiment_FileName = [handles.CustomExperiment_FileName,'_001'];
    end
end
set(cehandles.hEdt_FileName,'string',handles.CustomExperiment_FileName);

if handles.CustomExperiment_AutoName
    set(cehandles.hEdt_FileName,'enable','off');
    set(cehandles.hChk_AutoName,'value',true);
else
    set(cehandles.hEdt_FileName,'enable','on');
    set(cehandles.hChk_AutoName,'value',false);
end

