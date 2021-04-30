function [hErr,hAx,hPnl,hFig] = ForceExtension_timeordered(L,F,Lerr,Ferr,DataNames,hFig)
%Generate plot of force vs length using the timeordered plot interface
%   L = Tether length in um
%       [L_trk1, Ltrk2,...]
%   F = Force in pN
%       [F_trk1, F_trk2, ...]
%   Lerr = errorbar half-width for L
%   Ferr = errorbar half-width for F
% Optional
%   hFig: specify figure

if nargin<6
    hFig = [];
end

[hErr,hAx,hPnl,hFig] = plot_timeordered(...
    L,...
    F,...
    Lerr,Lerr,...
    Ferr,Ferr,DataNames,hFig);

hAx.Title.String = 'Force vs Length';
xlabel(hAx,'Avg. Tether Length [µm]');
ylabel(hAx,'Force [pN]');
set(hAx,'yscale','log');

%% Setup Fitting Menu
num_tracks = size(L,2);

hFitMenu = uimenu(hFig,'Label','Fit Data');
hShowFit = uimenu(hFitMenu,'Label','Show Fit');
hExclude = uimenu(hFitMenu,'Label','Exclude Data', 'Separator','on');
hInclude = uimenu(hFitMenu,'Label','Include Data');
hReset = uimenu(hFitMenu,'Label','Reset Data');

hFitLines = gobjects(num_tracks,1);
for n=1:num_tracks
    hFitLines(n) = line(hAx,NaN,NaN,'Marker','none','LineStyle','--','Color',hErr(n).Color,'Visible','off');
end
for t=1:num_tracks
    % show fit
    uimenu(hShowFit,'Label',DataNames{t},...
        'Checked','off',...
        'Interruptible','off',...
        'Callback', @(h,e) ShowFit(h,e,hAx,hErr(t),hFitLines(t)));
    
    % Exclude Data
    uimenu(hExclude,'Label',DataNames{t},...
        'Interruptible','off',...
        'Callback', @(h,e) ExcludeData(h,e,hAx,hErr(t),hFitLines(t)));
    
    % Include Data
    uimenu(hInclude,'Label',DataNames{t},...
        'Interruptible','off',...
        'Callback', @(h,e) IncludeData(h,e,hAx,hErr(t),hFitLines(t)));
    
    % reset data
    uimenu(hReset,'Label',DataNames{t},...
        'Interruptible','off',...
        'Callback', @(h,e) ResetData(h,e,hAx,hErr(t),hFitLines(t)));
    
end

function ShowFit(hMenu, ~, hAx, hEb, hFitLine)
if strcmpi(hMenu.Checked,'on')
    hMenu.Checked = 'off';
    if ishghandle(hFitLine)
        %excluded data
        if isappdata(hFitLine,'hExcLine') && ishghandle(getappdata(hFitLine,'hExcLine'))
            delete(getappdata(hFitLine,'hExcLine'))
            rmappdata(hFitLine,'hExcLine');
        end
        %legend update
        hLeg = findobj(hAx.Parent,'Type','legend');
        if ~isempty(hLeg)
            id = find(hLeg.PlotChildren==hFitLine);
            if ~isempty(id)
                hLeg.PlotChildren(id) = [];
            end
        end
        hFitLine.Visible = 'off';
    end
    return;
end
hMenu.Checked = 'on';

if ~ishghandle(hFitLine)
    hFitLine = line(hAx,NaN,NaN,'Marker','none','LineStyle','--','Color',hEb.Color);
end
hFitLine.Visible = 'on';

UpdateFit(hAx,hEb,hFitLine);

function UpdateFit(hAx,hEb, hFitLine)
if ~ishghandle(hFitLine)
    return;
end

if ~isappdata(hFitLine,'ExcludeIdx')
    ExcludeIdx = [];
    setappdata(hFitLine,'ExcludeIdx',ExcludeIdx);
else
    ExcludeIdx = getappdata(hFitLine,'ExcludeIdx');
end

%calc fit
L = hEb.XData;
F = hEb.YData;
L(ExcludeIdx) = [];
F(ExcludeIdx) = [];
[Lo,P,LoCI, PCI, ~] = FitWLC(L,F);

%update plot
xl = hAx.XLim;
yl = hAx.YLim;
x = linspace(0,Lo,30);
y = Fwlc(Lo,P,x);
set(hFitLine,'XData',x,'YData',y)
hAx.YLim = yl;
hAx.XLim = xl;

%update legend
hLeg = findobj(hAx.Parent,'Type','legend');
if ~isempty(hLeg)
    hFitLine.DisplayName = sprintf('L_0=%0.2f[%0.2f,%0.2f]µm L_p=%0.1f[%0.1f,%0.1f]nm',Lo,LoCI(1),LoCI(2),P,PCI(1),PCI(2));
    if ~any(hLeg.PlotChildren==hFitLine)
        hLeg.PlotChildren = [reshape(hLeg.PlotChildren,1,[]),reshape(hFitLine,1,[])];
    end
