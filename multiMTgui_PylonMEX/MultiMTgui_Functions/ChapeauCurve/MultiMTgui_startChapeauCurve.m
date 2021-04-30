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


%% Files
%===================
%try to create directory
if ~mkdir(handles.data_dir)
    warndlg('Could not create Data Output directory');
    setInFunctionFlag(hMain,false);
    return
end

if handles.CC_AutoName
    handles.CC_File = [datestr(now,'yyyy-mm-dd'),'_ChapeauCurve'];
end
%% Data File
%==========================
fnum = 1;
FileName = [handles.CC_File,sprintf('_%03.0f',fnum)];
while exist(fullfile(handles.data_dir,[FileName,'.mtdat']),'file')
    fnum = fnum+1;
    FileName = [handles.CC_File,sprintf('_%03.0f',fnum)];
end
handles.CC_File = FileName;

set(cchandles.hEdt_CC_File,'string',handles.CC_File);

% flist = dir(fullfile(handles.data_dir,[handles.CC_File,'*.mtdat']));
% if numel(flist)>0
%     handles.CC_File = [handles.CC_File,sprintf('_%03.0f',numel(flist)+1)];
% else
%     if handles.CC_AutoName
%         handles.CC_File = [handles.CC_File,'_001'];
%     end
% end
% set(cchandles.hEdt_CC_File,'string',handles.CC_File);


%% Create File
%=========================================
%% config data
%prepare file
Config.FileType = 'Chapeau Curve';
Config.CreationDate = datestr(now,'yyyy-mm-dd HH:MM');
Config.Comments = chararray2cstr(cchandles.hEdt_CC_Comments.String);
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

%% Camera Settings
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

%% Experiment Settings
Config.ChapeauCurveScheme.MagnetHeight= handles.mag_zpos;
Config.ChapeauCurveScheme.MagnetRotationsPositions = handles.CC_MagRot;
Config.ChapeauCurveScheme.FrameCount = handles.CC_FrameCount;


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
[handles.CC_FileID,handles.CC_Record] = mtdatwriteheader(...
    fullfile(handles.data_dir,[handles.CC_File,'.mtdat']),...
    Config,Record);

%% Set Flags
handles.ExperimentRunning = true;
handles.ExperimentType = 'ChapeauCurve';

%% Start Stop Button
set(cchandles.hBtn_CC_RunStop,'String','Stop');
set(cchandles.hBtn_CC_RunStop,'ForegroundColor',[1,0,0]);

%% Clear persistent vars in ProcFrame
clear MultiMTgui_CC_ProcessFrame;
clear MultiMTgui_CC_ProcessFrame_EM;
%% Save Data
guidata(hMain,handles);

%move magnet to first position
if ~strcmpi('ELECTROMAGNET', handles.MotorController)
    setMagnetRotation(hMain,handles.CC_MagRot(handles.CC_CurrentMagRotIndex));
    waitForMagnetRotation(hMain);
   
else
    handles.TC.StepSize = handles.CC_Step;
    set(cchandles.hEdt_CC_Step, 'String', num2str(handles.TC.StepSize));
    handles.TC.StepPeriod = handles.CurrentObj.Axis(handles.magraxis).CalculateStepDuration(hMain, handles.CC_Turn_Speed);
    handles.CurrentObj.Axis(handles.magraxis).SetTurn(hMain, handles.CC_Start);
    handles.CurrentObj.Axis(handles.magraxis).WaitForOnTarget(hMain);
    
end

setInFunctionFlag(hMain,false);