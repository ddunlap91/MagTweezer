classdef E816Axis < handle
    properties (Access = {?E816class,?E816Axis})
        hE816 = [];
        AxisID = '';
    end
    properties (SetAccess = private)
        TargetPosition = 0;
        Position = 0;
        Limits = [0,100];        
    end
    methods (Access = {?E816class,?E816Axis});
        function ax = E816Axis(hE816class,AxChar)
            if nargin ==0
                return;
            end
            ax.hE816 = hE816class;
            ax.AxisID = AxChar;
            
            %servo on
            calllib(ax.hE816.lib,'E816_SVO',ax.hE816.ID_e816,ax.AxisID,true);
        end
    end
    methods
        function status = setPosition(ax,val)
            val = min(val,ax.Limits(2));
            val = max(val,ax.Limits(1));
            ax.TargetPosition = val;
            %servo on
            status = calllib(ax.hE816.lib,'E816_MOV',ax.hE816.ID_e816,ax.AxisID,val);
            if ~status
                warning('Could not set E816 to target position');
            end
        end
        function val = get.Position(ax)
            [status,~,val] = calllib(ax.hE816.lib,'E816_qPOS',ax.hE816.ID_e816,ax.AxisID,0);
            if ~status
                warning('could not get updated E816 position');
                val = ax.Position;
            end
            ax.Position = val;
        end
        function ret = getOnTargetState(ax)
            [status,~,ret] = calllib(ax.hE816.lib,'E816_qONT',ax.hE816.ID_e816,ax.AxisID,0);
            if ~status
                warning('could not get updated E816 OnTargetStatus');
                ret = NaN;
            end
        end
        function WaitForOnTarget(ax)
            ont = false;
            t=tic;
            while(~ont)
                if toc(t)>3 %time out after 3 sec
                    return;
                end
                ont=ax.getOnTargetState();
                if isnan(ont)
                    return;
                end
                pause(0.01);
            end
        end
    end
end