end

%plot exclusion points
if isappdata(hFitLine,'hExcLine') && ishghandle(getappdata(hFitLine,'hExcLine'))
    hExcLine = getappdata(hFitLine,'hExcLine');
    set(hExcLine,'XData',hEb.XData(ExcludeIdx),'YData',hEb.YData(ExcludeIdx));
else
    if isempty(ExcludeIdx)
        hExcLine = line(hAx,NaN,NaN,'Marker','x','color','r','MarkerSize',12,'LineStyle','none');
    else
        hExcLine = line(hAx,hEb.XData(ExcludeIdx),hEb.YData(ExcludeIdx),'Marker','x','color','r','MarkerSize',12,'LineStyle','none');
    end
    setappdata(hFitLine,'hExcLine',hExcLine);
end

function ExcludeData(~, ~, hAx, hEb, hFitLine)
if ~ishghandle(hFitLine)
    return;
    %hFitLine = line(hAx,NaN,NaN,'Marker','none','LineStyle','--','Color',hEb.Color);
end
if ~isappdata(hFitLine,'ExcludeIdx')
    ExcludeIdx = [];
    setappdata(hFitLine,'ExcludeIdx',ExcludeIdx);
else
    ExcludeIdx = getappdata(hFitLine,'ExcludeIdx');
end

rect = getrect(hAx);
thisExclude = find( hEb.XData>rect(1) & hEb.XData<(rect(1)+rect(3)) & hEb.YData>rect(2) & hEb.YData<(rect(2)+rect(4)));
for n=numel(thisExclude):-1:1
    if any(thisExclude(n) == ExcludeIdx)
        thisExclude(n) = [];
    end
end
ExcludeIdx = [ExcludeIdx;reshape(thisExclude,[],1)];

setappdata(hFitLine,'ExcludeIdx',ExcludeIdx);

UpdateFit(hAx,hEb,hFitLine);

function IncludeData(~, ~, hAx, hEb, hFitLine)
if ~ishghandle(hFitLine)
    'not hghandle'
    return;
    %hFitLine = line(hAx,NaN,NaN,'Marker','none','LineStyle','--','Color',hEb.Color);
end
if ~isappdata(hFitLine,'ExcludeIdx')
    ExcludeIdx = [];
    setappdata(hFitLine,'ExcludeIdx',ExcludeIdx);
else
    ExcludeIdx = getappdata(hFitLine,'ExcludeIdx');
end

rect = getrect(hAx);
thisInclude = find( hEb.XData>rect(1) & hEb.XData<(rect(1)+rect(3)) & hEb.YData>rect(2) & hEb.YData<(rect(2)+rect(4)));
for n=numel(ExcludeIdx):-1:1
    if any(ExcludeIdx(n) == thisInclude)
        ExcludeIdx(n) = [];
    end
end
setappdata(hFitLine,'ExcludeIdx',ExcludeIdx);

UpdateFit(hAx,hEb,hFitLine);

function ResetData(~, ~, hAx, hEb, hFitLine)
if ~ishghandle(hFitLine)
    'not hghandle'
    return;
    %hFitLine = line(hAx,NaN,NaN,'Marker','none','LineStyle','--','Color',hEb.Color);
end
ExcludeIdx = [];
setappdata(hFitLine,'ExcludeIdx',ExcludeIdx);

UpdateFit(hAx,hEb,hFitLine);

function [Lo,P,LoCI, PCI, fo] = FitWLC(L,Fx)
%Fit Fx vs L to WLC model
% Fx: pN
% L: same units as Lo (um a good choice)
% Lo = contour length (units of L)
% P = persistence length in nm
% fo = fitobject

ft = fittype('log10(4.11/P*(1/4*(1-x/Lo)^(-2)-1/4+x/Lo))');
%ft = fittype( @(Lo,P,x) log10( 4.11./P.*(1/4*(1- lessthan1(x./Lo) ).^(-2)-1/4+lessthan1(x./Lo)) ));

Fx(isnan(L)) = [];
L(isnan(L)) = [];
L(isnan(Fx)) = [];
Fx(isnan(Fx)) = [];

if isempty(L)
    Lo = NaN;
    P = NaN;
    LoCI = [NaN,NaN];
    PCI = [NaN,NaN];
    fo = [];
end

fo = fit(L,log10(Fx),ft,...
        'StartPoint',[100,1],...
        'Lower',[0,0],...
        'Upper',[Inf,Inf]);

coef = coeffvalues(fo);
coefint = confint(fo);
Lo = coef(1);
P = coef(2);
LoCI = coefint(:,1);
PCI = coefint(:,2);

function F = Fwlc(Lo,P,x)
x(x>=Lo) = NaN;
x(x<=0) = NaN;
F = 4.11./P.*(1/4*(1-x./Lo).^(-2)-1/4+x./Lo);