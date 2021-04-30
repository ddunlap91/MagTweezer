classdef uirect < matlab.mixin.SetGet
    
    properties(SetAccess=protected)
        Parent = []; %parent axes
        Container = []; %figure or panel containing axes
        
        hRectangle = []; %rectangle handle
        hMarkers = []; %handle to the list of markers
    end
    
    properties(Access=protected)
        %CreateParent = false; %Flag specifying if parent axes was created  
        ParentDeleteListener;
        RectangleDeleteListener;
        
        MarkerOrder = {'x1_y1','x1_y2','x2_y2','x2_y1'}; %clockwise order starting at x1,y1
    end
    
    %%User Modifiable Parameters
    properties (SetObservable=true, AbortSet=true)
        
        Position = [];
        
        
        EdgeColor = 'r';
        FaceColor = 'none';
        LineStyle = '-';
        LineWidth = 0.5;
        
        EditLineStyle = ':';
        EditLineColor = 'auto';
        EditLineWidth = 1;
        
        Marker = 's';
        MarkerSize = 5;
        MarkerEdgeColor = 'auto';
        MarkerFaceColor = 'auto';
        
        UIContextMenu = [];
        
        UserData = [];
         
    end
    
    %% Modifiable without abortset
    properties(SetObservable=true,AbortSet=false)
        Curvature = [0,0];
        MarkerVisible = 'on';
        RectangleVisible = 'on';
        
        Resizable = true;
        Draggable = true;
    end
    
    properties(Dependent)
        %Visible;
        %Color;
        IsOval
    end
    
    %% Watchable Events
    properties (SetAccess=protected, SetObservable=true)
        BeingDragged = false;
        BeingResized = false;
    end
    
    events
        PositionChangedByUI;
        Resized;
        Dragged;
        VisibilityChanged;
    end
    
    %% Create & Delete
    methods
        %% Create
        function this = uirect(Parent,varargin)
            
            %% Validate inputs
            
            % Validate parent
            LookForParent = true;
            if nargin>0
                if ishghandle(Parent)
                    LookForParent = false;  
                elseif ischar(Parent)
                    varargin=[Parent,varargin];
                    Parent = [];
                else
                    error('First argument should be graphic handle or char array specifying first name-value pair');
                end
                
            else %no args
                Parent = [];
                LookForParent = false; 
            end
            
            if LookForParent
                indPar = find(strcmpi('Parent',varargin));
                if numel(indPar)>1
                    error('Parent name-value pair specified multiple times');
                elseif ~isempty(indPar)
                    Parent = varargin{indPar+1};
                    varargin(indPar:indPar+1)=[];
                else
                    Parent = [];
                end
            end

            %% Validate Parent
            if isempty(Parent)
                this.Container = gcf;
                this.Parent = gca;
                %this.CreatedParent = true;
            % figure or panel
            elseif ismember(class(Parent),{'matlab.ui.Figure','matlab.ui.container.Panel'}) || ...
                any(ismember(superclasses(Parent),{'matlab.ui.Figure','matlab.ui.container.Panel','matlab.mixin.CustomDisplay'}))

                this.Container = Parent;

                if isa(this.Container,'matlab.ui.Figure')
                    
                    figure(this.Container);
                    Parent = gca;

                else %panel
                    par = findobj(this.Container,'Type','Axes');
                    if isempty(par)
                        Parent = axes(this.Container);
                        %this.CreatedParent = true;
                    else
                        Parent = par(1);
                    end
                end
                this.Parent = Parent;
            %axes
            elseif isa(Parent,'matlab.graphics.axis.Axes')
                this.Parent = Parent;
            else
                error('Invalid Parent type');
            end
            this.Container = ancestor(this.Parent,'Figure');
            
            %% Create rectangle & markers
            
            this.hRectangle = rectangle('Parent',this.Parent,...
                'Position',zeros(1,4),...
                'EdgeColor',this.EdgeColor,...
                'FaceColor',this.FaceColor,...
                'LineStyle',this.LineStyle,...
                'Curvature',this.Curvature,...
                'Visible','off',...
                'Selected','off',...
                'SelectionHighlight','off',...
                'HandleVisibility','Callback',...
                'PickableParts','none',...
                'UIContextMenu',this.UIContextMenu,...
                'Interruptible','off',...
                'ButtonDownFcn',@(h,e) this.RectangleClick(h,e));
            
            this.hMarkers = gobjects(1,4);
            for n=1:4
                this.hMarkers(n) = line('Parent',this.Parent,...
                    'XData',NaN,...
                    'YData',NaN,...
                    'LineStyle','none',...
                    'Color',this.EdgeColor,...
                    'Marker',this.Marker,...
                    'MarkerSize',this.MarkerSize,...
                    'MarkerEdgeColor',this.MarkerEdgeColor,...
                    'MarkerFaceColor',this.MarkerFaceColor,...
                    'HandleVisibility','Callback',...
                    'PickableParts','none',...
                    'Visible','off',...
                    'Selected','off',...
                    'SelectionHighlight','off',...                    
                    'UIContextMenu',this.UIContextMenu,...
                    'Interruptible','off',...
                    'ButtonDownFcn',@(h,e) this.MarkersClicked(n,h,e));
            end
          
                
            %% Set Values using name-value pairs
            if mod(numel(varargin),2)~=0
                error('number of arguments does not match Name-value pair convention');
            end
            if ~isempty(varargin)
                set(this,varargin{:});
            end
            
            %% toggle face color
            ofc = this.MarkerFaceColor;
            this.MarkerFaceColor = 'none';
            this.MarkerFaceColor = ofc;
            
            %% If position is not set, have user select position
            if isempty(this.Position)
                
                if strcmpi(this.EditLineColor,'auto')
                    ELC = this.EdgeColor;
                else
                    ELC = this.EditLineColor;
                end
                if strcmpi(this.EditLineWidth,'auto')
                    ELW = this.LineWidth;
                else
                    ELW = this.EditLineWidth;
                end
                
                if strcmpi(this.EditLineStyle,'auto')
                    ELS = this.LineStyle;
                else
                    ELS = this.EditLineStyle;
                end
                this.BeingResized = true;  
                pos = getrect2(this.Parent,...
                    'Color',ELC,...
                    'LineStyle',ELS,...
                    'LineWidth',ELW);
                
                this.Position = pos;
                this.BeingResized = false;
            end
            
            %% Reset Visibility and editability
            set(this,...
                'MarkerVisible',this.MarkerVisible,...
                'RectangleVisible',this.RectangleVisible,...
                'Resizable',this.Resizable,...
                'Draggable',this.Draggable);
            
            
            %% Delete Listeners
            this.ParentDeleteListener = addlistener(this.Parent,'ObjectBeingDestroyed',@(~,~) delete(this));
            this.RectangleDeleteListener =  addlistener(this.hRectangle,'ObjectBeingDestroyed',@(~,~) delete(this));
            
        end
        
        %% Delete
        function delete(this)
            try
                delete(this.hRectangle);
            catch
            end
            delete(this.hMarkers);
            delete(this.ParentDeleteListener);
            
            %if this.CreatedParent
            %    delete(this.Parent)
            %end
            
        end
              
    end
    
    %% Hidden Methods for Callbacks
    methods(Hidden)
        function RectangleClick(this,~,~)
            this.BeingDragged = true;
            if strcmpi(this.EditLineColor,'auto')
                ELC = this.EdgeColor;
            else
                ELC = this.EditLineColor;
            end
            if strcmpi(this.EditLineWidth,'auto')
                ELW = this.LineWidth;
            else
                ELW = this.EditLineWidth;
            end

            if strcmpi(this.EditLineStyle,'auto')
                ELS = this.LineStyle;
            else
                ELS = this.EditLineStyle;
            end
            
            old_RecVis = this.RectangleVisible;
            this.RectangleVisible = 'off';
            old_MarVis = this.MarkerVisible;
            this.MarkerVisible = 'off';
            
            pos = dragrect2(this.Position,'Parent',this.Parent,...
                'LineStyle',ELS,...
                'LineWidth',ELW,...
                'Color',ELC,...
                'Marker','none');
            
            this.Position = pos;
            
            this.RectangleVisible = old_RecVis;
            this.MarkerVisible = old_MarVis; 
            
            this.BeingDragged = false;
            notify(this,'PositionChangedByUI');
                
        end
        function MarkersClicked(this,MarkerID,~,~)
            this.BeingResized = true;
            pos = this.Position;
            switch(this.MarkerOrder{MarkerID})
                case 'x1_y1'
                    FixedPos = [pos(1)+pos(3),pos(2)+pos(4)];
                case 'x1_y2'
                    FixedPos = [pos(1)+pos(3),pos(2)];
                case 'x2_y2'
                    FixedPos = [pos(1),pos(2)];
                case 'x2_y1'
                    FixedPos = [pos(1),pos(2)+pos(4)];
                case 'x1_y1.5'
                    FixedPos = [pos(1)+pos(3),pos(2)];
                case 'x1.5_y2'
                    FixedPos = [pos(1),pos(2)];
                case 'x2_y1.5'
                    FixedPos = [pos(1),pos(2)];
                case 'x1.5_y1'
                    FixedPos = [pos(1),pos(2)+pos(4)];
            end
            
            %temp hide
            old_RecVis = this.RectangleVisible;
            this.RectangleVisible = 'off';
            old_MarVis = this.MarkerVisible;
            this.MarkerVisible = 'off';
            
            if strcmpi(this.EditLineColor,'auto')
                ELC = this.EdgeColor;
            else
                ELC = this.EditLineColor;
            end
            if strcmpi(this.EditLineWidth,'auto')
                ELW = this.LineWidth;
            else
                ELW = this.EditLineWidth;
            end

            if strcmpi(this.EditLineStyle,'auto')
                ELS = this.LineStyle;
            else
                ELS = this.EditLineStyle;
            end
            
            pos = getrect2( this.Parent,...
                'defaultRect',pos,...
                'FixedPosition',FixedPos,...
                'LineStyle',ELS,...
                'LineWidth',ELW,...
                'Color',ELC,...
                'Marker',this.Marker,...
                'MarkerEdgeColor',this.MarkerEdgeColor,...
                'MarkerFaceColor',this.MarkerFaceColor);
            
            this.Position = pos;
            
            this.RectangleVisible = old_RecVis;
            this.MarkerVisible = old_MarVis;
            
            
            this.BeingResized = false;
            %% notify listeners
            notify(this,'PositionChangedByUI');
            
        end
