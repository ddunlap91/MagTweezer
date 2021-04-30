classdef boxplot2 < extras.GraphicsChild
    
    properties (SetObservable=true,AbortSet=true)
        OrdinateAxis = 'yaxis';
        
        Size = 8;
        
        WhiskerLineStyle = '-';
        BoxLineStyle = '-';
        BoxLineWidth = 0.5;
        WhiskerLineWidth = 0.5;
        WhiskerColor;
        BoxEdgeColor;
        BoxFaceColor = 'none';
        
        MidLineColor = 'r';
        MidLineWidth = 0.5;
        
        
        
        BoxQR = [0.25,0.75];
        WhiskerLength = 1.5;
        
    end
    
    properties 
        GroupData;
        GroupValues;
    end
    
    properties (Access=protected)
        LowWhiskers = extras.whisker.empty;
        UpWhiskers = extras.whisker.empty;
        Rectangles = extras.fixedrectangle.empty;
        
        MidLines = gobjects(0);
        
        Data_I = {};
        GroupsCoord_I = [];
    end
    
    %% create/delete
    methods
        function this = boxplot2(varargin)
            %% Setup parent
            this@extras.GraphicsChild(@() gca());
            varargin = this.CheckParentInput(varargin{:});
            
            if ~ishghandle(this.Parent) || ~strcmpi(this.Parent.Type,'axes')
                error('Parent must be a valid axes');
            end
                        
            %temporarily create line to get next color, then delete
            hl = line(this.Parent,NaN,NaN);
            this.WhiskerColor = hl.Color;
            this.BoxEdgeColor = hl.Color;
            delete(hl);
            
            %% Look for data and group
            if numel(varargin)>0
                if iscell(varargin{1})
                    this.GroupData = varargin{1};
                    assert(numel(varargin)>1 && isnumeric(varargin{2}),'Found Group Data, next input must be GroupValues');
                    this.GroupValues = varargin{2};
                end
                varargin(1:2) = [];
            end
            
            %% set other parameters
            set(this,varargin{:});
            
            this.Redraw();
        end
        
        function delete(this)
            
            delete(this.LowWhiskers);
            delete(this.UpWhiskers);
            delete(this.Rectangles);
            delete(this.MidLines);
        end
    end
    
    %% Internal Use
    methods (Access=protected)
        function r = createRect(this,center,edges)
            
            if strcmpi(this.OrdinateAxis,'yaxis')
                fdir = 'x';
            else
                fdir = 'y';
            end
            r = extras.fixedrectangle(this.Parent,...
                'FixedDirection',fdir,...
                'Width',this.Size,...
                'Edges',edges,...
                'FixedCenter',center,...
                'LineStyle',this.BoxLineStyle,...
                'EdgeColor',this.BoxEdgeColor,...
                'FaceColor',this.BoxFaceColor,...
                'LineWidth',this.BoxLineWidth);
        end
        
        function w = createWhisk(this,center,startVal,endVal) 
            if strcmpi(this.OrdinateAxis,'yaxis')
                w = extras.whisker(this.Parent,...
                    'CapWidth',this.Size,...
                    'WhiskerStartXY',[center,startVal],...
                    'WhiskerEndXY',[center,endVal],...
                    'LineStyle',this.WhiskerLineStyle,...
                    'Color',this.WhiskerColor,...
                    'LineWidth',this.WhiskerLineWidth);
            else
                w = extras.whisker(this.Parent,...
                    'CapWidth',this.Size,...
                    'WhiskerStartXY',[startVal,center],...
                    'WhiskerEndXY',[endVal,center],...
                    'LineStyle',this.WhiskerLineStyle,...
                    'Color',this.WhiskerColor,...
                    'LineWidth',this.WhiskerLineWidth);
              
            end
            
        end
        
        function l = createMidLine(this,center,midval)
            if strcmpi(this.OrdinateAxis,'yaxis')
                [px,py] = coord2points(this.Parent,center,midval);
                [cx,cy] = points2coords(this.Parent,px+this.Size*[-1/2,1/2],[py,py]);
            else %x orineted
                [px,py] = coord2points(this.Parent,center,midval);
                [cx,cy] = points2coords(this.Parent,[px,px],py+this.Size*[-1/2,1/2]);
            end
            l = line(this.Parent,...
                'XData',cx,'YData',cy,...
                'LineStyle','-',...
                'Marker','none',...
                'Color',this.MidLineColor,...
                'LineWidth',this.MidLineWidth);
            
        end
    end
    
    %% Callbacks
    methods (Hidden)
        function Redraw(this)
            
            %% chaeck valid and sizes
            if ~isvalid(this)
                return;
            end
            
            if isempty(this.GroupsCoord_I)
                delete(this.LowWhiskers);
                this.LowWhiskers = extras.whisker.empty;
                
                delete(this.UpWhiskers);
                this.UpWhiskers = extras.whisker.empty;
                
                delete(this.Rectangles);
                this.Rectangles = extras.fixedrectangle.empty;
                
                delete(this.MidLines);
                this.MidLines = gobjects(0);
            end
            
            %% resize whiskers and rectangles arrays
            if numel(this.GroupsCoord_I) < numel(this.LowWhiskers)
                delete( this.LowWhiskers(numel(this.GroupsCoord_I) ) );
                this.LowWhiskers(numel(this.GroupsCoord_I) ) = [];
                
            end
            
            if numel(this.GroupsCoord_I) < numel(this.UpWhiskers)
                delete( this.UpWhiskers(numel(this.GroupsCoord_I) ) );
                this.UpWhiskers(numel(this.GroupsCoord_I) ) = [];
                
            end
            
            if numel(this.GroupsCoord_I) < numel(this.Rectangles)
                delete(this.Rectangles(numel(this.GroupsCoord_I)+1:end));
                this.Rectangles(numel(this.GroupsCoord_I)+1:end) = [];
            end
            
            if numel(this.GroupsCoord_I) < numel(this.MidLines)
                delete(this.MidLines(numel(this.GroupsCoord_I)+1:end));
                this.MidLines(numel(this.GroupsCoord_I)+1:end) = [];
            end
            
            %% Update draw
            for n=1:numel(this.GroupsCoord_I)                
                qr = quantile(this.Data_I{n},this.BoxQR);
                
                qx = quantile(this.Data_I{n},[0.25,0.75]);
                
                wl = max(min(this.Data_I{n}),qx(1)-this.WhiskerLength*(qx(2)-qx(1)));
                wu = min(max(this.Data_I{n}),qx(2)+this.WhiskerLength*(qx(2)-qx(1)));
                
                %% draw rectangle
                if numel(this.Rectangles)<n || ~isvalid(this.Rectangles(n))
                    this.Rectangles(n) = this.createRect(this.GroupsCoord_I(n),qr);
                else
                    
                    set(this.Rectangles(n),'FixedCenter',this.GroupsCoord_I(n),'Edges',qr);
                    if strcmpi(this.OrdinateAxis,'yaxis')
                        this.Rectangles(n).FixedDirection = 'x';
                    else
                        this.Rectangles(n).FixedDirection = 'y';
                    end
                end
                
                %% Lower Whiskers
                if numel(this.LowWhiskers)<n || ~isvalid(this.LowWhiskers(n))
                    this.LowWhiskers(n) = this.createWhisk(this.GroupsCoord_I(n),qr(1),wl);
                else
                   if strcmpi(this.OrdinateAxis,'yaxis')
                        %lower
                        set(this.LowWhiskers(n),...
                            'WhiskerStartXY',[this.GroupsCoord_I(n),qr(1)],...
                            'WhiskerEndXY',[this.GroupsCoord_I(n),wl]);
                   else
                       set(this.LowWhiskers(n),...
                            'WhiskerStartXY',[qr(1),this.GroupsCoord_I(n)],...
                            'WhiskerEndXY',[wl,this.GroupsCoord_I(n)]);
                   end
                end
                
                %% Upper whiskers
                if numel(this.UpWhiskers)<n || ~isvalid(this.UpWhiskers(n))
                    this.UpWhiskers(n) = this.createWhisk(this.GroupsCoord_I(n),qr(2),wu);
                else
                    if strcmpi(this.OrdinateAxis,'yaxis')
                        %lower
                        set(this.UpWhiskers(n),...
                            'WhiskerStartXY',[this.GroupsCoord_I(n),qr(2)],...
                            'WhiskerEndXY',[this.GroupsCoord_I(n),wu]);
                   else
                       set(this.UpWhiskers(n),...
                            'WhiskerStartXY',[qr(2),this.GroupsCoord_I(n)],...
                            'WhiskerEndXY',[wu,this.GroupsCoord_I(n)]);
                   end
                end
                
                %% MidLines
                md = median(this.Data_I{n});
                if numel(this.MidLines)<n || ~isvalid(this.MidLines(n))
                    this.MidLines(n) = this.createMidLine(this.GroupsCoord_I(n),md);
                else
                    center = this.GroupsCoord_I(n);
                    if strcmpi(this.OrdinateAxis,'yaxis')
                        [px,py] = coord2points(this.Parent,center,md);
                        [cx,cy] = points2coords(this.Parent,px+this.Size*[-1/2,1/2],[py,py]);
                    else %x orineted
                        [px,py] = coord2points(this.Parent,center,md);
                        [cx,cy] = points2coords(this.Parent,[px,px],py+this.Size*[-1/2,1/2]);
                    end
                    set(this.MidLines(n),...
                        'XData',cx,'YData',cy);
                end

            end
            
            
        end
    end
    
    %% Set methods
    methods
        function set.GroupData(this,val)
            if ~iscell(val)
                error('Data should be a cell array, where each cell contains the data elements for each boxplot group');
            end
            
            for n=1:numel(val)
                if ~isnumeric(val{n})
                    error('Elements of Data cell array should be numeric arrays')
                end
            end
            
            this.GroupData = val;
            
            if numel(this.GroupData) == numel(this.GroupValues)
                this.Data_I = this.GroupData;
                this.GroupsCoord_I = this.GroupValues;
                
                this.Redraw();
            end
        end
        
        function set.GroupValues(this,val)
            if ~isnumeric(val)
                error('GroupValues must be a numeric array the same size as GroupData')
            end
            
            this.GroupValues = val;
            
            if numel(this.GroupData) == numel(this.GroupValues)
                this.Data_I = this.GroupData;
                this.GroupsCoord_I = this.GroupValues;
                
                this.Redraw();
            end
        end
        
        
        function set.Size(this,val)
            assert(isscalar(val)&&isnumeric(val)&&val>0,'Size must be scalar numeric specifying box dimension in points');
            
            this.Size = val;
            
            for n=1:numel(this.Rectangles)
                if isvalid(this.Rectangles(n))
                    this.Rectangles(n).Width = this.Size;
                end
            end
            
            for n=1:numel(this.LowWhiskers)
                if isvalid(this.LowWhiskers(n))
                    this.LowWhiskers(n).CapWidth = this.Size;
                end
            end
            
            for n=1:numel(this.UpWhiskers)
                if isvalid(this.UpWhiskers(n))
                    this.UpWhiskers(n).CapWidth = this.Size;
                end
            end
            
            this.Redraw();
        end
        
        function set.WhiskerLineStyle(this,val)
            
            for n=1:numel(this.LowWhiskers)
                if isvalid(this.LowWhiskers(n))
                    this.LowWhiskers(n).LineStyle = val;
                end
            end
            for n=1:numel(this.UpWhiskers)
                if isvalid(this.UpWhiskers(n))
                    this.UpWhiskers(n).LineStyle = val;
                end
            end
            
            this.WhiskerLineStyle = val;
        end
        
        
        function set.BoxLineStyle(this,val)
            for n=1:numel(this.Rectangles)
                if isvalid(this.Rectangles(n))
                    this.Rectangles(n).LineStyle = val;
                end
            end
            
            this.BoxLineStyle = val;
        end
        
        function set.BoxLineWidth(this,val)
            for n=1:numel(this.Rectangles)
                if isvalid(this.Rectangles(n))
                    this.Rectangles(n).LineWidth = val;
                end
            end
            
            this.BoxLineWidth = val;
        end
        
        function set.WhiskerLineWidth(this,val)
            for n=1:numel(this.LowWhiskers)
                if isvalid(this.LowWhiskers(n))
                    this.LowWhiskers(n).LineWidth = val;
                end
            end
            for n=1:numel(this.UpWhiskers)
                if isvalid(this.UpWhiskers(n))
                    this.UpWhiskers(n).LineWidth = val;
                end
            end
            
            this.WhiskerLineWidth = val;
        end
        
        function set.WhiskerColor(this,val)
            for n=1:numel(this.LowWhiskers)
                if isvalid(this.LowWhiskers(n))
                    this.LowWhiskers(n).Color = val;
                end
            end
            for n=1:numel(this.UpWhiskers)
                if isvalid(this.UpWhiskers(n))
                    this.LowWhiskers(n).Color = val;
                end
            end
            
            this.WhiskerColor = val;
        end
        
        function set.BoxEdgeColor(this,val)
            for n=1:numel(this.Rectangles)
                if isvalid(this.Rectangles(n))
                    this.Rectangles(n).EdgeColor = val;
                end
            end
            
            this.BoxEdgeColor = val;
        end
        
        function set.BoxFaceColor(this,val)
            for n=1:numel(this.Rectangles)
                if isvalid(this.Rectangles(n))
                    this.Rectangles(n).FaceColor = val;
                end
            end
            
            this.BoxFaceColor = val;
        end
        
        function set.BoxQR(this,val)
            assert(isnumeric(val)&&numel(val)==2,'BoxQR must be 2 element numeric')
            
            this.BoxQR = val;
            this.Redraw();
        end
        
        function set.WhiskerLength(this,val)
            assert(isnumeic(val)&&isscalar(val),'WhiskerLength must be numeric scalar');
            
            this.WhiskerLength = val;
            this.Redraw();
        end
        
        function set.MidLineColor(this,val)
            for n=1:numel(this.MidLines)
                if isvalid(this.MidLines(n))
                    this.MidLines(n).Color = val;
                end
            end
            
            this.MidLineColor = val;
        end
        
        function set.MidLineWidth(this,val)
            for n=1:numel(this.MidLines)
                if isvalid(this.MidLines(n))
                    this.MidLines(n).LineWidth = val;
                end
            end
            
            this.MidLineWidth = val;
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