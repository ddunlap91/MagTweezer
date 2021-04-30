% Dan Korari/updated Joshua Mendez

classdef TurnController < matlab.mixin.SetGet
    
    properties(SetAccess=protected)
        MagnetController
        TurnMonitor
    end
    
    properties(SetAccess=protected,SetObservable=true,AbortSet=true)
        Running = false;
    end
    
    properties (SetObservable=true,AbortSet=true)
        StepSize = 0.1; %FractionalSetp
        StepPeriod = 0.25; %time between steps
        TargetTurns=0;
    end
    
    properties(Access=protected)
        DeleteListener
        TurnListener
        
        StepTimer = timer;
    end
    
    %% Create/Delete
    methods
        function this = TurnController(MC,TM)
            this.MagnetController = MC;
            this.TurnMonitor = TM;
            this.DeleteListener = addlistener(MC,'ObjectBeingDestroyed',@(~,~) delete(this));
            
            this.TargetTurns = this.TurnMonitor.Turns;
            
            this.TurnListener = addlistener(this.TurnMonitor,'Turns','PostSet',@(~,~) this.TurnsCallback());
            
            %finish setting up timer
            delete(this.StepTimer);
            this.StepTimer = timer('BusyMode','queue',...
                'ExecutionMode','fixedSpacing',...
                'ObjectVisibility','off',...
                'Period',this.StepPeriod,...
                'TimerFcn',@(~,~) this.TimerCallback);
        end
        
        function delete(this)
            
            stop(this.StepTimer);
            delete(this.StepTimer);
            delete(this.TurnListener)
            delete(this.DeleteListener);
        end
    end
    
    %% Other Functions
    methods
        function start(this)
            this.Running = true;
            start(this.StepTimer);
        end
        function stop(this)
            stop(this.StepTimer);
            this.Running = false;
        end
    end
    
    %% Set Methods
    methods
        function set.StepSize(this,val)
            assert(isscalar(val)&&~isnan(val),'StepSize must be non-nan scalar number');
            this.StepSize = max(0,min(abs(val),0.5));
        end
        
        
        function set.TargetTurns(this,val)
            assert(isscalar(val)&&~isnan(val),'TargetTurns must be non-nan scalar number');
            this.TargetTurns = val;
        end
        
        function set.StepPeriod(this,val)
            assert(isscalar(val)&&~isnan(val)&&val>0,'StepPeriod must be greater than zero');
            this.StepPeriod = val;
            this.StepTimer.Period = val;
        end
    end
    
    %% Callbacks
    methods (Hidden)
        function TimerCallback(this)
            if ~isvalid(this)
                return;
            end
            
            if ~this.Running
                stop(this.StepTimer)
                return;
            end
            
            if abs(this.TargetTurns - this.TurnMonitor.Turns)<= 1e-5
                stop(this.StepTimer);
                this.Running = false;
                return;
            end
            
            if this.TargetTurns > this.TurnMonitor.Turns
                dT = min(this.StepSize,this.TargetTurns-this.TurnMonitor.Turns);
                dA = dT*2*pi;
                this.MagnetController.Angle = this.MagnetController.Angle + dA;
            else
                dT = max(-this.StepSize,this.TargetTurns-this.TurnMonitor.Turns);
                dA = dT*2*pi;
                this.MagnetController.Angle = this.MagnetController.Angle + dA;
            end
        end
        function TurnsCallback(this)
            if this.TargetTurns == this.TurnMonitor.Turns
                stop(this.StepTimer);
                this.Running = false;
                return;
            end
        end
    end
    
end