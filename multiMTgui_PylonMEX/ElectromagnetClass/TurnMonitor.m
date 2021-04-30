classdef TurnMonitor < handle
    
    properties (Access=protected)
        Controller
        
        AngleListener
        DeleteListener
        
        LastAngle
    end
    
    properties (SetObservable=true,SetAccess=protected,AbortSet=true)
        Turns = 0;
    end
    
    %% Create/Delete
    methods 
        function this = TurnMonitor(Controller)
            %% Link to Controller
            assert(isa(Controller,'MagnetController'),'Controller must be a valid MagnetController');
            this.Controller = Controller;
            this.LastAngle = this.Controller.Angle;
            %delete Listener
            this.DeleteListener = addlistener(this.Controller,'ObjectBeingDestroyed',@(~,~) delete(this));
            
            
            %% Angle Listener
            this.AngleListener = addlistener(this.Controller,'Angle','PostSet',@(~,~) this.AngleChanged);
        end
        
        function delete(this)
            delete(this.AngleListener)
            delete(this.DeleteListener);
        end
    end
    
    %% Callbacks
    methods (Hidden)
        function AngleChanged(this)
            A = this.Controller.Angle;
            dA = diffAngle(this.LastAngle,A);
            this.Turns = this.Turns + dA/(2*pi);
            this.LastAngle = A;

        end
    end
    
    methods
        function ResetTurnCounter(this)
            this.Turns = 0;
            
        end
    end
    
end

function dA = diffAngle(Init,Final)
dA = Final-Init;
if abs(dA)>pi
    if dA > 0
        %'greater'
        dA = -(2*pi-dA);
    else
        %'less'
        dA = (2*pi+dA);
    end
end
end