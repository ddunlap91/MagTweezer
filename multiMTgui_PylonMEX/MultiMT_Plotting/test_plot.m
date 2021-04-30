function test_plot()
close all;
hPlot = plot(10.^(1:5),1:5,'marker','s','markersize',8);hold on;

hAx = gca;

%set(hAx,'xscale','log');

% set(hAx,'units','points');
% 
% pos = plotboxpos(hAx);
% 
% set(hAx,'units','normalized');

% xl = get(hAx,'xlim');
% 
% xl = log10(xl);
% 
% c = 10^3;
% 
% w_log = 8*(xl(2)-xl(1))/pos(3);
% 
% c_log = log10(c);
% 
% plot([10^(c_log-w_log/2),10^(c_log+w_log/2)],[3,3]);

addlistener(hAx,'XLim','PostSet',@(a,b) disp('xlim'));
addlistener(hAx,'Position','PostSet',@(a,b) disp('position'));
%addlistener(hAx,'TightInset','PostSet',@(a,b) disp('TightInset'));
addlistener(hAx,'LooseInset','PostSet',@(a,b) disp('LooseInset'));
addlistener(hAx,'OuterPosition','PostSet',@(a,b) disp('OuterPosition'));
addlistener(hAx,'View','PostSet',@(a,b) disp('View'));
addlistener(hAx,'DataAspectRatio','PostSet',@(a,b) disp('DataAspectRatio'));
addlistener(hAx,'PlotBoxAspectRatio','PostSet',@(a,b) disp('PlotBoxAspectRatio'));
addlistener(hAx,'SizeChanged',@(~,~) disp('SizeChanged'));