%         function MouseMove(this,~,~)
%         end
%         function MouseUp(this,~,~)
%         end
    end
    
    
    %% Dependent
    methods
        function tf = get.IsOval(this)
            tf = any(this.Curvature~=0);
        end 
    end
    
    %% Set Methods
    methods
        function set.Position(this,pos)
            assert(numel(pos)==4,'Position must contain 4 elements')
            assert(all(~isnan(pos))&&all(~isinf(pos)),'Position must be finite and not NaN');
            
            this.hRectangle.Position = pos;
            
            
            if ~this.IsOval %just a rectangle
                
                for n=1:4
                    switch(this.MarkerOrder{n})
                        case 'x1_y1'
                            set(this.hMarkers(n),'XData',pos(1),'YData',pos(2));
                        case 'x1_y2'
                            set(this.hMarkers(n),'XData',pos(1),'YData',pos(2)+pos(4));
                        case 'x2_y2'
                            set(this.hMarkers(n),'XData',pos(1)+pos(3),'YData',pos(2)+pos(4));
                        case 'x2_y1'
                            set(this.hMarkers(n),'XData',pos(1)+pos(3),'YData',pos(2));
                    end
                end
                
            else %oval, move markers to middle
                for n=1:4
                    switch(this.MarkerOrder{n})
                        case 'x1_y1.5'
                            set(this.hMarkers(n),'XData',pos(1),'YData',pos(2)+pos(4)/2);
                        case 'x1.5_y2'
                            set(this.hMarkers(n),'XData',pos(1)+pos(3)/2,'YData',pos(2)+pos(4));
                        case 'x2_y1.5'
                            set(this.hMarkers(n),'XData',pos(1)+pos(3),'YData',pos(2)+pos(4)/2);
                        case 'x1.5_y1'
                            set(this.hMarkers(n),'XData',pos(1)+pos(3)/2,'YData',pos(2));
                    end
                end
            end
            
            this.Position = pos;
        end
        
        function set.Curvature(this,cur)
            assert(numel(cur)==2,'Curvature must contain 2 elements');
            
            this.hRectangle.Curvature = cur;
            
            %% set marker order
            if any(cur~=0) %isoval
                this.MarkerOrder = {'x1_y1.5','x1.5_y2','x2_y1.5','x1.5_y1'};
            else
               this.MarkerOrder =  {'x1_y1','x1_y2','x2_y2','x2_y1'};
            end
            
            this.Curvature = cur;
            
            %move markers if needed
            pos = this.Position;
            if ~isempty(pos)
                if ~this.IsOval %just a rectangle

                    for n=1:4
                        switch(this.MarkerOrder{n})
                            case 'x1_y1'
                                set(this.hMarkers(n),'XData',pos(1),'YData',pos(2));
                            case 'x2_y2'
                                set(this.hMarkers(n),'XData',pos(1),'YData',pos(2)+pos(4));
                            case 'x2_y2'
                                set(this.hMarkers(n),'XData',pos(1)+pos(3),'YData',pos(2)+pos(4));
                            case 'x2_y1'
                                set(this.hMarkers(n),'XData',pos(1)+pos(3),'YData',pos(2));
                        end
                    end

                else %oval, move markers to middle
                    for n=1:4
                        switch(this.MarkerOrder{n})
                            case 'x1_y1.5'
                                set(this.hMarkers(n),'XData',pos(1),'YData',pos(2)+pos(4)/2);
                            case 'x1.5_y2'
                                set(this.hMarkers(n),'XData',pos(1)+pos(3)/2,'YData',pos(2)+pos(4));
                            case 'x2_y1.5'
                                set(this.hMarkers(n),'XData',pos(1)+pos(3),'YData',pos(2)+pos(4)/2);
                            case 'x1.5_y1'
                                set(this.hMarkers(n),'XData',pos(1)+pos(3)/2,'YData',pos(2));
                        end
                    end
                end 
            end
        end
        
        function set.EdgeColor(this,val)
            assert( (ischar(val)&& ...
                        ismember(val,...
                        {'r','red',...
                        'g','green',...
                        'b','blue',...
                        'yellow','y',...
                        'magenta','m',...
                        'cyan','c',...
                        'white','w',...
                        'black','b',...
                        'none'})...
                    ) ||...
                (isnumeric(val)&&numel(val)==3&&all(val>=0)&&all(val<=1)),...
                'EdgeColor must be a valid color value');
            
            this.hRectangle.EdgeColor = val;
            
            if strcmpi(this.MarkerEdgeColor,'auto')
                for n=1:4
                    this.hMarkers(n).MarkerEdgeColor = val;
                end
            end
            if strcmpi(this.MarkerFaceColor,'auto')
                for n=1:4
                    this.hMarkers(n).MarkerFaceColor = val;
                end
            end
            
            this.EdgeColor = val;
        end
        
        function set.FaceColor(this,val)
            assert( (ischar(val)&& ...
                        ismember(val,...
                        {'r','red',...
                        'g','green',...
                        'b','blue',...
                        'yellow','y',...
                        'magenta','m',...
                        'cyan','c',...
                        'white','w',...
                        'black','b',...
                        'auto',...
                        'none'})...
                    ) ||...
                (isnumeric(val)&&numel(val)==3&&all(val>=0)&&all(val<=1)),...
                'FaceColor must be a valid color value');
            
            if strcmpi(val,'auto')
                this.hRectangle.FaceColor = this.EdgeColor;
            else
                this.hRectangle.FaceColor = val;
            end
            
            this.FaceColor = val;
            
        end
        
        function set.LineStyle(this,val)
            assert(ismember(val,{'-','--',':','-.','none'}),...
                'LineStyle must be valid style. See Line Properties.');
            
            this.hRectangle.LineStyle = val;
            this.LineStyle = val;
            
        end
        
        function set.LineWidth(this,val)
            assert(isnumeric(val)&&isscalar(val),'LineWidth must be numeric scalar');
            
            this.hRectangle.LineWidth = val;
            this.LineWidth = val;
        end
        
        function set.EditLineStyle(this,val)
            assert(ismember(val,{'-','--',':','-.','none','Auto'}),...
                'EditLineStyle must be valid style. See Line Properties.');
            
            this.EditLineStyle = val;
        end
        
        function set.EditLineWidth(this,val)
            aassert((ischar(val)&&strcmip(val,'auto'))||(isnumeric(val)&&isscalar(val)),...
                'EditLineWidth must be numeric scalar or ''auto''');
            
            this.EditLineWidth = val;
        end
        
        function set.EditLineColor(this,val)
            assert( (ischar(val)&& ...
                        ismember(val,...
                        {'r','red',...
                        'g','green',...
                        'b','blue',...
                        'yellow','y',...
                        'magenta','m',...
                        'cyan','c',...
                        'white','w',...
                        'black','b',...
                        'auto',...
                        'none'})...
                    ) ||...
                (isnumeric(val)&&numel(val)==3&&all(val>=0)&&all(val<=1)),...
                'EditLineColor must be a valid color value');
            
            this.EditLineColor = val;
        end
        
        function set.Marker(this,val)
            assert(ismember(val,...
                {'o','+','*','.','x','square','s','diamond','d','^','v','>','<','pentagram','p','hexagram','h','none'}),...
                'Marker must be valid style. See Line Properties.');
            
            for n=1:4
                this.hMarkers(n).Marker = val;
            end
            this.Marker = val;
        end
        
        function set.MarkerSize(this,val)
            assert(isnumeric(val)&&isscalar(val),'MarkerSize must be numeric scalar');
            
            for n=1:4
                this.hMarkers(n).MarkerSize = val;
            end
            this.MarkerSize = val;
        end
        
        function set.MarkerEdgeColor(this,val)
            assert( (ischar(val)&& ...
                        ismember(lower(val),...
                        {'r','red',...
                        'g','green',...
                        'b','blue',...
                        'yellow','y',...
                        'magenta','m',...
                        'cyan','c',...
                        'white','w',...
                        'black','b',...
                        'auto',...
                        'none'})...
                    ) ||...
                (isnumeric(val)&&numel(val)==3&&all(val>=0)&&all(val<=1)),...
                'MarkerEdgeColor must be a valid color value');
            
            if strcmpi(val,'auto')
                for n=1:4
                    this.hMarkers(n).MarkerEdgeColor = this.EdgeColor;
                end
            else
                for n=1:4
                    this.hMarkers(n).MarkerEdgeColor = val;
                end
            end
            this.MarkerEdgeColor = val;
            
        end
        
        function set.MarkerFaceColor(this,val)
            assert( (ischar(val)&& ...
                        ismember(lower(val),...
                        {'r','red',...
                        'g','green',...
                        'b','blue',...
                        'yellow','y',...
                        'magenta','m',...
                        'cyan','c',...
                        'white','w',...
                        'black','b',...
                        'auto',...
                        'none'})...
                    ) ||...
                (isnumeric(val)&&numel(val)==3&&all(val>=0)&&all(val<=1)),...
                'MarkerFaceColor must be a valid color value');
            
            if strcmpi(val,'auto')
                for n=1:4
                    this.hMarkers(n).MarkerFaceColor = this.EdgeColor;
                end
            else
                for n=1:4
                    this.hMarkers(n).MarkerFaceColor = val;
                end
            end
            this.MarkerFaceColor = val;
        end
        function set.MarkerVisible(this,val)
            assert(ismember(lower(val),{'on','off'}),'MarkerVisible must be ''on'' or ''off''.');
            
            for n=1:4
                this.hMarkers(n).Visible=val;
            end
            this.MarkerVisible = val;
            
            if this.Resizable
                for n=1:4
                    if strcmpi(this.hRectangle.Visible,'on')
                        this.hMarkers(n).PickableParts = 'all';
                    else
                        this.hMarkers(n).PickableParts = 'visible';
                    end
                end
            else
                for n=1:4
                    this.hMarkers(n).PickableParts = 'none';
                end 
            end
        end
        function set.RectangleVisible(this,val)
            assert(ismember(lower(val),{'on','off'}),'RectangleVisible must be ''on'' or ''off''.');
            
            this.hRectangle.Visible = val;
            this.RectangleVisible = val;
            
            if this.Resizable
                for n=1:4
                    if strcmpi(this.hRectangle.Visible,'on')
                        this.hMarkers(n).PickableParts = 'all';
                    else
                        this.hMarkers(n).PickableParts = 'visible';
                    end
                end
            else
                for n=1:4
                    this.hMarkers(n).PickableParts = 'none';
                end 
            end
        end
        function set.Resizable(this,val)
            assert(isscalar(val),'Resizable must be scalar true or false');
            this.Resizable = logical(val);
            
            if this.Resizable
                for n=1:4
                    if strcmpi(this.hRectangle.Visible,'on')
                        this.hMarkers(n).PickableParts = 'all';
                    else
                        this.hMarkers(n).PickableParts = 'visible';
                    end
                end
            else
                for n=1:4
                    this.hMarkers(n).PickableParts = 'none';
                end 
            end
        end
        function set.Draggable(this,val)
            assert(isscalar(val),'Draggable must be scalar true or false');
            this.Draggable = logical(val);
            
            if this.Draggable
                this.hRectangle.PickableParts = 'visible';
            else
                this.hRectangle.PickableParts = 'none';
            end
        end
        function set.UIContextMenu(this,val)
            this.UIContectMenu = val;
            
            this.hRectangle.UIContextMenu = val;
            for n=1:4
                this.hMarkers(n).UIContextMenu = val;
            end
        end
    end
