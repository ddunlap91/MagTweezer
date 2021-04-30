function MultiMTgui_startRecording(hMain)
setInFunctionFlag(hMain,true);
handles = guidata(hMain);

rechandles = guidata(handles.hFig_RecordXYZ);

if handles.RecXYZ_Recording
    return
end

if handles.num_tracks<=0
    warndlg('Currently there are no tracks to record.');
    return;
end


%File
%===============================================
%try to create directory
if ~mkdir(handles.data_dir)
    warndlg('Could not create Data Output directory');
    return
end
if handles.RecXYZ_AutoName
    handles.RecXYZ_File = [datestr(now,'yyyy-mm-dd'),'_LiveXYZData'];
end
%% Force Data File
%==========================
flist = dir(fullfile(handles.data_dir,[handles.RecXYZ_File,'*.mtdat']));
if numel(flist)>0
    handles.RecXYZ_File = [handles.RecXYZ_File,sprintf('_%03.0f',numel(flist)+1)];
else
    if handles.RecXYZ_AutoName
        handles.RecXYZ_File = [handles.RecXYZ_File,'_001'];
    end
end
set(rechandles.hEdt_RecXYZ_File,'string',handles.RecXYZ_File);

%% Prepare header
%config data
%prepare file
Config.FileType = 'Live Tracking';
Config.CreationDate = datestr(now,'yyyy-mm-dd HH:MM');
Config.Comments = chararray2cstr(rechandles.hEdt_RecXYZ_Comments.String); %ADD COMMENTS CODE HERE
%Hardware Config
Config.InstrumentName = handles.InstrumentName;
Config.CameraInterface = handles.CameraInterface;
Config.PxScale = handles.PxScale;
Config.PiezoController = handles.PiezoController;
Config.PiezoCOM = handles.PiezoCOM;
Config.PiezoBAUD = handles.PiezoBAUD;
Config.MotorController = handles.MotorController;
Config.MotorCOM = handles.MotorCOM;
Config.MotorBAUD = handles.MotorBAUD;
Config.magztype = handles.magztype;
Config.magzaxis = handles.magzaxis;
Config.magrtype = handles.magrtype;
Config.magraxis = handles.magraxis;
Config.mag_rotscale = handles.mag_rotscale;
Config.TemperatureController = handles.TemperatureController;
Config.TemperatureUnits = handles.TemperatureUnits;
Config.Temperature = handles.Temperature;
Config.LogFile = handles.LogFile;

Config.CalibrationMin = handles.CalStackMin;
Config.CalibrationMax = handles.CalStackMax;
Config.CalibrationStep = handles.CalStackStep;

Config.num_tracks = handles.num_tracks;
%Track Info
Config.TrackingInfo = struct('Type',{},'Radius',{},'IsCalibrated',{},'ZRef',{},'Window',{});
for n=1:handles.num_tracks
    Config.TrackingInfo(n).Type = handles.track_params(n).Type;
    Config.TrackingInfo(n).Radius = handles.track_params(n).Radius;
    Config.TrackingInfo(n).IsCalibrated = handles.track_params(n).IsCalibrated;
    Config.TrackingInfo(n).ZRef = handles.track_params(n).ZRef;
    Config.TrackingInfo(n).Window = handles.track_wind(n,:);
    Config.TrackingInfo(n).CalibrationPositions = handles.track_calib(n).ZPos;
end

%Camera Settings
Config.CameraSettings.FrameRate = handles.MMcam.FrameRate;
Config.CameraSettings.UseFrameRate = handles.MMcam.UseFrameRate;
Config.CameraSettings.ResultingFrameRate = handles.MMcam.ResultingFrameRate;
Config.CameraSettings.Expsoure = handles.MMcam.Exposure;
Config.CameraSettings.Gain = handles.MMcam.Gain;
Config.CameraSettings.ExposureAuto = handles.MMcam.ExposureAuto;
Config.CameraSettings.GainAuto = handles.MMcam.GainAuto;
Config.CameraSettings.TargetBrightness = handles.MMcam.TargetBrightness;
Config.CameraSettings.BlackLevel = handles.MMcam.BlackLevel;
Config.CameraSettings.ROI = handles.MMcam.ROI;


%% record structure
Record = struct('parameter',{},'format',{},'size',{});

Record(end+1).parameter = 'Date';
Record(end).format = 'double';
Record(end).size = [1,1];

% Record(end+1).parameter = 'Step';
% Record(end).format = 'uint32';
% Record(end).size = [1,1];
% 
% Record(end+1).parameter = 'FrameCount';
% Record(end).format = 'double';
% Record(end).size = [1,1];

Record(end+1).parameter = 'ObjectivePosition';
Record(end).format = 'double';
Record(end).size = [1,1];

Record(end+1).parameter = 'MagnetHeight';
Record(end).format = 'double';
Record(end).size = [1,1];

Record(end+1).parameter = 'MagnetRotation';
Record(end).format = 'double';
Record(end).size = [1,1];

Record(end+1).parameter = 'X';
Record(end).format = 'double';
Record(end).size = [handles.num_tracks,1];

Record(end+1).parameter = 'Y';
Record(end).format = 'double';
Record(end).size = [handles.num_tracks,1];

Record(end+1).parameter = 'Z_REL';
Record(end).format = 'double';
Record(end).size = [handles.num_tracks,1];

Record(end+1).parameter = 'Z_ABS';
Record(end).format = 'double';
Record(end).size = [handles.num_tracks,1];

Record(end+1).parameter = 'dZ';
Record(end).format = 'double';
Record(end).size = [handles.num_tracks,1];

Record(end+1).parameter = 'UsingTilt';
Record(end).format = 'int8';
Record(end).size = [1,1];

%% write header
[handles.RecXYZ_FileID,handles.RecXYZ_Record] = mtdatwriteheader(...
    fullfile(handles.data_dir,[handles.RecXYZ_File,'.mtdat']),...
    Config,Record);

%% Set Flags
handles.RecXYZ_Recording = true;

%% Start Stop Button
set(rechandles.hBtn_RecXYZ_StartStopRecord,'String','Stop');
set(rechandles.hBtn_RecXYZ_StartStopRecord,'ForegroundColor',[1,0,0]);

%% Clear Plots
try
    delete(handles.hAnimLine_ZPlot);
    handles.hAnimLine_ZPlot = gobjects(handles.num_tracks,1);
catch
end
try
    delete(handles.hAnimLine_XYPlot);
    handles.hAnimLine_XYPlot = gobjects(handles.num_tracks,1);
catch
end

handles.RecXYZ_StartTime = now();

%% Save Data
guidata(hMain,handles);

setInFunctionFlag(hMain,false);