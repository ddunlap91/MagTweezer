function hrect = imrect2(varargin)
%Create Dynamic rectangle on image (similar to imrect() included with
%image processing toolbox but built with the standard rectangle object)
% Input:
%   'Parent',hax - handle to parent axes (default = gca)
%   'Position',[x,y,w,h] - position of rectangle in axes units
%                          if not specified rbbox is called for user to
%                          select one graphically
%   'Color',ColorSpec - Color of rectangle edge and corner markers
%   'LineWidth',w - rectangle line width (default=0.5)
%   'LineStyle,LineSpec - rectangle line style
%   'MarkerSize',w - size of corner markers (default = 12*LineWidth)
%   'ResizeFcn',fcn or 'fcn' or {fcn,arg1...} - Function to call when
%               rectangle size is changed
%               The first argument of fcn will be hrect (the handle to the
%               rectange) use get(hrect,'position') to get position after
%               resize.
%   'LimMode','auto' or 'manual' - if 'manual' axis lims are fixed at
%               limits before imrect2 was called.
%   'HandleVisibility','on'(default)|'off'|'callback'
%               Visibility of object handle (see Rectangle properties)
%               This is useful if you want to have the rectangle persist
%               after something like plot(...) is called.
%               If the parent axes is set to 'NextPlot'='replacechildren'
%               then setting 'handlevisibility'='callback' will prevent
%               plot(...) from deleting the rectangle even if hold on is
%               not set.
%   'LockPosition',true|false(default) - specify if the position is locked
%               after the rectangle has been created. prevent user from
%               modifying position. 
%               LockPosition can be change after the rectangle is created
%               by changing the userdata.
%                   Example:
%                       ud = get(hrect,'userdata'); %get userdata
%                       ud.LockPosition = true; %change value
%                       set(hrect,'userdata',ud); %save userdata
% Output:
%   hrect - handle to the rectangle
%       Note: the hrect will contain userdata with the following elements
%           userdata.hPt_BL - handle to bottom left marker
%           userdata.hPt_BR - handle to bottom right marker
%           userdata.hPt_TL - handle to top left marker
%           userdata.hPt_TR - handle to top right marker
%           userdata.ResizeFcn - the resize function set above
%           userdata.LockPosition - (true/false) flag specifying if 
%                                   rectangle location is locked 
%        Also be aware that the ButtonDownFcn has been set for hrect and
%        the corner points (hPt...)
%==========================================================================
% Copyright 2015, Daniel Kovari. All rights reserved.

hrect = [];
%input parser
p = inputParser;
p.CaseSensitive = false;
addParameter(p,'Parent',[]);
addParameter(p,'Position',[]);
addParameter(p,'Color','k');
addParameter(p,'HandleVisibility','on', @(x) any(strcmpi(x,{'on','off','callback'})));
addParameter(p,'LineWidth',0.5);
addParameter(p,'LineStyle','-');
addParameter(p,'MarkerSize',[]);
addParameter(p,'ResizeFcn',[],@verify_fcn);
addParameter(p,'LimMode','auto',@(x) any(strcmpi(x,{'auto','manual'})));
addParameter(p,'LockPosition',false, @islogical);
parse(p,varargin{:});

hparent = p.Results.Parent;
position = p.Results.Position;
if ~isempty(hparent)
    if ~ishandle(hparent)||~strcmpi(get(hparent,'type'),'axes')
        error('hparent was not a valid axes handle');
    end
else
    hparent = gca;
end
if ~isempty(position)
    if ~isnumeric(position)||numel(position)~=4
        error('position must be [x,y,w,h]');
    end
end

hfig = get(hparent,'parent');

if isempty(position)
    axes(hparent);
    ptr = get(hfig,'pointer');
    set(hfig,'pointer','crosshair');
    switch(waitforbuttonpress)
        case 0 %user clicked the mouse
            r = rbbox;
            set(hfig,'pointer',ptr);
        case 1 %user pressed a key return without creating box
            set(hfig,'pointer',ptr);
            return;
    end
    %[x,y] = fig2axescoord([r(1);r(1)+r(3)],[r(2);r(2)+r(4)],hparent);
    %position = [x(1),y(1),x(2)-x(1),y(2)-y(1)];
    position = fig2axpos(r,hparent);
end


if strcmpi(p.Results.LimMode,'manual')
    xl = get(hparent,'xlim');
    yl = get(hparent,'ylim');
end
hrect = rectangle('parent',hparent,...
    'position',position,...
    'HandleVisibility',p.Results.HandleVisibility,...
    'LineWidth',p.Results.LineWidth,...
    'LineStyle',p.Results.LineStyle,...
    'EdgeColor',p.Results.Color);