end


function rect = getrect2(varargin)
% GETRECT2 Select rectangle with the mouse
%   This is a modified version of the built-in GETRECT function included
%   with MATLAB.
%   
% Syntax:
%   getrect2()
%   getrect2(defaultRect)
%   getrect2(fixedPosition)
%   getrect2(defaultRect,fixedPosition)
%   getrect2(__,Name,Value)
%   getrect2(hAx,__) or getrect2(hFig,__)
%   RECT = getrect2(__)
%
%   Without any arguments, the function waits for the user to select 
%   a rectangle in the current axes using the mouse.  Use the mouse to 
%   click and drag the desired rectangle.
%   RECT is a four-element vector with the form [xmin ymin width height].

%% Load custom cursor
persistent cross_cursor;
if isempty(cross_cursor)
    cross_cursor = load(fullfile(fileparts(mfilename('fullpath')),'cross_cursor.mat'));
end



%% Parse inputs
GETRECT_AX = [];

%if not using name-pair syntax, first argument will by 
if nargin > 0 && isscalar(varargin{1}) && ishghandle(varargin{1})
    GETRECT_AX = varargin{1};
    varargin(1) = []; %remove first element and process rest of varargin normally
end

fixedPosition = [];
defaultRect = [];

if numel(varargin)>0 && isnumeric(varargin{1}) && numel(varargin{1}) == 4
    defaultRect = varargin{1};
    varargin(1) = [];
