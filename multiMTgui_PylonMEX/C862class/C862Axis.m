classdef C862Axis < handle
    properties (Access = {?C862class, ?C862Axis})
        hC862 = [];
        AxisID = [];
    end
    properties (SetAccess = private)
        AxisType = '';
        IsRotary = false;
        HasLimitSwitch = false;
        initialized = false;
        referenced = false;
        Acceleration = 1;
        Deceleration = 1;
        Velocity = 0;
        Limits = [];
        Position = 0;
        TargetPosition = 0;
        MotorScale = 1; %steps/unit
        units = '';
    end
    methods (Access = {?C862class, ?C862Axis})
        function ax = C862Axis(hC862class, AxNum)
            if nargin ==0
                %return an un-set object
                return;
            end
            ax.hC862 = hC862class;
            ax.AxisID = AxNum;
        end
    end
    methods
        function ActivateBoard(ax)
            str=[1,sprintf('%0.0fxx',ax.AxisID)];
            fprintf(ax.hC862.scom,str); %set address
            fprintf(ax.hC862.scom,'TB'); %double check it actually changed
            t1=tic;
            while ax.hC862.scom.BytesAvailable<=0
                if toc(t1)>2
                    disp('time out. did not get a response in < 2s');
                    break;
                end
            end
            if ax.hC862.scom.BytesAvailable>0
                resp = fgetl(ax.hC862.scom);
                b = sscanf(resp,'B:%d');
                if b~=ax.AxisID
                    error('could not change Mercury controller address to %d',ax.AxisID);
                end
            else
                error('did not find Mercury controller: %d',ax.AxisID);
            end
        end
        function setAxisType(ax,AxType)
            switch upper(AxType)
                case 'M-126.PD2'
                    ax.IsRotary = false;
                    ax.MotorScale = 200000/20.0; %steps/mm
                    ax.units = 'mm';
                    ax.Limits = [0,20];
                    ax.AxisType = 'M-126.PD2';
                    ax.HasLimitSwitch = true;
                case 'M-126.PD'
                    ax.IsRotary = false;
                    ax.MotorScale = 200000/20.0; %steps/mm
                    ax.units = 'mm';
                    ax.Limits = [0,25];
                    ax.AxisType = 'M-126.PD';
                    ax.HasLimitSwitch = true;
                case 'C-150.PD'
                    ax.IsRotary = true;
                    ax.MotorScale = 4000/360; %steps/degree
                    ax.units = 'degrees';
                    ax.Limits = [-Inf,Inf];
                    ax.AxisType = 'C-150.PD';
                    ax.HasLimitSwitch = false;
                otherwise
                    ax.IsRotary = false;
                    ax.MotorScale = 1;
                    ax.units = 'steps';
                    ax.Limits = [-Inf,Inf];
                    ax.AxisType = AxType;
                    ax.HasLimitSwitch = true;
            end
        end
        function val = get.AxisType(ax)
            val = ax.AxisType;
        end
        function ret = Reference(ax)
            
            ret = true;
            ax.ActivateBoard();
            if ax.HasLimitSwitch
                fprintf(ax.hC862.scom,'FE1');
                pause(1);
                fprintf(ax.hC862.scom,'MR%0.0f\n',1*ax.MotorScale);
                pause(1);
                fprintf(ax.hC862.scom,'FE3');
            end
            disp("SCUBA:");
            ax.WaitForOnTarget();
            disp("ASD:");
            fprintf(ax.hC862.scom,'DH');
            fprintf(ax.hC862.scom,'MR%0.0f\n',20*ax.MotorScale);
            disp("BOOP:");
        end
        function ret = RunCMD(ax,CMDstr)
            ax.ActivateBoard();
            fprintf(ax.hC862.scom,CMDstr);
            ret = true;
        end
        function ret = setAcceleration(ax,acc)
            ax.ActivateBoard(); %change address to this board
            fprintf(ax.hC862.scom,'SA%0.0f\n',acc*ax.MotorScale);
            ax.Acceleration = acc;
            ret = true;
        end
        function ret = setDeceleration(ax,dec)
            ret = true;
            %do nothing there is no decel on mercury
        end
        function ret = setVelocity(ax,vel)
            ax.ActivateBoard(); %change address to this board
            fprintf(ax.hC862.scom,'SV%0.0f\n',vel*ax.MotorScale);
            ax.Velocity = vel;
            ret = true;
        end
        function val = get.Position(ax)
            ax.ActivateBoard();
            fprintf(ax.hC862.scom,'TP');
            t1=tic;
            while ax.hC862.scom.BytesAvailable<=0
                if toc(t1)>2
                    disp('time out. did not get a response in < 2s');
                    break;
                end
            end
            if ax.hC862.scom.BytesAvailable>0
                resp = fgetl(ax.hC862.scom);
                p = sscanf(resp,'P:%d');
                ax.Position = p/ax.MotorScale;
            end
            val = ax.Position;
        end
        function ret = setPosition(ax,val)
            ax.ActivateBoard(); %change address to this board
            val = min(val,ax.Limits(2));
            val = max(val,ax.Limits(1));
            fprintf(ax.hC862.scom,'MA%0.0f\n',val*ax.MotorScale);
            ax.TargetPosition = val;
            ret = true;
        end
        function ret = getOnTargetState(ax)
            fprintf(ax.hC862.scom,'TS');
            t1=tic;
            while ax.hC862.scom.BytesAvailable<=0
                if toc(t1)>2
                    error('Mercury Controler %d did not respond to request',ax.AxisID);
                end
            end
            resp = fgetl(ax.hC862.scom);
            if ~strncmpi(resp,'S:',2)
                warning('incorrect response');
                ret = NaN;
                return;
            end
            ret = logical(bitand(4,hex2dec(resp(4)))); %check bit 3 of first field of status vector true=in position
        end
        function val = getTargetPosition(ax)
            ax.ActivateBoard();
            fprintf(ax.hC862.scom,'TT');
            t1=tic;
            while ax.hC862.scom.BytesAvailable<=0
                if toc(t1)>2
                    disp('time out. did not get a response in < 2s');
                    break;
                end
            end
            if ax.hC862.scom.BytesAvailable>0
                resp = fgetl(ax.hC862.scom);
                p = sscanf(resp,'T:%d');
                ax.TargetPosition = p/ax.MotorScale;
            end
            val = ax.TargetPosition;
        end
        function WaitForOnTarget(ax)
            ax.ActivateBoard();
            done = false;
            while ~done
                fprintf(ax.hC862.scom,'TS');
                t1=tic;
                while ax.hC862.scom.BytesAvailable<=0
                    if toc(t1)>2
                        error('Mercury Controler %d did not respond to request',ax.AxisID);
                    end
                end
                resp = fgetl(ax.hC862.scom);
                if ~strncmpi(resp,'S:',2)
                    warning('incorrect response');
                    continue;
                end
                if logical(bitand(4,hex2dec(resp(4)))) %check bit 3 of first field of status vector true=in position
                    done = true;
                end
            end
        end
        function StopMotor(ax)
            ax.ActivateBoard();
            fprintf(ax.hC862.scom,'AB');
        end  
    end
end