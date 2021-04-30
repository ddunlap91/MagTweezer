%% Change the name of ctrl hat curve as "ExperimentData_1" and the name of the experimental hat curve as "ExperimentData_2"
%% EXPERIMENT Properties
%=============================
trk=2; %change trk number if necessary
DNA_LENGTH = 2115; %tether length in bp

%% Figure Dimensions and Settings
%======================================================
FIG_UNIT = 'centimeters'; %fig units
FIG_WIDTH = 18; %width in cm (or unit above)
FIG_HEIGHT = 13.7; %height in cm
AXES_COLOR = [0.2,0.2,0.2]; %color of the axes lines
AXES_LINE_WIDTH = 1;
LABEL_SIZE = 10;
LEGEND_SIZE = 10;
AXIS_FONT_SIZE = 8;

%Control 1 Line Format
CTRL1_FMT = {'Color','k',...
             'LineStyle','-',...
             'LineWidth',1.5,...
             'Marker','o',...
             'MarkerSize',6,...
             'MarkerEdgeColor','k',...
             'MarkerFaceColor','none'};
%Control 2 Line Format
CTRL2_FMT = {'Color','k',...
             'LineStyle','-',...
             'LineWidth',1.5,...
             'Marker','o',...
             'MarkerSize',6,...
             'MarkerEdgeColor','k',...
             'MarkerFaceColor','none'};
%Protein Curve FWD fromat
FWD_FMT = {'Color','r',...
             'LineStyle','-',...
             'LineWidth',1.5,...
             'Marker','o',...
             'MarkerSize',6,...
             'MarkerEdgeColor','r',...
             'MarkerFaceColor','none'};
 %Protein Curve FWD fromat
REV_FMT = {'Color','b',...
             'LineStyle','-',...
             'LineWidth',1.5,...
             'Marker','o',...
             'MarkerSize',6,...
             'MarkerEdgeColor','b',...
             'MarkerFaceColor','none'};

%% Setup Figure
%=========================================
hLin_control_1  = []; %handle to contol plot
hLin_control_2 = [];
hLin_fwd = [];
hLin_rev = [];

hFig = figure();
set(hFig,...
    'units',FIG_UNIT,...
    'position',[0,0,FIG_WIDTH,FIG_HEIGHT]);


movegui(hFig,'center'); %center the figure on the screen

%make pdf save cropped version without borders
set(hFig,'PaperUnits',FIG_UNIT,'PaperSize',[FIG_WIDTH,FIG_HEIGHT]);

%create main axes
hAx_zturns = gca; %the main z vs sigma axes, gca is a function in matlab "get current axis"
hold(hAx_zturns,'on');

%return
%% Load DATA
%====================================================
% FILE_EXT = '*.txt';
% [filename,path] = uigetfile(FILE_EXT,'Select first hat curve');
% 
% %check if user hit cancel
% if filename==0
%     return;
% end

% data = dlmread(fullfile(path,filename)); %read data from text
Turn_1=[ExperimentData_1.MagnetRotation]';
Extension_1=[ExperimentData_1.mean_dZ]';
Error_1=[ExperimentData_1.std_dZ]';

data=Turn_1;
data(:,2)=Extension_1(:,trk(1:1));
data(:,3)=Error_1(:,trk(1:1));
% %data format should be:
% % Turn Zext dZext

%Offset data
%===================================
hFig_tmp = figure();
errorbar(data(:,1),data(:,2),data(:,3),'-o');
xlabel('Turns');
ylabel('Z_{ext} (\mum)');
title('Select point to use as a reference (Z=0). Press return to skip.');
[x,y] = ginput(1);

%check if user skipped selecting point
if isempty(x)
    Z_Ref = 0;
else
    %find closest point in data
    [~,ind] = min(sqrt( (data(:,1)-x).^2 + (data(:,2)-y).^2));
    Z_ref = data(ind,2);
end

corrected_data = data;
corrected_data(:,2) = corrected_data(:,2)-Z_ref;

%we dont need the temp figure  anymore
close(hFig_tmp);
clear hFig_tmp;

%% Split data
%============================
control_data_1 = corrected_data(1:end/2,:);
control_data_2 = corrected_data(end/2+1:end,:);

%% Plot Control Data
%=====================================
figure(hFig);
set(hFig,'currentaxes',hAx_zturns); %set zturns to current axes

hLin_control_1 = errorbar(hAx_zturns,control_data_1(:,1),control_data_1(:,2),control_data_1(:,3),CTRL1_FMT{:});
hLin_control_2 = errorbar(hAx_zturns,control_data_2(:,1),control_data_2(:,2),control_data_2(:,3),CTRL2_FMT{:});

% hLin_control_1 = plot(hAx_zturns,control_data_1(:,1),control_data_1(:,2),CTRL1_FMT{:});
% hLin_control_2 = plot(hAx_zturns,control_data_2(:,1),control_data_2(:,2),CTRL2_FMT{:});

%% Load Protein Data
%============================
% FILE_EXT = '*.txt';
% [filename,path] = uigetfile(FILE_EXT,'Select second hat curve');
% 
% %check if user hit cancel
% if filename==0
%     return;
% end
% 
% data = dlmread(fullfile(path,filename)); %read data from text
Turn_2=[ExperimentData_2.MagnetRotation]';
Extension_2=[ExperimentData_2.mean_dZ]';
Error_2=[ExperimentData_2.std_dZ]';