end
if numel(varargin)>0 && isnumeric(varargin{1})
    if numel(varargin{1}) ~= 2
        error('Specifying fixed position must have numel==2');
    end
    fixedPosition = varargin{1};
    varargin(1) = [];
end

%Use input parser to process name-value pairs
p = inputParser;
p.CaseSensitive = false;
addParameter(p,'defaultRect',[],@(x) isempty(x) || isnumeric(x)&&numel(x)==4);
addParameter(p,'FixedPosition',[],@(x) isempty(x) || isnumeric(x)&&numel(x)==2);
addParameter(p,'LineStyle',':',@(x) ischar(x)&&any(strcmpi(x,{'-','--',':','-.','none'})));
addParameter(p,'LineWidth',0.5,@(x) isnumeric(x)&&isscalar(x)&&x>=0);
addParameter(p,'Color','k',@(x) isnumeric(x)&&numel(x)==3&&all(x<=1 & x>=0) ||...
                                ischar(x)&&any(strcmpi(x,...
                                    {'y','yellow',...
                                    'm','magenta',...
                                    'c','cyan',...
                                    'r','red',...
                                    'g','green',...
                                    'b','blue',...
                                    'w','white',...
                                    'k','black'})));
addParameter(p,'Marker','none',@(x) ischar(x)&&any(strcmpi(x,{'+','o','*','.','x','s','square','d','diamond','^','v','>','<','p','pentagram','h','hexagram','none'})));
addParameter(p,'MarkerEdgeColor','auto',@(x) isnumeric(x)&&numel(x)==3&&all(x<=1 & x>=0) ||...
                                ischar(x)&&any(strcmpi(x,...
                                    {'y','yellow',...
                                    'm','magenta',...
                                    'c','cyan',...
                                    'r','red',...
                                    'g','green',...
                                    'b','blue',...
                                    'w','white',...
                                    'k','black',...
                                    'none','auto'})));
