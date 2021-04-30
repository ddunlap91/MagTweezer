function PlotChapeauCurve(varargin)

%% Load Data
if nargin>1
    header = varargin{1};
    ExperimentData = varargin{2};
    filename = '';
else
    if nargin<1
        [header,ExperimentData,filepath] = LoadExperimentData();
    else
        [header,ExperimentData,filepath] = LoadExperimentData(varargin{1});
    end
    if isempty(header)
        return;
    end
    [~,filename,~] = fileparts(filepath); 
end

if ~isfield(ExperimentData,'StepData') || isempty(ExperimentData(1).StepData)
    warning('Data could not be loaded from file. Experiment might have been canceled or data could be corrupted.');
    return;
end

%% Plot Hat Curves
num_tracks = numel(header.TrackingInfo);
MeasTrk = find(strcmpi({header.TrackingInfo.Type},'Measurement'));
RefTrk = find(strcmpi({header.TrackingInfo.Type},'Reference'));
AllNames = cell(num_tracks,1);
for n=1:num_tracks
    AllNames{n} = sprintf('Trk %d, %s',n,header.TrackingInfo(n).Type);
end
MeasNames = cell(numel(MeasTrk),1);
for n=1:numel(MeasTrk)
    MeasNames{n} = sprintf('Trk %d',MeasTrk(n));
end
%% L vs Mag
dZ = [ExperimentData.mean_dZ]';

sdZ = [ExperimentData.std_dZ]';

[~,hAx,~,hFig] = plot_timeordered(...
        repmat([ExperimentData.MagnetRotation]',1,numel(MeasTrk)),...
        dZ(:,MeasTrk),...
        [],[],...
        sdZ(:,MeasTrk),sdZ(:,MeasTrk),MeasNames);
hAx.Title.String = 'Tether Height vs Magnet Rotation';
xlabel(hAx,'Magnet Rotation [Turns]');
ylabel(hAx,'Avg. Tether Height [µm]');
hFig.Name = [filename,' dZ v. MagR'];
if ~isempty(filename)
    hFig.NumberTitle = 'off';
end
putvar(header,ExperimentData)