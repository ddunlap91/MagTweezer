function [hErr,hAx,hPnl,hFig] = plot_timeordered(X,Y,XLower,XUpper,YLower,YUpper,DataSetNames,hFig)
%Plot datasets X,Y in a panel_plot figure
%Panel contains controls for selecting which datasets are displayed and
%whether or not arrows/colorcoding is used to indicate the time-ordering of
%the data.
%
%Input:
% plot_timeordered(X,Y)
%   X: matrix of x data
%       if size(X,1)>1, the columns of X are assumed to correspond to
%       separate data sets
%   Y: matrix of y data
%       must have same dims as X
%
%Plot data with error bars:
% plot_timeordered(X,Y,XLower,XUpper,YLower,YUpper)
%Optionally set limits to empty to not include
% plot_timeordered(X,Y,[],...,YUpper)
%   Plot 
%Specify figure
%   plot_timeordered(...,hFig)

%% Validate data
if any(size(X)~=size(Y))
    error('dim of X and Y must match');
end

num_tracks = size(X,2);
% if size(X,1)==1
%     X=X';
%     Y=Y';
% end

if nargin>2 && ~isempty(XLower)
    if any(size(XLower) ~= size(X))
        error('xlower must be same size as x');
    end
else
    XLower= [];
end

if nargin>3 && ~isempty(XUpper)
    if any(size(XUpper) ~= size(X))
        error('XUpper must be same size as x');
    end
else
    XUpper = [];
end

if nargin>4 && ~isempty(YLower)
    if any(size(YLower) ~= size(X))
        error('YLower must be same size as x');
    end
else
   YLower = [];
end

if nargin>4 && ~isempty(YUpper)
    if any(size(YUpper) ~= size(X))
        error('YUpper must be same size as x');
    end
else
    YUpper = [];
end

if nargin<7
    DataSetNames = cell_sprintf('Data %d',1:num_tracks);
else
    if numel(DataSetNames)<num_tracks
        for n=numel(DataSetNames)+1:num_tracks
            DataSetNames{n} = sprintf('Data %d',n);
        end
    end
end

if nargin<8
    hFig = [];
end

% if ~ismatrix(X)
%     X = reshape(X,[],1);
%     Y = reshape(Y,[],1);
%     XLower = reshape(XLower,[],1);
%     XUpper = reshape(XUpper,[],1);
%     YLower = reshape(YLower,[],1);
%     YUpper = reshape(YUpper,[],1);
% end

%% init variables
dX = diff(X,1,1);
dY = diff(Y,1,1);



ShowArrow = false;
SelectedTracks = 1:num_tracks;
NotSelectedTracks = [];

data_colors = lines(num_tracks);

[hFig,hAx,hPnl] = panel_plot('ParentFigure',hFig);
hold(hAx,'on');
%% Plot Data
hErr = [];
hQvr = [];
Leg_Obj = [];
%Leg_Str = {};
for tk=1:num_tracks
    
    if ~isempty(XLower)
        xl = XLower(:,tk);
    else
        xl = [];
    end
    if ~isempty(XUpper)
        xu = XUpper(:,tk);
    else
        xu = [];
    end
    if ~isempty(YLower)
        yl = YLower(:,tk);
    else
        yl = [];
    end
    if ~isempty(YUpper)
        yu = YUpper(:,tk);
    else
        yu = [];
    end
    
    hE = errorbar2(hAx,X(:,tk),Y(:,tk),...
                xl,xu,...
                yl,yu,...
                'Marker','s',...
                'MarkerFaceColor',data_colors(tk,:),...
                'MarkerSize',4,...
                'Color',data_colors(tk,:));
    h = hE.DataLineHandle;

    hErr = [hErr,hE];

    Leg_Obj = [Leg_Obj,h];
    %Leg_Str = [Leg_Str,sprintf('Trk %d',tk)];


    hQ = quiver(hAx,X(1:end-1,tk),Y(1:end-1,tk),dX(:,tk),dY(:,tk),0,'-','filled','color',data_colors(tk,:));
    hQvr = [hQvr,hQ];
    if ShowArrow
        set(hQ,'Visible','on');
    else
        set(hQ,'Visible','off');
    end
    
    %add listener to xdata and ydata
    addlistener(hE,'XData','PostSet',@ReplotQuiver);
    addlistener(hE,'YData','PostSet',@ReplotQuiver);
