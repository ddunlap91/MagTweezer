classdef ImageLevelsUI < matlab.mixin.SetGet
    % GUI for interactively setting image color scale
    %   Create:
    %    obj = ImageLevelsUI(ImageHandle,Parent)
    %           IamgeHandle: handle to image or imagesc object containing
    %           image
    %           Parent: optional handle to parent figure or panel in which
    %           the gui should be created. If Parent is not specified, a
    %           figure will be created automatically. The Created figure
    %           will be closed when obj is deleted.
    
    %% set at creation
    properties(SetAccess=protected)
        
        Parent %the parent axes 
        CreatedParent;
        ImageHandle;
        
        
    end
    
    %% internal properties
    properties(Access=protected)
        ParentDeleteListener
        ImageDeleteListener
        ImageChangeListener
        
        hChk_Auto
        hEdt_Min
        hEdt_Max
        hAxes
        HistogramStairs
        MinLine
        MaxLine
        AxesLimListener
        
        %for mouse functions
        CLICK_ON=false;
        orig_MouseMove
        orig_MouseUp
    end
    
    %% Dependent Properties
    properties(Dependent)
        ImageParent
    end
    
    %% User accessible settings
    properties (AbortSet=true)
        AutoScale=false% t/f
        Min = 0;
        Max = 1;
    end
    
    %% Create
    methods
        function this = ImageLevelsUI(ImageHandle,Parent)
            
            this.ImageHandle = ImageHandle;
            
            %% Validate Parent
            if nargin<2
                %% Create Figure
                Parent = figure('Name','Image Levels',...
                    'NumberTitle','off',...
                    'MenuBar','none',...
                    'ToolBar','none');
                this.CreatedParent = true;
                
                Parent.Position(4)=200;
            end
            assert(ishghandle(Parent),'Parent must be graphics handle');
            
            this.Parent = Parent;
            
            %% Build GUI
            VB =  uix.VBox('Parent',this.Parent,...
                'Padding',3);
            
            HB = uix.HBox('Parent',VB);
            
            %auto button
            this.hChk_Auto = uicontrol('Parent',HB,...
                'style','checkbox',...
                'String','Auto Scale',...
                'Value',this.AutoScale,...
                'Callback',@(h,~) set(this,'AutoScale',h.Value));
            
            %small empty space
            uix.HBox('Parent',HB);
            
            %hb for min
            hbmn = uix.HBox('Parent',HB);
            
            uicontrol('Parent',hbmn,...
                'style','text',...
                'string','Min:');
            this.hEdt_Min = uicontrol('Parent',hbmn,...
                'style','edit',...
                'string',num2str(this.Min),...
                'Callback',@(h,~) this.editMin(h.String));
            hbmn.Widths=[40,-1];
            
            %spacer box
            uix.HBox('Parent',HB);
            
            %hb for min
            hbmx = uix.HBox('Parent',HB);
            
            uicontrol('Parent',hbmx,...
                'style','text',...
                'string','Max:');
            this.hEdt_Max = uicontrol('Parent',hbmx,...
                'style','edit',...
                'string',num2str(this.Max),...
                'Callback',@(h,~) this.editMax(h.String));
            hbmx.Widths=[40,-1];
            
            HB.Widths = [75,2,100,-1,100];
            
            %Axes
            this.hAxes = axes('Parent',VB);
            
            VB.Heights=[25,-1];
            
            %% Create UI Plot Elements
            switch(class(this.ImageHandle.CData))
                case {'int8','int16','int32','int64','uint8','uint16','uint32','uint64'}
                    [cnt,edges] = histcounts(this.ImageHandle.CData(:),intmin(class(this.ImageHandle.CData)):intmax(class(this.ImageHandle.CData)));
                case 'double'
                    [cnt,edges] = histcounts(this.ImageHandle.CData(:));
                otherwise
                    warning('Invalide CData Type');
                    cnt = NaN;
                    edges = [NaN,NaN];
            end
            this.HistogramStairs = stairs(this.hAxes,edges(1:end-1),cnt,'Color','k','LineWidth',2);
            
            hold(this.hAxes,'on');
            
            this.MinLine = line(this.hAxes,...
                'XData',[this.Min,this.Min],...
                'YData',[0,1*max(this.HistogramStairs.YData)],...
                'Color','r',...
                'LineStyle','-',...
                'LineWidth',2,...
                'Marker','none',...
                'ButtonDownFcn',@(h,e) this.MinButtonDown(h,e));
            
            this.MaxLine = line(this.hAxes,...
                'XData',[this.Min,this.Min],...
                'YData',[0,1*max(this.HistogramStairs.YData)],...
                'Color','r',...
                'LineStyle','-',...
                'LineWidth',2,...
                'Marker','none',...
                'ButtonDownFcn',@(h,e) this.MaxButtonDown(h,e));
            axis(this.hAxes,'tight');
            
            xlabel(this.hAxes,'Intensity');
            ylabel(this.hAxes,'Counts');
            
            %listener for axes ylim changes
            this.AxesLimListener = addlistener(this.HistogramStairs,'YData','PostSet',@(~,~) this.AxesYLimChange());
            
            %% Setup Image Listeners
            this.ImageChangeListener=addlistener(this.ImageHandle,'CData','PostSet',@(~,~) this.ImageUpdated());
            
            %% Delete Listener
            this.ImageDeleteListener = addlistener(this.ImageHandle,'ObjectBeingDestroyed',@(~,~) delete(this));
            this.ParentDeleteListener = addlistener(this.Parent,'ObjectBeingDestroyed',@(~,~) delete(this));
            
            %% Set Default Limits
            this.Min = this.ImageParent.CLim(1);
            this.Max = this.ImageParent.CLim(2);
            
            %% call update
            this.ImageUpdated()
            
        end
    end
    
    %% Delete
    methods
        function delete(this)
            if this.CreatedParent
                delete(this.Parent);
            end
            delete(this.AxesLimListener);
            delete(this.ImageChangeListener);
            delete(this.ImageDeleteListener);
            delete(this.ParentDeleteListener);
        end
    end
    
    %% Hidden callback functions
    methods(Hidden=true)
        function editMin(this,str)
            val = str2double(str);
            if ~isnan(val)
                this.Min = val;
            end
            this.hEdt_Min.String = num2str(this.Min);
        end
        function editMax(this,str)
            val = str2double(str);
            if ~isnan(val)
                this.Max = val;
            end
            this.hEdt_Max.String = num2str(this.Max);
        end
        
        function ImageUpdated(this)
            if ~isvalid(this)
                return;
            end
            
            if this.AutoScale || isa(this.ImageHandle.CData,'double')
                CDATA_MIN = min(this.ImageHandle.CData(:));
                CDATA_MAX = max(this.ImageHandle.CData(:));
            end
            
            if this.AutoScale
                this.Min = CDATA_MIN;
                this.Max = CDATA_MAX;
            end
            
            if isa(this.ImageHandle.CData,'double')
                this.hAxes.XLim = [min(this.Min,CDATA_MIN),max(this.Max,CDATA_MAX)];
                    
                    [cnt,edges] = histcounts(this.ImageHandle.CData(:));
            else
                this.Min = max(intmin(class(this.ImageHandle.CData)),this.Min);
                this.Max = min(intmax(class(this.ImageHandle.CData)),this.Max);
                this.hAxes.XLim = [intmin(class(this.ImageHandle.CData)),intmax(class(this.ImageHandle.CData))];
                    
                [cnt,edges] = histcounts(this.ImageHandle.CData(:),intmin(class(this.ImageHandle.CData)):intmax(class(this.ImageHandle.CData)));
            end
 
            cnt =[cnt,0];
            %edges=[edges];
            set(this.HistogramStairs,'XData',edges,'YData',cnt);
            
        end
        
        %Mouse Functions
        function MouseUp(this,~,~)
            this.CLICK_ON = false;
            hFig = ancestor(this.hAxes,'figure');
            set(hFig,'WindowButtonMotionFcn',this.orig_MouseMove);
            set(hFig,'WindowButtonUpFcn',this.orig_MouseUp);
        end
        
        function MinButtonDown(this,~,e)
            this.AutoScale = false;
            if e.Button==1 && ~this.CLICK_ON
                this.CLICK_ON = true;
                hFig = ancestor(this.hAxes,'figure');
                this.orig_MouseMove = get(hFig,'WindowButtonMotionFcn');
                this.orig_MouseUp = get(hFig,'WindowButtonUpFcn');
                set(hFig,'WindowButtonUpFcn',@(h,e) this.MouseUp(h,e),'WindowButtonMotionFcn',@(h,e) this.MinMouseMove(h,e));
            end
        end
        
        function MinMouseMove(this,~,~)
            if this.CLICK_ON
                pt = get(this.hAxes, 'CurrentPoint');
                %x = pt(1,1);
                %y = pt(1,2);
                try
                    this.Min = pt(1,1);
                catch ME
                    disp(ME.getReport)
                end
            end
            
        end
        
        function MaxButtonDown(this,~,e)
            this.AutoScale = false;
            if e.Button==1 && ~this.CLICK_ON
                this.CLICK_ON = true;
                hFig = ancestor(this.hAxes,'figure');
                this.orig_MouseMove = get(hFig,'WindowButtonMotionFcn');
                this.orig_MouseUp = get(hFig,'WindowButtonUpFcn');
                set(hFig,'WindowButtonUpFcn',@(h,e) this.MouseUp(h,e),'WindowButtonMotionFcn',@(h,e) this.MaxMouseMove(h,e));
            end
        end
        
        function MaxMouseMove(this,~,~)
            if this.CLICK_ON
                pt = get(this.hAxes, 'CurrentPoint');
                %x = pt(1,1);
                %y = pt(1,2);
                try
                    this.Max = pt(1,1);
                catch ME
                    disp(ME.getReport)
                end
            end
            
        end
        
        function AxesYLimChange(this)
            this.MinLine.YData = [0,max(this.HistogramStairs.YData)];
            this.MaxLine.YData = [0,max(this.HistogramStairs.YData)];
        end
    end
    
    %% set Methods
    methods
        function set.Min(this,val)     
            if isnan(val)||isinf(val)
                return;
            end
            
            if isa(this.ImageHandle.CData,'double')
                val = min(double(this.Max)-eps,double(val));
            else
                val = min(this.Max-1, max(intmin(class(this.ImageHandle.CData)),val));
            end
            
            this.Min = val;
            this.MinLine.XData = [val,val];
            this.ImageParent.CLim = [this.Min,this.Max];
            
            this.hEdt_Min.String = num2str(val);
        end
        function set.Max(this,val)
            if isnan(val)||isinf(val)
                return;
            end
            
            if isa(this.ImageHandle.CData,'double')
                val = max(double(this.Min)+eps,double(val));
            else
                val = max(this.Min+1, min(intmax(class(this.ImageHandle.CData)),val));
            end
            
            this.Max = val;
            this.MaxLine.XData = [val,val];
            this.ImageParent.CLim = [this.Min,this.Max];
            this.hEdt_Max.String = num2str(val);
        end
        
        function set.AutoScale(this,val)
            val = logical(val);
            this.AutoScale = val;
            
            if this.AutoScale
                this.ImageUpdated();
            end
            
            this.hChk_Auto.Value = this.AutoScale;
        end
        
    end
    
    %% Dependent Get
    methods
        function hax = get.ImageParent(this)
            hax = get(this.ImageHandle,'Parent');
        end
    end
    
    %% Static Image Icon
    methods (Static)
        function img = ToolbarIcon()
            persistent out;
            if isempty(out)
                pth = mfilename('fullpath');
                [pth,~] = fileparts(pth);
                out = imread(fullfile(pth,'LevelsUI_Button.png'));
            end
            img = out;
        end
    end
end