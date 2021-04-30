function [header,ExperimentData,filepath] = LoadExperimentData(filepath)

persistent lastdir;
if nargin< 1
    [filename,pathname] = uigetfile(fullfile(lastdir,'*.mtdat'),'Choose Experiment Data File');
    if filename==0
        header = [];
        ExperimentData = [];
        filepath = [];
        return;
    end
    lastdir = pathname;
    filepath = fullfile(pathname,filename);
end

%% load data
opath = addpath(fullfile(fileparts(mfilename('fullpath')),'mtdat_fileio'));
[header,data] = mtdatread(filepath);


%validate data
% if ~isfield(header,'ExperimentScheme')
%     error('no ExperimentScheme field in header');
% end
% if ~isfield(header.ExperimentScheme,'ExperimentSteps')
%     error('not Experiment Steps in header.ExperimentScheme');
% end

%% organize data by step
num_tracks = numel(header.TrackingInfo);
Zref = [header.TrackingInfo.ZRef];
ExperimentData = struct('StepData',[]);
for n=1:max([data.Step])%numel(header.ExperimentScheme.ExperimentSteps):-1:1
    ExperimentData(n).StepData = data([data.Step]==n);
    ExperimentData(n).StepData = rmfield(ExperimentData(n).StepData,'Step');
    
    %Input Parameters
    if isfield(ExperimentData(n).StepData,'MagnetHeight')
        ExperimentData(n).MagnetHeight = nanmean([ExperimentData(n).StepData.MagnetHeight]);
    end
    if isfield(ExperimentData(n).StepData,'MagnetRotation')
        ExperimentData(n).MagnetRotation = nanmean([ExperimentData(n).StepData.MagnetRotation]);
    end
    
    %Experiment Data Averages
    if isfield(ExperimentData(n).StepData,'X')
        ExperimentData(n).meanX = nanmean([ExperimentData(n).StepData.X],2);
        ExperimentData(n).stdX = nanstd([ExperimentData(n).StepData.X],0,2);
    end
    if isfield(ExperimentData(n).StepData,'Y')
        ExperimentData(n).meanY = nanmean([ExperimentData(n).StepData.Y],2);
        ExperimentData(n).stdY = nanstd([ExperimentData(n).StepData.Y],0,2);
    end
    if isfield(ExperimentData(n).StepData,'Z_REL')
        ExperimentData(n).meanZ_REL = nanmean([ExperimentData(n).StepData.Z_REL],2);
        ExperimentData(n).stdZ_REL = nanstd([ExperimentData(n).StepData.Z_REL],0,2);
    end
    if isfield(ExperimentData(n).StepData,'Z_ABS')
        ExperimentData(n).meanZ_ABS = nanmean([ExperimentData(n).StepData.Z_ABS],2);
        ExperimentData(n).stdZ_ABS = nanstd([ExperimentData(n).StepData.Z_ABS],0,2);
    end
    
    if isfield(ExperimentData(n).StepData,'dZ')
        ExperimentData(n).mean_dZ = nanmean([ExperimentData(n).StepData.dZ],2);
        ExperimentData(n).std_dZ = nanstd([ExperimentData(n).StepData.dZ],0,2);
    else
        if isfield(ExperimentData(n).StepData,'Z_REL') && isfield(ExperimentData(n).StepData,'Z_ABS')
            for t=1:numel(ExperimentData(n).StepData)
                ExperimentData(n).StepData(t).dZ = (ExperimentData(n).StepData(t).Z_ABS(Zref) -  ExperimentData(n).StepData(t).Z_REL);
                %no dZ for particles referenced against self.
                ExperimentData(n).StepData(t).dZ(Zref==(1:num_tracks)) = NaN;
            end
            ExperimentData(n).mean_dZ= nanmean([ExperimentData(n).StepData.dZ],2);
            ExperimentData(n).std_dZ= nanstd([ExperimentData(n).StepData.dZ],0,2);
        end
    end
    
    %Time
    if isfield(ExperimentData(n).StepData,'Date')
        dT = num2cell( ([ExperimentData(n).StepData.Date] - ExperimentData(n).StepData(1).Date)*86400);
        [ExperimentData(n).StepData.dT] = deal( dT{:} );
    end
end

%% Return Output
if nargout<1
    putvar(header,ExperimentData);
    clear header;
    clear ExperimentData;
end

path(opath);


