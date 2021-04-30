function MultiMT_SaveExperimentScheme(hMain, filename)

handles = guidata(hMain);

%% Validate Experiment Scheme data
% if experiment scheme doesn't exist or is empty warn and exit
if ~isfield(handles,'ExperimentScheme') || ~isfield(handles.ExperimentScheme,'ExperimentSteps')
    warndlg('ExperimentScheme doesnt exist in variables. Something in wrong.','No ExperimentScheme','modal');
    return;
end
if isempty(handles.ExperimentScheme.ExperimentSteps)
    warndlg('No steps in current experiment. Nothing to save.','No Data','modal');
    return;
end

%% Prompt for file if needed.
persistent pathname;
if isempty(pathname)
    pathname = handles.data_dir;
end
if nargin<2
    [filename,pathname] = uiputfile({'*.mtexp','MultiMT Experiment Scheme'},'Save Experiment Scheme',pathname);
    if file==0
        return;
    end
    filename = fullfile(pathname,filename);
end

%% misc header info
header.FileType = 'Custom Experiment';
header.CreationDate = datestr(now,'yyyy-mm-dd HH:MM');

%% Ask to save camera settings
btn = questdlg('Save Camera Settings?','Save','Yes','No','Yes');
if isempty(btn)
    return;
end
if strcmpi('yes',btn)
    header.CameraSettings.TargetFrameRate = handles.MMcam.TargetFrameRate;
    header.CameraSettings.ResultingFrameRate = handles.MMcam.ResultingFrameRate;
    header.CameraSettings.Expsoure = handles.MMcam.Exposure;
    header.CameraSettings.Gain = handles.MMcam.Gain;
    header.CameraSettings.ExposureAuto = handles.MMcam.ExposureAuto;
    header.CameraSettings.GainAuto = handles.MMcam.GainAuto;
    header.CameraSettings.TargetIntensity = handles.MMcam.TargetIntensity;
    header.CameraSettings.BlackLevel = handles.MMcam.BlackLevel;
    header.CameraSettings.ROI = handles.MMcam.ROI;
end

%% experiment scheme data
header.ExperimentScheme = handles.ExperimentScheme;

%% write header
pth = fileparts(filename);
if ~exist(pth,'dir')
  if ~mkdir(pth)
      error('Could not create directory: %s',pth);
  end
end
mtdatwriteheaderonly(filename,header);
