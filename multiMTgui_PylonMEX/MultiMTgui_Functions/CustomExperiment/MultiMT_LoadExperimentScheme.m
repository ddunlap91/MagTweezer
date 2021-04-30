function MultiMT_LoadExperimentScheme(hMain,filename)

handles = guidata(hMain);
persistent pathname;
if isempty(pathname)
    pathname = handles.data_dir;
end
%% prompt for file
if nargin<2
    [filename,pathname] = uigetfile({'*.mtdat;*.mtexp','MultiMT Files';...
                                     '*.mtdat','MultiMT Data File';...
                                     '*.mtexp','MultiMT Experiment Scheme'},...
                                     'Load Experiment Scheme',pathname);
     if filename==0
         return;
     end
     filename = fullfile(pathname,filename);
end

if ~exist(filename,'file')
    error('File specified file: %s does not exist',filename);
end

%% Load data
header = mtdatread(filename);

%% maybe include data validation here
% TO DO

%% Set Experiment Scheme data
handles.ExperimentScheme = header.ExperimentScheme;

%add empty duration and framecount
if ~isfield(handles.ExperimentScheme.ExperimentSteps,'Duration')
    [handles.ExperimentScheme.ExperimentSteps.Duration] = deal([]);
end
if ~isfield(handles.ExperimentScheme.ExperimentSteps,'FrameCount')
    [handles.ExperimentScheme.ExperimentSteps.FrameCount] = deal([]);
end

hCE = handles.hFig_CustomExperiment;
cehandles = guidata(hCE);

%% Capture Offline
set(cehandles.hChk_CaptureOffline,'value',handles.ExperimentScheme.CaptureOffline);

%% Minimize ROI
set(cehandles.hChk_MinimizeROI,'value',handles.ExperimentScheme.MinimizeROI);

%% Fixed Duration/FrameCount
set(cehandles.hRad_FixedFrameCount,'value',~handles.ExperimentScheme.FixedDuration);
set(cehandles.hRad_FixedDuration,'value',handles.ExperimentScheme.FixedDuration);

%% Output Data
set(cehandles.hChk_OutputX,'value',handles.ExperimentScheme.OutputX);
set(cehandles.hChk_OutputY,'value',handles.ExperimentScheme.OutputY);
set(cehandles.hChk_OutputZabs,'value',handles.ExperimentScheme.OutputZabs);
set(cehandles.hChk_OutputZrel,'value',handles.ExperimentScheme.OutputZrel);

%% Camera Settings
if isfield(header,'CameraSettings')
    btn = questdlg('Apply camera settings?','Camera Settings','Yes','No','Yes');
    if strcmpi('yes',btn)
        handles.MMcam.TargetFrameRate = header.CameraSettings.TargetFrameRate;
        handles.MMcam.ResultingFrameRate =header.CameraSettings.ResultingFrameRate;
        handles.MMcam.Exposure = header.CameraSettings.Expsoure;
        handles.MMcam.Gain = header.CameraSettings.Gain;
        handles.MMcam.ExposureAuto = header.CameraSettings.ExposureAuto;
        handles.MMcam.GainAuto = header.CameraSettings.GainAuto;
        handles.MMcam.TargetIntensity = header.CameraSettings.TargetIntensity;
        handles.MMcam.BlackLevel = header.CameraSettings.BlackLevel;
        if ~handles.ExperimentScheme.MinimizeROI
            handles.MMcam.ROI = header.CameraSettings.ROI;
        end
    end
end

%% Save Data
guidata(hMain,handles);