function PlotForceExtension(varargin)

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

%% Calculate Tether Length & Force
kBT=1.380648813e-23*(273.15+header.Temperature)*10^6;
for n=1:numel(ExperimentData)
    X = bsxfun(@minus,[ExperimentData(n).StepData.X],ExperimentData(n).meanX)*header.PxScale;
    Y = bsxfun(@minus,[ExperimentData(n).StepData.Y],ExperimentData(n).meanY)*header.PxScale;
    for s=1:numel(ExperimentData(n).StepData)
        ExperimentData(n).StepData(s).L =sqrt(X(:,s).^2+Y(:,s).^2+ExperimentData(n).StepData(s).dZ.^2);
    end
    ExperimentData(n).meanL = nanmean([ExperimentData(n).StepData.L],2);
    ExperimentData(n).stdL = nanstd([ExperimentData(n).StepData.L],0,2);
    ExperimentData(n).Fx = kBT*ExperimentData(n).meanL./(ExperimentData(n).stdX.^2 * header.PxScale.^2);
    ExperimentData(n).FxErr = kBT*ExperimentData(n).stdL./(ExperimentData(n).stdX.^2 * header.PxScale.^2);
end
% meanL = ExperimentData(n).meanL
% stdL = ExperimentData(n).stdL
% stdX = ExperimentData(n).stdX
% Fx = ExperimentData(n).Fx


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
%% Plot Data
%=========================
%% L vs Mag
mL = [ExperimentData.meanL]';
mL(:,RefTrk) = [];
sL = [ExperimentData.stdL]';
sL(:,RefTrk) = [];

[~,hAx,~,hFig] = plot_timeordered(...
        repmat([ExperimentData.MagnetHeight]',1,numel(MeasTrk)),...
        mL,...
        [],[],...
        sL,sL,MeasNames);
hAx.Title.String = 'Length vs Magnet Height';
xlabel(hAx,'Magnet Height [mm]');
ylabel(hAx,'Avg. Tether Length [µm]');
hFig.Name = [filename,' L v. MagH'];
if ~isempty(filename)
    hFig.NumberTitle = 'off';
end

%% Fx v Mag
Fx = [ExperimentData.Fx]'*10^12;
Fx(:,RefTrk) = [];
FxErr = [ExperimentData.FxErr]'*10^12;
FxErr(:,RefTrk) = [];

[~,hAx,~,hFig] = plot_timeordered(...
    repmat([ExperimentData.MagnetHeight]',1,numel(MeasTrk)),...
    Fx,...
    [],[],...
    FxErr,FxErr,MeasNames);
hAx.Title.String = 'Force vs Magnet Height';
xlabel(hAx,'Magnet Height [mm]');
ylabel(hAx,'Force ( k_BTL/<dx^2>) [pN]');
%set(hAx,'yscale','log');
hFig.Name = [filename,' F v. MagH'];
if ~isempty(filename)
    hFig.NumberTitle = 'off';
end

%% Fx v L
[~,hAx_FvL,~,hFig_FvL] = ForceExtension_timeordered(...
    mL,...
    Fx,...
    sL,FxErr,...
    MeasNames);
hAx_FvL.Title.String = 'Force vs Length';
xlabel(hAx_FvL,'Avg. Tether Length [µm]');
ylabel(hAx_FvL,'Force ( k_BTL/<dx^2>) [pN]');

hFig_FvL.Name = [filename,' F v. L'];
if ~isempty(filename)
    hFig_FvL.NumberTitle = 'off';
end

%% Export Data to Workspace
putvar(header,ExperimentData)