if strcmpi(p.Results.LimMode,'manual')
    set(hparent,'xlim',xl);
    set(hparent,'ylim',yl);
end

MarkerSize = p.Results.MarkerSize;
if isempty(MarkerSize)
    MarkerSize = 12*p.Results.LineWidth;
end

%setup resize handle points on corners
userdata.hPt_BL = line(position(1),position(2),0,...
    'parent',hparent,...
    'HandleVisibility',p.Results.HandleVisibility,...
    'marker','s',...
    'MarkerSize',MarkerSize,...
    'MarkerEdgeColor','none',...
    'MarkerFaceColor',p.Results.Color,...
    'ButtonDownFcn',{@BL_click,hrect});
userdata.hPt_BR = line(position(1)+position(3),position(2),0,...
    'parent',hparent,...
    'HandleVisibility',p.Results.HandleVisibility,...
    'marker','s',...
    'MarkerSize',MarkerSize,...
    'MarkerEdgeColor','none',...
    'MarkerFaceColor',p.Results.Color,...
    'ButtonDownFcn',{@BR_click,hrect});
userdata.hPt_TL = line(position(1),position(2)+position(4),0,...
    'parent',hparent,...
    'HandleVisibility',p.Results.HandleVisibility,...
    'marker','s',...
    'MarkerSize',MarkerSize,...
    'MarkerEdgeColor','none',...
    'MarkerFaceColor',p.Results.Color,...
    'ButtonDownFcn',{@TL_click,hrect});
userdata.hPt_TR = line(position(1)+position(3),position(2)+position(4),0,...
    'parent',hparent,...
    'HandleVisibility',p.Results.HandleVisibility,...
    'marker','s',...
    'MarkerSize',MarkerSize,...
    'MarkerEdgeColor','none',...
    'MarkerFaceColor',p.Results.Color,...
    'ButtonDownFcn',{@TR_click,hrect});

userdata.ResizeFcn = p.Results.ResizeFcn;
userdata.LockPosition = p.Results.LockPosition;

userdata.PosListener = addlistener(hrect,'Position','PostSet',@ResizeListener);
set(hrect,'userdata',userdata);
set(hrect,'ButtonDownFcn',@drag_rect);
set(hrect,'DeleteFcn',@delete_rect);


function ResizeListener(~,evt)
hrect = evt.AffectedObject;
userdata = get(hrect,'userdata');
position = get(hrect,'Position');
set(userdata.hPt_BL,'xdata',position(1),'ydata',position(2));
set(userdata.hPt_BR,'xdata',position(1)+position(3),'ydata',position(2));
set(userdata.hPt_TL,'xdata',position(1),'ydata',position(2)+position(4));
set(userdata.hPt_TR,'xdata',position(1)+position(3),'ydata',position(2)+position(4));

function drag_rect(hrect,~)
ud = get(hrect,'userdata');
if ud.LockPosition %check if lock position
    return;
end
%ud.PosListener.Enabled = false;
hax = get(hrect,'parent');
p = get(hrect,'position');
%dragrect doesn't work with normalized units
orig_units = get(get(hax,'parent'),'units');
if strcmpi(orig_units,'normalized');
    set(get(hax,'parent'),'units','pixels');
end
%drag rectangle
r = dragrect(ax2figpos(p,hax));
p = fig2axpos(r); %get position value in axes units
%return figure units to whatever they were
set(get(hax,'parent'),'units',orig_units);

%set positions
set(hrect,'position',p);
%corner points --done by listener
% set(ud.hPt_BL,'xdata',p(1),'ydata',p(2));
% set(ud.hPt_BR,'xdata',p(1)+p(3),'ydata',p(2));
% set(ud.hPt_TL,'xdata',p(1),'ydata',p(2)+p(4));
% set(ud.hPt_TR,'xdata',p(1)+p(3),'ydata',p(2)+p(4));
% ud.PosListener.Enabled = true;
ExecResizeFcn(hrect);


function [x,y] = fig2axescoord(x,y,hax)
if nargin<3
    hax = gca;
end
par_units = get(get(hax,'parent'),'units');
orig_units = get(hax,'units');
set(hax,'units',par_units);
pos = plotboxpos(hax);
xl = get(hax,'xlim');
yl = get(hax,'ylim');
if(strcmpi(get(hax,'xdir'),'normal'))
    x = (x-pos(1))/pos(3)*(xl(2)-xl(1))+xl(1);
else
    x = xl(2) - (x-pos(1))/pos(3)*(xl(2)-xl(1));
end
if(strcmpi(get(hax,'ydir'),'normal'))
    y = (y-pos(2))/pos(4)*(yl(2)-yl(1))+yl(1);
