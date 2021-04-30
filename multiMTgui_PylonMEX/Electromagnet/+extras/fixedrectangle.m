classdef fixedrectangle < extras.GraphicsChild
    properties (SetObservable=true,AbortSet=true)
        FixedDirection = 'x'
        Width = 8;
        Edges = [NaN;NaN]
        FixedCenter = NaN;
    end
    
    properties (SetAccess=protected)
        Rectangle
        
        %listeners
        ParentSizeChange
        ParentLocationChange
        ClaReset
        XLimChanged
        YLimChanged
        XScaleChanged
        YScaleChanged
        %ChildAdded
    end
    
    properties (Dependent)
        EdgeColor
        FaceColor
        LineStyle
        LineWidth
    end
    
    %% Create/Delete
    methods
        function this = fixedrectangle(varargin)
            %% Setup parent
            this@extras.GraphicsChild(@() gca());
            varargin = this.CheckParentInput(varargin{:});
            
            if ~ishghandle(this.Parent) || ~strcmpi(this.Parent.Type,'axes')
                error('Parent must be a valid axes');
            end
            
            %% Create Rectangle Object
            this.Rectangle = rectangle('Parent',this.Parent,...
                'Position',[0,1,0,1],...
                'HandleVisibility','callback',...
                'Visible','off');
            %% add Listener for axes resize
            
            this.ParentSizeChange = addlistener(this.Parent,'SizeChanged',@(~,~) this.Redraw());
            this.ParentLocationChange = addlistener(this.Parent,'LocationChanged',@(~,~) this.Redraw());
        
            this.ClaReset = addlistener(this.Parent,'ClaReset',@(~,~) delete(this));
            
            this.XLimChanged = addlistener(this.Parent,'XLim','PostSet',@(~,~) this.Redraw());
            this.YLimChanged = addlistener(this.Parent,'YLim','PostSet',@(~,~) this.Redraw());

            this.XScaleChanged = addlistener(this.Parent,'XScale','PostSet',@(~,~) this.Redraw());
            this.YScaleChanged = addlistener(this.Parent,'YScale','PostSet',@(~,~) this.Redraw());
            
            
            %this.ChildAdded = addlistener(this.Parent,'ChildAdded',@(~,~) this.Redraw());
            %% Set values
            set(this,varargin{:});
            
            this.Redraw();
            
        end
        
        function delete(this)
            
            %listeners
            delete(this.ParentSizeChange);
            delete(this.ParentLocationChange);
            delete(this.ClaReset);
            delete(this.XLimChanged);
            delete(this.YLimChanged);
            delete(this.XScaleChanged);
            delete(this.YScaleChanged);
            %delete(this.ChildAdded);
            
            delete(this.Rectangle);
            
        end
    end
    
    %% set methods
    methods
        function set.FixedDirection(this,val)
            assert(ischar(val),'FixedDirection must be a valid char array');
            
            val = lower(val);
            if val(1)=='x'
                this.FixedDirection = 'x';
            elseif val(1)=='y'
                this.FixedDirection = 'y';
            else
                error('FixedDirection must be a valid char array: ''x'' or ''y''');
            end
            
            this.Redraw();
        end
        
        function set.Width(this,val)
            assert(isscalar(val)&&isnumeric(val) && val>=0,'Width must be scalar numeric')
            
            this.Width = val;
            this.Redraw();
        end
        
        function set.Edges(this,val)
            assert(numel(val)==2 && isnumeric(val),'Edges must be 2x1 or 1x2 numeric');
            
            this.Edges = reshape(val,2,1);
            this.Redraw();
        end
        
        function set.FixedCenter(this,val)
            assert(isscalar(val)&&isnumeric(val),'FixedCenter must be numeric scalar');
            
            this.FixedCenter = val;
            this.Redraw();
        end
        
    end
    
    %% dependent
    methods
        function set.EdgeColor(this,val)
            this.Rectangle.EdgeColor = val;
        end
        function val = get.EdgeColor(this)
            val = this.Rectangle.EdgeColor;
        end
            
        function set.FaceColor(this,val)
            this.Rectangle.FaceColor = val;
        end
        function val = get.FaceColor(this)
            val = this.Rectangle.FaceColor;
        end 
        
        function set.LineStyle(this,val)
            this.Rectangle.LineStyle = val;
        end
        function val = get.LineStyle(this)
            val = this.Rectangle.LineStyle;
        end
        
        function set.LineWidth(this,val)
            this.Rectangle.LineWidth = val;
        end
        function val = get.LineWidth(this)
            val = this.Rectangle.LineWidth;
        end
        
    end
    
    %% callbacks
    methods(Hidden)
        function Redraw(this)
            
            if any(isnan(this.Edges))||isnan(this.FixedCenter)
                this.Rectangle.Visible = 'off';
                return;
            else
                this.Rectangle.Visible = 'on';
            end
            
            
            if this.FixedDirection == 'x'
                [px,py] = coord2points(this.Parent,...
                    [this.FixedCenter;this.FixedCenter],...
                    this.Edges);
                
                [cx,cy] = points2coords(this.Parent,...
                    px+this.Width*[-1/2;1/2],py);
                
            else %'y'
                [px,py] = coord2points(this.Parent,...
                    this.Edges,...
                    [this.FixedCenter;this.FixedCenter]);
                [cx,cy] = points2coords(this.Parent,...
                    px,py+this.Width*[-1/2;1/2]);
            end
            cx = sort(cx);
            cy = sort(cy);
            this.Rectangle.Position = [cx(1),cy(1),cx(2)-cx(1),cy(2)-cy(1)];
            
        end
    end
end

function [xf,yf] = coord2points(ax,x,y)
% convert coordinate in axes to points in figure image
orig_units = ax.Units;
ax.Units = 'points';
ax_pos = plotboxpos(ax); %pos of axis plot area in points [x0,y0,w,h]
ax.Units = orig_units;

XL = ax.XLim;
YL = ax.YLim;

if strcmp(ax.XScale,'linear')
    xf = (x-XL(1))/(XL(2)-XL(1))*ax_pos(3) + ax_pos(1);
else %log scale
    xf = (log10(x)-log10(XL(1)))/(log10(XL(2))-log10(XL(1)))*ax_pos(3) + ax_pos(1);
end

if strcmp(ax.YScale,'linear')
    yf = (y-YL(1))/(YL(2)-YL(1))*ax_pos(4) + ax_pos(2);
else %log scale
    yf = (log10(y)-log10(YL(1)))/(log10(YL(2))-log10(YL(1)))*ax_pos(4) + ax_pos(2);
end

end

function [xa,ya] = points2coords(ax,x,y)
% convert coordinate in axes to points in figure image
orig_units = ax.Units;
ax.Units = 'points';
pos = plotboxpos(ax); %pos of axis plot area in points [x0,y0,w,h]
ax.Units = orig_units;

XL = ax.XLim;
YL = ax.YLim;

if strcmp(ax.XScale,'linear')
    xa = (x-pos(1))/pos(3)*(XL(2)-XL(1))+XL(1);
else %log scale
    xa = XL(1)*10^( (x-pos(1))/pos(3)*log10(XL(2)/XL(1)) );
end

if strcmp(ax.YScale,'linear')
    ya = (y-pos(2))/pos(4)*(YL(2)-YL(1))+YL(1);
else %log scale
    ya = YL(1)*10^( (y-pos(2))/pos(4)*log10(YL(2)/YL(1)) );
end


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