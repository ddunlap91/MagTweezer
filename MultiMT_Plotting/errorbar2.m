classdef errorbar2 < matlab.mixin.SetGet
%Class for plotting data with error bars
%   errorbar2(X) creates an errorbar object with only XData defined
%
%   errorbar2(X,Y) Creates errorbar object with XData and YData Defined
%
%   errorbar2(X,Y,XLOW,XUPP) creates errorbar object with Error bars along
%   x-direction with limits specified by XLOW and XHIGH
%
%   errorbar2(X,Y,XLOW,XUPP,YLOW,YUPP) creates errorbar object with error bars
%   along both x and y, defined by the limits [*LOW,*UPP]
%
%   errorbar2(__,name,value) specifies error properties using name-value
%   pairs
%
%   errorbar2(AXES_HANDLE, ___) specify axes to draw on
%
% Optional Parameters
%         %% Lines, Markers
%         %Data point properties
%         LineStyle = '-';
%         LineWidth = 0.5;
%         Color = [0,0,0];
%         Marker = 'none';
%         MarkerSize = 6;
%         MarkerEdgeColor = 'auto';
%         MarkerFaceColor = 'none';
%         
%         %whisker properties
%         XWhiskerLineStyle = '-';
%         XWhiskerLineWidth = 0.5;
%         XWhiskerColor = [0,0,0];
%         XWhiskerMarker = 'none';
%         XWhiskerMarkerSize = 6;
%         XWhiskerMarkerEdgeColor = 'auto';
%         XWhiskerMarkerFaceColor = 'none';
%         
%         YWhiskerLineStyle = '-';
%         YWhiskerLineWidth = 0.5;
%         YWhiskerColor = [0,0,0];
%         YWhiskerMarker = 'none';
%         YWhiskerMarkerSize = 6;
%         YWhiskerMarkerEdgeColor = 'auto';
%         YWhiskerMarkerFaceColor = 'none';
%         %% XBar
%         XBarSize = 12 %in points
%         XBarLineStyle = '-';
%         XBarLineWidth = 0.5;
%         XBarColor = 'auto'
%         XBarMarker = 'none';
%         XBarMarkerSize = 6;
%         XBarMarkerEdgeColor = 'auto';
%         XBarMarkerFaceColor = 'auto';
%         %% YBar
%         YBarSize = 12 %in points
%         YBarLineStyle = '-';
%         YBarLineWidth = 0.5;
%         YBarColor = 'auto';
%         YBarMarker = 'none';
%         YBarMarkerSize = 6;
%         YBarMarkerEdgeColor = 'auto';
%         YBarMarkerFaceColor = 'auto';
% Copyright 2016 Daniel T. Kovari

    properties (SetObservable = true)
        %% Lines, Markers
        %Data point properties
        LineStyle = '-';
        LineWidth = 0.5;
        Color = [0,0,0];
        Marker = 'none';
        MarkerSize = 6;
        MarkerEdgeColor = 'auto';
        MarkerFaceColor = 'none';
        
        %whisker properties
        XWhiskerLineStyle = '-';
        XWhiskerLineWidth = 0.5;
        XWhiskerColor = [0,0,0];
        XWhiskerMarker = 'none';
        XWhiskerMarkerSize = 6;
        XWhiskerMarkerEdgeColor = 'auto';
        XWhiskerMarkerFaceColor = 'none';
        
        YWhiskerLineStyle = '-';
        YWhiskerLineWidth = 0.5;
        YWhiskerColor = [0,0,0];
        YWhiskerMarker = 'none';
        YWhiskerMarkerSize = 6;
        YWhiskerMarkerEdgeColor = 'auto';
        YWhiskerMarkerFaceColor = 'none';
        %% XBar
        XBarSize = 12 %in points
        XBarLineStyle = '-';
        XBarLineWidth = 0.5;
        XBarColor = 'auto'
        XBarMarker = 'none';
        XBarMarkerSize = 6;
        XBarMarkerEdgeColor = 'auto';
        XBarMarkerFaceColor = 'auto';
        %% YBar
        YBarSize = 12 %in points
        YBarLineStyle = '-';
        YBarLineWidth = 0.5;
        YBarColor = 'auto';
        YBarMarker = 'none';
        YBarMarkerSize = 6;
        YBarMarkerEdgeColor = 'auto';
        YBarMarkerFaceColor = 'auto';
        
        %% Data
        XData;
        XDataAuto;
        YData;
        YDataAuto;
        XLowerData;
        XUpperData;
        YLowerData;
        YUpperData;
        
        %% Visbilility
        Visible
        Clipping
        
        %% Identifiers
        Tag
        DisplayName
        %more in const and dependent
        
        %% Parent/Child
        Parent
        HandleVisibility
        
        %% Interactive Control
        ButtonDownFcn
        UIContextMenu
        Selected
        SelectionHighlight
        
        %% Callback Execution Control
        PickableParts
        HitTest
        Interruptible
        BusyAction
        
        %% Creation Deletion
        CreateFcn
        DeleteFcn
        %BeingDeleted is setprivate and SetObservable
        
    end
    properties (SetAccess = private)
        %% Parent/Child
        Children; %graphics object array holding all plot elements
        DataLineHandle;
        XLowerLineHandles;
        XUpperLineHandles;
        YLowerLineHandles;
        YUpperLineHandles;
        XLowerBarHandles;
        XUpperBarHandles;
        YLowerBarHandles;
        YUpperBarHandles;
        
    end
    properties (SetAccess=private, SetObservable = true)
        BeingDeleted = false;
    end
    properties (Hidden)
        AnnotationObj;
        AxesSizeListener;
        AxesXLimListener;
        AxesYLimListener;
        AxesDeleteListener;
        AxesClaListener;
        AxesXScaleListener;
        AxesYScaleListener;
    end
    properties (Access = private)
        initialized = false;
    end
    properties (Dependent)
        %% Identifiers
        Annotation
    end
    properties (Constant)
        %% Identifiers
        Type = 'errorbar2';
    end
    methods %constructor and destructor
        function this = errorbar2(varargin)
            %parse input
            p = inputParser;
            p.CaseSensitive = false;
            %% Data Line
            addParameter(p,'LineStyle','-',@(x) any(strcmpi(x,{'-','--',':','-.','none'})));
            addParameter(p,'LineWidth',0.5,@(x) isscalar(x)&&isnumeric(x));
            addParameter(p,'Color',[0,0,0], @(x) isnumeric(x)&&numel(x)==3&&all(x>=0)&&all(x<=1) || ischar(x)&& any(strcmpi(x,{'yellow','y','magenta','m','cyan','c','red','r','green','g','blue','b','white','w','black','k'})));
            addParameter(p,'Marker','none', @(x) any(strcmpi(x,{'o','+','*','.','x','square','s','diamond','d','^','v','>','<','pentagram','p','hexagram','h','none'})));
            addParameter(p,'MarkerSize',6,@(x) isscalar(x)&&isnumeric(x));
            addParameter(p,'MarkerFaceColor','none', @valid_LineColor);
            addParameter(p,'MarkerEdgeColor','auto', @valid_LineColor);
            %% XWhisker
            addParameter(p,'XWhiskerLineStyle','-',@(x) any(strcmpi(x,{'-','--',':','-.','none'})));
            addParameter(p,'XWhiskerLineWidth',0.5,@(x) isscalar(x)&&isnumeric(x));
            addParameter(p,'XWhiskerColor','auto', @valid_LineColor);
            addParameter(p,'XWhiskerMarker','none', @(x) any(strcmpi(x,{'o','+','*','.','x','square','s','diamond','d','^','v','>','<','pentagram','p','hexagram','h','none'})));
            addParameter(p,'XWhiskerMarkerSize',6,@(x) isscalar(x)&&isnumeric(x));
            addParameter(p,'XWhiskerMarkerFaceColor','none', @valid_LineColor);
            addParameter(p,'XWhiskerMarkerEdgeColor','auto', @valid_LineColor);
            %% YWhisker
            addParameter(p,'YWhiskerLineStyle','-',@(x) any(strcmpi(x,{'-','--',':','-.','none'})));
            addParameter(p,'YWhiskerLineWidth',0.5,@(x) isscalar(x)&&isnumeric(x));
            addParameter(p,'YWhiskerColor','auto', @valid_LineColor);
            addParameter(p,'YWhiskerMarker','none', @(x) any(strcmpi(x,{'o','+','*','.','x','square','s','diamond','d','^','v','>','<','pentagram','p','hexagram','h','none'})));
            addParameter(p,'YWhiskerMarkerSize',6,@(x) isscalar(x)&&isnumeric(x));
            addParameter(p,'YWhiskerMarkerFaceColor','none', @valid_LineColor);
            addParameter(p,'YWhiskerMarkerEdgeColor','auto', @valid_LineColor);
            %% XBar
            addParameter(p,'XBarSize',12,@(x) isscalar(x)&&isnumeric(x));
            addParameter(p,'XBarLineStyle','-',@(x) any(strcmpi(x,{'-','--',':','-.','none'})));
            addParameter(p,'XBarLineWidth',0.5,@(x) isscalar(x)&&isnumeric(x));
            addParameter(p,'XBarColor','auto', @valid_LineColor);
            addParameter(p,'XBarMarker','none', @(x) any(strcmpi(x,{'o','+','*','.','x','square','s','diamond','d','^','v','>','<','pentagram','p','hexagram','h','none'})));
            addParameter(p,'XBarMarkerSize',6,@(x) isscalar(x)&&isnumeric(x));
            addParameter(p,'XBarMarkerFaceColor','none', @valid_LineColor);
            addParameter(p,'XBarMarkerEdgeColor','auto', @valid_LineColor);
            %% YBar
            addParameter(p,'YBarSize',12,@(x) isscalar(x)&&isnumeric(x));
            addParameter(p,'YBarLineStyle','-',@(x) any(strcmpi(x,{'-','--',':','-.','none'})));
            addParameter(p,'YBarLineWidth',0.5,@(x) isscalar(x)&&isnumeric(x));
            addParameter(p,'YBarColor','auto', @valid_LineColor);
            addParameter(p,'YBarMarker','none', @(x) any(strcmpi(x,{'o','+','*','.','x','square','s','diamond','d','^','v','>','<','pentagram','p','hexagram','h','none'})));
            addParameter(p,'YBarMarkerSize',6,@(x) isscalar(x)&&isnumeric(x));
            addParameter(p,'YBarMarkerFaceColor','none', @valid_LineColor);
            addParameter(p,'YBarMarkerEdgeColor','auto', @valid_LineColor);
            %% Data
            addParameter(p,'XData',[],@isnumeric);
            addParameter(p,'YData',[],@isnumeric);
            addParameter(p,'XLowerData',[],@isnumeric);
            addParameter(p,'XUpperData',[],@isnumeric);
            addParameter(p,'YLowerData',[],@isnumeric);
            addParameter(p,'YUpperData',[],@isnumeric);
            
            addParameter(p,'Parent',[],@(x) isempty(x)||ishghandle(x));
            
            %% set Data in passed not as parameter
            setXData = false;
            setYData = false;
            setXLower = false;
            setXUpper = false;
            setYLower = false;
            setYUpper = false;
            setParent = false;
            
            parseStart = 7;
            if nargin<1
                error('one input required')
            end
            
            if ishghandle(varargin{1})
                hAxes = varargin{1};
                setParent = true;
                varargin(1) = [];
            end
            
            for n = 1:min(6,numel(varargin))
                if ischar(varargin{n})
                    parseStart = n;
                    break;
                elseif n==1 
                    this.XData = varargin{n};
                    setXData = true;
                elseif n==2
                    this.YData = varargin{n};
                    setYData = true;
                elseif n==3
                    this.XLowerData = varargin{n};
                    setXLower = true;
                elseif n==4
                    this.XUpperData = varargin{n};
                    setXUpper = true;
                elseif n==5
                    this.YLowerData = varargin{n};
                    setYLower = true;
                elseif n==6
                    this.YUpperData = varargin{n};
                    setYUpper = true;
                end
            end
            parse(p,varargin{parseStart:end});
            ParamsToSet = p.Results;
            %% deal with parent
            if ~setParent
                hAxes = p.Results.Parent;
                if isempty(hAxes)||~ishghandle(hAxes)
                    hAxes = gca;
                end
            end
            ParamsToSet = rmfield(ParamsToSet,'Parent');
            this.Parent = hAxes;
            %'ctor parent appdata'
            %getappdata(this.Parent,'errorbar2_objects')
            
            %% other data
            if setXData
                ParamsToSet = rmfield(ParamsToSet,'XData');
            end
            if setYData
                ParamsToSet = rmfield(ParamsToSet,'YData');
            end
            if setXLower
                ParamsToSet = rmfield(ParamsToSet,'XLowerData');
            end
            if setXUpper
                ParamsToSet = rmfield(ParamsToSet,'XUpperData');
            end
            if setYLower
                ParamsToSet = rmfield(ParamsToSet,'YLowerData');
            end
            if setYUpper
                ParamsToSet = rmfield(ParamsToSet,'YUpperData');
            end
            %% set remaining parameters
            set(this,ParamsToSet);
            
            this.initialized = true;
            %% plot data
            this.replotdata();
            