addParameter(p,'MarkerFaceColor','auto',@(x) isnumeric(x)&&numel(x)==3&&all(x<=1 & x>=0) ||...
                                ischar(x)&&any(strcmpi(x,...
                                    {'y','yellow',...
                                    'm','magenta',...
                                    'c','cyan',...
                                    'r','red',...
                                    'g','green',...
                                    'b','blue',...
                                    'w','white',...
                                    'k','black',...
                                    'none','auto'})));
addParameter(p,'MarkerSize',6,@(x) isnumeric(x)&&isscalar(x)&&x>=0);

parse(p,varargin{:});

if isempty(defaultRect)
    defaultRect = p.Results.defaultRect;
end
if isempty(fixedPosition)
    fixedPosition = p.Results.FixedPosition;
end


%make sure GETRECT is an axes handle, if figure then find the axes
if ~isempty(GETRECT_AX) && ishghandle(GETRECT_AX)
    switch get(GETRECT_AX, 'Type')
        case 'figure' %first arg was figure handle
            GETRECT_FIG = GETRECT_AX;
            GETRECT_AX = get(GETRECT_FIG, 'CurrentAxes');
            if isempty(GETRECT_AX)
                GETRECT_AX = axes('Parent', GETRECT_FIG);
            end
        case 'axes'
           GETRECT_FIG = ancestor(GETRECT_AX, 'figure');
        otherwise
            error('parent handle must be an axes or a figure');
    end
