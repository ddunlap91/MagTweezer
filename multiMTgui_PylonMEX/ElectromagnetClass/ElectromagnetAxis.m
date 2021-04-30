classdef ElectromagnetAxis < handle
    properties (Access = private)
        Limits = [];
        Velocity = 0;
        Ang_Velocity = 0;
        Current = 0;
        Turns = 0;
        Step_Duration = 0;
        Num_Voltages = 0;
        Num_Turns = 0;
        AxType = '';
    end
    
    methods (Access = public)
        function this=ElectromagnetAxis(ax_id) % constructor
            this.setAxisType(ax_id);
        end
        function setAxisType(this, ax_id) %set object to correspond to B field strength or orientation
            if ax_id == 1
                this.AxType = 'r';
                this.Limits = [-inf, inf];
            elseif ax_id == 2
                this.AxType = 'z';
                this.Limits = [-255, 255];
            end
        end
%%        function setAcceleration(varargin)
%%            disp("SET ACCLERATION CALLED");
%            disp(varargin);
%        end
%        function setDeceleration(varargin)
%            disp("SET DECELERATION CALLED");
%            disp(varargin);
%        end
%        function Reference(varargin)
%            disp("REFERENCE CALLED");
%            disp(varargin);
%        end
%        function setVelocity(varargin)
%            disp("SET VELOCITY CALLED");
%            disp(varargin);
%        end
%        function setPosition(this,val)
%            disp("set position has been called");
%            disp(varargin);
%        end
        function WaitForOnTarget(this, hMain) %used to approximate speed
            handles = guidata(hMain);
            target = this.TargetPosition(hMain);
            if this.AxType == 'r'
                current = handles.TM.Turns;
                while abs(target - current)>= 1e-5 %vals are sufficiently close
                    current = handles.TM.Turns;
                    pause(handles.TC.StepPeriod);
                end
            
            elseif this.AxType == 'z' %current already discretized to smallest possible unit
                pause(this.Step_Duration);
            end
        end
        
        %setters
        function SetVelocity(this, val)
            if this.AxType == 'r'
                this.Ang_Velocity = val;
            elseif this.AxType == 'z' 
                this.Velocity = val;
            end
        end
       
        function SetCurrent(this, val, hMain) 
            handles = guidata(hMain);
            current = max(this.Limits(1), min(val, this.Limits(2))); %ensure valid current
            handles.MC.Controller.Target = [current, current]; 
            this.Current = current;
            pause(this.Step_Duration);
             
        end
        function SetTurn(this, hMain, turn)
            handles = guidata(hMain);
            handles.TC.TargetTurns = turn;
            this.Turns = turn;
            if ~handles.TC.Running %start TurnController timer
                handles.TC.start();
            else
                return;
            end
                
        end
        %getters
        function target=TargetPosition(this, hMain) %get target value
            handles = guidata(hMain);
            if this.AxType == 'r'
                target = handles.TC.TargetTurns;
            elseif this.AxType == 'z'
                target = handles.MC.Controller.Target;
            end
        end
        function current = getCurrent(this)
            current = this.Current;
        end
        function turn = getTurns(this)
            turn = this.Turns;
        end
        function velocity = getVelocity(this)
            if strcmpi(this.AxType, 'r')
                velocity = this.Ang_Velocity;
      
            elseif strcmpi(this.AxType, 'z')
                velocity = this.Velocity;
            end
        end
    end
    methods (Access = public)
        function Step_Duration = CalculateStepDuration(this, varargin) 
            %discretize current/turn to smallest possible value and
            %calculate time per step
                                                                               
            hMain = varargin{1};
            handles = guidata(hMain);
            if strcmp(this.AxType, 'r')
                Step_Duration = (abs(handles.CC_Start - handles.CC_End) / handles.CC_Step) / handles.CC_Turn_Speed;
                this.Step_Duration = Step_Duration;
            elseif strcmp(this.AxType, 'z')
                speed = handles.FE_EM_Speed;
                start = varargin{2};
                stop = varargin{4};
                step = varargin{3};
                this.Num_Voltages = abs((start - stop) / step);
                total_duration = this.Num_Voltages / speed;
                this.Step_Duration=total_duration / this.Num_Voltages;
                disp(this.Step_Duration);
                if step > 1
                    Step_Duration = this.Step_Duration / step;
                    this.Step_Duration = Step_Duration;
                end
            end
        end
            
    end
end