data(:,1)=Turn_2(:,1);
data(:,2)=Extension_2(:,trk(1:1));
data(:,3)=Error_2(:,trk(1:1));
% %data format should be:
% % Turn Zext dZext

%Offset data
%===================================
% hFig_tmp = figure();
% errorbar(data(:,1),data(:,2),data(:,3),'-o');
% xlabel('Turns');
% ylabel('Z_{ext} (\mum)');
% title('Select point to use as a reference (Z=0). Press return to skip.');
% [x,y] = ginput(1);

%check if user skipped selecting point
%if isempty(x)
%    Z_Ref_p = 0;
%else
%    %find closest point in data
%    [~,ind] = min(sqrt( (data(:,1)-x).^2 + (data(:,2)-y).^2));
%    Z_ref_p = data(ind,2);
%end

corrected_data = data;
%corrected_data(:,2) = corrected_data(:,2)-Z_ref_p;
corrected_data(:,2) = corrected_data(:,2)-Z_ref; %Use same off set as the ctrl hat curve.

% %we dont need the temp figure  anymore
% close(hFig_tmp);
% clear hFig_tmp;


%split the data
prot_data_1 = corrected_data(1:end/2,:);
prot_data_2 = corrected_data(end/2+1:end,:);

%check for forward or backward
if prot_data_1(end,1)>prot_data_1(1,1)
    %first is forward
    prot_data_fwd = prot_data_1;
    prot_data_rev = prot_data_2;
else
    %first is reverse
    prot_data_fwd = prot_data_2;
    prot_data_rev = prot_data_1;
end
%cleanup the variables we don't need anymore
clear prot_data_1;
clear prot_data_2;
clear data;
clear corrected_data;

%% Plot protein curves
%===========================================
figure(hFig);
set(hFig,'currentaxes',hAx_zturns); %set zturns to current axes

hLin_fwd = errorbar(hAx_zturns,prot_data_fwd(:,1),prot_data_fwd(:,2),prot_data_fwd(:,3),FWD_FMT{:});
hLin_rev = errorbar(hAx_zturns,prot_data_rev(:,1),prot_data_rev(:,2),prot_data_rev(:,3),REV_FMT{:});

% hLin_fwd = plot(hAx_zturns,prot_data_fwd(:,1),prot_data_fwd(:,2),FWD_FMT{:});
% hLin_rev = plot(hAx_zturns,prot_data_rev(:,1),prot_data_rev(:,2),REV_FMT{:});

%% Create Legend
%==================================
leg_handles = [hLin_control_1,hLin_control_2,hLin_fwd,hLin_rev];
leg_strings = {'Control','Control','Forward','Reverse'};
legend(hAx_zturns,leg_handles,leg_strings,'FontSize',LEGEND_SIZE);


%% Change Limits or ticks
%============================
%if you want to set the limits or the tick locations for the main axis
%(turns) then you should do it here
 %xlim(hAx_zturns,[-22,22]);
 %set(hAx_zturns,'xtick',-25:5:25)


%% Format the Axes (top and bottom)
%===============================================
set(hAx_zturns,...
    'xaxislocation','bottom',...
    'yaxislocation','left',...
    'box','off',...
    'tickdir','out',...
    'YScale','linear',...
    'ygrid','on',...
    'GridLineStyle',':',...
    'xcolor',AXES_COLOR,...
    'ycolor',AXES_COLOR,...
    'XMinorTick','on', ...
    'YMinorTick','on', ...
    'LineWidth',AXES_LINE_WIDTH,...
    'color','none',...
    'FontSize',AXIS_FONT_SIZE);
%set labels
xlabel(hAx_zturns,'Turns','FontSize',LABEL_SIZE);
ylabel(hAx_zturns,'DNA Extension (\mum)','FontSize',LABEL_SIZE);


%% Create the sigma axis
%==========================
%note: this is a dumb axis and won't readjust when you make changes to the
%turns axis so you need to create this just before you are done plotting
%everything

%create second axes on top of first
hAx_zsig = axes('Position',get(hAx_zturns,'position'),...%set pos to pos of main axes
                    'xaxislocation','top',...
                    'yaxislocation','left',...
                    'box','off',...
                    'tickdir','out',...
                    'YScale','linear',...
                    'ygrid','off',...
                    'XMinorTick'  , 'on'      , ...
                    'YMinorTick'  , 'off'      , ...
                    'YTick',[],...
                    'YTickLabel',{},...
                    'xcolor',AXES_COLOR,...
                    'ycolor',AXES_COLOR,...
                    'LineWidth',AXES_LINE_WIDTH,...
                    'FontSize',AXIS_FONT_SIZE);


xlabel(hAx_zsig,'\sigma (%)','FontSize',LABEL_SIZE);

uistack(hAx_zturns,'top'); %move turns axes to top

%% Setup sigma axis limits and ticks
%========================================
%this should be the last block of code before saving the figure
xlim_turn = get(hAx_zturns,'xlim');
xtick_turn = get(hAx_zturns,'xtick');

xlim_sig = xlim_turn/(DNA_LENGTH/10.4)*100;
xtick_sig = xtick_turn/(DNA_LENGTH/10.4)*100;

%set limits so that we minimize the non-integer overhang on both axes
%not done


set(hAx_zsig,...
    'xlim',xlim_sig);

%set sigma ticks here
 set(hAx_zsig,...
     'xtick',-16:4:16);

%lock turns axis limit
set(hAx_zturns,...
    'xlim',xlim_turn,...
    'xtickmode','manual')
%% Save the fiure
%===============================