else %user has not set an axes yet, use GCA
    GETRECT_AX = gca;
    GETRECT_FIG = ancestor(GETRECT_AX, 'figure');
end


%% Handle defaultRect
%if user specified default rect but not a fixed corner use the corner
%furthest away from the cursor as the fixed corner
if ~isempty(defaultRect) && isempty(fixedPosition)
    XY = [defaultRect(1),defaultRect(2);...
          defaultRect(1),defaultRect(2)+defaultRect(4);...
          defaultRect(1)+defaultRect(3),defaultRect(2)+defaultRect(4);...
          defaultRect(1)+defaultRect(3),defaultRect(2)];
    cpt = get(GETRECT_AX, 'CurrentPoint');
    [~,r] = min( (XY(:,1)-cpt(1,1)).^2 + (XY(:,2)-cpt(1,2)).^2);
    %mod(r+1,4)+1
    fixedPosition = XY(mod(r+1,4)+1,:);
end

%% Setup for rectangle creation
% Remember initial figure state
state = uisuspend(GETRECT_FIG);

% Set up initial callbacks for initial stage
set(GETRECT_FIG, ...
    'Pointer', 'custom', ...
    'PointerShapeCData',cross_cursor.cross,...
    'PointerShapeHotSpot',[16,16],...
    'Interruptible','off',...
    'WindowKeyPressFcn',@HitKey);