%             if nargout == 0
%                 clear this
%             end
        end
        function delete(this)
            %'in delete'
            this.BeingDeleted = true;
            %% delete old axes items
            try
                delete(this.Children);
            catch
            end
            try
                delete(this.AxesSizeListener);
            catch
            end
            try
                delete(this.AxesXLimListener);
            catch
            end
                delete(this.AxesYLimListener);
            try
                delete(this.AxesDeleteListener);
            catch
            end
            try
                delete(this.AxesClaListener);
            catch
            end
            try
                delete(this.AxesXScaleListener);
            catch
            end
            try
                delete(this.AxesYScaleListener);
            catch
            end
            try
                hErs = getappdata(this.Parent,'errorbar2_objects');
                hErs(hErs==this) = [];
                setappdata(this.Parent,'errorbar2_objects',hErs);
                %'ok'
            catch
            end
            this.initialized = false;
        end
%         function ret = ishghandle(this)
%             ret = isvalid(this);
%         end
    end
    methods (Access=private)
        function replotdata(this)
            if ~this.initialized
                return;
            end
            %% make sure axes exists
            if isempty(this.Parent)||~ishghandle(this.Parent)
                return;
            end
            %% create data line if needed
            if isempty(this.DataLineHandle)||~ishghandle(this.DataLineHandle)
                this.DataLineHandle = line(this.Parent,NaN,NaN);
            end
            %% make/set dataline data 
            if ~isempty(this.YData) && ~isempty(this.XData) 
                if any(size(this.YData)~=size(this.XData))
                    return;
                end
                set(this.DataLineHandle,'XData',this.XData,'YData',this.YData);
            else %both empty
                %delete all lines and return
%                warning('setting both XData and YData to empty deletes all graphics elements created by errorbar2');
                delete(this.Children);
                this.Children = [];
                this.DataLineHandle = [];
                this.XWhiskerLineHandles =[];
                this.YWhiskerLineHandles = [];
                this.XLowerBarHandles = [];
                this.XUpperBarHandles = [];
                this.YLowerBarHandles = [];
                this.YUpperBarHandles = [];
                return;
            end
            %set dataline properties
            this.DataLineHandle.LineStyle = this.LineStyle;
            this.DataLineHandle.LineWidth = this.LineWidth;
            this.DataLineHandle.Color = this.Color;
            this.DataLineHandle.Marker = this.Marker;
            this.DataLineHandle.MarkerSize = this.MarkerSize;
            this.DataLineHandle.MarkerEdgeColor = this.MarkerEdgeColor;
            this.DataLineHandle.MarkerFaceColor = this.MarkerFaceColor;
            this.replotdataYLower;
            this.replotdataYLower
            
            %% Whiskers and Bars
            this.replotdataXLower;
            this.replotdataXUpper;
            this.replotdataYLower;
            this.replotdataYUpper;
            
            %%reset children and reorder plots
            this.resetChildren;
        end
        function replotdataXYonly(this)
            if ~this.initialized
                return;
            end
            %% make sure axes exists
            if isempty(this.Parent)||~ishghandle(this.Parent)
                return;
            end
            %% create data line if needed
            if isempty(this.DataLineHandle)||~ishghandle(this.DataLineHandle)
                this.replotdata;
                return;
            end
            %% make/set dataline data
            if any(size(this.YData)~=size(this.XData))
                return;
            end
            if ~isempty(this.YData) && ~isempty(this.XData) 
                set(this.DataLineHandle,'XData',this.XData,'YData',this.YData);
            else %both empty
                %delete all lines and return
