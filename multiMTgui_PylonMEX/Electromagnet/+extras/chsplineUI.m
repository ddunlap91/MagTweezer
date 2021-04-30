classdef chsplineUI < extras.GraphicsChild
    %User interface for dynamically editing cubic hermite spline in an
    %interactive plot
    %
    % usage:
    % obj = extras.chsplineUI(x,y)
    % obj = extras.chsplineUI(x,y,'Parent',parent)
    % obj = extras.chsplineUI(parent,___)
    % obj = extras.chsplineUI(Name,value,...)
    
    properties (SetObservable=true,AbortSet=true)
        Interactive = true;
        X = [];
        Y = [];
        
        LineStyle = '-';
        Color = 'k';
        Marker = 's';
        LineWidth = 1;     
        MarkerSize = 8;
        MarkerEdgeColor = 'auto';
        MarkerFaceColor = 'auto';
        DisplayName
    end
    
    properties
        UIeditCallback
    end
    
    events
        ChangedByUI
    end
    
    properties %(Access=protected)
        X_ = [NaN;NaN]; %data points used for computing spline
        Y_ = [NaN;NaN]; %data points used for computing spline
        chpp;
        
        hCHline
        hPts
        hSegLines
        
        hFig
        
        CLICK_ON = false;
        
        editX_
        editY_
        editLine
        
        orig_MouseMove
        orig_MouseUp
    end
    
    %% create
    methods
        function this = chsplineUI(varargin)
            % obj = chsplineUI(x,y)
            % obj = chsplineUI(x,y,'Parent',parent)
            % obj = chsplineUI(parent,___)
            % obj = chsplineUI(Name,value,...)
            
            %% initiate graphics parent related variables
            this@extras.GraphicsChild(@() gca());
            %look for parent specified in arguments, s
            varargin = this.CheckParentInput(varargin{:});
            
            if ~strcmp(this.Parent.Type,'axes')
                error('Parent must be an axes')
            end
            
            this.hFig = ancestor(this.Parent,'figure');
            
            if numel(varargin)>0
                %% Check for numeric input
                if isnumeric(varargin{1}) && isnumeric(varargin{2})
                    this.X = varargin{1};
                    this.Y = varargin{2};

                    varargin(1:2) = [];
                end

                %% set remaining parameters
                if numel(varargin)>2
                    set(this,varargin{:})
                end
            end
        end
    end
    
    methods
        function set.Interactive(this,val)
            assert(isscalar(val),'Interactive must be scalar logical');
            val = logical(val);
            
            this.Interactive = val;
            
            this.UpdateInteractive();
        end
        
        function set.DisplayName(this,val)
            assert(ischar(val)||isempty(val),'DisplayName must be a char array');
            if ~isempty(this.hCHline) && isvalid(this.hCHline)
                set(this.hCHline,'DisplayName',val);
            end
            this.DisplayName = val;
        end
    end
    
    %% X Y set methods
    methods
        function set.X(this,val)
            assert(isnumeric(val),'X must be numeric');
            val = reshape(val,[],1); %make col array
            
            assert(all(diff(val)>0),'all X values must be asscending and distinct');
            
            this.X = val;
            
            if numel(this.X)==numel(this.Y)
                this.X_ = this.X;
                this.Y_ = this.Y;
                
                this.UpdatePlot();
            end
            
        end
        
        function set.Y(this,val)
            assert(isnumeric(val),'Y must be numeric');
            val = reshape(val,[],1); %make col array
            
            this.Y = val;
            
            if numel(this.Y)==numel(this.X)
                this.X_ = this.X;
                this.Y_ = this.Y;
                
                this.UpdatePlot();
            end
            
        end
    end
    
    methods (Access=protected)
        function UpdatePlot(this)
            this.chpp = pchip(this.X_,this.Y_);
            
            
            %% update visible line
            xx = [];
            for n=1:numel(this.X_)-1
                xx = [xx,linspace(this.X_(n),this.X_(n+1),200)'];
            end
            
            yy = ppval(this.chpp,xx(:));
            yy = reshape(yy,[],numel(this.X_)-1);
            
            if isempty(this.hCHline) || ~isvalid(this.hCHline)
                this.hCHline = line(this.Parent,...
                    'XData',xx(:),'YData',yy(:),...
                    'LineStyle',this.LineStyle,...
                    'Color',this.Color,...
                    'LineWidth',this.LineWidth,...
                    'Marker','none',...
                    'MarkerSize',this.MarkerSize,...
                    'MarkerEdgeColor',this.MarkerEdgeColor,...
                    'MarkerFaceColor',this.MarkerFaceColor,...
                    'Visible','on',...
                    'Interruptible','off',...
                    'SelectionHighlight','off',...
                    'PickableParts','none',...
                    'HitTest','off');
                if ~isempty(this.DisplayName)
                    set(this.hCHline,'DisplayName',this.DisplayName);
                end
            else
                set(this.hCHline,'XData',xx(:),'YData',yy(:));
            end
            
            
            
            %% update segements
                        
            delete(this.hSegLines);
            
            this.hSegLines = gobjects(numel(this.X_)-1,1);
            for n=1:numel(this.X_)-1
                %context menus
                uMenu = uicontextmenu(this.hFig);
                uimenu(uMenu,'Label','Add Point','Callback',@(~,~) this.AddPoint(n));

                this.hSegLines(n) = line(this.Parent,...
                'XData',xx(:,n),'YData',yy(:,n),...
                'Visible','off',...
                'LineStyle','none',...
                'Color',this.Color,...
                'LineWidth',this.LineWidth,...
                'Marker',this.Marker,...
                'MarkerSize',this.MarkerSize,...
                'MarkerEdgeColor',this.MarkerEdgeColor,...
                'MarkerFaceColor',this.MarkerFaceColor,...
                'Interruptible','off',...
                'SelectionHighlight','off',...
                'PickableParts','all',...
                'UIContextMenu',uMenu,...
                'DisplayName','',...
                'HitTest','on');
            end
            
            %% update pts
            delete(this.hPts);
            this.hPts = gobjects(numel(this.X_),1);
            for n=1:numel(this.X_)
                uMenu = uicontextmenu(this.hFig);
                uimenu(uMenu,'Label','Delete Point','Callback',@(~,~) this.DeletePoint(n));
                
                this.hPts(n) = ...
                    line(this.Parent,...
                    'XData',this.X_(n),'YData',this.Y_(n),...
                    'Visible','on',...
                    'LineStyle','none',...
                    'Color',this.Color,...
                    'LineWidth',this.LineWidth,...
                    'Marker',this.Marker,...
                    'MarkerSize',this.MarkerSize,...
                    'MarkerEdgeColor',this.MarkerEdgeColor,...
                    'MarkerFaceColor',this.MarkerFaceColor,...
                    'Interruptible','off',...
                    'SelectionHighlight','off',...
                    'PickableParts','visible',...
                    'HitTest','on',...
                    'UIContextMenu',uMenu,...
                    'DisplayName','',...
                    'ButtonDownFcn',@(h,e) this.MovePoint(n,h,e));
            end
            
            %% Update Interactive
            this.UpdateInteractive();
            
        end
        
        function UpdateInteractive(this)
            if ~this.Interactive
                if ~isempty(this.hPts)
                    set(this.hPts,'Visible','off','PickableParts','none','HitTest','off');
                end
                
                if ~isempty(this.hSegLines)
                    set(this.hSegLines,'PickableParts','none','HitTest','off');
                end
            else
                if ~isempty(this.hPts)
                    set(this.hPts,'Visible','on','PickableParts','visible','HitTest','on');
                end
                
                if ~isempty(this.hSegLines)
                    set(this.hSegLines,'PickableParts','all','HitTest','on');
                end
            end
        end
    end
    
    %% Callbacks
    methods (Hidden)
        function AddPoint(this,segID)
            this.CLICK_ON = true;
            this.editX_ = this.X_;
            this.editY_ = this.Y_;
            
            this.editX_ = [this.editX_(1:segID); (this.editX_(segID) + this.editX_(segID+1))/2; this.editX_(segID+1:end)];
            this.editY_ = [this.editY_(1:segID); (this.editY_(segID) + this.editY_(segID+1))/2; this.editY_(segID+1:end)];
            
            %create edit line
            this.editLine = line(this.Parent,...
                    'XData',NaN,'YData',NaN,...
                    'LineStyle','--',...
                    'Color',this.Color,...
                    'LineWidth',this.LineWidth,...
                    'Marker','none',...
                    'Interruptible','off',...
                    'SelectionHighlight','off',...
                    'PickableParts','none',...
                    'DisplayName','',...
                    'HitTest','off');
            %setup move callbacks  
            hFig = ancestor(this.Parent,'figure');
            this.orig_MouseMove = get(hFig,'WindowButtonMotionFcn');
            this.orig_MouseUp = get(hFig,'WindowButtonUpFcn');
            set(hFig,'WindowButtonUpFcn',@(h,e) this.MouseUp(h,e,segID+1),'WindowButtonMotionFcn',@(h,e) this.MouseMove(h,e,segID+1));
        end
        
        function DeletePoint(this,pointID)
            X_ = this.X_;
            Y_ = this.Y_;
            X_(pointID) = [];
            Y_(pointID) = [];
            
            this.X = X_;
            this.Y = Y_; %triggers UpdatPlot
            
            %% fire callbacks
            notify(this,'ChangedByUI');
            hgfeval(this.UIeditCallback,this,struct('Event','UIEditDone'));
        end
        
        function MovePoint(this,pointID,hObj,evt)
            if evt.Button==1
                this.CLICK_ON = true;
                this.editX_ = this.X_;
                this.editY_ = this.Y_;
               
                this.editLine = line(this.Parent,...
                    'XData',NaN,'YData',NaN,...
                    'LineStyle','--',...
                    'Color',this.Color,...
                    'LineWidth',this.LineWidth,...
                    'Marker','none',...
                    'Interruptible','off',...
                    'SelectionHighlight','off',...
                    'PickableParts','none',...
                    'DisplayName','',...
                    'HitTest','off');
                
                hFig = ancestor(this.Parent,'figure');
                this.orig_MouseMove = get(hFig,'WindowButtonMotionFcn');
                this.orig_MouseUp = get(hFig,'WindowButtonUpFcn');
                set(hFig,'WindowButtonUpFcn',@(h,e) this.MouseUp(h,e,pointID),'WindowButtonMotionFcn',@(h,e) this.MouseMove(h,e,pointID));
            end
        end
        
        function MouseUp(this,h,e,pointID)
            
            %% cleanup
            delete(this.editLine);
            
            this.CLICK_ON = false;
            hFig = ancestor(this.Parent,'figure');
            set(hFig,'WindowButtonMotionFcn',this.orig_MouseMove);
            set(hFig,'WindowButtonUpFcn',this.orig_MouseUp);
            
            
            
            this.X = this.editX_;
            this.Y = this.editY_; %Triggers UpdatePlot
            
            %% fire callbacks
            notify(this,'ChangedByUI');
            hgfeval(this.UIeditCallback,this,struct('Event','UIEditDone'));
            
        end
        
        function MouseMove(this,h,e,pointID)
            if this.CLICK_ON
                pt = get(this.Parent, 'CurrentPoint');
                this.editX_(pointID) = pt(1,1);
                this.editY_(pointID) = pt(1,2);
                
                if pointID>1
                    this.editX_(pointID) = max(this.editX_(pointID-1)+eps,this.editX_(pointID));
                end
                
                if pointID<numel(this.editX_)
                    this.editX_(pointID) = min(this.editX_(pointID),this.editX_(pointID+1)-eps);
                end
                try
                    echpp = pchip(this.editX_,this.editY_);

                    xx = [];
                    for n = max(1,pointID-1): min(numel(this.editX_)-1,pointID+1)
                        xx = [xx,linspace(this.editX_(n),this.editX_(n+1),200)'];
                    end
                    yy = ppval(echpp,xx(:));

                    try
                    set(this.editLine,'XData',xx(:),'YData',yy(:));
                    catch
                    end
                catch
                end
            end
        end
    end
end