else
    y = yl(2) - (y-pos(2))/pos(4)*(yl(2)-yl(1));
end
set(hax,'units',orig_units);

function [x,y] = axes2figcoord(x,y,hax)
if nargin<3
    hax = gca;
end
par_units = get(get(hax,'parent'),'units');
orig_units = get(hax,'units');
set(hax,'units',par_units);
pos = plotboxpos(hax); %position of axes in figure?
xl = get(hax,'xlim');
yl = get(hax,'ylim');
if(strcmpi(get(hax,'xdir'),'normal'))
    x = (x-xl(1))/(xl(2)-xl(1))*pos(3)+pos(1);
else
    x = (xl(2)-x)/(xl(2)-xl(1))*pos(3)+pos(1);
end
if(strcmpi(get(hax,'ydir'),'normal'))
    y = (y-yl(1))/(yl(2)-yl(1))*pos(4)+pos(2);
else
    y = (yl(2)-y)/(yl(2)-yl(1))*pos(4)+pos(2);
end
set(hax,'units',orig_units);

function p = ax2figpos(p,hax)
if nargin<2
    hax = gca;
end
[x,y] = axes2figcoord([p(1),p(1)+p(3)],[p(2),p(2)+p(4)],hax);

if(strcmpi(get(hax,'xdir'),'normal'))
    p(1) = x(1);
    p(3) = x(2)-x(1);
else
    p(1) = x(2);
    p(3) = x(1) - x(2);
end
if(strcmpi(get(hax,'ydir'),'normal'))
    p(2) = y(1);
    p(4) = y(2)-y(1);
else
    p(2) = y(2);
    p(4) = y(1) - y(2);
end

function p = fig2axpos(p,hax)
if nargin<2
    hax = gca;
end
[x,y] = fig2axescoord([p(1);p(1)+p(3)],[p(2);p(2)+p(4)],hax);
if(strcmpi(get(hax,'xdir'),'normal'))
    p(1) = x(1);
    p(3) = x(2)-x(1);
else
    p(1) = x(2);
    p(3) = x(1) - x(2);
end
if(strcmpi(get(hax,'ydir'),'normal'))
    p(2) = y(1);
    p(4) = y(2)-y(1);
else
    p(2) = y(2);
    p(4) = y(1) - y(2);
end

function BL_click(~,~,hrect)
ud = get(hrect,'userdata');
if ud.LockPosition %check if lock position
    return;
end
%ud.PosListener.Enabled = false;
hax = get(hrect,'parent');
p = get(hrect,'position');
r = ax2figpos(p,hax);
xnorm = strcmpi(get(hax,'xdir'),'normal');
ynorm = strcmpi(get(hax,'ydir'),'normal');

if xnorm&&ynorm
    r = rbbox(r,[r(1)+r(3),r(2)+r(4)]); %BL clicked
elseif ~xnorm&&ynorm
    r = rbbox(r,[r(1),r(2)+r(4)]); %BR clicked
elseif xnorm&&~ynorm
    r = rbbox(r,[r(1)+r(3),r(2)]);%TL clicked
elseif ~xnorm&&~ynorm
    r = rbbox(r,[r(1),r(2)]);%TR clicked
end

p = fig2axpos(r,hax);

%set positions
set(hrect,'position',p);
%corner points
% set(ud.hPt_BL,'xdata',p(1),'ydata',p(2));
% set(ud.hPt_BR,'xdata',p(1)+p(3),'ydata',p(2));
% set(ud.hPt_TL,'xdata',p(1),'ydata',p(2)+p(4));
% set(ud.hPt_TR,'xdata',p(1)+p(3),'ydata',p(2)+p(4));
% ud.PosListener.Enabled = true;
ExecResizeFcn(hrect);

function BR_click(~,~,hrect)
ud = get(hrect,'userdata');
if ud.LockPosition %check if lock position
    return;
end
%ud.PosListener.Enabled = false;
hax = get(hrect,'parent');
p = get(hrect,'position');
r = ax2figpos(p,hax);
xnorm = strcmpi(get(hax,'xdir'),'normal');
ynorm = strcmpi(get(hax,'ydir'),'normal');
if xnorm&&ynorm
    r = rbbox(r,[r(1),r(2)+r(4)]); %BR clicked
elseif ~xnorm&&ynorm
    r = rbbox(r,[r(1)+r(3),r(2)+r(4)]); %BL clicked
elseif xnorm&&~ynorm
    r = rbbox(r,[r(1),r(2)]);%TR clicked
elseif ~xnorm&&~ynorm
    r = rbbox(r,[r(1)+r(3),r(2)]);%TL clicked
end

