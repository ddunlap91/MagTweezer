function MultiMTgui_startChapeauCurve(hMain)
setInFunctionFlag(hMain,true);

handles = guidata(hMain);
cchandles = guidata(handles.hFig_ChapeauCurve);

if handles.ExperimentRunning
    warndlg('There is an experiment already running.');
    setInFunctionFlag(hMain,false);
    return;
end

if handles.num_tracks<=0
    warndlg('Currently there are no tracks to process.');
    setInFunctionFlag(hMain,false);
    return;
end

handles.CC_MagRot = handles.CC_Start:handles.CC_Step:handles.CC_End;

if handles.CC_FwdRev
    handles.CC_MagRot = [handles.CC_MagRot,handles.CC_End:-handles.CC_Step:handles.CC_Start];
end
handles.CC_NumMagRot = numel(handles.CC_MagRot);

handles.CC_CurrentMagRotIndex = 1;
handles.CC_CurrentFrame = 1;

handles.CC_Zavg = NaN(handles.num_tracks,handles.CC_NumMagRot);
handles.CC_varZ = NaN(handles.num_tracks,handles.CC_NumMagRot);



%Files
%===================
%try to create directory
s = mkdir(handles.data_dir);
if ~s
    warndlg('Could not create Data Output directory');
    setInFunctionFlag(hMain,false);
    return
end

if handles.CC_AutoName
    handles.CC_File = [datestr(now,'yyyy-mm-dd'),'_ChapeauCurve'];
end
%Force Data File
%==========================
flist = dir(fullfile(handles.data_dir,[handles.CC_File,'*.txt']));
if numel(flist)>0
    handles.CC_File = [handles.CC_File,sprintf('_%03.0f',numel(flist)+1)];
else
    if handles.CC_AutoName
        handles.CC_File = [handles.CC_File,'_001'];
    end
end
set(cchandles.hEdt_CC_File,'string',handles.CC_File);

[handles.CC_FileID,err_msg] = fopen(fullfile(handles.data_dir,[handles.CC_File,'.txt']),'w');
if ~isempty(err_msg)
    disp(err_msg);
    error('Problem creating file');
end
%Write the File Preamble
fprintf(handles.CC_FileID,'Chapeau Curve\n');
fprintf(handles.CC_FileID,'================================================\n');
fprintf(handles.CC_FileID,'PxScale:\t%f\n',handles.PxScale);
fprintf(handles.CC_FileID,'MagnetHeight:\t%f\n',handles.mag_zpos);
fprintf(handles.CC_FileID,'MagnetStart:\t%f\n',handles.CC_Start);
fprintf(handles.CC_FileID,'MagnetStep:\t%f\n',handles.CC_Step);
fprintf(handles.CC_FileID,'MagnetEnd:\t%f\n',handles.CC_End);
fprintf(handles.CC_FileID,'FrameCount:\t%i\n',handles.CC_FrameCount);
fprintf(handles.CC_FileID,'FwdRev:\t%i\n',handles.CC_FwdRev);
fprintf(handles.CC_FileID,'TotalTracks:\t%i\n',handles.num_tracks);
%find reference tracks
rt = find(strcmpi('Reference',{handles.track_params.Type}));
if isempty(rt)
    fprintf(handles.CC_FileID,'RefenenceTracks:\t[]\n');
else
    fprintf(handles.CC_FileID,'RefenenceTracks:\t[%i',rt(1));
    if numel(rt)>1
        fprintf(handles.CC_FileID,',%i',rt(2:end));
    end
    fprintf(handles.CC_FileID,']\n');
end

if handles.CC_DriftCompensation
    fprintf(handles.CC_FileID,'DriftCompensation:\ttrue\n');
else
    fprintf(handles.CC_FileID,'DriftCompensation:\tfalse\n');
end
if handles.CC_TiltCompensation&&numel(rt)>2
    fprintf(handles.CC_FileID,'TiltCompensation:\ttrue\n');
else
    fprintf(handles.CC_FileID,'TiltCompensation:\tfalse\n');
end

fprintf(handles.CC_FileID,'Comments:\n');
str= get(cchandles.hEdt_CC_Comments,'string');
for l=1:size(str,1)
    fprintf(handles.CC_FileID,str(l,:));
    fprintf(handles.CC_FileID,'\n');
end
handles.CC_Comments = str;
fprintf(handles.CC_FileID,'\n\n');
%write header
fprintf(handles.CC_FileID,'DATE      \tTime        \tMagR  \t');
for trkID = 1:handles.num_tracks
    %align cloumn for '%0.8e\t'
    fprintf(handles.CC_FileID,'Zavg%02i        \tvarX%02i        \tvarY%02i        \tvarZ%02i        \t',trkID,trkID,trkID,trkID);
end
fprintf(handles.CC_FileID,'\n');

%XYZ FILE
%===========================
if handles.CC_WriteXYZ
    %XY_FILE
    handles.CC_XY_File = [handles.CC_File,'_XY.bin'];
    handles.CC_XY_FileID = fopen(fullfile(handles.data_dir,handles.CC_XY_File),'w');
    %first number in XY_File tells us how many tracks were recorded
    fwrite(handles.CC_XY_FileID,handles.num_tracks,'uint8');
    %number of reference tracks
    fwrite(handles.CC_XY_FileID,numel(rt),'uint8');
    if ~isempty(rt)
        fwrite(handles.CC_XY_FileID,rt,'uint8');
    end
    %Z_File
    handles.CC_Z_File = [handles.CC_File,'_Z.bin'];
    handles.CC_Z_FileID = fopen(fullfile(handles.data_dir,handles.CC_Z_File),'w');
    %first number in XY_File tells us how many tracks were recorded
    fwrite(handles.CC_Z_FileID,handles.num_tracks,'uint8');
    %number of reference tracks
    fwrite(handles.CC_Z_FileID,numel(rt),'uint8');
    if ~isempty(rt)
        fwrite(handles.CC_Z_FileID,rt,'uint8');
    end
    %write refernce id for each track
    fwrite(handles.CC_Z_FileID, [handles.track_params.ZRef],'uint8');
end


handles.ExperimentRunning = true;
handles.ExperimentType = 'ChapeauCurve';


set(cchandles.hBtn_CC_RunStop,'String','Stop');
set(cchandles.hBtn_CC_RunStop,'ForegroundColor',[1,0,0]);

%Save Data
guidata(hMain,handles);

%move magnet to first position
setMagnetRotation(hMain,handles.CC_MagRot(handles.CC_CurrentMagRotIndex));
waitForMagnetRotation(hMain);

setInFunctionFlag(hMain,false);