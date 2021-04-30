classdef C843Axis < handle
    properties (Access = {?C843class, ?C843Axis})
        hC843 = [];
        AxisID = '';
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
    end
    methods (Access = {?C843class, ?C843Axis})
        function ax = C843Axis(hC843class, AxChar)
            if nargin ==0
                %return an un-set object
                return;
            end
            ax.hC843 = hC843class;
            ax.AxisID = AxChar;
        end
    end
    methods
        function setAxisType(ax,AxType)
            if ~isa(ax.hC843,'C843class')
                return;
            end
            [stat,~,typ] = calllib(ax.hC843.lib,'C843_CST',ax.hC843.ID_c843,ax.AxisID,AxType);
            if ~stat
                warning('Could not set Axis: %s to "%s". Check card connections, and make sure the drivers for the %s have been installed (see PI help files).',ax.AxisID,AxType,AxType);
                ax.AxisType = typ;
                return
            end
            ax.AxisType = AxType;
            
            %intitalize the axis
            ret = calllib(ax.hC843.lib, 'C843_INI',ax.hC843.ID_c843,ax.AxisID); %try to initialize motor
            if ret~=1
                warning('Could not initialize channel %c',ax.AxisID);
                ax.initialized = false;
                return;
            else
                ax.initialized = true;
            end
            
            %check if it is rotary
            [~,~,~,val] = calllib(ax.hC843.lib,'C843_qSPA',ax.hC843.ID_c843,ax.AxisID,19,0,'',0);
            ax.IsRotary = logical(val);
            %check if it has limit switches
            [~,~,val] = calllib(ax.hC843.lib,'C843_qLIM',ax.hC843.ID_c843,ax.AxisID,0);
            ax.HasLimitSwitch = logical(val);
            
            if ax.IsRotary&&~ax.HasLimitSwitch
                %assume cts rotation is allowed, ie inf limits
                ax.Limits = [-Inf,Inf];
                %set position to zero
                [~,~,val] = calllib(ax.hC843.lib,'C843_POS',ax.hC843.ID_c843,ax.AxisID,0);
                ax.Position = val;
                ax.TargetPosition = val;
            else
                %get limits
                [~,~,lowlim] = calllib(ax.hC843.lib, 'C843_qTMN',ax.hC843.ID_c843,ax.AxisID,0);
                [~,~,hilim] = calllib(ax.hC843.lib, 'C843_qTMX',ax.hC843.ID_c843,ax.AxisID,0);
                ax.Limits = [lowlim,hilim];
                
                %the stage has limits, so it probably needs to be
                %referenced
                ax.Reference();
            end
            
            %get velocity
            [~,~,val] = calllib(ax.hC843.lib, 'C843_qVEL',ax.hC843.ID_c843,ax.AxisID,0);
            ax.Velocity = val;
            
            %get acceleration
            [~,~,~,val] = calllib(ax.hC843.lib,'C843_qSPA',ax.hC843.ID_c843,ax.AxisID,11,0,'',0);
            ax.Acceleration = val;
            
            %get deceleration
            [~,~,~,val] = calllib(ax.hC843.lib,'C843_qSPA',ax.hC843.ID_c843,ax.AxisID,12,0,'',0);
            ax.Deceleration = val;
            
            %get position
            [~,~,val] = calllib(ax.hC843.lib,'C843_qPOS',ax.hC843.ID_c843,ax.AxisID,0);
            ax.Position = val;
            ax.TargetPosition = val;
            
        end
        function val = get.AxisType(ax)
            [stat,~,typ] = calllib(ax.hC843.lib,'C843_qCST',ax.hC843.ID_c843,ax.AxisID,'',1024);
            if ~stat
                warning('Could not execute C843_qCST. Using old value.');
                val = ax.AxisType;
                return;
            end
            ax.AxisType = typ;
            val = typ;
        end
        function ret = Reference(ax)
            if ax.IsRotary&&~ax.HasLimitSwitch
                %set position to zero
                [ret,~,val] = calllib(ax.hC843.lib,'C843_POS',ax.hC843.ID_c843,ax.AxisID,0);
                ax.Position = val;
                ax.TargetPosition = val;
                return;
            end
            %reference the axis
            ret = calllib(ax.hC843.lib, 'C843_REF',ax.hC843.ID_c843,ax.AxisID); %try to refernce linear motor
            if ret~=1
                warning('Could not reference %s on channel %c',ax.AxisType,ax.AxisID);
                return;
            end
            %wait for reference to finish
            disp('Waiting for reference to finish...')
            refstat = 0;
            [~,~,refstat] = calllib(ax.hC843.lib, 'C843_IsReferencing',ax.hC843.ID_c843,ax.AxisID,refstat); %get current status
            while any(refstat)
                pause(0.01);
                [~,~,refstat] = calllib(ax.hC843.lib, 'C843_IsReferencing',ax.hC843.ID_c843,ax.AxisID,refstat); %get current status
            end
            disp('Finished referencing.');
            ax.referenced = true;
        end
        function [ret,varargout] = RunCMD(ax,CMDstr,varargin)
            %run the c++ command from the C843_DLL library
            %CMDstr(ID_c843,AxisID,varargin{1},varargin{2},...,varargin{end})
            %output is consistent with calllib() syntax
            %Example
            % [ret,~,str] = MyAxis.RunCMD('C843_qCST','',1024);
            %will run
            %[ret,~,str]=calllib(MyAxis.hC843.lib,'C843_qCST',MyAxis.hC843.ID_c843,MyAxis.AxisID,'',1024);
            
            varargout = cell(1,nargout-1);
            [ret,varargout{:}] = calllib(ax.hC843.lib,CMDstr,ax.hC843.ID_c843,ax.AxisID,varargin{:});
        end
        function ret = setAcceleration(ax,acc)
            ret = calllib(ax.hC843.lib, 'C843_SPA',ax.hC843.ID_c843,ax.AxisID,11,acc,''); %max accel
            if ~ret
                warning('Could not set Acceleration');
            end
            ax.Acceleration = acc;
        end
        function ret = setDeceleration(ax,dec)
            ret = calllib(ax.hC843.lib, 'C843_SPA',ax.hC843.ID_c843,ax.AxisID,12,dec,''); %max accel
            if ~ret
                warning('Could not set Deceleration');
                return;
            end
            ax.Deceleration = dec;
        end
        function ret = setVelocity(ax,vel)
            ret = calllib(ax.hC843.lib, 'C843_VEL',ax.hC843.ID_c843,ax.AxisID,vel);
            if ~ret
                warning('Could not set velocity');
                return;
            end
            ax.Velocity = vel;
        end
        function val = get.Position(ax)
            [ret,~,val] = calllib(ax.hC843.lib, 'C843_qPOS',ax.hC843.ID_c843,ax.AxisID,0);
            if ~ret
                warning('Could not get position of axis. using old value');
                val = ax.Position;
                return
            end
            ax.Position = val;
        end
        function ret = setPosition(ax,val)
            ret = calllib(ax.hC843.lib, 'C843_MOV',ax.hC843.ID_c843,ax.AxisID,val);
            if ~ret
                warning('could not set axis position');
                return;
            end
            ax.TargetPosition = val;
        end
        function ret = getOnTargetState(ax)
            [status,~,ret] = calllib(ax.hC843.lib, 'C843_qONT',ax.hC843.ID_c843,ax.AxisID,0);
            if ~status
                warning('could not get updated C843 OnTargetStatus');
                ret = NaN;
            end
        end
        function WaitForOnTarget(ax)
            ont = false;
            while(~ont)
                ont=ax.getOnTargetState();
                if isnan(ont)
                    return;
                end
                pause(0.01);
            end
        end
    end
end