function MultiMTgui_setupRecordXYZ(hRecXYZ)

rechandles = guidata(hRecXYZ);
hMain = rechandles.hMainWindow;
handles = guidata(hMain);

handles.hFig_RecordXYZ = hRecXYZ;

%setup gui
set(rechandles.hEdt_RecXYZ_OutDir,'String',handles.data_dir);

if handles.RecXYZ_AutoName||isempty(handles.RecXYZ_File)
    handles.RecXYZ_File = [datestr(now,'yyyy-mm-dd'),'_LiveXYZData'];
end

% %Check if we should append and if we need to make a new file
% flist = dir(fullfile(handles.data_dir,[handles.RecXYZ_File,'*.bin']));
% if ~handles.RecXYZ_AppendData
%     if numel(flist)>0
%         handles.RecXYZ_File = [handles.RecXYZ_File,sprintf('_%03.0f',numel(flist)+1)];
%     else
%         %need to create new file starting at _001
%         handles.RecXYZ_File = [handles.RecXYZ_File,'_001'];
%     end
% else
%     if numel(flist)==0
%         handles.RecXYZ_File = [handles.RecXYZ_File,'_001'];
%     end
% end

%%%%%%%%%%%%%
%% Dan Hack fix later
flist = dir(fullfile(handles.data_dir,[handles.RecXYZ_File,'*.bin']));
if numel(flist)>0
    handles.RecXYZ_File = [handles.RecXYZ_File,sprintf('_%03.0f',numel(flist)+1)];
else
    if handles.RecXYZ_AutoName
        handles.RecXYZ_File = [handles.RecXYZ_File,'_001'];
    end
end
set(rechandles.hEdt_RecXYZ_File,'string',handles.RecXYZ_File);

if handles.RecXYZ_AutoName
    set(rechandles.hEdt_RecXYZ_File,'enable','off');
    set(rechandles.hChk_RecXYZ_AutoName,'value',true);
else
    set(rechandles.hEdt_RecXYZ_File,'enable','on');
    set(rechandles.hChk_RecXYZ_AutoName,'value',false);
end
%%%%%%%
%% 

set(rechandles.hEdt_RecXYZ_File,'string',handles.RecXYZ_File);

%comments
set(rechandles.hEdt_RecXYZ_Comments,'string',handles.RecXYZ_Comments);

%% Setup Controls
if ~handles.RecXYZ_Recording
    set(rechandles.hBtn_RecXYZ_StartStopRecord,'ForegroundColor',[0,0.5,0],'String','Start');
else
    set(rechandles.hBtn_RecXYZ_StartStopRecord,'ForegroundColor',[1,0,0],'String','Stop');
end

%% Plot Controls
rechandles.hChk_UpdateZPlot.Value = handles.UpdateLiveZPlot;
rechandles.hChk_UpdateXYPlot.Value = handles.UpdateLiveXYPlot;

%% set flags
handles.RecXYZ_open = true;
set(handles.hMenu_RecordXYZ,'checked','on');

%save data
guidata(hMain,handles);

    