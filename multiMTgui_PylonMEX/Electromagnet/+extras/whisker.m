classdef whisker < extras.GraphicsChild
    
    properties
        Color
        LineStyle = '-';
        LineWidth = 0.5
        WhiskerStartXY = [NaN,NaN];
        WhiskerEndXY = [NaN,NaN];
        
        CapWidth = 8;
                
    end
    
    properties (SetAccess=protected)
        WhiskerLine = gobjects(0);
        
        CapLine = gobjects(0);
        
        %listeners
        ParentSizeChange
        ParentLocationChange
        ClaReset
        XLimChanged
        YLimChanged
        XScaleChanged
        YScaleChanged
        
        CapLineStyle = '-';
    end
    
    %% Create/Delete
    methods
        function this = whisker(varargin)
            %% Setup parent
            this@extras.GraphicsChild(@() gca());
            varargin = this.CheckParentInput(varargin{:});
            
            if ~ishghandle(this.Parent) || ~strcmpi(this.Parent.Type,'axes')
                error('Parent must be a valid axes');
            end
            
            %% Create Whisker and Cap lines
            this.WhiskerLine = line(...
                'Parent',this.Parent,...
                'LineWidth',this.LineWidth,...
                'LineStyle',this.LineStyle,...
                'Marker','none',...
                'HandleVisibility','off',...
                'XData',NaN,'YData',NaN);
            this.Color = this.WhiskerLine.Color;
            
            this.CapLine = line(...
                'Parent',this.Parent,...
                'LineWidth',this.LineWidth,...
                'LineStyle',this.CapLineStyle,...
                'Marker','none',...
                'HandleVisibility','off',...
                'Color',this.Color,...
                'XData',NaN,'YData',NaN);
            
            %% add Listener for axes resize
            
            this.ParentSizeChange = addlistener(this.Parent,'SizeChanged',@(~,~) this.RedrawLines());
            this.ParentLocationChange = addlistener(this.Parent,'LocationChanged',@(~,~) this.RedrawLines());
        
            this.ClaReset = addlistener(this.Parent,'ClaReset',@(~,~) delete(this));
            
            this.XLimChanged = addlistener(this.Parent,'XLim','PostSet',@(~,~) this.RedrawLines());
            this.YLimChanged = addlistener(this.Parent,'YLim','PostSet',@(~,~) this.RedrawLines());

            this.XScaleChanged = addlistener(this.Parent,'XScale','PostSet',@(~,~) this.RedrawLines());
            this.YScaleChanged = addlistener(this.Parent,'YScale','PostSet',@(~,~) this.RedrawLines());
            
            %% Set remaining properties
            set(this,varargin{:});
        end
        
        function delete(this)
            delete(this.WhiskerLine);
            delete(this.CapLine);
            
            %listeners
            delete(this.ParentSizeChange);
            delete(this.ParentLocationChange);
            delete(this.ClaReset);
            delete(this.XLimChanged);
            delete(this.YLimChanged);
            delete(this.XScaleChanged);
            delete(this.YScaleChanged);
        
        end
    end
    
    %% Set Methods
    methods
        function set.Color(this,val)
            %% validate color
            if isnumeric(val)
                assert(numel(val)==3,'If numeric, color must have numel(Color)==3');
                assert(all(val<=1 & val>=0),'Color RGB triples must be 0<=Color<=1');
                
                this.Color = reshape(val,1,[]);
                
            elseif ischar(val)
                switch(lower(val))
                    case {  'y','yellow',...
                            'm','magenta',...
                            'c','cyan',...
                            'r','red',...
                            'g','green',...
                            'b','blue',...
                            'w','white',...
                            'k','black'}
                        this.Color = lower(val);
                    otherwise
                        error('Invalid colorspec');
                end
            else
                error('Color must be numeric RGB triplet or valid colorspec char array');
            end
            
            try
                set(this.WhiskerLine,'Color',this.Color);
                set(this.CapLine,'Color',this.Color);
            catch
            end
        end
        
        function set.LineStyle(this,val)
            set(this.WhiskerLine,'LineStyle',val);  
            this.LineStyle = val;
        end
        
        function set.LineWidth(this,val)
            set(this.WhiskerLine,'LineWidth',val);
            set(this.CapLine,'LineWidth',val);
            
            this.LineWidth = val;
        end
        
        function set.WhiskerStartXY(this,val)
            assert(numel(val)==2,'WhiskerStartXY must contain 2 elements: [x0,y0]');
            this.WhiskerStartXY = val;
            
            this.RedrawLines();
        end
        
        function set.WhiskerEndXY(this,val)
            assert(numel(val)==2,'WhiskerStartXY must contain 2 elements: [x0,y0]');
            this.WhiskerEndXY = val;
            
            this.RedrawLines();
        end
    end
    
    %% Internal Functions
    methods (Hidden)
        function RedrawLines(this)
            
            %% whiskerLine
            this.WhiskerLine.XData = [this.WhiskerStartXY(1),this.WhiskerEndXY(1)];
            this.WhiskerLine.YData = [this.WhiskerStartXY(2),this.WhiskerEndXY(2)];
            
            %% Cap Line
            
            [wx,wy] = coord2points(this.Parent,...
                this.WhiskerLine.XData,...
                this.WhiskerLine.YData);
            
            a = atan(-diff(wx)/diff(wy));
            cxp = cos(a)*20*[-1/2,1/2]+wx(2);
            cyp = sin(a)*20*[-1/2,1/2]+wy(2);
            
            [cx,cy] = points2coords(this.Parent,cxp,cyp);
            
            this.CapLine.XData = cx;
            this.CapLine.YData = cy;
            
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