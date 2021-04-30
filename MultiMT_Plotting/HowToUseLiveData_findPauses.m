close all;



% Use this code to format live data for plotting

T = ([LiveData.Date]' - LiveData(1).Date)*24*3600; %time in seconds

dZ = [LiveData.dZ]'; %concatenate and rotate dZ data
%   dZ = ...
%       [dZ_trk1(Time0), dZ_trk2(Time0),...
%        dZ_trk1(Time1), dZ_trk2(Time1),...
%        ...
%        dZ_trk1(TimeEnd), dZ_trk2(TimeEnd),...


%% Look at changes in Z_abs (doesn't use relative measurement)

Zabs = [LiveData.Z_ABS]';

% assuming track 1 is reference calculate drift
Z_drift = Zabs(:,1);
%Z_drift = Z_drift - Z_drift(1);

%filter the drift to eliminate noise
WINDOW = 60;
Z_drift_filt = movmean(Z_drift,WINDOW,1,'omitnan'); %moving average

%shift values to start at 0;
Z_drift = Z_drift - Z_drift_filt(1);
Z_drift_filt = Z_drift_filt - Z_drift_filt(1);


%alternative use last of unfiltered data, comment above if using this code
%Z_drift_filt(end+1:end+floor(WINDOW/2)-1) = X_drift(end-floor(WINDOW/2):end);

%plot drift
% figure();
% plot(T,Z_drift,'-');
% hold on;
% title('Drift based on refernce bead')
% plot(T,Z_drift_filt,'-');
% xlabel('time (sec)');
% ylabel('z drift (µm)');

%% Correct measurement Data for drift
Z_exp = Zabs(:,2:end);

% figure();
% plot(repmat(T,1,size(Z_exp,2)),Z_exp);
% title('Raw Zabs Data');
% xlabel('time (sec)');
% ylabel('Zabs: Height Relative to Calibration LUT (µm)');


Z_exp = bsxfun(@minus,Z_exp,nanmean(Z_exp(1:WINDOW,:),1)); %shift data to be zero for an average of the first WINDOW points, you need to use matrix expansion here which is why we have bsxfun


% figure();
% plot(repmat(T,1,size(Z_exp,2)),Z_exp);
% title('Mean-shifted Zabs data');
% xlabel('Time (sec)');
% ylabel('Zabs-<Zabs>_{1:wind} (µm)');

Z_exp = bsxfun(@minus,Z_exp,Z_drift_filt); %subtract the drift from each column

%remember, Z position is in terms of objective position so if particle gets
%further away from objective (i.e. moves further away from glass) the Z_abs
%will decrease.
%Therefore we need to take the negative to get the relative tether change
Z_exp = -Z_exp;

%% Seperately Plot Drift corrected data
for i=1:size(Z_exp,2)
figure();
plot(T,Z_exp(:,i),...
    'LineStyle','none',...
    'Marker','.',...
    'MarkerSize',3);
titlename=strcat('Drift-corrected change in particle',num2str(i),'height');
title(titlename)
xlabel('Time (sec)');
ylabel('Change in bead height (µm)');

%add filtered data
WIND_exp = 200;
Z_exp_filt = movmean(Z_exp,WIND_exp,1,'omitnan');%%filter(ones(WIND_exp,1)/WIND_exp,1,Z_exp); %moving average

%shift time
%Z_exp_filt = Z_exp_filt(floor(WIND_exp/2):end,:);
%Z_exp_filt(end+1:end+floor(WIND_exp/2)-1,:) = NaN;

hold on
plot(T,Z_exp_filt(:,i),'-');


trace = questdlg('Try finding pause?', ...
	'Trace', ...
	'Yes','No','Cancel','No');
% Handle response

switch trace
    case 'Yes'
        find_pauses(T, Z_exp(:,i));
        pause;
    case 'No'
        
        % do nothing
    case 'Cancel'
        break
end



end
