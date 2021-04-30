function status = MultiMTgui_initializeVariables(hMain)
%MultiMTgui_initializeGUI(hObject) Initialize shared Variables
% Input:
%   hMain - handle to main figure window
%       This function should be called after the guidata has been updated
% Output:
%   status - boolean true=initialized, false=error
% Example:
%   ...
%   %Update handles structure
%   guidata(hObject,handles);
%   ... (other functions which don't change or update hObject)
%   initstat = MultiMTgui_initializeVariables(hObject);
%   if ~initstat
%       error('Did not initialize GUI');
%   end
%
% Note: This function will update the guidata before returning
status = true;
%get copy of handles
handles = guidata(hMain);

%% Load config file
%========================================
handles.CFG_FILE = fullfile(handles.guipath,'MultiMTgui_config.mat');
if ~exist(handles.CFG_FILE,'file')
    error(['Could not load Config File: ',handles.CFG_FILE]);
    %disp('Using hard-coded default settings');
    
    %handles.PxScale = 1;
else
    cfg = load(handles.CFG_FILE);
    
    if ~isfield(cfg,'InstrumentName')
        handles.InstrumentName = 'Unnamed Instrument';
    else
        handles.InstrumentName = cfg.InstrumentName;
    end
    
    if ~isfield(cfg,'CameraInterface')
        disp('Config File does not specify CameraInterface.');
        disp('Using default: TIS_DCAM');
        handles.CameraInterface = 'TIS_DCAM';
    else
        handles.CameraInterface = cfg.CameraInterface;
        
        if ~any(strcmpi(handles.CameraInterface,...
                {'TIS_DCAM',...
                 'GigE'}))
             error('CameraInterface: %s is not a valid paramter',handles.CameraInterface);
        end
    end
    
    if ~isfield(cfg,'PxScale')
        disp('Config File does not contain PxScale.');
        disp('Using hardcoded value');
        handles.PxScale = 1;
    else
        handles.PxScale = cfg.PxScale;
    end
    
    if ~isfield(cfg,'PiezoController')
        disp('Config File does not contain PiezoController.');
        disp('Using hardcoded value');
        handles.PiezoController = 'PI E-665.CR';
    else
        handles.PiezoController = upper(cfg.PiezoController);
    end
    
    if ~isfield(cfg,'PiezoCOM')
        disp('Config File does not contain PiezoCOM.');
        disp('Using hardcoded value');
        handles.PiezoCOM = 'COM4';
    else
        handles.PiezoCOM = cfg.PiezoCOM;
    end
    
    if ~isfield(cfg,'PiezoBAUD')
        disp('Config File does not contain PiezoBAUD.');
        disp('Using hardcoded value');
        handles.PiezoBAUD = 9600;
    else
        handles.PiezoBAUD = cfg.PiezoBAUD;
    end
    
    if ~isfield(cfg,'MotorController')
        disp('Config File does not contain MotorController.');
        disp('Using hardcoded value');
        handles.MotorController = 'PI C-843 (PCI)';
    else
        handles.MotorController = upper(cfg.MotorController);
    end
    
    switch upper(handles.MotorController)
        case 'PI C-843 (PCI)'
            handles.MotorCOM = 'NA';
            handles.MotorBAUD = 0;
        otherwise
            if ~isfield(cfg,'MotorCOM')
                disp('Config File does not contain MotorCOM.');
                disp('Using hardcoded value');
                handles.MotorCOM = 'COM4';
            else
                handles.MotorCOM = cfg.MotorCOM;
            end

            if ~isfield(cfg,'MotorBAUD')
                disp('Config File does not contain MotorBAUD.');
                disp('Using hardcoded value');
                handles.MotorBAUD = 9600;
            else
                handles.MotorBAUD = cfg.MotorBAUD;
            end
    end
    
    if ~isfield(cfg,'MagZAxisType')
        disp('Config File does not contain MagZAxisType.');
        disp('Using hardcoded value');
        handles.magztype = 'M-126.PD2';
    else
        handles.magztype= cfg.MagZAxisType;
    end
    
    if ~isfield(cfg,'MagZAxisID')
        disp('Config File does not contain MagZAxisID.');
        disp('Using hardcoded value');
        handles.magzaxis = 1;
    else
        handles.magzaxis= cfg.MagZAxisID;
    end
    
    if ~isfield(cfg,'MagRAxisType')
        disp('Config File does not contain MagRAxisType.');
        disp('Using hardcoded value');
        handles.magrtype = 'C-150.PD';
    else
        handles.magrtype= cfg.MagRAxisType;
    end
    
    if ~isfield(cfg,'MagRAxisID')
        disp('Config File does not contain MagRAxisID.');
        disp('Using hardcoded value');
        handles.magraxis = 2;
    else
        handles.magraxis= cfg.MagRAxisID;
    end
    
    if ~isfield(cfg,'RotationScale')
        disp('Config File does not contain RotationScale.');
        disp('Using hardcoded value');
        handles.mag_rotscale = 720;
    else
        handles.mag_rotscale= cfg.RotationScale;
    end
    
    if ~isfield(cfg,'TemperatureController')
        handles.TemperatureController = 'NONE';
    else
        handles.TemperatureController = cfg.TemperatureController;
    end
    if ~isfield(cfg,'TemperatureUnits')
        handles.TemperatureUnits = '°C';
    else
        handles.TemperatueUnits = cfg.TemperatureUnits;
    end
    if ~isfield(cfg,'Temperature')
        disp('Config File does not contain a Temp.');
        fprintf('Using hardcoded value: %0.2f%s\n',25,handles.TemperatureUnits);
        handles.Temperature = 25;
    else
        handles.Temperature = cfg.Temperature;
    end
    
    if ~isfield(cfg,'DataDirectory')
        disp('Config File does not specify a DataDirectory');
        handles.data_base = 'C:\DATA\Magnetic Tweezers\Experiments'; %base directory to save experimental data
        fprintf('Using: %s\n',handles.data_base);
    else
        handles.data_base = cfg.DataDirectory;
    end
    
    if ~isfield(cfg,'LogFile')
        disp('Config File does not specify a log file.');
        disp('MLogger will create a new one.');
        handles.LogFile = fullfile(handles.data_base,['MLogger - ',datestr(now,'yyyy-mm-dd'),'.log']);
    else
        handles.LogFile = cfg.LogFile;
    end
    
    disp(handles)
end
%% Hardware Interface Variables
%======================================
%settings timer polls the hardware for changes
handles.SettingsTimer = [];

% Objective
handles.obj_zpos = 1; %piezo z-axis position [µm]
handles.obj_zlim = [0,1]; % piezo z-axis limits [µm], set by MultiMTgui_initializeHardware()

%Magnet
handles.mag_zpos = 0.5; %magnet position
handles.mag_zlim = [0,1]; %set by MultiMTgui_initializeHardware()
handles.mag_zspeed = 1; %um/sec?
%handles.mag_rotscale = 720; %number (maybe steps???) per turn, this should probably be determined by a motor control class in future versions
handles.mag_rotpos = 0; %magnet rotation (turns)
handles.mag_rotspeed = 1; %magnet rotation speed turns/sec?

%motor parameters...eventually we may want to check this with the hardware
%maximums.
handles.mag_maxzvel = 100; %maximum speed of the linear motor
handles.mag_maxrotvel = 100; %maximum speed of rotation motor in turns/time

%Camera Interface
handles.MMcam = [];
handles.ImageWidth = 0;
handles.ImageHeight = 0;

%Motor Interface
handles.MotorObj = [];


%piezo interface
handles.PiezoObj = [];

handles.HardwareInitialized = false; %true if hardware has been initialized.
%% GUI
%==========================
% Note: for variables that correspond to gui control look in the respective
% setup function like MultiMTgui_setupMicroscopeControls()
handles.hFig_ControlsWindow = [];
handles.hFig_CommentsWindow = [];
handles.hFig_ImageWindow = [];
handles.hAx_CameraImageAxes = [];
handles.hFig_TrackingControls = [];
handles.hFig_ForceExtension = [];
handles.hFig_ChapeauCurce = [];
handles.hFig_HardwareSettings = [];

%ROI Variables
handles.ROI_hrect = []; %handle to imrect2 for ROI, if no ROI set this should be empty
handles.ROI_lastpos = []; %Last position of ROI, used by the enable/diasble ROI check box

%GUI Flags
handles.controls_open = false;
handles.tracking_open = false;
handles.comments_open = false;
handles.imagefig_open = false;
handles.hardwaresettings_open = false;
handles.FE_open = false; %force extension window
handles.CC_open = false;

%% Logger
handles.logger = MLogger(handles.LogFile);

%% Tracking and Calibration
%=========================================================================
handles.num_tracks = 0;
handles.current_track_selection = [];
handles.track_params = struct('Sel',{},'Type',{},'Radius',{},'Color',{},'Lock',{},'IsCalibrated',{},'ZRef',{}); %parameters used by TrackingContols GUI
handles.track_calib = struct('IrStack',{},'Radius',{},'ZPos',{},'IsCalibrated',{});%calibration data
%handles.CalStack = []; %z-stack of images used for z calibration
%handles.CalStackPos = []; %z-positions in calibration stack
handles.CalStackMin = 0;
handles.CalStackMax = 100;
handles.CalStackStep = 0.02;
handles.CalStackStepCount = 3;
handles.track_wind = NaN(0,4); %windows used by tracking function
handles.track_hrect = []; %handles to imrect2 rectangles showing tracking windows
handles.track_xyzlabel = []; %handles to text labels listing xyz position
handles.TiltCorrection = false;
handles.TiltCorrectionReference = 0;
%handles.track_XYZ = []; %current bead positions
%% EXPERIMENT VARIABLES
%============================================
%Data Folder and files...eventually move this somewhere else
%handles.data_base = 'D:\DATA\Magnetic Tweezers\Experiments'; %base directory to save experimental data
handles.data_dir = fullfile(handles.data_base,datestr(now,'yyyy-mm-dd')); %directory to save experimental data

%% Custom Experiment
%==========================================================================
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
handles.hFig_CustomExperiment = [];
handles.CustomExperiment_OfflineModeRunning = false;
handles.CustomExperiment_LiveModeRunning = false;
handles.CustomExperiment_paused = false;
handles.CustomExperiment_FileID = []; %file id for currently open custom experiment data file
%handles for plots
handles.hFig_CustExp_LvMH = [];
handles.hFig_CustExp_LvMR = [];
handles.hFig_CustExp_FvMH = [];
handles.hFig_CustExp_FvMR = [];
handles.hFig_CustExp_FvL = [];
%% RecordXYZ Parameters
%===============================
handles.RecXYZ_open = false;
handles.hFig_RecordXYZ = [];

handles.RecXYZ_AutoName = true;
handles.RecXYZ_File = [];
handles.RecXYZ_Recording = false;
handles.RecXYZ_Comments = [];

handles.hFig_LiveZPlot = gobjects;
handles.hAnimLine_ZPlot = gobjects;
handles.RecXYZ_StartTime = 0;

handles.hFig_LiveXYPlot = gobjects;
handles.hAnimLine_XYPlot = gobjects;

handles.UpdateLiveZPlot = false;
handles.UpdateLiveXYPlot = false;

handles.RecXYZ_FileID = [];
handles.hFig_RecXYZPlot = [];

%% Force Extension Parameters
%============================
handles.FE_File = [];
handles.FE_FileID = 0;

handles.FE_AutoName = true;
handles.FE_WriteXYZ = true;
handles.FE_XY_File = [];
handles.FE_XY_FileID = 0;
%XY_File is a binary formated file
% Data Structure: data = fread(XY_File...)
%   data(1) = Number of tracks (uint8)
%   data(2) = Number of reference tracks (uint8)
%   data(3:3+NumRefTracks) = index of each of the reference tracks (uint8)
%   data(4+NumRefTracks:NumTracks) = Reference ID for each track (uint8)
% The remaining numbers are the Time+XY data formatted as 'double' with
% the stucture:
%   data= [Time0, X1, Y1,,...,Xn,Yn;...
%          Time1, X1, Y1,,...,Xn,Yn;...]
% Drift Compensation:
%   The X and Y values are the un-compensated values.
%   to compensate for drift use the average shift from the reference tracks
%   specified by data(3:3+NumRefTracks)
handles.FE_Z_File = [];
handles.FE_Z_FileID = 0;
%Z_File is a binary formated file
% Data Structure: data = fread(Z_File...)
%   data(1) = Number of tracks (uint8)
%   data(2) = Number of reference tracks (uint8)
%   data(3:3+NumRefTracks) = index of each of the reference tracks (uint8)
%   data(4+NumRefTracks:NumTracks) = Reference ID for each track (uint8)
% The remaining numbers are the Time+Zrel,Zabs data formatted as 'double' with
% the stucture:
%   data= [Time0, Zrel1, Zabs1,,...,Zreln,Zabsn;...
%          Time1, Zrel1, Zabs1,,...,Zreln,Zabsn;...]
% Zrel is the zposition referenced against the specified track (refID)
% Zabs is the zposition is the z position relative to a track's own
% reference-stack.  If SaveAbsZ(trkID)=false this Zabs=NaN

handles.FE_Start = 0;
handles.FE_Step = 1;
handles.FE_End = 10;
handles.FE_FrameCount = 300;
handles.FE_FwdRev = false;

handles.FE_MagPos = [];
handles.FE_CurrentMagPosIndex = 0;
handles.FE_NumMagPos = 0;
handles.FE_CurrentFrame = 1;
%handles.FE_XY_Acc = [];
%handles.FE_FrameTime = [];
%handles.FE_ImageData = [];
%handles.FE_MagPosStartTime = [];

handles.FE_Comments = [];

handles.FE_CalcMethod = 'Variance <dx2>';
handles.FE_Lavg = [];
handles.FE_Fx = [];
handles.FE_Fy = [];

handles.FE_hFig_LvMag = [];
handles.FE_hFig_FvMag = [];
handles.FE_hFig_FvL = [];

handles.FE_plotLvMag = true;
handles.FE_plotFvMag = true;
handles.FE_plotFvL = true;

handles.FE_hWaitbar = [];


%% Chapeau Parameters
%=====================================
handles.CC_File = [];
handles.CC_FileID = 0;
handles.CC_Comments = [];

handles.CC_AutoName = true;
handles.CC_WriteXYZ = true;
handles.CC_XY_File = [];
handles.CC_XY_FileID = 0;
%XY_File is a binary formated file
% Data Structure: data = fread(XY_File...)
%   data(1) = Number of tracks (uint8)
%   data(2) = Number of reference tracks (uint8)
%   data(3:3+NumRefTracks) = index of each of the reference tracks (uint8)
%   data(4+NumRefTracks:NumTracks) = Reference ID for each track (uint8)
% The remaining numbers are the Time+XY data formatted as 'double' with
% the stucture:
%   data= [Time0, X1, Y1,,...,Xn,Yn;...
%          Time1, X1, Y1,,...,Xn,Yn;...]
% Drift Compensation:
%   The X and Y values are the un-compensated values.
%   to compensate for drift use the average shift from the reference tracks
%   specified by data(3:3+NumRefTracks)
handles.CC_Z_File = [];
handles.CC_Z_FileID = 0;
%Z_File is a binary formated file
% Data Structure: data = fread(Z_File...)
%   data(1) = Number of tracks (uint8)
%   data(2) = Number of reference tracks (uint8)
%   data(3:3+NumRefTracks) = index of each of the reference tracks (uint8)
%   data(4+NumRefTracks:NumTracks) = Reference ID for each track (uint8)
% The remaining numbers are the Time+Zrel,Zabs data formatted as 'double' with
% the stucture:
%   data= [Time0, Zrel1, Zabs1,,...,Zreln,Zabsn;...
%          Time1, Zrel1, Zabs1,,...,Zreln,Zabsn;...]
% Zrel is the zposition referenced against the specified track (refID)
% Zabs is the zposition is the z position relative to a track's own
% reference-stack.  If SaveAbsZ(trkID)=false this Zabs=NaN

handles.CC_Start = 0;
handles.CC_Step = 1;
handles.CC_End = 10;
handles.CC_FrameCount = 100;
handles.CC_FwdRev = false;

handles.CC_MagRot = [];
handles.CC_CurrentMagRotIndex = 0;
handles.CC_NumMagRot = 0;
handles.CC_CurrentFrame = 1;

%handles.CC_SaveAbsZ = []; Just use FE_SaveAbsZ

handles.CC_Zavg = [];
handles.CC_varZ = [];

handles.CC_hFig_Chapeau = [];
handles.CC_plotChapeau = true;
handles.CC_plotChapeauErrorBars = true;
handles.CC_hWaitbar = [];

%% Experiment Running Flags
%=========================================
handles.PauseSystem  = false;
handles.CalibrationRunning = false;
handles.ExperimentRunning = false;
handles.ExperimentType = ''; %string specifying experiment type. used in MultiMTgui_CameraCallback
%       'ForceExtension' - Force Extension experiment

handles.TrackingControlsEnabled = true; %flag to disable tracking controls during experiment run                          
handles.InUserFunction = false; %flag telling camera call we are in a function and don't want to process frame data
handles.ExperimentWindowOpen = false;
% END
%==============================
%% update handles
guidata(hMain,handles)
end