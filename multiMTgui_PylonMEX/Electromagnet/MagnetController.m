classdef MagnetController < extras.GraphicsChild
    properties (SetAccess=protected)
        Controller
        ControlUI
        UIray
        
        RadiusEdit
        AngleEdit
        
        AmplitudeLimits = [0,255];
    end
    properties (SetObservable=true)
        Angle = 0
        Amplitude = 0;
    end
    
    properties(Access=protected)
        OuterHBox
        
        
        ValueChangedListener
        InValUpdater = false; %flag to prevent value updated from changing the controler target when it updates internally
        InUICallback = false;
    end
    
    methods
        function this = MagnetController(varargin)
            % Syntax
            %   MagnetController(COMPORT)
            %   MagnetControler(Parent,COMPORT)
            %   MagnetController(COMPORT,'Parent',Parent)
            
            %% Setup Graphics
            this@extras.GraphicsChild(@(~,~) ...
                figure('Name','MagnetController',...
                'menubar','none',...
                'NumberTitle','off'));
            %look for parent specified in arguments
            varargin = this.CheckParentInput(varargin{:});
            
            %% Com Port

            persistent LastCOM;
            if isempty(LastCOM)
                LastCOM = '';
            end
            if numel(varargin)<1
                answer = {-1};
                while ~ischar(answer{1})
                    answer = inputdlg('COM Port (e.g. COM5)','COM Port',1,{LastCOM});
                    if isempty(answer)
                        if this.CreatedParent
                            delete(this.Parent);
                        end
                        error('No COM Port specified');
                    end
                end
                COMPORT = answer{1};
            else
                assert(ischar(varargin{1}),'Com port must be specified by a char array');
                COMPORT = varargin{1};
            end
                
                
            this.Controller = VNH_Controller(COMPORT);
            
            LastCOM = COMPORT;
            
            %% GUIS
            
            this.OuterHBox = uix.HBox('Parent',this.Parent);
            
            this.ControlUI = extras.hardware.TargetValueDeviceUI(this.OuterHBox,this.Controller);
            
            this.Controller.Target = [0,0];
            
            this.ValueChangedListener = addlistener(this.Controller,'Value','PostSet',@(~,~) this.UpdateFromControls);
            
            
            %% Create UIray controller
            vb = uix.VBox('Parent',this.OuterHBox);
            hb = uix.HBox('Parent',vb);
            uicontrol('Parent',hb,...
                'Style','text',...
                'String','Strength','HorizontalAlignment','right');
            this.RadiusEdit = uicontrol('Parent',hb,...
                'Style','Edit',...
                'String','0',...
                'Callback',@(~,~) this.RadiusEditCalllback,...
                'TooltipString','Strength of magnetic Field (0-255)');
            uicontrol('Parent',hb,...
                'Style','text',...
                'String','Angle','HorizontalAlignment','right');
            this.AngleEdit = uicontrol('Parent',hb,...
                'Style','Edit',...
                'String','0',...
                'Callback',@(~,~) this.AngleEditCalllback,...
                'TooltipString','Angle of field, in degrees');
            hb.Widths = [60,-1,60,-1];
            
            
            
            this.UIray = extras.uiray(vb,'RadiusLim',this.AmplitudeLimits);
            this.UIray.UIeditCallback = @(~,~) this.UpdateFromUIray;
            %set(hFig,'CloseRequestFcn',@(~,~) disp('Cannot close angle display. Delete MagnetConroller object to close'));
            
            try
                set(this.UIray.Parent,'LooseInset',get(this.UIray.Parent,'TightInset'));
            catch
            end
            
            vb.Heights = [40,-1];
            
            this.OuterHBox.Widths=[155,-1];
            
            
        end
        
        function delete(this)
            delete(this.ValueChangedListener);
            
            this.Controller.Target=[0,0];
            pause(0.4);
            
            delete(this.UIray);
            delete(this.ControlUI);
            
            delete(this.OuterHBox);
            delete(this.Controller);
            
        end
    end
    methods (Access=protected)
        function SetControllerValues(this)
            if ~this.InValUpdater
                if this.Amplitude==0
                    this.Controller.Target = [0,0];
                else
                    x = this.Amplitude*cos(this.Angle-pi/4);
                    y = -this.Amplitude*sin(this.Angle-pi/4);

                    this.Controller.Target = [x,y];
                end
            end
        end
    end
    
    methods(Hidden)
        
        function RadiusEditCalllback(this)
            this.InUICallback = true;
            val = str2double(this.RadiusEdit.String);
            val = max(this.AmplitudeLimits(1),min(abs(val),this.AmplitudeLimits(2)));
            this.Amplitude = val;
            this.InUICallback = false;
        end
        
        function AngleEditCalllback(this)
            this.InUICallback = true;
            val = str2double(this.AngleEdit.String);
            val = mod(val*pi/180,2*pi);
            this.Angle = val;
            this.InUICallback = false;
        end
        
        function UpdateFromUIray(this)
            this.InUICallback = true;
            this.InValUpdater = true;
            
            this.Amplitude = this.UIray.Radius;
            this.Angle = this.UIray.Angle;
            this.InValUpdater = false;
            
            this.SetControllerValues();
            
            this.InUICallback = false;
            
        end
        function UpdateFromControls(this)
            if this.InUICallback
                return
            end
           
            this.InValUpdater = true;
            xy = this.Controller.Value;
            x = xy(1);
            y = xy(2);
            %a = sqrt(x^2+y^2)
            this.Amplitude = sqrt(x^2+y^2);
            if this.Amplitude >0
                this.Angle = mod(atan2(-y,x)+pi/4,2*pi);
            end
            this.InValUpdater = false;
        end
    end
    
    methods
        
        function set.Angle(this,val)
            assert(isscalar(val)&&isnumeric(val),'Value must be numeric scalar');
            this.Angle=round(mod(val,2*pi),4);
            
            this.UIray.Angle = this.Angle;
            
            this.AngleEdit.String = num2str(round(val*180/pi,3));
            
            this.SetControllerValues();
        end
        
        function set.Amplitude(this,val)
            assert(isscalar(val)&&isnumeric(val),'Value must be numeric scalar');
            this.Amplitude = max(this.AmplitudeLimits(1),min(abs(val),this.AmplitudeLimits(2)));
            
            this.UIray.Radius = this.Amplitude;
            
            this.RadiusEdit.String = num2str(val);
            
            this.SetControllerValues();
        end
    end
end