p = fig2axpos(r,hax);
%set positions
set(hrect,'position',p);
%corner points
% set(ud.hPt_BL,'xdata',p(1),'ydata',p(2));
% set(ud.hPt_BR,'xdata',p(1)+p(3),'ydata',p(2));
% set(ud.hPt_TL,'xdata',p(1),'ydata',p(2)+p(4));
% set(ud.hPt_TR,'xdata',p(1)+p(3),'ydata',p(2)+p(4));
% ud.PosListener.Enabled = true;
ExecResizeFcn(hrect);

function TL_click(~,~,hrect)
ud = get(hrect,'userdata');
if ud.LockPosition %check if lock position
    return;
end
%ud.PosListener.Enabled = false;
hax = get(hrect,'parent');
p = get(hrect,'position');
r = ax2figpos(p,hax);
xnorm = strcmpi(get(hax,'xdir'),'normal');
ynorm = strcmpi(get(hax,'ydir'),'normal');
if xnorm&&ynorm
    r = rbbox(r,[r(1)+r(3),r(2)]);%TL clicked
elseif ~xnorm&&ynorm
    r = rbbox(r,[r(1),r(2)]);%TR clicked
elseif xnorm&&~ynorm
    r = rbbox(r,[r(1)+r(3),r(2)+r(4)]);%BL clicked
elseif ~xnorm&&~ynorm
    r = rbbox(r,[r(1),r(2)+r(4)]);%BR clicked
end
p = fig2axpos(r,hax);
%set positions
set(hrect,'position',p);
%corner points
% set(ud.hPt_BL,'xdata',p(1),'ydata',p(2));
% set(ud.hPt_BR,'xdata',p(1)+p(3),'ydata',p(2));
% set(ud.hPt_TL,'xdata',p(1),'ydata',p(2)+p(4));
% set(ud.hPt_TR,'xdata',p(1)+p(3),'ydata',p(2)+p(4));
% ud.PosListener.Enabled = true;
ExecResizeFcn(hrect);


function TR_click(~,~,hrect)
ud = get(hrect,'userdata');
if ud.LockPosition %check if lock position
    return;
end
%ud.PosListener.Enabled = false;
hax = get(hrect,'parent');
p = get(hrect,'position');
r = ax2figpos(p,hax);
xnorm = strcmpi(get(hax,'xdir'),'normal');
ynorm = strcmpi(get(hax,'ydir'),'normal');
if xnorm&&ynorm
    r = rbbox(r,[r(1),r(2)]);%TR clicked
elseif ~xnorm&&ynorm
    r = rbbox(r,[r(1)+r(3),r(2)]);%TL clicked
elseif xnorm&&~ynorm
    r = rbbox(r,[r(1),r(2)+r(4)]);%BR clicked
elseif ~xnorm&&~ynorm
    r = rbbox(r,[r(1)+r(3),r(2)+r(4)]);%BL clicked
end
p = fig2axpos(r,hax);
%set positions
set(hrect,'position',p);
%corner points
% set(ud.hPt_BL,'xdata',p(1),'ydata',p(2));
% set(ud.hPt_BR,'xdata',p(1)+p(3),'ydata',p(2));
% set(ud.hPt_TL,'xdata',p(1),'ydata',p(2)+p(4));
% set(ud.hPt_TR,'xdata',p(1)+p(3),'ydata',p(2)+p(4));
% ud.PosListener.Enabled = true;
ExecResizeFcn(hrect);

function ExecResizeFcn(hrect)
ud = get(hrect,'userdata');
if isempty(ud.ResizeFcn)
    return;
end

if ischar(ud.ResizeFcn)
    f = str2func(ud.ResizeFcn);
elseif iscell(ud.ResizeFcn)
    if ischar(ud.ResizeFcn{1})
        f = str2func(ud.ResizeFcn{1});
        f = @(x) f(x,ud.ResizeFcn{2:end});
    else
        f = @(x) ud.ResizeFcn{1}(x,ud.ResizeFcn{2:end});
    end
elseif isa(ud.ResizeFcn,'function_handle')
    f = ud.ResizeFcn;
else
    error('Something is wrong with ud.ResizeFcn');
end
f(hrect);

function stat = verify_fcn(f)
if isa(f,'function_handle')
    stat=true;
elseif ischar(f)
    stat = true;
elseif iscell(f)&&(isa(f{1},'function_handle')||ischar(f{1}))
    stat = true;
elseif isempty(f)
    stat = true;
else
    stat = false;
end

function delete_rect(hrect,~)
%disp('indelete')
ud = get(hrect,'userdata');
%delete corner points
try
    delete(ud.hPt_BL);
    delete(ud.hPt_BR);
    delete(ud.hPt_TL);
    delete(ud.hPt_TR);
catch
end
%delete the rectangle;
delete(hrect);

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