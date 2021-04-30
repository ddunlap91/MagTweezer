classdef uiray < extras.GraphicsChild
    %UIRAY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess=private)
        ArrowLine;
        RayLine;
        EndMarker;
        OriginMarker;
        
        UpperLimArc;
        LowerLimArc;
        
        DragState = 'none';
        
        Orig_MouseMove;
        Orig_MouseUp;
        
    end
    
    properties (Hidden) %Graphics object listeners
        AxesXLimListener;
        AxesYLimListener;
        
    end
    
    properties (SetObservable, AbortSet)
        Radius=1;
        Angle=0;
        
        RadiusDragable=true;
        AngleDragable=true;
        XOrigin=0;
        YOrigin=0;
        
        RadiusLim = [0,Inf];
        AngleLim = [0,2*pi];
        
        UIeditCallback
    end
    
    events
        UIeditcomplete;
    end
    
    properties (Dependent=true,SetObservable=true, AbortSet=true)
        RayLineVisible = true;
        EndMarkerVisible = true;
        OriginMarkerVisible = true;
        ArrowLineVisible = true;
        
        LimArcVisible = true;
        
        RayLineStyle = '--';
        RayLineWidth = 1.5;
        RayLineColor = 'k';
        
        ArrowLineStyle = '-';
        ArrowLineWidth = 2.5;
        ArrowLineColor = 'r';
        
        EndMarkerSymbol ='o';
        EndMarkerSize = 6;
        EndMarkerEdgeColor = 'k';
        EndMarkerFaceColor ='auto';
        
        OriginMarkerSymbol = '+';
        OriginMarkerSize = 14;
        OriginMarkerEdgeColor = 'none';
        OriginMarkerFaceColor = 'k';
    end

    methods %Constructor and Destructor
        function this = uiray(varargin)
            
            %% Setup Parent
            %initiate graphics parent related variables
            this@extras.GraphicsChild('axes');
            %look for parent specified in arguments
            varargin = this.CheckParentInput(varargin{:});
           
            
            %% Create Lines
            this.LowerLimArc = line(this.Parent,NaN,NaN,...
                'Color','k',...
                'LineStyle',':',...
                'LineWidth',0.5,...
                'HandleVisibility','callback',...
                'DeleteFcn',@(~,~) delete(this),...
                'SelectionHighlight','off',...
                'PickableParts','none',...
                'HitTest','off');
            this.UpperLimArc = line(this.Parent,NaN,NaN,...
                'Color','k',...
                'LineStyle',':',...
                'LineWidth',0.5,...
                'HandleVisibility','callback',...
                'DeleteFcn',@(~,~) delete(this),...
                'SelectionHighlight','off',...
                'PickableParts','none',...
                'HitTest','off');
            this.RayLine = line(this.Parent,NaN,NaN,...
                'HandleVisibility','callback',...
                'DeleteFcn',@(~,~) delete(this),...
                'SelectionHighlight','off',...
                'Interruptible','off',...
                'ButtonDownFcn',@(~,~) this.MouseClick_Line() );
            this.ArrowLine = line(this.Parent,NaN,NaN,...
                'HandleVisibility','callback',...
                'DeleteFcn',@(~,~) delete(this),...
                'SelectionHighlight','off',...
                'Interruptible','off',...
                'ButtonDownFcn',@(~,~) this.MouseClick_Line() );
            this.OriginMarker = line(this.Parent,NaN,NaN,...
                'HandleVisibility','callback',...
                'DeleteFcn',@(~,~) delete(this),...
                'Interruptible','off',...
                'SelectionHighlight','off');
            this.EndMarker = line(this.Parent,NaN,NaN,...
                'HandleVisibility','callback',...
                'DeleteFcn',@(~,~) delete(this),...
                'SelectionHighlight','off',...
                'PickableParts','all',...
                'HitTest','on',...
                'Interruptible','off',...
                'ButtonDownFcn',@(~,~) this.MouseClick_Marker() );
            
            %% Set other arguments
            % Parse Attributes
            p = inputParser;
            p.CaseSensitive = false;
            
            addParameter(p,'RadiusLim',[0,Inf]);
            addParameter(p,'AngleLim',[0,2*pi]);
            addParameter(p,'Radius',1);
            addParameter(p,'Angle',0);
            addParameter(p,'RayLineVisible',true);
            addParameter(p,'EndMarkerVisible',true);
            addParameter(p,'OriginMarkerVisible',true);
            addParameter(p,'ArrowLineVisible',true);
            addParameter(p,'RadiusDragable',true);
            addParameter(p,'AngleDragable',true);
            addParameter(p,'XOrigin',0);
            addParameter(p,'YOrigin',0);
            addParameter(p,'RayLineStyle','--');
            addParameter(p,'RayLineWidth',1.5);
            addParameter(p,'RayLineColor','k');
            addParameter(p,'ArrowLineStyle','-');
            addParameter(p,'ArrowLineWidth',2.5);
            addParameter(p,'ArrowLineColor','r');
            addParameter(p,'EndMarkerSymbol','o');
            addParameter(p,'EndMarkerSize',6);
            addParameter(p,'EndMarkerEdgeColor','k');
            addParameter(p,'EndMarkerFaceColor','auto');
            addParameter(p,'OriginMarkerSymbol','+');
            addParameter(p,'OriginMarkerSize',14);
            addParameter(p,'OriginMarkerEdgeColor','none');
            addParameter(p,'OriginMarkerFaceColor','k');
            addParameter(p,'LimArcVisible',true);
            addParameter(p,'UIeditCallback',[]);

            
            parse(p,varargin{:});
            
            %Set Parameters
            set(this,p.Results);
            
            %% Setup axes listeners
            this.AxesXLimListener = addlistener(this.Parent,'XLim','PostSet',@(~,~) this.AxesLimChange);
            this.AxesYLimListener = addlistener(this.Parent,'YLim','PostSet',@(~,~) this.AxesLimChange);
            
            
            this.updatePositions();
            this.updateLimArc();
            
            %% If created parent, make axes square
            if this.CreatedParent
                if isinf(this.RadiusLim(2))
                    RMax = 1.2*this.Radius;
                else
                    RMax = 1.05*this.RadiusLim(2);
                end
                axis(this.Parent,'square');
                set(this.Parent,'XLim',[-RMax,RMax],'YLim',[-RMax,RMax],...
                    'XAxisLocation','Origin',...
                    'YAxisLocation','Origin');
            end
        end
        
        function delete(this)
            
            %force mouseup event to reset figure callbacks
            try
            this.MouseUp();
            catch
            end
            
            %delete listeners
            try
            delete(this.AxesXLimListener);
            delete(this.AxesYLimListener);
            catch
            end
            
            %delete graphical elements
            try
            delete(this.ArrowLine);
            delete(this.RayLine);
            delete(this.EndMarker);
            delete(this.OriginMarker);
            catch
            end
            
            
            
        end
    end
    
    methods% mouse callbacks
        function MouseClick_Line(this)
            if this.AngleDragable
                this.DragState = 'theta';
                
                %set ui callbacks
                this.Orig_MouseMove = this.ParentFigure.WindowButtonMotionFcn;
                this.Orig_MouseUp = this.ParentFigure.WindowButtonUpFcn;
                this.ParentFigure.WindowButtonUpFcn = @(h,e) this.MouseUp(h,e);
                this.ParentFigure.WindowButtonMotionFcn = @(h,e) this.MouseMove(h,e);
            end
        end
        function MouseClick_Marker(this)
            if this.RadiusDragable
                this.DragState = 'radius';
                
                %set ui callbacks
                this.Orig_MouseMove = this.ParentFigure.WindowButtonMotionFcn;
                this.Orig_MouseUp = this.ParentFigure.WindowButtonUpFcn;
                this.ParentFigure.WindowButtonUpFcn = @(h,e) this.MouseUp(h,e);
                this.ParentFigure.WindowButtonMotionFcn = @(h,e) this.MouseMove(h,e);
            end
        end
        
        function MouseMove(this,~,~)
            %this.DragState
            switch this.DragState
                case 'theta'
                    pt = get(this.Parent, 'CurrentPoint');
                    %convert to polar
                    theta = mod(atan2( pt(1,2)-this.YOrigin ,pt(1,1)-this.XOrigin),2*pi);
                    this.Angle = max(this.AngleLim(1),min(this.AngleLim(2),theta));
                case 'radius'
                    pt = get(this.Parent, 'CurrentPoint');
                    %convert to polar
                    r = sqrt( (pt(1,1)-this.XOrigin)^2 + (pt(1,2)-this.YOrigin)^2);
                    
                    
                    %if behind origin, set to min
                    theta = mod(atan2( pt(1,2)-this.YOrigin ,pt(1,1)-this.XOrigin),2*pi);
                    if abs(this.Angle-theta)>pi/2 %>90 deg
                        this.Radius = this.RadiusLim(1);
                    else
                        this.Radius = max(this.RadiusLim(1),min(this.RadiusLim(2),r));
                    end
                    
            end
            
        end
        function MouseUp(this,~,~)
            this.DragState = 'none';
            this.ParentFigure.WindowButtonUpFcn = this.Orig_MouseUp;
            this.ParentFigure.WindowButtonMotionFcn = this.Orig_MouseMove;
            
            %fire uieditcallback
            hgfeval(this.UIeditCallback,this,struct('Event','DragDone'));
            
            %notify event listeners
            notify(this,'UIeditcomplete');
        end
        
    end
    
    methods %axes listeners
        function AxesLimChange(this)
            if isinf(this.RadiusLim(2))
                xlims = this.Parent.XLim;
                ylims = this.Parent.YLim;
                
                corners = [xlims(1),xlims(1),xlims(2),xlims(2);...
                           ylims(1),ylims(2),ylims(1),ylims(2)];
                corners=corners-[this.XOrigin;this.YOrigin];
                
                RMax = max( sqrt(sum(corners.^2,1)));
                set(this.RayLine,...
                    'XData',[this.XOrigin,this.XOrigin+RMax*cos(this.Angle)],...
                    'YData',[this.YOrigin,this.YOrigin+RMax*sin(this.Angle)]);
            end
        end
    end
    
    methods(Access=private)
        function updatePositions(this)
            
            %set arrow positions
            set(this.ArrowLine,...
                'XData',[this.XOrigin,this.XOrigin+this.Radius*cos(this.Angle)],...
                'YData',[this.YOrigin,this.YOrigin+this.Radius*sin(this.Angle)]);
            %set marker position
            set(this.EndMarker,...
                'XData',this.XOrigin+this.Radius*cos(this.Angle),...
                'YData',this.YOrigin+this.Radius*sin(this.Angle));
            
            % set ray line position
            RMax = this.RadiusLim(2);
            if isinf(RMax)
                xlims = this.Parent.XLim;
                ylims = this.Parent.YLim;
                
                corners = [xlims(1),xlims(1),xlims(2),xlims(2);...
                           ylims(1),ylims(2),ylims(1),ylims(2)];
                corners=corners-[this.XOrigin;this.YOrigin];
                
                RMax = max( sqrt(sum(corners.^2,1)));
            end
            set(this.RayLine,...
                'XData',[this.XOrigin,this.XOrigin+RMax*cos(this.Angle)],...
                'YData',[this.YOrigin,this.YOrigin+RMax*sin(this.Angle)]);
        end
        function updateLimArc(this)
            tt = linspace(this.AngleLim(1),this.AngleLim(2),500);
            if this.RadiusLim(1)>0
                set(this.LowerLimArc,'xdata',this.RadiusLim(1)*cos(tt),'ydata',this.RadiusLim(1)*sin(tt));
            else
                set(this.LowerLimArc,'xdata',NaN,'ydata',NaN);
            end
            if ~isinf(this.RadiusLim(2))
                set(this.UpperLimArc,'xdata',this.RadiusLim(2)*cos(tt),'ydata',this.RadiusLim(2)*sin(tt));
            else
                set(this.UpperLimArc,'xdata',NaN,'ydata',NaN);
            end
        end
    end
    
    methods %set Methods
        function set.Radius(this,val)
            assert(isscalar(val),'must be scalar');
            %set to limits
            val = min(max(this.RadiusLim(1),val),this.RadiusLim(2));
            
            this.Radius = val;
            
            this.updatePositions();
            
        end
        function set.Angle(this,val)
            assert(isscalar(val),'must be scalar');
            val = mod(val,2*pi);
            %set to limits
            val = min(max(this.AngleLim(1),val),this.AngleLim(2));
            
            this.Angle = val;
            
            this.updatePositions();
            
        end
        function set.XOrigin(this,val)
            assert(isscalar(val)&&isnumeric(val),'value must be numeric scalar');
            
            this.XOrigin = val;
            this.updatePositions();
            
        end
        function set.YOrigin(this,val)
            assert(isscalar(val)&&isnumeric(val),'value must be numeric scalar');
            
            this.YOrigin = val;
            this.updatePositions();
        end
        
        function set.RadiusLim(this,val)
            assert(numel(val)==2,'lim must have numel(...)==2');
            assert(all(val>=0),'all lim>=0');
            val = reshape(val,1,2);
            val = sort(val);
            this.RadiusLim = val;
            this.Radius = max(this.RadiusLim(1),min(this.Radius,this.RadiusLim(2)));
            this.updateLimArc();
            this.updatePositions();
        end
        function set.AngleLim(this,val)
            assert(numel(val)==2,'lim must have numel(...)==2');
            assert(all(val>=0),'all lim>=0');
            val = reshape(val,1,2);
            val = sort(val);
            this.AngleLim = mod(val,2*pi);
            this.Angle = max(this.AngleLim(1),min(this.Angle,this.AngleLim(2)));
            this.updateLimArc();
            this.updatePositions();
        end
        
        function set.RadiusDragable(this,val)
            assert( isscalar(val)&&(isnumeric(val)||islogical(val))...
                ||ischar(val)&&ismember(lower(val),{'off','on'}),...
                'Invalid data for RadiusDragable');
            if ~ischar(val)
                val=logical(val);
            else
                switch lower(val)
                    case 'on'
                        val = true;
                    case 'off'
                        val = false;
                end
            end
            this.RDraggable = val;
            
            if ~this.RDraggable
                this.EndMarker.PickableParts = 'none';
            else
                this.EndMarker.PickableParts = 'all';
            end
        end
        function set.AngleDragable(this,val)
            assert( isscalar(val)&&(isnumeric(val)||islogical(val))...
                ||ischar(val)&&ismember(lower(val),{'off','on'}),...
                'Invalid data for AngleDragable');
            if ~ischar(val)
                val=logical(val);
            else
                switch lower(val)
                    case 'on'
                        val = true;
                    case 'off'
                        val = false;
                end
            end
            this.AngleDragable = val;
            
            if ~this.AngleDragable
                this.ArrowLine.PickableParts = 'none';
                this.RayLine.PickableParts = 'none';
            else
                this.ArrowLine.PickableParts = 'visible';
                this.RayLine.PickableParts = 'visible';
            end
        end
        
        function set.RayLineVisible(this,val)
            assert( isscalar(val)&&(isnumeric(val)||islogical(val))...
                ||ischar(val)&&ismember(lower(val),{'off','on'}),...
                'Invalid data for RayLineVisible');
            
            if ~ischar(val)
                val=logical(val);
            end
            if islogical(val)
                if val
                    this.RayLine.Visible = 'on';
                else
                    this.RayLine.Visible = 'off';
                end
            else
                this.RayLine.Visible = lower(val);
            end
        end
        function set.EndMarkerVisible(this,val)
            assert( isscalar(val)&&(isnumeric(val)||islogical(val))...
                ||ischar(val)&&ismember(lower(val),{'off','on'}),...
                'Invalid data for EndMarkerVisible');
            
            if ~ischar(val)
                val=logical(val);
            end
            if islogical(val)
                if val
                    this.EndMarker.Visible = 'on';
                else
                    this.EndMarker.Visible = 'off';
                end
            else
                this.EndMarker.Visible = lower(val);
            end
        end
        function set.OriginMarkerVisible(this,val)
            assert( isscalar(val)&&(isnumeric(val)||islogical(val))...
                ||ischar(val)&&ismember(lower(val),{'off','on'}),...
                'Invalid data for OriginMarkerVisible');
            
            if ~ischar(val)
                val=logical(val);
            end
            if islogical(val)
                if val
                    this.OriginMarker.Visible = 'on';
                else
                    this.OriginMarker.Visible = 'off';
                end
            else
                this.OriginMarker.Visible = lower(val);
            end
        end
        function set.ArrowLineVisible(this,val)
            assert( isscalar(val)&&(isnumeric(val)||islogical(val))...
                ||ischar(val)&&ismember(lower(val),{'off','on'}),...
                'Invalid data for ArrowLineVisible');
            
            if ~ischar(val)
                val=logical(val);
            end
            if islogical(val)
                if val
                    this.ArrowLine.Visible = 'on';
                else
                    this.ArrowLine.Visible = 'off';
                end
            else
                this.ArrowLine.Visible = lower(val);
            end
        end
        
        function set.LimArcVisible(this,val)
            assert( isscalar(val)&&(isnumeric(val)||islogical(val))...
                ||ischar(val)&&ismember(lower(val),{'off','on'}),...
                'Invalid data for RayLineVisible');
            
            if ~ischar(val)
                val=logical(val);
            end
            if islogical(val)
                if val
                    this.LowerLimArc.Visible = 'on';
                    this.UpperLimArc.Visible = 'on';
                else
                    this.LowerLimArc.Visible = 'off';
                    this.UpperLimArc.Visible = 'off';
                end
            else
                this.LowerLimArc.Visible = val;
                this.UpperLimArc.Visible = val;
            end
        end

        
        function set.RayLineStyle(this,val)
            this.RayLine.LineStyle = val;
        end
        function set.RayLineWidth(this,val)
            this.RayLine.LineWidth = val;
        end
        function set.RayLineColor(this,val)
            this.RayLine.Color = val;
        end
        
        function set.ArrowLineStyle(this,val)
            this.ArrowLine.Style = val;
        end
        
        function set.ArrowLineWidth(this,val)
            this.ArrowLine.LineWidth = val;
        end
        function set.ArrowLineColor(this,val)
            this.ArrowLine.Color = val;
        end
        
        function set.EndMarkerSymbol(this,val)
            this.EndMarker.Marker = val;
        end
        function set.EndMarkerSize(this,val)
            this.EndMarker.MarkerSize = val;
        end
        function set.EndMarkerEdgeColor(this,val)
            if ischar(val) && strcmpi(val,'auto')
                this.EndMarker.MarkerEdgeColor = this.ArrowLine.Color;
            else
                this.EndMarker.MarkerEdgeColor = val;
            end
        end
        function set.EndMarkerFaceColor(this,val)
            if ischar(val) && strcmpi(val,'auto')
                this.EndMarker.MarkerFaceColor = this.ArrowLine.Color;
            else
                this.EndMarker.MarkerFaceColor = val;
            end
        end
        
        function set.OriginMarkerSymbol(this,val)
            this.OriginMarker.Marker = val;
        end
        function set.OriginMarkerSize(this,val)
            this.OriginMarker.MarkerSize = val;
        end
        function set.OriginMarkerEdgeColor(this,val)
            if ischar(val) && strcmpi(val,'auto')
                this.OriginMarker.MarkerEdgeColor = this.ArrowLine.Color;
            else
                this.OriginMarker.MarkerEdgeColor = val;
            end
        end
        function set.OriginMarkerFaceColor(this,val)
            if ischar(val) && strcmpi(val,'auto')
                this.OriginMarker.MarkerFaceColor = this.ArrowLine.Color;
            else
                this.OriginMarker.MarkerFaceColor = val;
            end
        end
        
        
    end
    
    methods %get methods for dependent values
        function val = get.RayLineVisible(this)
            val = this.RayLine.Visible;
        end
        function val = get.EndMarkerVisible(this)
            val = this.EndMarker.Visible;
        end
        function val = get.OriginMarkerVisible(this)
            val=this.OriginMarker.Visible;
        end
        function val = get.ArrowLineVisible(this)
            val = this.ArrowLine.Visible;
        end
        
        function val = get.RayLineStyle(this)
            val = this.RayLine.LineStyle;
        end
        function  val = get.RayLineWidth(this)
            val = this.RayLine.LineWidth;
        end
        function val = get.RayLineColor(this)
            val = this.RayLine.Color;
        end
        
        function val = get.ArrowLineStyle(this)
            val = this.ArrowLine.LineStyle;
        end
        function val = get.ArrowLineWidth(this)
            val = this.ArrowLine.LineWidth;
        end
        function val = get.ArrowLineColor(this)
            val = this.ArrowLine.Color;
        end
        
        function val = get.EndMarkerSymbol(this)
            val = this.EndMarker.Marker;
        end
        function val = get.EndMarkerSize(this)
            val = this.EndMarker.MarkerSize;
        end
        function val = get.EndMarkerEdgeColor(this)
            val = this.EndMarker.MarkerEdgeColor;
        end
        function val = get.EndMarkerFaceColor(this)
            val = this.EndMarker.MarkerFaceColor;
        end
        
        function val = get.OriginMarkerSymbol(this)
            val = this.OriginMarker.Marker;
        end
        function val = get.OriginMarkerSize(this)
            val = this.OriginMarker.MarkerSize;
        end
        function val = get.OriginMarkerEdgeColor(this)
            val = this.OriginMarker.MarkerEdgeColor;
        end
        function val = get.OriginMarkerFaceColor(this)
            val = this.OriginMarker.MarkerFaceColor;
        end
        
        function val = get.LimArcVisible(this)
            val = this.LowerLimArc.Visible;
        end
    end
end


function tf = isUIFigure(hFigList)
  tf = arrayfun(@(x)isstruct(struct(x).ControllerInfo), hFigList);
end

