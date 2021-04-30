classdef TurnControlUI < extras.GraphicsChild
    
    properties(SetAccess=protected)
        TurnController
    end
    
    properties (Access=protected)
        DeleteListener
        OuterScroll
        OuterVBox
        
        CurrentTurnsEdit
        ResetTurnsButton
        TargetTurnsEdit
        StepSizeEdit
        StepPeriodEdit
        StartStopButton
        
        TurnListener
        TargetTurnsListener
        StepSizeListener
        StepPeriodListener
        
        RunningListener
    end
    
    %% create/delete
    methods
        function this = TurnControlUI(varargin)
        % Syntax
        %   TurnControlUI(TurnCtrl)
        %   TurnControlUI(Parent,TurnCtrl);
        %   TurnControlUI(TurnCtrl,'Parent',Parent)
            
            %% Parent
            this@extras.GraphicsChild(@(~,~) ...
                figure('Name','TurnController',...
                'menubar','none',...
                'NumberTitle','off'));
            %look for parent specified in arguments
            varargin = this.CheckParentInput(varargin{:});
            
            %% Connect Turn monitor
            assert(~isempty(varargin)&&isa(varargin{1},'TurnController'),'Must specify valid TurnController');
            
            this.TurnController = varargin{1};
            
            this.DeleteListener = addlistener(this.TurnController.TurnMonitor,'ObjectBeingDestroyed',@(~,~) delete(this));
            
            %% Create GUI
            this.OuterScroll = uix.ScrollingPanel('Parent',this.Parent);
            
            this.OuterVBox = uix.VBox('Parent',this.OuterScroll);
            this.OuterScroll.MinimumHeights = 25*6+6*4;
            this.OuterVBox.Padding = 5;
            
            % Current Turns
            hb = uix.HBox('Parent',this.OuterVBox);
            uicontrol('Parent',hb,...
                'style','text',...
                'String','Current Turns',...
                'HorizontalAlignment','right');
            
            this.CurrentTurnsEdit = uicontrol('Parent',hb,...
                'style','edit',...
                'String','0',...
                'TooltipString','Current turn count',...
                'Enable','inactive');
            this.ResetTurnsButton = uicontrol('Parent',hb,...
                'style','pushbutton',...
                'String','Reset',...
                'TooltipString','Reset turn counter to zero',...
                'Callback',@(~,~) this.TurnController.TurnMonitor.ResetTurnCounter());
            
            hb.Widths = [-1,-2,50];
            
            %---------------------
            uix.Empty('parent',this.OuterVBox);
            uicontrol('Parent',this.OuterVBox,...
                'style','text',...
                'BackgroundColor',[0,0,0]);
            uix.Empty('parent',this.OuterVBox);
            
            % Target Turns
            hb = uix.HBox('Parent',this.OuterVBox);
            uicontrol('Parent',hb,...
                'style','text',...
                'String','Target Turns',...
                'HorizontalAlignment','right');
            
            this.TargetTurnsEdit = uicontrol('Parent',hb,...
                'style','edit',...
                'String',num2str(this.TurnController.TargetTurns),...
                'TooltipString','Final turn count after rotations',...
                'Enable','on',...
                'Callback',@(h,~) set(this.TurnController,'TargetTurns',str2double(h.String)));
            
            hb.Widths = [-1,-2];
            
            % StepSize
            hb = uix.HBox('Parent',this.OuterVBox);
            uicontrol('Parent',hb,...
                'style','text',...
                'String','Step Size',...
                'HorizontalAlignment','right');
            
            this.StepSizeEdit = uicontrol('Parent',hb,...
                'style','edit',...
                'String',num2str(this.TurnController.StepSize),...
                'TooltipString','Amount to rotate during each time step (in turn, max=0.5)',...
                'Enable','on',...
                'Callback',@(h,~) set(this.TurnController,'StepSize',str2double(h.String)));
            
            hb.Widths = [-1,-2];
            
            % StepPeriod
            hb = uix.HBox('Parent',this.OuterVBox);
            uicontrol('Parent',hb,...
                'style','text',...
                'String','Step Period',...
                'HorizontalAlignment','right');
            
            this.StepPeriodEdit = uicontrol('Parent',hb,...
                'style','edit',...
                'String',num2str(this.TurnController.StepPeriod),...
                'TooltipString','Amount to rotate during each time step (in turn, max=0.5)',...
                'Enable','on',...
                'Callback',@(h,~) set(this.TurnController,'StepPeriod',str2double(h.String)));
            
            hb.Widths = [-1,-2];
            
            %-----------------------
            uix.Empty('parent',this.OuterVBox);
            uicontrol('Parent',this.OuterVBox,...
                'style','text',...
                'BackgroundColor',[0,0,0]);
            uix.Empty('parent',this.OuterVBox);
            
            % Start/Stop
            this.StartStopButton = uicontrol('Parent',this.OuterVBox,...
                'Style','pushbutton',...
                'ForegroundColor',[0,0.5,0],...
                'FontSize',18,...
                'String','Start',...
                'TooltipString','Start/Stop turn stepper',...
                'Callback',@(~,~) this.startstop);
            
            this.OuterVBox.Heights = [25,3,1,3,25,25,25,3,1,3,50];
            
            %% Listeners
            this.TurnListener = addlistener(this.TurnController.TurnMonitor,'Turns','PostSet',@(~,~) set(this.CurrentTurnsEdit,'String',num2str(round(this.TurnController.TurnMonitor.Turns,3))));
            this.TargetTurnsListener = addlistener(this.TurnController,'TargetTurns','PostSet',@(~,~) set(this.TargetTurnsEdit,'String',num2str(this.TurnController.TargetTurns)));
            this.StepSizeListener = addlistener(this.TurnController,'StepSize','PostSet',@(~,~) set(this.StepSizeEdit,'String',num2str(this.TurnController.StepSize)));
            this.StepPeriodListener = addlistener(this.TurnController,'StepPeriod','PostSet',@(~,~) set(this.StepPeriodEdit,'String',num2str(this.TurnController.StepPeriod)));
            
            this.RunningListener = addlistener(this.TurnController,'Running','PostSet',@(~,~) this.RunningChanged);
            
            %% Update button state
            this.RunningChanged;
            
            %% Resize figure if created
            if this.CreatedParent
                this.ParentFigure.Units = 'pixels';
                this.ParentFigure.Position(3) = 250;
                this.ParentFigure.Position(4) = 25*6+6*4+1;
            end
            
        end
        
        function delete(this)
            delete(this.DeleteListener);
            
            delete(this.TurnListener);
            delete(this.TargetTurnsListener);
            delete(this.StepSizeListener);
            delete(this.StepPeriodListener);
            
            delete(this.RunningListener);
            
            delete(this.OuterVBox);
            delete(this.OuterScroll);
            
        end
        
    end
    
    %% Callbacks
    methods (Hidden)
        function RunningChanged(this)
            if this.TurnController.Running
                this.StartStopButton.ForegroundColor = [1,0,0];
                this.StartStopButton.String = 'Stop';
            else
                this.StartStopButton.ForegroundColor = [0,0.5,0];
                this.StartStopButton.String = 'Start';
            end
        end
            
        function startstop(this)
            if this.TurnController.Running
                this.TurnController.stop;
            else
                this.TurnController.start;
            end
        end
    end
end