%                warning('setting both XData and YData to empty deletes all graphics elements created by errorbar2');
                delete(this.Children);
                this.Children = [];
                this.DataLineHandle = [];
                this.XWhiskerLineHandles =[];
                this.YWhiskerLineHandles = [];
                this.XLowerBarHandles = [];
                this.XUpperBarHandles = [];
                this.YLowerBarHandles = [];
                this.YUpperBarHandles = [];
                return;
            end
        end
        function replotdataXLower(this)
            if any(size(this.YData)~=size(this.XData))
                return;
            end
            %% XLower
            if isempty(this.XLowerLineHandles)||~any(ishghandle(this.XLowerLineHandles))
                try
                    delete(this.XLowerLineHandles);
                catch
                end
                this.XLowerLineHandles = [];
            end
            if numel(this.XLowerLineHandles)<numel(this.XData)
                whiskcolor = this.XWhiskerColor;
                if strcmpi(whiskcolor,'auto')
                    whiskcolor = this.Color;
                end
                for n=numel(this.XLowerLineHandles)+1:numel(this.XData)
                    this.XLowerLineHandles(n) = line(this.Parent,NaN,NaN);
                    set(this.XLowerLineHandles(n),...
                        'LineStyle',this.XWhiskerLineStyle,...
                        'LineWidth',this.XWhiskerLineWidth,...
                        'Color',whiskcolor,...
                        'Marker',this.XWhiskerMarker,...
                        'MarkerSize',this.XWhiskerMarkerSize,...
                        'MarkerEdgeColor',this.XWhiskerMarkerEdgeColor,...
                        'MarkerFaceColor',this.XWhiskerMarkerFaceColor);
                end
            end
            if numel(this.XLowerLineHandles)>numel(this.XData)
                delete(this.XLowerLineHandles(numel(this.XData)+1:end));
                this.XLowerLineHandles(numel(this.XData)+1:end) = [];
            end
            %set data for x whiskers
            if ~isempty(this.XLowerData)
                if numel(this.XLowerData)<numel(this.XData)
                    this.XLowerData(end+1:numel(this.XData)) = NaN;
                end
                %set whisker data
                for n=1:min(numel(this.XData),numel(this.YData))
                    set(this.XLowerLineHandles(n),...
                        'XData',this.XData(n)+[-this.XLowerData(n),0],...
                        'YData',[this.YData(n),this.YData(n)]);
                end
            else %no x bounds, don't plot
                for n=1:numel(this.XLowerLineHandles)
                    set(this.XLowerLineHandles(n),'XData',NaN,'YData',NaN);
                end
            end
            %% X Bar Low
            if isempty(this.XLowerBarHandles)||~any(ishghandle(this.XLowerBarHandles))
                try
                    delete(this.XLowerBarHandles);
                catch
                end
                this.XLowerBarHandles = [];
            end
            if numel(this.XLowerBarHandles)<numel(this.XData)
                barcolor = this.XBarColor;
                if strcmpi(barcolor,'auto')
                    barcolor = this.Color;
                end
                for n=numel(this.XLowerBarHandles)+1:numel(this.XData)
                    this.XLowerBarHandles(n) = line(this.Parent,NaN,NaN);
                    set(this.XLowerBarHandles(n),...
                        'LineStyle',this.XBarLineStyle,...
                        'LineWidth',this.XBarLineWidth,...
                        'Color',barcolor,...
                        'Marker',this.XBarMarker,...
                        'MarkerSize',this.XBarMarkerSize,...
                        'MarkerEdgeColor',this.XBarMarkerEdgeColor,...
                        'MarkerFaceColor',this.XBarMarkerFaceColor);
                end
            end
            if numel(this.XLowerBarHandles)>numel(this.XData)
                delete(this.XLowerBarHandles(numel(this.XData)+1:end));
                this.XLowerBarHandles(numel(this.XData)+1:end) = [];
            end
            %% calc xbar height, set data
            orig_units = get(this.Parent,'units');
            set(this.Parent,'units','points');
            pos = plotboxpos(this.Parent);
            set(this.Parent,'units',orig_units);
            y_range = get(this.Parent,'ylim');
            if strcmpi(this.Parent.YScale,'log') %log scale
                y_range = log10(y_range);
                height = this.XBarSize*(y_range(2)-y_range(1))/pos(4);
                for n=1:min(numel(this.XData),numel(this.XLowerData))
                    set(this.XLowerBarHandles(n),'YData',10.^(log10(this.YData(n))+[-height/2,height/2]),'XData',(this.XData(n)-this.XLowerData(n))*[1,1]);
                end
            else %linear scale
                height = this.XBarSize*(y_range(2)-y_range(1))/pos(4);
                for n=1:min(numel(this.XData),numel(this.XLowerData))
                    set(this.XLowerBarHandles(n),'YData',this.YData(n)+[-height/2,height/2],'XData',(this.XData(n)-this.XLowerData(n))*[1,1]);
                end
            end
        end
        function replotdataXUpper(this)
            if any(size(this.YData)~=size(this.XData))
                return;
            end
            %% X Upper whisker
            if isempty(this.XUpperLineHandles)||~any(ishghandle(this.XUpperLineHandles))
                try
                    delete(this.XUpperLineHandles);
                catch
                end
                this.XUpperLineHandles = [];
            end
            if numel(this.XUpperLineHandles)<numel(this.XData)
                whiskcolor = this.XWhiskerColor;
                if strcmpi(whiskcolor,'auto')
                    whiskcolor = this.Color;
                end
                for n=numel(this.XUpperLineHandles)+1:numel(this.XData)
                    this.XUpperLineHandles(n) = line(this.Parent,NaN,NaN);
                    set(this.XUpperLineHandles(n),...
                        'LineStyle',this.XWhiskerLineStyle,...
                        'LineWidth',this.XWhiskerLineWidth,...
                        'Color',whiskcolor,...
                        'Marker',this.XWhiskerMarker,...
                        'MarkerSize',this.XWhiskerMarkerSize,...
                        'MarkerEdgeColor',this.XWhiskerMarkerEdgeColor,...
                        'MarkerFaceColor',this.XWhiskerMarkerFaceColor);
                end
            end
            if numel(this.XUpperLineHandles)>numel(this.XData)
                delete(this.XUpperLineHandles(numel(this.XData)+1:end));
                this.XUpperLineHandles(numel(this.XData)+1:end) = [];
            end
            %set data for x whiskers
            if ~isempty(this.XUpperData)
                if numel(this.XUpperData)<numel(this.XData)
                    this.XUpperData(end+1:numel(this.XData)) = NaN;
                end
                %set whisker data
                for n=1:min(numel(this.XData),numel(this.YData))
                    set(this.XUpperLineHandles(n),...
                        'XData',this.XData(n)+[0,this.XUpperData(n)],...
                        'YData',[this.YData(n),this.YData(n)]);
                end
            else %no x bounds, don't plot
                for n=1:numel(this.XUpperLineHandles)
                    set(this.XUpperLineHandles(n),'XData',NaN,'YData',NaN);
                end
            end
            %% X Bar Low
            if isempty(this.XUpperBarHandles)||~any(ishghandle(this.XUpperBarHandles))
                try
                    delete(this.XUpperBarHandles);
                catch
                end
                this.XUpperBarHandles = [];
            end
            if numel(this.XUpperBarHandles)<numel(this.XData)
                barcolor = this.XBarColor;
                if strcmpi(barcolor,'auto')
                    barcolor = this.Color;
                end
                for n=numel(this.XUpperBarHandles)+1:numel(this.XData)
                    this.XUpperBarHandles(n) = line(this.Parent,NaN,NaN);
                    set(this.XUpperBarHandles(n),...
                        'LineStyle',this.XBarLineStyle,...
                        'LineWidth',this.XBarLineWidth,...
                        'Color',barcolor,...
                        'Marker',this.XBarMarker,...
                        'MarkerSize',this.XBarMarkerSize,...
                        'MarkerEdgeColor',this.XBarMarkerEdgeColor,...
                        'MarkerFaceColor',this.XBarMarkerFaceColor);
                end
            end
            if numel(this.XUpperBarHandles)>numel(this.XData)
                delete(this.XUpperBarHandles(numel(this.XData)+1:end));
                this.XUpperBarHandles(numel(this.XData)+1:end) = [];
            end
            %% calc xbar height, set data
            orig_units = get(this.Parent,'units');
            set(this.Parent,'units','points');
            pos = plotboxpos(this.Parent);
            set(this.Parent,'units',orig_units);
            y_range = get(this.Parent,'ylim');
            if strcmpi(this.Parent.YScale,'log') %log scale
                y_range = log10(y_range);
                height = this.XBarSize*(y_range(2)-y_range(1))/pos(4);
                for n=1:min(numel(this.XData),numel(this.XUpperData))
                    set(this.XUpperHandles(n),'YData',10.^(log10(this.YData(n))+[-height/2,height/2]),'XData',(this.XData(n)+this.XUpperData(n))*[1,1]);
                end
            else %linear scale
                height = this.XBarSize*(y_range(2)-y_range(1))/pos(4);
                for n=1:min(numel(this.XData),numel(this.XUpperData))
                    set(this.XUpperBarHandles(n),'YData',this.YData(n)+[-height/2,height/2],'XData',(this.XData(n)+this.XUpperData(n))*[1,1]);
                end
            end
        end
        function replotdataYLower(this)
            if any(size(this.YData)~=size(this.XData))
                return;
            end
            %% XLower
            if isempty(this.YLowerLineHandles)||~any(ishghandle(this.YLowerLineHandles))
                try
                    delete(this.YLowerLineHandles);
                catch
                end
                this.YLowerLineHandles = [];
            end
            if numel(this.YLowerLineHandles)<numel(this.YData)
                whiskcolor = this.YWhiskerColor;
                if strcmpi(whiskcolor,'auto')
                    whiskcolor = this.Color;
                end
                for n=numel(this.YLowerLineHandles)+1:numel(this.YData)
                    this.YLowerLineHandles(n) = line(this.Parent,NaN,NaN);
                    set(this.YLowerLineHandles(n),...
                        'LineStyle',this.YWhiskerLineStyle,...
                        'LineWidth',this.YWhiskerLineWidth,...
                        'Color',whiskcolor,...
                        'Marker',this.YWhiskerMarker,...
                        'MarkerSize',this.YWhiskerMarkerSize,...
                        'MarkerEdgeColor',this.YWhiskerMarkerEdgeColor,...
                        'MarkerFaceColor',this.YWhiskerMarkerFaceColor);
                end
            end
            if numel(this.YLowerLineHandles)>numel(this.YData)
                delete(this.YLowerLineHandles(numel(this.YData)+1:end));
                this.YLowerLineHandles(numel(this.YData)+1:end) = [];
            end
            %set data for Y whiskers
            if ~isempty(this.YLowerData)
                if numel(this.YLowerData)<numel(this.YData)
                    this.YLowerData(end+1:numel(this.YData)) = NaN;
                end
                %set whisker data
                for n=1:min(numel(this.YData),numel(this.XData))
                    set(this.YLowerLineHandles(n),...
                        'YData',this.YData(n)+[-this.YLowerData(n),0],...
                        'XData',[this.XData(n),this.XData(n)]);
                end
            else %no Y bounds, don't plot
                for n=1:numel(this.YLowerLineHandles)
                    set(this.YLowerLineHandles(n),'XData',NaN,'YData',NaN);
                end
            end
            %% Y Bar Low
            if isempty(this.YLowerBarHandles)||~any(ishghandle(this.YLowerBarHandles))
                try
                    delete(this.YLowerBarHandles);
                catch
                end
                this.YLowerBarHandles = [];
            end
            if numel(this.YLowerBarHandles)<numel(this.YData)
                barcolor = this.YBarColor;
                if strcmpi(barcolor,'auto')
                    barcolor = this.Color;
                end
                for n=numel(this.YLowerBarHandles)+1:numel(this.YData)
                    this.YLowerBarHandles(n) = line(this.Parent,NaN,NaN);
                    set(this.YLowerBarHandles(n),...
                        'LineStyle',this.YBarLineStyle,...
                        'LineWidth',this.YBarLineWidth,...
                        'Color',barcolor,...
                        'Marker',this.YBarMarker,...
                        'MarkerSize',this.YBarMarkerSize,...
                        'MarkerEdgeColor',this.YBarMarkerEdgeColor,...
                        'MarkerFaceColor',this.YBarMarkerFaceColor);
                end
            end
            if numel(this.YLowerBarHandles)>numel(this.YData)
                delete(this.YLowerBarHandles(numel(this.YData)+1:end));
                this.YLowerBarHandles(numel(this.YData)+1:end) = [];
            end
            %% calc Ybar height, set data
            orig_units = get(this.Parent,'units');
            set(this.Parent,'units','points');
            pos = plotboxpos(this.Parent);
            set(this.Parent,'units',orig_units);
            x_range = get(this.Parent,'xlim');
            if strcmpi(this.Parent.XScale,'log') %log scale
                x_range = log10(x_range);
                width = this.YBarSize*(x_range(2)-x_range(1))/pos(3);
                for n=1:min(numel(this.YData),numel(this.YLowerData))
                    set(this.YLowerBarHandles(n),'XData',10.^(log10(this.XData(n))+[-width/2,width/2]),'YData',(this.YData(n)-this.YLowerData(n))*[1,1]);
                end
            else %linear scale
                width = this.YBarSize*(x_range(2)-x_range(1))/pos(3);
                for n=1:min(numel(this.YData),numel(this.YLowerData))
                    set(this.YLowerBarHandles(n),'XData',this.XData(n)+[-width/2,width/2],'YData',(this.YData(n)-this.YLowerData(n))*[1,1]);
                end
            end
        end
        function replotdataYUpper(this)
            if any(size(this.YData)~=size(this.XData))
                return;
            end
            %% Y upper whisker
            if isempty(this.YUpperLineHandles)||~any(ishghandle(this.YUpperLineHandles))
                try
                    delete(this.YUpperLineHandles);
                catch
                end
                this.YUpperLineHandles = [];
            end
            if numel(this.YUpperLineHandles)<numel(this.YData)
                whiskcolor = this.YWhiskerColor;
                if strcmpi(whiskcolor,'auto')
                    whiskcolor = this.Color;
                end
                for n=numel(this.YUpperLineHandles)+1:numel(this.YData)
                    this.YUpperLineHandles(n) = line(this.Parent,NaN,NaN);
                    set(this.YUpperLineHandles(n),...
                        'LineStyle',this.YWhiskerLineStyle,...
                        'LineWidth',this.YWhiskerLineWidth,...
                        'Color',whiskcolor,...
                        'Marker',this.YWhiskerMarker,...
                        'MarkerSize',this.YWhiskerMarkerSize,...
                        'MarkerEdgeColor',this.YWhiskerMarkerEdgeColor,...
                        'MarkerFaceColor',this.YWhiskerMarkerFaceColor);
                end
            end
            if numel(this.YUpperLineHandles)>numel(this.YData)
                delete(this.YUpperLineHandles(numel(this.YData)+1:end));
                this.YUpperLineHandles(numel(this.YData)+1:end) = [];
            end
            %set data for Y whiskers
            if ~isempty(this.YUpperData)
                if numel(this.YUpperData)<numel(this.YData)
                    this.YUpperData(end+1:numel(this.YData)) = NaN;
                end
                %set whisker data
                for n=1:min(numel(this.YData),numel(this.XData))
                    set(this.YUpperLineHandles(n),...
                        'YData',this.YData(n)+[0,this.YUpperData(n)],...
                        'XData',[this.XData(n),this.XData(n)]);
                end
            else %no Y bounds, don't plot
                for n=1:numel(this.YUpperLineHandles)
                    set(this.YUpperLineHandles(n),'XData',NaN,'YData',NaN);
                end
            end
            %% Y Bar Upper
            if isempty(this.YUpperBarHandles)||~any(ishghandle(this.YUpperBarHandles))
                try
                    delete(this.YUpperBarHandles);
                catch
                end
                this.YUpperBarHandles = [];
            end
            if numel(this.YUpperBarHandles)<numel(this.YData)
                barcolor = this.YBarColor;
                if strcmpi(barcolor,'auto')
                    barcolor = this.Color;
                end
                for n=numel(this.YUpperBarHandles)+1:numel(this.YData)
                    this.YUpperBarHandles(n) = line(this.Parent,NaN,NaN);
                    set(this.YUpperBarHandles(n),...
                        'LineStyle',this.YBarLineStyle,...
                        'LineWidth',this.YBarLineWidth,...
                        'Color',barcolor,...
                        'Marker',this.YBarMarker,...
                        'MarkerSize',this.YBarMarkerSize,...
                        'MarkerEdgeColor',this.YBarMarkerEdgeColor,...
                        'MarkerFaceColor',this.YBarMarkerFaceColor);
                end
            end
            if numel(this.YUpperBarHandles)>numel(this.YData)
                delete(this.YUpperBarHandles(numel(this.YData)+1:end));
                this.YUpperBarHandles(numel(this.YData)+1:end) = [];
            end
            %% calc Ybar height, set data
            orig_units = get(this.Parent,'units');
            set(this.Parent,'units','points');
            pos = plotboxpos(this.Parent);
            set(this.Parent,'units',orig_units);
            x_range = get(this.Parent,'xlim');
            if strcmpi(this.Parent.XScale,'log') %log scale
                x_range = log10(x_range);
                width = this.YBarSize*(x_range(2)-x_range(1))/pos(3);
                for n=1:min(numel(this.YData),numel(this.YUpperData))
                    set(this.YUpperBarHandles(n),'XData',10.^(log10(this.XData(n))+[-width/2,width/2]),'YData',(this.YData(n)+this.YUpperData(n))*[1,1]);
                end
            else %linear scale
                width = this.YBarSize*(x_range(2)-x_range(1))/pos(3);
                for n=1:min(numel(this.YData),numel(this.YUpperData))
                    set(this.YUpperBarHandles(n),'XData',this.XData(n)+[-width/2,width/2],'YData',(this.YData(n)+this.YUpperData(n))*[1,1]);
                end
            end
        end
        function resetChildren(this)
            %% make children array
            this.Children = [this.DataLineHandle,...
                                this.XLowerLineHandles,...
                                this.XUpperLineHandles,...
                                this.YLowerLineHandles,...
                                this.YUpperLineHandles,...
                                this.XLowerBarHandles,...
                                this.XUpperBarHandles,...
                                this.YLowerBarHandles,...
                                this.YUpperBarHandles];
            %% reorder so data is on top
            if ~isempty(this.DataLineHandle) && ishghandle(this.DataLineHandle)
                uistack(this.DataLineHandle,'top');
            end
        end
        function AxesSizeChange(this)
            if ~this.initialized
                return;
            end