end
legend(Leg_Obj,DataSetNames{:},'Location','northwest');
%% Setup panel contols
pnl_pos = hPnl.Position;

row_height = 2;
row_spacing = 0.1;
row_pos = pnl_pos(4)-row_height-row_spacing;

%Toggle Arrow
hSA = uicontrol('Parent',hPnl,...
        'Style','checkbox',...
        'Units','characters',...
        'position',[1,row_pos,pnl_pos(3)-1,row_height],...
        'String','Show Arrow',...
        'Value',ShowArrow,...
        'HorizontalAlignment','center',...
        'Callback',@ToggleShowArrow);
row_pos = row_pos - row_height - row_spacing;

%Tracks
hT = uicontrol('Parent',hPnl,...
        'Style','text',...
        'Units','characters',...
        'position',[0,row_pos,pnl_pos(3)-1,row_height-.5],...
        'String',' Tracks:',...
        'HorizontalAlignment','Left');
hTL = uicontrol('Parent',hPnl,...
        'Style','listbox',...
        'Units','characters',...
        'position',[1,0,pnl_pos(3)-1,row_pos],...
        'Max',2,...
        'Value',SelectedTracks,...
        'String',DataSetNames,...
        'HorizontalAlignment','Left',...
        'Callback',@SelectTracks);

set(hPnl,'SizeChangedFcn',@ResizePanel);
%% Callback functions
    function ResizePanel(hPnl,~)
        pnl_pos = hPnl.Position;

        row_height = 2;
        row_spacing = 0.1;
        row_pos = pnl_pos(4)-row_height-row_spacing;
        
        hSA.Position = [1,row_pos,pnl_pos(3)-1,row_height];
        row_pos = row_pos - row_height - row_spacing;
        row_pos = row_pos - row_height - row_spacing;
        hT.Position = [0,row_pos,pnl_pos(3)-1,row_height-.5];
        hTL.Position = [1,0,pnl_pos(3)-1,row_pos];
        
    end
    function ToggleShowArrow(hObj,~)
    	ShowArrow = get(hObj,'value');
        set(hQvr(SelectedTracks),'Visible','off');
        if ShowArrow
            set(hQvr(SelectedTracks),'Visible','on');
        else
            set(hQvr(SelectedTracks),'Visible','off');
        end
    end
    function SelectTracks(hObj,~)
        SelectedTracks = get(hObj,'value');
        NotSelectedTracks = 1:num_tracks;
        NotSelectedTracks(SelectedTracks) = [];
        set(hErr(NotSelectedTracks),'Visible','off');
        set(hErr(SelectedTracks),'Visible','on');
        set(hQvr(NotSelectedTracks),'Visible','off');
        if ShowArrow
            set(hQvr(SelectedTracks),'Visible','on');
        end
    end
    function ReplotQuiver(~,~)
%         if isempty(hQvr)||numel(hQvr)<numel(hErr)||any(~ishghandle(hQvr))
            delete(hQvr);
            hQvr = [];
            for t = 1:num_tracks
                thisX = hErr(t).XData;
                thisY = hErr(t).YData;
                if isempty(thisX)||isempty(thisY)||any(size(thisX)~=size(thisY))||numel(thisX)<2
                    continue
                end
                dX = diff(thisX);
                dY = diff(thisY);
                hQ = quiver(hAx,thisX(1:end-1),thisY(1:end-1),dX(:),dY(:),0,'-','filled','color',data_colors(t,:));
                hQvr = [hQvr,hQ];
            end
%         else
%             for t = 1:num_tracks
%                 thisX = hErr(t).XData;
%                 thisY = hErr(t).YData;
%                 if isempty(thisX)||isempty(thisY)||any(size(thisX)~=size(thisY))||numel(thisX)<2
%                     continue;
%                 end
%                 dX = diff(thisX);
%                 dY = diff(thisY);
%                 set(hQvr(t),'XData',thisX(1:end-1),'YData',thisY(1:end-1),'UData',dX(:),'VData',dY(:));
%             end
%         end
        if ShowArrow
            set(hQvr(SelectedTracks),'Visible','on');
        else
            set(hQvr(SelectedTracks),'Visible','off');
        end
        set(hQvr(NotSelectedTracks),'visible','off');
    end
end    

    
function c = cell_sprintf(format,data)
c = {};
for dataElement = data
    c{end+1} = sprintf(format,dataElement);
end
end