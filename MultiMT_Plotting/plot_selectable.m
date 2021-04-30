function [hLines,hAx,hPnl,hFig] = plot_selectable(X,Y,DataSetNames,hFig,colors)

%% Validate data
if any(size(X)~=size(Y))
    error('dim of X and Y must match');
end

num_tracks = size(X,2);

if nargin<3
    DataSetNames = cell_sprintf('Data %d',1:num_tracks);
else
    if numel(DataSetNames)<num_tracks
        for n=numel(DataSetNames)+1:num_tracks
            DataSetNames{n} = sprintf('Data %d',n);
        end
    end
end

if nargin<4
    hFig = [];
end

if nargin<5
    colors = lines(num_tracks);
end

[hFig,hAx,hPnl] = panel_plot('ParentFigure',hFig);
hold(hAx,'on');
%% Plot Data
hLines = gobjects(num_tracks,1);


for n=1:num_tracks
    hLines(n) = plot(hAx,X(:,n),Y(:,n),'Marker','none','LineStyle','-','Color',colors(n,:));
    hLines(n).DisplayName = DataSetNames{n};
end
legend(hAx,'Location','northwest');

%% Data Selector
SelectedTracks = 1:num_tracks;

pnl_pos = hPnl.Position;

row_height = 2;
row_spacing = 0.1;
row_pos = pnl_pos(4)-row_height-row_spacing;

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
        
        hT.Position = [0,row_pos,pnl_pos(3)-1,row_height-.5];
        hTL.Position = [1,0,pnl_pos(3)-1,row_pos];
        
    end
    function SelectTracks(hObj,~)
        SelectedTracks = get(hObj,'value');
        NotSelectedTracks = 1:num_tracks;
        NotSelectedTracks(SelectedTracks) = [];
        set(hLines(NotSelectedTracks),'Visible','off');
        set(hLines(SelectedTracks),'Visible','on');
    end
end    

    
function c = cell_sprintf(format,data)
c = {};
for dataElement = data
    c{end+1} = sprintf(format,dataElement);
end
end