%             if ~isvalid(this.Parent)||isempty(this.Parent)||~ishghandle(this.Parent)
%                 return;
%             end
            
            if numel(this.YData)~=numel(this.XData)
                %plot is not setup yet
                return
            end

            %% calc axes pos
            orig_units = get(this.Parent,'units');
            set(this.Parent,'units','points');
            pos = plotboxpos(this.Parent);
            set(this.Parent,'units',orig_units);
            %% xbar
            y_range = get(this.Parent,'ylim');
            if strcmpi(this.Parent.YScale,'log') %log scale
                y_range = log10(y_range);
                height = this.XBarSize*(y_range(2)-y_range(1))/pos(4);

                for n=1:min([numel(this.XData),numel(this.XLowerData),numel(this.XLowerBarHandles)])
                    set(this.XLowerBarHandles(n),'YData',10.^(log10(this.YData(n))+[-height/2,height/2]),'XData',(this.XData(n)-this.XLowerData(n))*[1,1]);
                end
                for n=1:min([numel(this.XData),numel(this.XUpperData),numel(this.XUpperBarHandles)])
                    set(this.XUpperBarHandles(n),'YData',10.^(log10(this.YData(n))+[-height/2,height/2]),'XData',(this.XData(n)+this.XUpperData(n))*[1,1]);
                end

            else %linear scale
                height = this.XBarSize*(y_range(2)-y_range(1))/pos(4);

                for n=1:min([numel(this.XData),numel(this.XLowerData),numel(this.XLowerBarHandles)])
                    set(this.XLowerBarHandles(n),'YData',this.YData(n)+[-height/2,height/2],'XData',(this.XData(n)-this.XLowerData(n))*[1,1]);
                end
                for n=1:min([numel(this.XData),numel(this.XUpperData),numel(this.XUpperBarHandles)])
                    set(this.XUpperBarHandles(n),'YData',this.YData(n)+[-height/2,height/2],'XData',(this.XData(n)+this.XUpperData(n))*[1,1]);
                end
            end

            %% ybar
            x_range = get(this.Parent,'xlim');
            if strcmpi(this.Parent.XScale,'log') %log scale
                x_range = log10(x_range);
                width = this.YBarSize*(x_range(2)-x_range(1))/pos(3);

                for n=1:min([numel(this.YData),numel(this.YLowerData),numel(this.YLowerBarHandles)])
                    set(this.YLowerBarHandles(n),'XData',10.^(log10(this.XData(n))+[-width/2,width/2]),'YData',(this.YData(n)-this.YLowerData(n))*[1,1]);
                end
                for n=1:min([numel(this.YData),numel(this.YUpperData),numel(this.YUpperBarHandles)])
                    set(this.YUpperBarHandles(n),'XData',10.^(log10(this.XData(n))+[-width/2,width/2]),'YData',(this.YData(n)+this.YUpperData(n))*[1,1]);
                end

            else %linear scale
                width = this.YBarSize*(x_range(2)-x_range(1))/pos(3);

                for n=1:min([numel(this.YData),numel(this.YLowerData),numel(this.YLowerBarHandles)])
                    set(this.YLowerBarHandles(n),'XData',this.XData(n)+[-width/2,width/2],'YData',(this.YData(n)-this.YLowerData(n))*[1,1]);
                end
                for n=1:min([numel(this.YData),numel(this.YUpperData),numel(this.YUpperBarHandles)])
                    set(this.YUpperBarHandles(n),'XData',this.XData(n)+[-width/2,width/2],'YData',(this.YData(n)+this.YUpperData(n))*[1,1]);
                end
            end
        end
    end
    methods %set methods
        %% Data point properties
        function set.LineStyle(this,val)
            if ~valid_LineStyle(val)
                error('invalid line style');
            end
            this.LineStyle = val;
            try
                set(this.DataLineHandle,'LineStyle',val);
            catch
            end
        end
        function set.LineWidth(this,val)
            if ~(isscalar(val)&&isnumeric(val))
                error('invalid line width');
            end
            this.LineWidth = val;
            try
                set(this.DataLineHandle,'LineWidth',val);
            catch
            end
        end
        function set.Color(this,val)
            if ~valid_LineColor(val)
                error('invalid line color');
            end
            if any(strcmpi(val,{'auto','none'}))
                error('invalid line color');
            end
            this.Color = val;
            try
                set(this.DataLineHandle,'Color',val);
            catch
            end
            try
                if strcmpi(this.XWhiskerColor,'auto')
                    for n=1:numel(this.XWhiskerLineHandles)
                        set(this.XWhiskerLineHandles,'Color',val);
                    end
                end
            catch
            end
            try
                if strcmpi(this.YWhiskerColor,'auto')
                    for n=1:numel(this.YWhiskerLineHandles)
                        set(this.YWhiskerLineHandles,'Color',val);
                    end
                end
            catch
            end
        end
        function set.Marker(this,val)
            if ~valid_LineMarker(val)
                error('invalid line marker');
            end
            if strcmpi(val,'auto')
                error('invalid line marker');
            end
            this.Marker = val;
            try
                set(this.DataLineHandle,'Marker',val);
            catch
            end
        end
        function set.MarkerSize(this,val)
            if ~(isscalar(val)&&isnumeric(val))
                error('invalid markersize');
            end
            this.MarkerSize = val;
            try
                set(this.DataLineHandle,'MarkerSize',val);
            catch
            end
        end
        function set.MarkerEdgeColor(this,val)
            if ~valid_LineColor(val)
                error('invalid line color');
            end
            this.MarkerEdgeColor = val;
            try
                set(this.DataLineHandle,'MarkerEdgeColor',val);
            catch
            end
        end
        function set.MarkerFaceColor(this,val)
            if ~valid_LineColor(val)
                error('invalid line color');
            end
            this.MarkerFaceColor = val;
            try
                set(this.DataLineHandle,'MarkerFaceColor',val);
            catch
            end
        end
        %% X whisker properties
        function set.XWhiskerLineStyle(this,val)
            if ~valid_LineStyle(val)
                error('invalid line style');
            end
            this.XWhiskerLineStyle = val;
            for n=1:numel(this.XLowerLineHandles)
                try
                    set(this.XLowerLineHandles(n),'LineStyle',val);
                catch
                end
            end
            for n=1:numel(this.XUpperLineHandles)
                try
                    set(this.XUpperLineHandles(n),'LineStyle',val);
                catch
                end
            end
        end
        function set.XWhiskerLineWidth(this,val)
            if ~(isscalar(val)&&isnumeric(val))
                error('invalid line width');
            end
            this.XWhiskerLineWidth = val;
            for n=1:numel(this.XLowerLineHandles)
                try
                    set(this.XLowerLineHandles(n),'LineWidth',val);
                catch
                end
            end
            for n=1:numel(this.XUpperLineHandles)
                try
                    set(this.XUpperLineHandles(n),'LineWidth',val);
                catch
                end
            end
        end
        function set.XWhiskerColor(this,val)
            if ~valid_LineColor(val)
                error('invalid line color');
            end
            this.XWhiskerColor = val;
            
            try
                if strcmpi(val,'auto')
                    val = this.Color;
                end
                for n=1:numel(this.XLowerLineHandles)
                    try
                        set(this.XLowerLineHandles(n),'Color',val);
                    catch
                    end
                end
            catch
            end
            try
                if strcmpi(val,'auto')
                    val = this.Color;
                end
                for n=1:numel(this.XUpperLineHandles)
                    try
                        set(this.XUpperLineHandles(n),'Color',val);
                    catch
                    end
                end
            catch
            end
        end
        function set.XWhiskerMarker(this,val)
            if ~valid_LineMarker(val)
                error('invalid line marker');
            end
            if strcmpi(val,'auto')
                error('invalid line color');
            end
            this.XWhiskerMarker = val;
            for n=1:numel(this.XLowerLineHandles)
                try
                    set(this.XLowerLineHandles(n),'Marker',val);
                catch
                end
            end
            for n=1:numel(this.XUpperLineHandles)
                try
                    set(this.XUpperLineHandles(n),'Marker',val);
                catch
                end
            end
        end
        function set.XWhiskerMarkerSize(this,val)
            if ~(isscalar(val)&&isnumeric(val))
                error('invalid markersize');
            end
            this.XWhiskerMarkerSize = val;
            for n=1:numel(this.XLowerLineHandles)
                try
                    set(this.XLowerLineHandles(n),'MarkerSize',val);
                catch
                end
            end
            for n=1:numel(this.XUpperLineHandles)
                try
                    set(this.XUpperLineHandles(n),'MarkerSize',val);
                catch
                end
            end
        end
        function set.XWhiskerMarkerEdgeColor(this,val)
            if ~valid_LineColor(val)
                error('invalid line color');
            end
            this.XWhiskerMarkerEdgeColor = val;
            try
                for n=1:numel(this.XLowerLineHandles)
                    try
                        set(this.XLowerLineHandles(n),'MarkerEdgeColor',val);
                    catch
                    end
                end
            catch
            end
            try
                for n=1:numel(this.XUpperLineHandles)
                    try
                        set(this.XUpperLineHandles(n),'MarkerEdgeColor',val);
                    catch
                    end
                end
            catch
            end
        end
        function set.XWhiskerMarkerFaceColor(this,val)
            if ~valid_LineColor(val)
                error('invalid line color');
            end
            this.XWhiskerMarkerFaceColor = val;
            
            try
                for n=1:numel(this.XLowerLineHandles)
                    try
                        set(this.XLowerLineHandles(n),'MarkerFaceColor',val);
                    catch
                    end
                end
            catch
            end
            try
                for n=1:numel(this.XUpperLineHandles)
                    try
                        set(this.XUpperLineHandles(n),'MarkerFaceColor',val);
                    catch
                    end
                end
            catch
            end
        end
        %% Y Whisker
        function set.YWhiskerLineStyle(this,val)
            if ~valid_LineStyle(val)
                error('invalid line style');
            end
            this.YWhiskerLineStyle = val;
            for n=1:numel(this.YLowerLineHandles)
                try
                    set(this.YLowerLineHandles(n),'LineStyle',val);
                catch
                end
            end
            for n=1:numel(this.YUpperLineHandles)
                try
                    set(this.YUpperLineHandles(n),'LineStyle',val);
                catch
                end
            end
        end
        function set.YWhiskerLineWidth(this,val)
            if ~(isscalar(val)&&isnumeric(val))
                error('invalid line width');
            end
            this.YWhiskerLineWidth = val;
            for n=1:numel(this.YLowerLineHandles)
                try
                    set(this.YLowerLineHandles(n),'LineWidth',val);
                catch
                end
            end
            for n=1:numel(this.YUpperLineHandles)
                try
                    set(this.YUpperLineHandles(n),'LineWidth',val);
                catch
                end
            end
        end
        function set.YWhiskerColor(this,val)
            if ~valid_LineColor(val)
                error('invalid line color');
            end
            this.YWhiskerColor = val;
            
            try
                if strcmpi(val,'auto')
                    val = this.Color;
                end
                for n=1:numel(this.YLowerLineHandles)
                    try
                        set(this.YLowerLineHandles(n),'Color',val);
                    catch
                    end
                end
            catch
            end
            try
                if strcmpi(val,'auto')
                    val = this.Color;
                end
                for n=1:numel(this.YUpperLineHandles)
                    try
                        set(this.YUpperLineHandles(n),'Color',val);
                    catch
                    end
                end
            catch
            end
        end
        function set.YWhiskerMarker(this,val)
            if ~valid_LineMarker(val)
                error('invalid line marker');
            end
            if strcmpi(val,'auto')
                error('invalid line color');
            end
            this.YWhiskerMarker = val;
            for n=1:numel(this.YLowerLineHandles)
                try
                    set(this.YLowerLineHandles(n),'Marker',val);
                catch
                end
            end
            for n=1:numel(this.YUpperLineHandles)
                try
                    set(this.YUpperLineHandles(n),'Marker',val);
                catch
                end
            end
        end
        function set.YWhiskerMarkerSize(this,val)
            if ~(isscalar(val)&&isnumeric(val))
                error('invalid markersize');
            end
            this.YWhiskerMarkerSize = val;
            for n=1:numel(this.YLowerLineHandles)
                try
                    set(this.YLowerLineHandles(n),'MarkerSize',val);
                catch
                end
            end
            for n=1:numel(this.YUpperLineHandles)
                try
                    set(this.YUpperLineHandles(n),'MarkerSize',val);
                catch
                end
            end
        end
        function set.YWhiskerMarkerEdgeColor(this,val)
            if ~valid_LineColor(val)
                error('invalid line color');
            end
            this.YWhiskerMarkerEdgeColor = val;
            
            try
                for n=1:numel(this.YLowerLineHandles)
                    try
                        set(this.YLowerLineHandles(n),'MarkerEdgeColor',val);
                    catch
                    end
                end
            catch
            end
            try
                for n=1:numel(this.YUpperLineHandles)
                    try
                        set(this.YUpperLineHandles(n),'MarkerEdgeColor',val);
                    catch
                    end
                end
            catch
            end
        end
        function set.YWhiskerMarkerFaceColor(this,val)
            if ~valid_LineColor(val)
                error('invalid line color');
            end
            this.YWhiskerMarkerFaceColor = val;
            
            try
                for n=1:numel(this.YLowerLineHandles)
                    try
                        set(this.YLowerLineHandles(n),'MarkerFaceColor',val);
                    catch
                    end
                end
            catch
            end
            try
                for n=1:numel(this.YUpperLineHandles)
                    try
                        set(this.YUpperLineHandles(n),'MarkerFaceColor',val);
                    catch
                    end
                end
            catch
            end
        end 
        %% Y bar properties
        function set.YBarSize(this,val)
            if ~isscalar(val)||~isnumeric(val)
                error('value must be numeric scalar');
            end
            this.YBarSize = val;
            try
            this.AxesSizeChange;
            catch
            end
        end
        function set.YBarLineStyle(this,val)
            if ~valid_LineStyle(val)
                error('invalid line style');
            end
            this.YBarLineStyle = val;
            for n=1:numel(this.YLowerBarHandles)
                try
                    set(this.YLowerBarHandles(n),'LineStyle',val);
                catch
                end
            end
            for n=1:numel(this.YUpperBarHandles)
                try
                    set(this.YUpperBarHandles(n),'LineStyle',val);
                catch
                end
            end
        end
        function set.YBarLineWidth(this,val)
            if ~(isscalar(val)&&isnumeric(val))
                error('invalid line width');
            end
            this.YBarLineWidth = val;
            for n=1:numel(this.YLowerBarHandles)
                try
                    set(this.YLowerBarHandles(n),'LineWidth',val);
                catch
                end
            end
            for n=1:numel(this.YUpperBarHandles)
                try
                    set(this.YUpperBarHandles(n),'LineWidth',val);
                catch
                end
            end
        end
        function set.YBarColor(this,val)
            if ~valid_LineColor(val)
                error('invalid line color');
            end
            this.YBarColor = val;
            
            try
                if strcmpi(val,'auto')
                    val = this.Color;
                end
                for n=1:numel(this.YLowerBarHandles)
                    try
                        set(this.YLowerBarHandles(n),'Color',val);
                    catch
                    end
                end
                for n=1:numel(this.YUpperBarHandles)
                    try
                        set(this.YUpperBarHandles(n),'Color',val);
                    catch
                    end
                end
            catch
            end
        end
        function set.YBarMarker(this,val)
            if ~valid_LineMarker(val)
                error('invalid line marker');
            end
            if strcmpi(val,'auto')
                error('invalid line color');
            end
            this.YBarMarker = val;
            for n=1:numel(this.YLowerBarHandles)
                try
                    set(this.YLowerBarHandles(n),'Marker',val);
                catch
                end
            end
            for n=1:numel(this.YUpperBarHandles)
                try
                    set(this.YUpperBarHandles(n),'Marker',val);
                catch
                end
            end
        end
        function set.YBarMarkerSize(this,val)
            if ~isnumeric(val)||~isscalar(val)
                error('invalid line marker');
            end
            if strcmpi(val,'auto')
                error('invalid line color');
            end
            this.YBarMarkerSize = val;
            for n=1:numel(this.YLowerBarHandles)
                try
                    set(this.YLowerBarHandles(n),'MarkerSize',val);
                catch
                end
            end
            for n=1:numel(this.YUpperBarHandles)
                try
                    set(this.YUpperBarHandles(n),'MarkerSize',val);
                catch
                end
            end
        end
        function set.YBarMarkerEdgeColor(this,val)
            if ~valid_LineColor(val)
                error('invalid line color');
            end
            this.YBarMarkerEdgeColor = val;
            
            try
                if strcmpi(val,'auto')
                    val = this.Color;
                end
                for n=1:numel(this.YLowerBarHandles)
                    try
                        set(this.YLowerBarHandles(n),'MarkerEdgeColor',val);
                    catch
                    end
                end
                for n=1:numel(this.YUpperBarHandles)
                    try
                        set(this.YUpperBarHandles(n),'MarkerEdgeColor',val);
                    catch
                    end
                end
            catch
            end
        end
        function set.YBarMarkerFaceColor(this,val)
            if ~valid_LineColor(val)
                error('invalid line color');
            end
            this.YBarMarkerFaceColor = val;
            
            try
                if strcmpi(val,'auto')
                    val = this.Color;
                end
                for n=1:numel(this.YLowerBarHandles)
                    try
                        set(this.YLowerBarHandles(n),'MarkerFaceColor',val);
                    catch
                    end
                end
                for n=1:numel(this.YUpperBarHandles)
                    try
                        set(this.YUpperBarHandles(n),'MarkerFaceColor',val);
                    catch
                    end
                end
            catch
            end
        end
        %% X Bar
        function set.XBarSize(this,val)
            if ~isscalar(val)||~isnumeric(val)
                error('value must be numeric scalar');
            end
            this.XBarSize = val;
            try
            this.AxesSizeChange;
            catch
            end
        end
        function set.XBarLineStyle(this,val)
            if ~valid_LineStyle(val)
                error('invalid line style');
            end
            this.XBarLineStyle = val;
            for n=1:numel(this.XLowerBarHandles)
                try
                    set(this.XLowerBarHandles(n),'LineStyle',val);
                catch
                end
            end
            for n=1:numel(this.XUpperBarHandles)
                try
                    set(this.XUpperBarHandles(n),'LineStyle',val);
                catch
                end
            end
        end
        function set.XBarLineWidth(this,val)
            if ~(isscalar(val)&&isnumeric(val))
                error('invalid line width');
            end
            this.XBarLineWidth = val;
            for n=1:numel(this.XLowerBarHandles)
                try
                    set(this.XLowerBarHandles(n),'LineWidth',val);
                catch
                end
            end
            for n=1:numel(this.XUpperBarHandles)
                try
                    set(this.XUpperBarHandles(n),'LineWidth',val);
                catch
                end
            end
        end
        function set.XBarColor(this,val)
            if ~valid_LineColor(val)
                error('invalid line color');
            end
            this.XBarColor = val;
            
            try
                if strcmpi(val,'auto')
                    val = this.Color;
                end
                for n=1:numel(this.XLowerBarHandles)
                    try
                        set(this.XLowerBarHandles(n),'Color',val);
                    catch
                    end
                end
                for n=1:numel(this.XUpperBarHandles)
                    try
                        set(this.XUpperBarHandles(n),'Color',val);
                    catch
                    end
                end
            catch
            end
        end
        function set.XBarMarker(this,val)
            if ~valid_LineMarker(val)
                error('invalid line marker');
            end
            if strcmpi(val,'auto')
                error('invalid line color');
            end
            this.XBarMarker = val;
            for n=1:numel(this.XLowerBarHandles)
                try
                    set(this.XLowerBarHandles(n),'Marker',val);
                catch
                end
            end
            for n=1:numel(this.XUpperBarHandles)
                try
                    set(this.XUpperBarHandles(n),'Marker',val);
                catch
                end
            end
        end
        function set.XBarMarkerSize(this,val)
            if ~isnumeric(val)||~isscalar(val)
                error('invalid line marker');
            end
            if strcmpi(val,'auto')
                error('invalid line color');
            end
            this.XBarMarkerSize = val;
            for n=1:numel(this.XLowerBarHandles)
                try
                    set(this.XLowerBarHandles(n),'MarkerSize',val);
                catch
                end
            end
            for n=1:numel(this.XUpperBarHandles)
                try
                    set(this.XUpperBarHandles(n),'MarkerSize',val);
                catch
                end
            end
        end
        function set.XBarMarkerEdgeColor(this,val)
            if ~valid_LineColor(val)
                error('invalid line color');
            end
            this.XBarMarkerEdgeColor = val;
            
            try
                if strcmpi(val,'auto')
                    val = this.Color;
                end
                for n=1:numel(this.XLowerBarHandles)
                    try
                        set(this.XLowerBarHandles(n),'MarkerEdgeColor',val);
                    catch
                    end
                end
                for n=1:numel(this.XUpperBarHandles)
                    try
                        set(this.XUpperBarHandles(n),'MarkerEdgeColor',val);
                    catch
                    end
                end
            catch
            end
        end
        function set.XBarMarkerFaceColor(this,val)
            if ~valid_LineColor(val)
                error('invalid line color');
            end
            this.XBarMarkerFaceColor = val;
            
            try
                if strcmpi(val,'auto')
                    val = this.Color;
                end
                for n=1:numel(this.XLowerBarHandles)
                    try
                        set(this.XLowerBarHandles(n),'MarkerFaceColor',val);
                    catch
                    end
                end
                for n=1:numel(this.XUpperBarHandles)
                    try
                        set(this.XUpperBarHandles(n),'MarkerFaceColor',val);
                    catch
                    end
                end
            catch
            end
        end
        %% Data
        function set.XData(this,val)
            this.XData = val;
            try
                this.replotdataXYonly;
                this.resetChildren;
            catch
            end
        end
        function set.YData(this,val)
            this.YData = val;
            try
                this.replotdataXYonly;
                this.resetChildren;
            catch
            end
        end
        function set.XLowerData(this,val)
            this.XLowerData = val;
            try
                this.replotdataXLower;
                this.resetChildren;
            catch
            end
        end
        function set.XUpperData(this,val)
            this.XUpperData = val;
            try
                this.replotdataXUpper;
                this.resetChildren;
            catch
            end
        end
        function set.YLowerData(this,val)
            this.YLowerData = val;
            try
                this.replotdataYLower;
                this.resetChildren;
            catch
            end
        end
        function set.YUpperData(this,val)
            this.YUpperData = val;
            try
                this.replotdataYUpper;
                this.resetChildren;
            catch
            end
        end
        %% Visbilility
        function set.Visible(this,val)
            val = lower(val);
            if ~any(strcmp(val,{'off','on'}))
                error('visibile must be either "on" or "off"');
            end
            set(this.Children,'visible',val);
            this.Visible = val;
        end
