function MultiMTgui_startForceExtension(hMain)
setInFunctionFlag(hMain,true);

handles = guidata(hMain);
fehandles = guidata(handles.hFig_ForceExtension);

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


handles.FE_MagPos = handles.FE_Start:handles.FE_Step:handles.FE_End;
handles.FE_Voltage = fehandles.FE_VStart:fehandles.FE_VStep:fehandles.FE_VEnd;
handles.FE_EM_Speed = fehandles.FE_EM_Speed;

if handles.FE_FwdRev
    handles.FE_MagPos = [handles.FE_MagPos,handles.FE_End:-handles.FE_Step:handles.FE_Start];
    handles.FE_Voltage = [handles.FE_Voltage, fehandles.FE_VEnd:-fehandles.FE_VStep:fehandles.FE_VStart];
  
end
disp(handles.FE_Voltage);
handles.FE_NumMagPos = numel(handles.FE_MagPos);
handles.FE_NumVoltages = numel(handles.FE_Voltage);

handles.FE_CurrentMagPosIndex = 1;
handles.FE_CurrentFrame = 1;

handles.FE_Lavg = NaN(handles.num_tracks,handles.FE_NumMagPos);
handles.FE_Fx = NaN(handles.num_tracks,handles.FE_NumMagPos);
handles.FE_Fy = NaN(handles.num_tracks,handles.FE_NumMagPos);


%% Files
%===================
%try to create directory
if ~mkdir(handles.data_dir)
    warndlg('Could not create Data Output directory');
    setInFunctionFlag(hMain,false);
    return
end

if handles.FE_AutoName
    handles.FE_File = [datestr(now,'yyyy-mm-dd'),'_ForceExtension'];
end
%% Force Data File
%==========================
fnum = 1;
FileName = [handles.FE_File,sprintf('_%03.0f',fnum)];
while exist(fullfile(handles.data_dir,[FileName,'.mtdat']),'file')
    fnum = fnum+1;
    FileName = [handles.FE_File,sprintf('_%03.0f',fnum)];
end
handles.FE_File = FileName;

set(fehandles.hEdt_FE_File,'string',handles.FE_File);



%% Create File

%config data
%prepare file
Config.FileType = 'Force Extension';
Config.CreationDate = datestr(now,'yyyy-mm-dd HH:MM');
Config.Comments = chararray2cstr(fehandles.hEdt_FE_Comments.String); %ADD COMMENTS CODE HERE
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



Config.ForceExtensionScheme.MagnetRotation = handles.mag_rotpos;
Config.ForceExtensionScheme.MagnetHeightPositions = handles.FE_MagPos;
Config.ForceExtensionScheme.FrameCount = handles.FE_FrameCount;


%% record structure
Record = struct('parameter',{},'format',{},'size',{});

Record(end+1).parameter = 'Date';
Record(end).format = 'double';
Record(end).size = [1,1];

Record(end+1).parameter = 'Step';
Record(end).format = 'uint32';
Record(end).size = [1,1];

Record(end+1).parameter = 'FrameCount';
Record(end).format = 'double';
Record(end).size = [1,1];

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
[handles.FE_FileID,handles.FE_Record] = mtdatwriteheader(...
    fullfile(handles.data_dir,[handles.FE_File,'.mtdat']),...
    Config,Record);

%% Set Flags
handles.ExperimentRunning = true;
handles.ExperimentType = 'ForceExtension';

%% Start Stop Button
set(fehandles.hBtn_FE_RunStop,'String','Stop');
set(fehandles.hBtn_FE_RunStop,'ForegroundColor',[1,0,0]);

%% Clear persistent vars in ProcFrame
clear MultiMTgui_FE_ProcessFrame;
clear MultiMTgui_FE_ProcessFrame_EM;

%% Save Data
guidata(hMain,handles);

%move magnet to first position
if ~strcmp('ELECTROMAGNET', handles.MotorController)
    setMagnetZPosition(hMain,handles.FE_MagPos(handles.FE_CurrentMagPosIndex));
    waitForMagnetZPosition(hMain);
else
    EM_Controller = handles.CurrentObj.Axis(handles.magzaxis);
    EM_Controller.CalculateStepDuration(handles.hFig_Main, fehandles.FE_VStart, fehandles.FE_VStep, fehandles.FE_VEnd);
    handles.MC.Controller.Target = [handles.FE_Voltage(1), handles.FE_Voltage(1)];
end

setInFunctionFlag(hMain,false);