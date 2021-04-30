function MultiMT_startCustomExperiment(hMain)

handles = guidata(hMain);
cehandles = guidata(handles.hFig_CustomExperiment);

if handles.num_tracks < 1
    warndlg('No tracks defined. Experiment will not run','No Tracks','modal');
    return;
end

%% Turn off frame rate limit
handles.FrameRateEnable_PreCustomExperiment = handles.MMcam.UseFrameRate;
handles.MMcam.UseFrameRate = false;

%% Set ROI if needed
handles.ROI_PreCustomExperiment = handles.MMcam.ROI;
if handles.ExperimentScheme.MinimizeROI
    rad = reshape([handles.track_params.Radius],[],1);
    ROI = [ max(1, handles.track_wind(:,1) - rad/2), ... %x1
            max(1, handles.track_wind(:,3) - rad/2),... %y1
            min(handles.MMcam.WidthMax,handles.track_wind(:,2) + rad/2),... %x2
            min(handles.MMcam.HeightMax,handles.track_wind(:,4) + rad/2)]; %y2
    roi(1:2) = min(ROI(:,1:2),[],1); %lowest x1,y1
    roi(3:4) = max(ROI(:,3:4),[],1); %highest x2,y2
    roi(3:4) = roi(3:4)-roi(1:2) + 1; %convert x2,y2 to width,height
    handles.MMcam.ROI = roi;
end

%% Create File

%config data
%prepare file
Config.FileType = 'Custom Experiment';
Config.CreationDate = datestr(now,'yyyy-mm-dd HH:MM');
Config.Comments = chararray2cstr(cehandles.hEdt_Comments.String); %ADD COMMENTS CODE HERE
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

%Track Info
Config.num_tracks = handles.num_tracks;
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


%% Frame count /duration
if handles.ExperimentScheme.FixedDuration
    
    if handles.ExperimentScheme.CaptureOffline
        FrameCount = num2cell( round([handles.ExperimentScheme.ExperimentSteps.Duration]*handles.MMcam.ResultingFrameRate));
        [handles.ExperimentScheme.ExperimentSteps.FrameCount] = deal(FrameCount{:});
    else
        [handles.ExperimentScheme.ExperimentSteps.FrameCount] = deal(NaN);
    end

else
    if handles.ExperimentScheme.CaptureOffline
        Duration = num2cell( [handles.ExperimentScheme.ExperimentSteps.FrameCount]/handles.MMcam.ResultingFrameRate);
        [handles.ExperimentScheme.ExperimentSteps.Duration] = deal(Duration{:});
    else
        [handles.ExperimentScheme.ExperimentSteps.Duration] = deal(NaN);
    end
end

%% Check Experiment Scheme Data for errors
fields = fieldnames(handles.ExperimentScheme.ExperimentSteps);
for n=1:numel(handles.ExperimentScheme.ExperimentSteps)
    for f = fields
        if isempty(handles.ExperimentScheme.ExperimentSteps(n).(f{1})) || isinf(handles.ExperimentScheme.ExperimentSteps(n).(f{1}))
            str = sprintf('Error in experiment Step: %d Field: %s',n,f{1});
            errordlg(str,'Incomplete Experiment','modal');
            return;
        end
    end
end

%experiment scheme
Config.ExperimentScheme = handles.ExperimentScheme;

%% Record Structure
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

%other input parameters
% params = fieldnames(handles.ExperimentScheme.ExperimentSteps);
% for n=1:numel(params)
%     if ~any(strcmpi(params{n},{'FrameCount','Duration','ObjectivePosition','MagnetHeight','MagnetRotation'}))
%         Record(end+1).parameter = params{n};
%         Record(end).format = 'double';
%         Record(end).size = [1,1];
%     end
% end

%% output data
if handles.ExperimentScheme.OutputX 
    Record(end+1).parameter = 'X';
    Record(end).format = 'double';
    Record(end).size = [handles.num_tracks,1];
end

if handles.ExperimentScheme.OutputY
    Record(end+1).parameter = 'Y';
    Record(end).format = 'double';
    Record(end).size = [handles.num_tracks,1];
end

if handles.ExperimentScheme.OutputZ
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
end

%% Create filename if needed
%update file name
handles = MultiMT_updateCustomExperimentFileName(handles,cehandles);
%open file for writing
if ~exist(handles.data_dir,'dir')
    mkdir(handles.data_dir);
end
[handles.CustomExperiment_FileID,handles.CustomExperiment_Record] = mtdatwriteheader(fullfile(handles.data_dir,[handles.CustomExperiment_FileName,'.mtdat']),...
    Config,Record);

%% Disable gui elements
set(cehandles.hEdt_Dir,'enable','off');
set(cehandles.hEdt_FileName,'enable','off');
set(cehandles.hChk_AutoName,'enable','off');
set(cehandles.hEdt_Comments,'enable','off');
set(cehandles.hRad_FixedFrameCount,'enable','off');
set(cehandles.hRad_FixedDuration,'enable','off');
set(cehandles.hBtn_ClearAll,'enable','off');
set(cehandles.hChk_CaptureOffline,'enable','off');
set(cehandles.hChk_MinimizeROI,'enable','off');
set(cehandles.hChk_OutputX,'enable','off');
set(cehandles.hChk_OutputY,'enable','off');
set(cehandles.hChk_OutputZ,'enable','off');
%set(cehandles.hChk_OutputZrel,'enable','off');
%set(cehandles.hChk_OutputZabs,'enable','off');

set(cehandles.hBtn_StartPause,'String','STOP','ForegroundColor',[1,0,0]);
drawnow;

%% Setup CustomExperimentData Container
handles.CustomExperimentData = struct('StepData',{},...
                                        'MagnetHeight',{},...
                                        'MagnetRotation',{},...
                                        'mean_dZ',{},...
                                        'std_dZ',{},...
                                        'meanX',{},...
                                        'stdX',{},...
                                        'meanY',{},...
                                        'stdY',{},...
                                        'meanL',{},...
                                        'stdL',{},...
                                        'Fx',{},...
                                        'FxErr',{});
                                        
%% Save guidata
guidata(hMain,handles);

%% Start Experiment
if handles.ExperimentScheme.CaptureOffline %using post-processing capture/proc loop function
    handles.CustomExperiment_OfflineModeRunning = true;
    handles.CustomExperiment_paused = false;
    guidata(hMain,handles);
    MultiMT_RunOfflineCustomExperiment(hMain);
else %using live, set flag for camera callback
    
    %handles.CustomExperiment_LiveModeRunning = true;
end