% %         Clipping
%         %% Identifiers
% %         Tag
% %         DisplayName
% %         %more in const and dependent  
        %% Parent/Child
        function set.Parent(this,val)
            %'set parent'
            %val
            %% delete old axes items
            try
                delete(this.Children)
            catch
            end
            try
                delete(this.AxesSizeListener);
            catch
            end
            try
                delete(this.AxesXLimListener);
            catch
            end
                delete(this.AxesYLimListener);
            try
                delete(this.AxesDeleteListener);
            catch
            end
            try
                delete(this.AxesClaListener);
            catch
            end
            try
                delete(this.AxesXScaleListener);
            catch
            end
            try
                delete(this.AxesYScaleListener);
            catch
            end
            try
                hErs = getappdata(this.Parent,'errorbar2_objects');
                hErs(hErs==this) = [];
                setappdata(this.Parent,'errorbar2_objects',hErs);
                %'ok'
            catch
            end
            
            %% setup new axes
            this.Parent = val;
            if isempty(this.Parent) || ~ishghandle(this.Parent)
                this.Parent = [];
                return;
            end
            if ~ishold(this.Parent);
                try
                    this.Parent.Children;
                catch
                end
            end
            this.AxesXScaleListener = addlistener(this.Parent,'XScale','PostSet',@(~,~) this.AxesSizeChange);
            this.AxesYScaleListener = addlistener(this.Parent,'YScale','PostSet',@(~,~) this.AxesSizeChange);
            this.AxesSizeListener = addlistener(this.Parent,'SizeChanged',@(~,~) this.AxesSizeChange);
            this.AxesXLimListener = addlistener(this.Parent,'XLim','PostSet',@(~,~) this.AxesSizeChange);
            this.AxesYLimListener = addlistener(this.Parent,'YLim','PostSet',@(~,~) this.AxesSizeChange);
            this.AxesDeleteListener = addlistener(this.Parent,'ObjectBeingDestroyed',@(~,~) delete(this));
            this.AxesClaListener = addlistener(this.Parent,'Cla',@(~,~) delete(this));
            
            if isappdata(this.Parent,'errorbar2_objects')
                eb2obj = getappdata(this.Parent,'errorbar2_objects');
            else
                eb2obj = [];
            end
            eb2obj = [eb2obj,this];
            setappdata(this.Parent,'errorbar2_objects',eb2obj);
            
            this.replotdata();
        end
