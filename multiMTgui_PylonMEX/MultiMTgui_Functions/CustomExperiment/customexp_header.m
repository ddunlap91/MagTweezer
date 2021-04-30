%prepare file
Config.FileType = 'Custom Experiment';
Config.CreationDate = datestr(now,'yyyy-mm-dd HH:MM');
Config.Comments = [] %ADD COMMENTS CODE HERE
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
Config.TemperatueUnits = handles.TemperatueUnits;
Config.Temperatue = handles.Temperatue;
Config.LogFile = handles.LogFile;

Config.CalibrationMin = handles.CalStackMin;
Config.CalibrationMax = handles.CalStackMax;
Config.CalibrationStep = handles.CalStackStep;

%Track Info
Config.TrackingInfo = struct('Type',{},'Radius',{},'IsCalibrated',{},'Zref',{},'Window',{});
for n=1:handles.num_tracks
    Config.TrackingInfo(n).Type = handles.track_params(n).Type;
    Config.TrackingInfo(n).Radius = handles.track_params(n).Radius;
    Config.TrackingInfo(n).IsCalibrated = handles.track_params(n).IsCalibrated;
    Config.TrackingInfo(n).Zref = handles.track_params(n).Zref;
    Config.TrackingInfo(n).Window = handles.track_wind(n,:);
    Config.TrackingInfo(n).CalibrationPositions = handles.track_calib(n).ZPos;
end

%Camera Settings
Config.CameraSettings.TargetFrameRate 
Config.CameraSettings.ResultingFrameRate
Config.CameraSettings.Expsoure
Config.CameraSettings.Gain
Config.CameraSettings.ExposureAuto
Config.CameraSettings.GainAuto
Config.CameraSettings.TargetIntensity
Config.CameraSettings.BlackLevel
Config.CameraSettings.ROI

%Experiment Scheme
Config.ExperimentScheme.CaptureOffline = true; 
Config.ExperimentScheme.MinimizeROI = true;
Config.ExperimentScheme.FixedDuration = true; %false means fixed frame count
Config.ExperimentScheme.ExperimentSteps = struct('FrameCount',{},'Duration',{});


%Record Structure
Record = struct('parameter',{},'format',{},'size',{});

Record(end+1).parameter = 'Date';
Record(end).format = 'double';
Record(end).size = [1,1];

Record(end+1).parameter = 'Step';
Record(end).format = 'uint32';
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


if SAVE_X
    Record(end+1).parameter = 'X';
    Record(end).format = 'double';
    Record(end).size = [handles.num_tracks,1];
end

if SAVE_Y
    Record(end+1).parameter = 'Y';
    Record(end).format = 'double';
    Record(end).size = [handles.num_tracks,1];
end

if SAVE_ZREL
    Record(end+1).parameter = 'Z_REL';
    Record(end).format = 'double';
    Record(end).size = [handles.num_tracks,1];
end

if SAVE_ZABS
    Record(end+1).parameter = 'Z_ABS';
    Record(end).format = 'double';
    Record(end).size = [handles.num_tracks,1];
end