% Set axes limit modes to manual, so that the presence of lines used to
% draw the rectangles doesn't change the axes limits.
original_modes = get(GETRECT_AX, {'XLimMode', 'YLimMode', 'ZLimMode'});
set(GETRECT_AX,'XLimMode','manual', ...
               'YLimMode','manual', ...
               'ZLimMode','manual');
           
% Initialize the lines to be used for the drag
GETRECT_H1 = line('Parent', GETRECT_AX, ...
                  'XData', [0 0 0 0 0], ...
                  'YData', [0 0 0 0 0], ...
                  'Visible', 'off', ...
                  'Clipping', 'off', ...
                  'Color', p.Results.Color, ...
                  'LineStyle', p.Results.LineStyle,...
                  'LineWidth',p.Results.LineWidth,...
                  'Marker',p.Results.Marker,...
                  'MarkerEdgeColor',p.Results.MarkerEdgeColor,...
                  'MarkerFaceColor',p.Results.MarkerFaceColor,...
                  'MarkerSize',p.Results.MarkerSize);
%% Callback Functions
    function HitKey(~,evt)
        if strcmpi(evt.Key,'escape')
            rect = defaultRect;
            set(GETRECT_H1, 'UserData', 'Completed');
        end
    end
    function MouseDown(~,~)
        pt = get(GETRECT_AX, 'CurrentPoint');
        fixedPosition = pt(1,1:2);
        set(GETRECT_FIG,'WindowButtonMotionFcn',@MouseMotion);
        set(GETRECT_FIG,'WindowButtonUpFcn',@MouseUp);
        set(GETRECT_FIG,'WindowButtonDownFcn',[]);
        set(GETRECT_H1,'Visible','on',...
                'XData',fixedPosition(1),...
                'YData',fixedPosition(2));
    end
    function MouseUp(~,~)
        pt = get(GETRECT_AX, 'CurrentPoint');
        rect = [min(fixedPosition(1),pt(1,1)), min(fixedPosition(2),pt(1,2)),abs(pt(1,1)-fixedPosition(1)),abs(pt(1,2)-fixedPosition(2))];
        if rect(3)~=0 && rect(4)~=0
            set(GETRECT_H1, 'UserData', 'Completed');
        end
    end
    function MouseMotion(~,~)
        pt = get(GETRECT_AX, 'CurrentPoint');
        set(GETRECT_H1,'XData',[fixedPosition(1),fixedPosition(1)  ,pt(1,1)    ,pt(1,1)            ,fixedPosition(1)],...
            'YData',[fixedPosition(2),pt(1,2)           ,pt(1,2)    ,fixedPosition(2)   ,fixedPosition(2)]);
    end

if isempty(fixedPosition)
    set(GETRECT_FIG,'WindowButtonDownFcn',@MouseDown);
else
    set(GETRECT_FIG,'WindowButtonMotionFcn',@MouseMotion);
    set(GETRECT_FIG,'WindowButtonUpFcn',@MouseUp);
    set(GETRECT_FIG,'WindowButtonDownFcn',[]);
    pt = get(GETRECT_AX, 'CurrentPoint');
    set(GETRECT_H1,'Visible','on','XData',[fixedPosition(1),fixedPosition(1)  ,pt(1,1)    ,pt(1,1)            ,fixedPosition(1)],...
            'YData',[fixedPosition(2),pt(1,2)           ,pt(1,2)    ,fixedPosition(2)   ,fixedPosition(2)]);
end

%% Wait for presses, and process
rect = defaultRect;
waitfor(GETRECT_H1, 'UserData', 'Completed');