%         function set.HandleVisibility(this,val)
%         end
%         %% Interactive Control
% %         ButtonDownFcn
% %         UIContextMenu
% %         Selected
% %         SelectionHighlight
% %         
% %         %% Callback Execution Control
% %         PickableParts
% %         HitTest
% %         Interruptible
% %         BusyAction
% %         
% %         %% Creation Deletion
% %         CreateFcn
% %         DeleteFcn
    end
end

function ret = valid_LineStyle(x)
ret = ischar(x)&&any(strcmpi(x,{'-','--',':','-.','none'}));
end

function ret = valid_LineColor(x)
ret = isnumeric(x)&&numel(x)==3&&all(x>=0)&&all(x<=1) || ischar(x)&& any(strcmpi(x,{'none','auto','yellow','y','magenta','m','cyan','c','red','r','green','g','blue','b','white','w','black','k'}));
end

function ret = valid_LineMarker(x)
ret = any(strcmpi(x,{'o','+','*','.','x','square','s','diamond','d','^','v','>','<','pentagram','p','hexagram','h','none'}));
end

function pos = plotboxpos(h)
%PLOTBOXPOS Returns the position of the plotted axis region
% pos = plotboxpos(h)
%
% This function returns the position of the plotted region of an axis,
% which may differ from the actual axis position, depending on the axis
% limits, data aspect ratio, and plot box aspect ratio.  The position is
% returned in the same units as the those used to define the axis itself.
% This function can only be used for a 2D plot.  
%
% Input variables:
%   h:      axis handle of a 2D axis (if ommitted, current axis is used).
% Output variables:
%   pos:    four-element position vector, in same units as h
% Copyright 2010 Kelly Kearney

