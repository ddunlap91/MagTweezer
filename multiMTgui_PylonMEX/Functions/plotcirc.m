function [hlin,hcir] = plotcirc(x,y,r,varargin)
%Plot (x,y) using standard plot() but also draw circles around each point
% Input:
%   x - xdata
%   y - ydata
%   r - radius, if numel(r)==1 all circles have the same radius, otherwise
%       the radius should be defined for each point
% Optional Inputs:
%   'LineSpec',str - a vaild LineSpec used to format the plot(x,y) funciton
%   'Parent',hax - handle to parent axes
%   'LineParams,{'Name',value} - cell array that is passed to plot(...)
%           specifying additional parameters for the line
%   'CircleParams',{...} - cell array for params to pass to rectangle(...)
%           you can specify seperate parameters for each circle using
%           nested cells
%           Example:
%               ...'CircleParams',{{'FaceColor','r'},{'FaceColor','b'},...}
% Output:
%   hlin - handle to line created by plot(x,y,...)
%   hcir(n) - array of handles to circle objects created by rectangle(...)

if numel(r)~=1&&numel(r)~=numel(x)
    error('rad must have either 1 element or same number as x and y')
end

%validate inputs

p = inputParser;
p.CaseSensitive = false;
addParameter(p,'LineSpec',[],@(x) isempty(x)||ischar(x));
addParameter(p,'Parent',[],@(x) isempty(x)||(ishandle(x)&&strcmpi(get(x,'type'),'axes')));
addParameter(p,'CircleParams',{})
addParameter(p,'LineParams',{});

parse(p,varargin{:});

if ~isempty(p.Results.Parent)
    hax = p.Results.Parent;
else
    hax = gca;
end

%validate Circle Params
CP = p.Results.CircleParams;
if isempty(CP)
    perCP = false;
else
    allcell = true;
    for n=1:numel(CP)
        if ~iscell(CP{n})
            allcell = false;
            break;
        end
    end
    if allcell
        if numel(CP)~=numel(x)
            error('when specifying parameter list for each point, the number of lists must = numel(x)');
        end
        perCP = true;
    else
        perCP = false;
    end
end


holdstate = ishold(hax);
if ~holdstate
    cla(hax);
end

n = numel(x);
%create last circle first to initialize the handle output array
if numel(r)==1
    thisR =r;
else
   thisR = r(n); 
end
if perCP
    thisCP = CP{n};
else
    thisCP = CP;
end
hcir(n) = rectangle('parent',hax,'position',[x(n)-thisR,y(n)-thisR,2*thisR,2*thisR],'curvature',[1,1],thisCP{:});

hold(hax,'on'); %turn hold on;
for n=1:numel(x)-1
    if numel(r)==1
        thisR =r;
    else
       thisR = r(n); 
    end
    if perCP
        thisCP = CP{n};
    else
        thisCP = CP;
    end
    hcir(n) = rectangle('parent',hax,'position',[x(n)-thisR,y(n)-thisR,2*thisR,2*thisR],'curvature',[1,1],thisCP{:});
end

if ~isempty(p.Results.LineSpec)
    hlin = plot(x,y,p.Results.LineSpec,'parent',hax,p.Results.LineParams{:});
else
    hlin = plot(x,y,'parent',hax,p.Results.LineParams{:});
end

if holdstate
    hold(hax,'on');
else
    hold(hax,'off');
end