%% Cleanup
% Delete the animation objects
try
    delete(GETRECT_H1);
catch
end
% Restore the figure state
try
   uirestore(state);
catch
end
%restore axes state
try
   set(GETRECT_AX, {'XLimMode','YLimMode','ZLimMode'}, original_modes);
catch
end

end


function rect = dragrect2(rect,varargin)

%% Parse Inputs

p=inputParser;
p.CaseSensitive = false;
p.KeepUnmatched = true;

addParameter(p,'Parent',[]);

addParameter(p,'LineStyle',':');
addParameter(p,'LineWidth',0.5,@(x) isnumeric(x)&&isscalar(x)&&x>=0);
addParameter(p,'Color','k');
addParameter(p,'Marker','none');
addParameter(p,'MarkerEdgeColor','auto');
addParameter(p,'MarkerFaceColor','auto');
addParameter(p,'MarkerSize',6,@(x) isnumeric(x)&&isscalar(x)&&x>=0);

parse(p,varargin{:});

if isempty(p.Results.Parent)
    GETRECT_AX = gca;
else
    GETRECT_AX = p.Results.Parent;
end
switch get(GETRECT_AX, 'Type')
    case 'figure' %first arg was figure handle
        GETRECT_FIG = GETRECT_AX;
        GETRECT_AX = get(GETRECT_FIG, 'CurrentAxes');
        if isempty(GETRECT_AX)
            GETRECT_AX = axes('Parent', GETRECT_FIG);
        end
    case 'axes'
       GETRECT_FIG = ancestor(GETRECT_AX, 'figure');
    otherwise
        error('parent handle must be an axes or a figure');
end

%%
orig_rect = rect;

state = uisuspend(GETRECT_FIG);

% Set axes limit modes to manual, so that the presence of lines used to
% draw the rectangles doesn't change the axes limits.
original_modes = get(GETRECT_AX, {'XLimMode', 'YLimMode', 'ZLimMode'});
set(GETRECT_AX,'XLimMode','manual', ...
               'YLimMode','manual', ...
               'ZLimMode','manual');


%% Create moving rectangle
GETRECT_H1 = line('Parent', GETRECT_AX, ...
                  'Color',p.Results.Color,...
                  'LineWidth',p.Results.LineWidth,...
                  'LineStyle',p.Results.LineStyle,...
                  'Marker',p.Results.Marker,...
                  'MarkerSize',p.Results.MarkerSize,...
                  'MarkerEdgeColor',p.Results.MarkerEdgeColor,...
                  'MarkerFaceColor',p.Results.MarkerFaceColor,...
                  'XData', [rect(1),rect(1),        rect(1)+rect(3),rect(1)+rect(3),rect(1)], ...
                  'YData', [rect(2),rect(2)+rect(4),rect(2)+rect(4),rect(2),        rect(2)], ...
                  'Visible', 'on', ...
                  'Clipping', 'off', ...
                  p.Unmatched);
              
% Set up initial callbacks for initial stage
set(GETRECT_FIG,...
    'Interruptible','off',...
    'WindowKeyPressFcn',@HitKey,...
    'WindowButtonMotionFcn',@MouseMotion,...
    'WindowButtonUpFcn',@MouseUp);

%% initial point
orig_pt = get(GETRECT_AX, 'CurrentPoint');

%% wait for completed
waitfor(GETRECT_H1, 'UserData', 'Completed');

%% Cleanup
% Delete the animation objects
try
    delete(GETRECT_H1);
catch
end
% Restore the figure state
try
   uirestore(state);
catch
end
%restore axes state
try
   set(GETRECT_AX, {'XLimMode','YLimMode','ZLimMode'}, original_modes);
catch
end

%% Callback Functions
    function HitKey(~,evt)
        if strcmpi(evt.Key,'escape')
            rect = orig_rect;
            set(GETRECT_H1, 'UserData', 'Completed');
        end
    end
    function MouseMotion(~,~)
        pt = get(GETRECT_AX, 'CurrentPoint');
        
        rect(1:2) = orig_rect(1:2)+[pt(1,1)-orig_pt(1,1),pt(1,2)-orig_pt(1,2)];
        
        set(GETRECT_H1,'XData',[rect(1),rect(1),        rect(1)+rect(3),rect(1)+rect(3),rect(1)],...
                       'YData',[rect(2),rect(2)+rect(4),rect(2)+rect(4),rect(2),        rect(2)]);
    end
    function MouseUp(~,~)
        set(GETRECT_H1, 'UserData', 'Completed');
    end
end