% Check input
if nargin < 1
    h = gca;
end

if ~ishandle(h) || ~strcmp(get(h,'type'), 'axes')
    error('Input must be an axis handle');
end

% Get position of axis in pixels

currunit = get(h, 'units');
set(h, 'units', 'pixels');
axisPos = get(h, 'Position');
set(h, 'Units', currunit);

% Calculate box position based axis limits and aspect ratios

darismanual  = strcmpi(get(h, 'DataAspectRatioMode'),    'manual');
pbarismanual = strcmpi(get(h, 'PlotBoxAspectRatioMode'), 'manual');

if ~darismanual && ~pbarismanual
    pos = axisPos; 
else
    dx = diff(get(h, 'XLim'));
    dy = diff(get(h, 'YLim'));
    dar = get(h, 'DataAspectRatio');
    pbar = get(h, 'PlotBoxAspectRatio');

    limDarRatio = (dx/dar(1))/(dy/dar(2));
    pbarRatio = pbar(1)/pbar(2);
    axisRatio = axisPos(3)/axisPos(4);

    if darismanual
        if limDarRatio > axisRatio
            pos(1) = axisPos(1);
            pos(3) = axisPos(3);
            pos(4) = axisPos(3)/limDarRatio;
            pos(2) = (axisPos(4) - pos(4))/2 + axisPos(2);
        else
            pos(2) = axisPos(2);
            pos(4) = axisPos(4);
            pos(3) = axisPos(4) * limDarRatio;
            pos(1) = (axisPos(3) - pos(3))/2 + axisPos(1);
        end
    elseif pbarismanual
        if pbarRatio > axisRatio
            pos(1) = axisPos(1);
            pos(3) = axisPos(3);
            pos(4) = axisPos(3)/pbarRatio;
            pos(2) = (axisPos(4) - pos(4))/2 + axisPos(2);
        else
            pos(2) = axisPos(2);
            pos(4) = axisPos(4);
            pos(3) = axisPos(4) * pbarRatio;
            pos(1) = (axisPos(3) - pos(3))/2 + axisPos(1);
        end
    end
end

% Convert plot box position to the units used by the axis
temp = axes('Units', 'Pixels', 'Position', pos, 'Visible', 'off', 'parent', get(h, 'parent'));
set(temp, 'Units', currunit);
pos = get(temp, 'position');
delete(temp);
end