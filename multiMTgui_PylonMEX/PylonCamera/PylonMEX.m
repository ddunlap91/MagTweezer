classdef (Sealed) PylonMEX < matlab.mixin.SetGet
% Interface for Basler Pylon USB Cameras
    
    %% Class Control Properties
    properties (SetAccess=private) %class control properties
        tFrameTimer = timer();
        tDrawTimer = timer();
        fDrawTimerRate = 20;
        drawtic = [];
        
        
        imagetimeout = 5;
        
        FrameRateHistory = NaN(1,2);
        FRHidx = 1;
        
        ImageData
        clkImageTime

        bLiveModeRunning = false;
        
        fFrameCallback = [];
        fDrawCallback = [];
        fPropertyUpdateCallback = [];
        FrameCallbackDuration = NaN(5,1);
        
    end
    properties %graphic handles, user can modify these
        hfigImageFig
        haxImageAxes
        bDrawImage = true;
        himCameraImage
        hTxt_FPS
        DEBUG = false;
        
%         userdata = [];
        
%         hLine = [];
%         plotdata = true;
%         plotdataX = [];
%         plotdataY = [];
    end
    properties(Dependent)
        ResultingFrameRate;
    end
    %% Private Class Control Methods
    methods (Static)
        function obj = getInstance() %function to get or create an instance of PylonClass()
            persistent localObj
            if isempty(localObj) || ~isvalid(localObj)
                localObj = PylonMEX();
            end
            obj = localObj;
        end
    end
    methods (Access=private)
        function this = PylonMEX() %constructor
            %% Load PylonMEX
            Pylon.PylonMEX_Initialize();
            
            %% Initialize Fixed values
            this.WidthMax = Pylon.PylonMEX_GetProperty('WidthMax');
            this.HeightMax = Pylon.PylonMEX_GetProperty('HeightMax');
            
            %% Inititlize Property Structures
            %% Exposure
            this.cExposure = struct(...
                  'IsProp',true,...
                  'Type','intfIFloat',...
                  'HasLimits',true,...
                  'Limits',Pylon.PylonMEX_GetExposureLimits(),...
                  'HasFixedValues',false,...
                  'FixedValues',[],...
                  'Units','µs',...
                  'Value',Pylon.PylonMEX_GetExposure());
            %% Exposure Auto
            this.cExposureAuto = struct(...
                  'IsProp',true,...
                  'Type','intfIBoolean',...
                  'HasLimits',false,...
                  'Limits',[0,1],...
                  'HasFixedValues',true,...
                  'FixedValues',[0,1],...
                  'Units','',...
                  'Value',Pylon.PylonMEX_GetExposureAuto());
            %% ROI
            this.HasROI = Pylon.PylonMEX_HasROI;
            if this.HasROI
                Pylon.PylonMEX_ClearROI();
                this.locROI = Pylon.PylonMEX_GetROI();
                this.locROI(1:2) = this.locROI(1:2) + 1;
            end
            this.UsingROI = false;
            %% Non-special props
            this.cGain = InitPropByName('Gain');  
            this.cGainAuto = InitPropByName('GainAuto');
            this.cTargetBrightness = InitPropByName('AutoTargetBrightness');
            this.cFrameRate = InitPropByName('AcquisitionFrameRate');
            this.cUseFrameRate = InitPropByName('AcquisitionFrameRateEnable');
            this.cOffset = InitPropByName('BlackLevel'); %aka blacklevel, brightness
            
            %% timers
            try %delete timers left from previous instances
                delete(this.tFrameTimer);
                delete(this.tDrawTimer);
            catch
            end
            
            %Setup Frame Grabber Timer
             this.tFrameTimer = timer('BusyMode','drop',... %drop frames if the computer can't keep up
                                      'ExecutionMode','fixedRate',... %execute timer with fixed rate
                                      'TimerFcn',@(tmr,event) this.liveframehandler(tmr,event),...
                                      'Name','FrameGrabberTimer');
            
            this.tDrawTimer = timer('BusyMode','drop',...
                    'ExecutionMode','fixedRate',...
                    'Period',round((1/this.fDrawTimerRate),3),...
                    'TimerFcn',@(~,~) this.drawimage());
                    %'TimerFcn',@(~,~) drawnow);
                    %'TimerFcn',@(~,~) this.drawimage());
            set(this.tDrawTimer,'Name','DrawTimer');
        end
        function liveframehandler(this,tmr,~)
            %try
            % LIVE FRAME HANDLER
            %=============================================================
            
            %make sure only one instance of liveframehandler is running
            %if isMultipleCall();  return;  end
            
                lasttime = this.clkImageTime;
                t1 = tic;
                tmrstopped = false;
                %usewait = false;
                while Pylon.PylonMEX_BufferCount() <1 && toc(t1)<this.imagetimeout
                    if ~tmrstopped %stop time it is out of sync
                        stop(tmr);
                        tmrstopped = true;
                    end
                    %disp('wait');
                    %pause(0.002);
                end
                if toc(t1)>=this.imagetimeout
                    error('Timeout during liveframehandler');
                end
                %t_grabbed = tic;
                
                %process current image
                [this.ImageData,this.clkImageTime] = Pylon.PylonMEX_GrabNoWait();
                %this.ImageData = Pylon.PylonMEX_GrabNoWait();
                %this.clkImageTime = now(); %update image clock

                %this.ImageData = double(this.ImageData);             
                %execute user callback
                if ~isempty(this.fFrameCallback)&&(isa(this.fFrameCallback,'function_handle')||...
                    (iscell(this.fFrameCallback)&&isa(this.fFrameCallback{1},'function_handle')))
                    if iscell(this.fFrameCallback)
                        this.fFrameCallback{1}(this,this.fFrameCallback{2:end});
                    else
                        this.fFrameCallback(this);
                    end
                end
                
                CalledDraw = false;
                if this.bDrawImage && (isempty(this.drawtic)||toc(this.drawtic)>=1/this.fDrawTimerRate)
                    this.drawimage();
                    this.drawtic = tic();
                    CalledDraw = true;
                end
                
                % Calculate Frame Rate
                if ~isempty(lasttime) %&& this.clkImageTime~=lasttime %&& ~CalledDraw
                    this.FrameRateHistory(this.FRHidx) = 1/(this.clkImageTime-lasttime)/86400;
                    this.FRHidx = this.FRHidx + 1;
                    if this.FRHidx > numel(this.FrameRateHistory)
                        this.FRHidx=1;
                    end
                end
                
                %if we stopped the timer restart the timer
                if tmrstopped
                    if ~CalledDraw
                        %new period, only if 
                        tmr.period = round(1/Pylon.PylonMEX_ResultingFrameRate,3);
                    end
                    try
                        start(tmr);
                    catch
                    end
                    
                end
                
            %=============================================================    
            %% END LIVE FRAME HANDLER
%             catch exception
%                 if ~isvalid(this) %object was deleted while we were processing
%                     %surpress error output
%                     return
%                 end
%                 
%                 disp '***** Live Frame Handler ERROR *****'
%                 disp('message:')
%                 disp (exception.message)
%                 disp('stack')
%                 disp (exception.stack)
%                 for k=1:numel(exception.stack)
%                     disp(exception.stack(k).file)
%                     disp(exception.stack(k).name)
%                     disp(exception.stack(k).line)
%                 end
%                 disp '***********************************************'
%                 error('something wrong in liveframehandler');
%             end
        end
        function drawimage(this)
            if ~this.bDrawImage 
                return;
            end
            %draws current image on specfied axes
            if ~ishandle(this.haxImageAxes)
                warning('the image axis is missing. Turning live draw off');
                this.bDrawImage = false;
                return;
            end
            if ~ishandle(this.himCameraImage)
                warning('The image handle himCameraImage is not valid. creating a new image');
                this.himCameraImage = image('Parent',this.haxImageAxes,'CDataMapping','scaled');
                return;
            end
            
            if this.DEBUG && ~isempty(this.hTxt_FPS) && ishghandle(this.hTxt_FPS)
                set(this.hTxt_FPS,'String',sprintf('FPS: %f',this.GetCaptureFrameRate()));
            end
            
            set(this.himCameraImage,'cdata',this.ImageData);

            %% update image
            drawnow limitrate;
        end
        function PropertyUpdate(this)
            % Run PropertyUpdate Callback
            if ~isempty(this.fPropertyUpdateCallback)&&(isa(this.fPropertyUpdateCallback,'function_handle')||...
                (iscell(this.fPropertyUpdateCallback)&&isa(this.fPropertyUpdateCallback{1},'function_handle')))
                if iscell(this.fPropertyUpdateCallback)
                    this.fPropertyUpdateCallback{1}(this,this.fPropertyUpdateCallback{2:end});
                else
                    this.fPropertyUpdateCallback(this);
                end
            end
        end
    end
    %% User Accessible Class Control Methods
    methods
        %% Destructor
        function delete(this) %destructor, called on errors in constructor
            disp('Deleting PylonMEX');
            this.StopLiveMode();
            drawnow();
            pause(0.1);
            delete(this.tFrameTimer);
            disp('Deleting FrameTimer'); %for some reason deleting the timer doesn't clear the event queue unless we print something here
            delete(this.tDrawTimer);
            
            
            %Unload device
            Pylon.PylonMEX_Shutdown();
            clear -regexp Pylon.PylonMEX_\w*; %clear loaded mex funcitons
            
        end
        
        %% Camera Crontrol Functions
        function [img,time,Ngrabbed] = SnapImage(this,nframes)
            waslive = this.bLiveModeRunning;
            if nargin<2 %just get a single image
                nframes = 1;
            end
            if waslive
                stop(this.tFrameTimer);
                %this.StopLiveMode();
            end
            [img,time,~,Ngrabbed] = Pylon.PylonMEX_GrabN(nframes,this.imagetimeout*1000);
            if Ngrabbed>0
                %time = datenum(time);
                this.ImageData = img{Ngrabbed};
                this.clkImageTime = time(Ngrabbed);
            end
            if this.bDrawImage && nframes>1
                this.drawimage();
                this.drawtic = tic();
            end
            if nframes==1
                img = img{1};
            end
            
            if waslive
                start(this.tFrameTimer);
                %this.StartLiveMode();
            end
        end
        function StartLiveMode(this)
            %set period of the frame grabber timer
            set(this.tFrameTimer,'Period',round(1/Pylon.PylonMEX_ResultingFrameRate,3));
            
            %disp('Started Live Acquisition');
            try
                start(this.tFrameTimer); %start the timer
            catch
            end
            if strcmpi(get(this.tFrameTimer,'Running'),'on')
                this.bLiveModeRunning = true;
            else
                disp('Camera is not running, even though StartLiveMode() was called');
                this.bLiveModeRunning = false;
                return;
            end
            
        end
        function StopLiveMode(this)
            stop(this.tFrameTimer);
            stop(this.tDrawTimer);
            this.bLiveModeRunning = false;
        end
        
        %% Camera Control Settings
        function setImageAxes(this,hAx)
            if ~(ishandle(hAx)&&strcmpi(get(p.Results.Parent,'type'),'axes'))
                warning('setImageAxes expects a valid axes handle. Skipping.')
                return;
            end
            this.setupAxes(hAx);
        end
        function setupAxes(this,hAx,DEBUG)
            if nargin>2
                this.DEBUG = DEBUG;
            end
            waslive = this.bLiveModeRunning;
            if waslive
                this.StopLiveMode();
            end
            % setupAxes(hAx) - prepare axis for displaying the live image
            % This function creates an image (MMcam.himCameraImage) which
            % displays the live camera feed.
            % The axis is set to 'NextPlot'='replacechildren' so that user
            % called plotting functions don't wipe out the axis settings
            % The image handle is hidden using
            % set(MMcam.himCameraImage,'handlevisibility','callback');
            % so that the user can call plot and never have to worry about
            % deleting the image.
            
            if nargin>1&&~isempty(hAx)&&ishghandle(hAx)
                this.haxImageAxes = hAx;
            elseif nargin>1
                warning('Specified axis was not a valid graphics handle, using previous handle');
            end
            if isempty(this.haxImageAxes)||~ishandle(this.haxImageAxes)
                warning('No axis handle has been defined. Will create a new figure and axis.');
                this.hfigImageFig = figure();
                this.haxImageAxes = gca;
            end
            cla(this.haxImageAxes,'reset'); %reset the axis
            
            img = this.SnapImage();
            this.himCameraImage = image('Parent',this.haxImageAxes,'CData',img);
            set(this.himCameraImage,'CDataMapping','scaled');
            set(this.haxImageAxes,'CLim',[0,255]);
            
            % format image
            %this.ResetImageClim();
            axis(this.haxImageAxes,'image');
            set(this.haxImageAxes,'ydir','reverse');
            colormap(this.haxImageAxes,'gray');
            set(this.haxImageAxes,'xlim',[0,this.WidthMax],'ylim',[0,this.HeightMax]);
            
            %lock the axes behavior to prevent plot from clearing the axis
            %settings
            set(this.haxImageAxes,'NextPlot','replacechildren');
            %hide the image handle so that plot doesn't delete it
            set(this.himCameraImage,'handlevisibility','callback');
            
            %FrameRate Display
            if this.DEBUG
                this.hTxt_FPS = text(10,10,'0 FPS','color','red');
                set(this.hTxt_FPS,'handlevisibility','callback');
            end
            
            drawnow;
            
            this.bDrawImage = true;
            
            if waslive
                this.StartLiveMode();
            end
        end
        function setDrawImage(this,val)
            if ~(isscalar(val)||islogical(val))
                warning('setDrawImage expects logical value');
                return;
            end
            this.bDrawImage = val;
        end
        
        function fps = GetCaptureFrameRate(this)
            fps = nanmean(this.FrameRateHistory);
        end
        function fps = get.ResultingFrameRate(this)
            fps = Pylon.PylonMEX_ResultingFrameRate;
        end
        
        %% Set Callbacks
        function setFrameCallback(this,fCbk)
            if ~(isempty(fCbk)||isa(fCbk,'function_handle')||...
                (iscell(fCbk)&&isa(fCbk{1},'function_handle')))
                error('setFrameCallback expects an empty array, a callback, or a cell arracy containing a callback as the first element');
            end
            
            %stop live mode if needed
            waslive = this.bLiveModeRunning;
            if waslive
                this.StopLiveMode();
            end
            
            this.fFrameCallback = fCbk;
            
            if waslive
                this.StartLiveMode();
            end
            
        end
        function setPropertyUpdateCallback(this,fCbk)
            if ~(isempty(fCbk)||isa(fCbk,'function_handle')||...
                (iscell(fCbk)&&isa(fCbk{1},'function_handle')))
                error('setDrawCallback expects an empty array, a callback, or a cell arracy containing a callback as the first element');
            end
            %stop live mode if needed
            this.fPropertyUpdateCallback = fCbk;
        end
    end
    %% Camera Properties
    properties(SetAccess=private) % Camera Properties --> initialized at startup
        %% Max Width and Height
        WidthMax = 0;
        HeightMax = 0;
        %% PropertyValueStructures, used to hold value in matlab so we dont need to make tons of MEX calls just to read values
        cExposure;
        cExposureAuto;
        cGain;         
        cGainAuto;
        cTargetBrightness;
        cFrameRate;
        cUseFrameRate;
        cPixelType;
        cOffset; %aka blacklevel, brightness
        %% ROI
        locROI;
        UsingROI = false;
        HasROI;
        %% PixelFormat
        BytesPerPixel = 1;
    end
    properties (Dependent) % Camera Properties - with legacy aliases
        %% Exposure
        Exposure;
        bHasExposureLimits;
        dExposureLimits;
        sExposureUnits;
        dExposure;
        %% Exposure auto
        ExposureAuto;
        bExposureAuto
        csExposureAutoValues;
        bHasExposureAuto;
        %% Gain
        Gain;
        bHasGain;
        dGain;
        bGainValuesFixed;
        dGainLimits;
        csGainValues;
        %% GainAuto
        GainAuto;
        bHasGainAuto;
        bGainAuto;
        csGainAutoValues;
        %% ROI
        ROI;
        dImageWidth;
        dImageHeight;
        %% Frame Rate
        FrameRate;
        UseFrameRate;
        bHasFrameRate;
        dTargetFrameRate;
        dActualFrameRate;
        csFrameRateValues;
        bFrameRateValuesFixed;
        dFrameRateLimits;
        %% SoftAutoGain
        TargetBrightness;
        bHasSoftAutoGain;
        bSoftAutoGain;
        SoftAutoGainIntensity;
        SoftAutoGainLimits;
        %% Brightness
        %Note: Offset=Brightness=BlackLevel
        Offset;
        Brightness;
        BlackLevel;
        bHasBrightness;
        dBrightness;
        bBrightnessValuesFixed;
        dBrightnessLimits;
        csBrightnessValues;

    end
    properties %other legacy properties
        SoftAutoGainLastI = NaN;
    end
    methods % Camera Property access menthods
        function PropStruct = SetPropertyUsingStruct(this,PropStruct,val)
            switch(PropStruct.Type)
            case {'intfIInteger','intfIFloat'}
                if ischar(val)
                    val = num2double(val);
                end
                if ~isnumeric(val) || ~isscalar(val)
                    error('val must be numeric scalar');
                end
                if isnan(val)||isinf(val)
                    error('val must be a finite number');
                end

            case {'intfIEnumeration','intfIString'}
                if ~ischar(val)
                    error('value must be a string');
                end

            case 'intfIBoolean'
                if ~isscalar(val)
                    error('val must be scalar');
                end
                if ~isnumeric(val) && ~islogical(val)
                    error('val must be numeric or logical');
                end
                val = logical(val);
            end
            Pylon.PylonMEX_SetProperty(PropStruct.Keyword,val);
            PropStruct.Value = Pylon.PylonMEX_GetProperty(PropStruct.Keyword);
        end
        %% Exposure
        function set.Exposure(this,val)
            if ischar(val)
                val = num2double(val);
            end
            if ~isnumeric(val) || ~isscalar(val)
                error('val must be numeric scalar');
            end
            Pylon.PylonMEX_SetExposure(val);
            this.cExposure.Value = Pylon.PylonMEX_GetExposure();
            
            %run property update callback
            this.PropertyUpdate();
        end
        function val = get.Exposure(this)
            val = this.cExposure.Value;
        end
        function val = get.bHasExposureLimits(this)
            val = this.cExposure.HasLimits;
        end
        function val = get.dExposureLimits(this)
            val = this.cExposure.Limits;
        end
        function val = get.sExposureUnits(this)
            val = this.cExposure.Units;
        end
        function val = get.dExposure(this)
            val = this.Exposure;
        end
        %% Exposure Auto
        function set.ExposureAuto(this,val)
            if ~isscalar(val)
                error('val must be scalar');
            end
            if ~isnumeric(val) && ~islogical(val)
                error('val must be numeric or logical');
            end
            Pylon.PylonMEX_SetExposureAuto(logical(val));
            this.cExposureAuto.Value = Pylon.PylonMEX_GetExposureAuto();
            
            %run property update callback
            this.PropertyUpdate();
        end
        function val = get.ExposureAuto(this)
            val = this.cExposureAuto.Value;
        end
        function val = get.bExposureAuto(this)
            val = this.cExposureAuto.Value;
        end
        function val = get.csExposureAutoValues(this)
            val = this.cExposureAuto.FixedValues;
        end
        function val = get.bHasExposureAuto(this)
            val = this.cExposureAuto.IsProp;
        end
        %% Gain
        function set.Gain(this,val)
            this.cGain = this.SetPropertyUsingStruct(this.cGain,val);
            
            %run property update callback
            this.PropertyUpdate();
        end
        function val = get.Gain(this)
            val = this.cGain.Value;
        end
        function val = get.bHasGain(this)
            val = this.cGain.IsProp;
        end
        function val = get.dGain(this)
            val = this.Gain;
        end
        function val = get.bGainValuesFixed(this)
            val = this.cGain.HasFixedValues;
        end
        function val = get.dGainLimits(this)
            val = this.cGain.Limits;
        end
        function val = get.csGainValues(this)
            val = this.cGain.FixedValues;
        end
        %% GainAuto
        function set.GainAuto(this,val)
            %hack to convert to simple bool
            val = logical(val);
            if val
                val = 'Continuous';
            else
                val = 'Off';
            end
            this.cGainAuto = this.SetPropertyUsingStruct(this.cGainAuto,val);
            
            %run property update callback
            this.PropertyUpdate();
        end
        function val = get.GainAuto(this)
            val = this.cGainAuto.Value;
            %hack for simple bool
            val =  strcmpi(val,'Continuous');
        end
        function val = get.bHasGainAuto(this)
            val = this.cGain.IsProp;
        end
        function val = get.bGainAuto(this)
            val = this.GainAuto;
        end
        function val = get.csGainAutoValues(this)
            val = this.cGainAuto.FixedValues;
        end
        %% ROI
        function ClearROI(this)
            waslive = this.bLiveModeRunning;
            if waslive
                this.StopLiveMode();
            end
            
            if this.HasROI
                Pylon.PylonMEX_ClearROI();
            	this.locROI = Pylon.PylonMEX_GetROI;
                this.locROI(1:2) = this.locROI(1:2)+1;
            	this.UsingROI = false;
            end
            
            if ishghandle(this.himCameraImage)
                set(this.himCameraImage,...
                    'XData',[1,this.WidthMax],...
                    'YData',[1,this.HeightMax]);
            end

            %run property update callback
            this.PropertyUpdate();
            
            if waslive
                this.StartLiveMode();
            end
        end
        function set.ROI(this,val)
            if numel(val)~=4
                error('val must be 1x4');
            end
            
            waslive = this.bLiveModeRunning;
            if waslive
                this.StopLiveMode();
            end
            
            val = round(max([1,1,1,1],min(val,[this.WidthMax-1,this.HeightMax-1,this.WidthMax-1,this.HeightMax-1])));
            if this.HasROI
                val(1:2) = val(1:2) - 1; %convert to 0-indexed coord.
                Pylon.PylonMEX_SetROI(val);
                this.locROI = Pylon.PylonMEX_GetROI;
                this.locROI(1:2) = this.locROI(1:2)+1;
                this.UsingROI = true;
            end
            
            %change image placement
            if ishghandle(this.himCameraImage)
                set(this.himCameraImage,...
                    'XData',[this.locROI(1),this.locROI(1)+this.locROI(3)-1],...
                    'YData',[this.locROI(2),this.locROI(2)+val(4)-1]);
            end
            
            if waslive
                this.StartLiveMode();
            end
            %run property update callback
            this.PropertyUpdate();
        end
        function val = get.ROI(this)
            val = this.locROI;
        end
        function val = get.dImageWidth(this)
            if this.HasROI
                val = this.locROI(3);
            else
                val = this.WidthMax;
            end
        end
        function val = get.dImageHeight(this)
            if this.HasROI
                val = this.locROI(4);
            else
                val = this.HeightMax;
            end
        end
        %% Frame Rate
        function set.FrameRate(this,val)
            this.cFrameRate = this.SetPropertyUsingStruct(this.cFrameRate,val);
            
            %run property update callback
            this.PropertyUpdate();
        end
        function val = get.FrameRate(this)
            val = this.cFrameRate.Value;
        end
        function set.UseFrameRate(this,val)
            waslive = this.bLiveModeRunning;
            if waslive
                this.StopLiveMode();
            end
            this.cUseFrameRate = this.SetPropertyUsingStruct(this.cUseFrameRate,val);
            
            %run property update callback
            this.PropertyUpdate();
            if waslive
                this.StartLiveMode();
            end
        end
        function val = get.UseFrameRate(this)
            val = this.cUseFrameRate.Value;
        end
        function val = get.bHasFrameRate(this)
            val = this.cFrameRate.IsProp;
        end
        function val = get.dTargetFrameRate(this)
            val = this.FrameRate;
        end
        function val = get.dActualFrameRate(this)
            val = nanmean(this.FrameRateHistory);
            if isempty(val)
                val = 0;
            end
        end
        function val = get.csFrameRateValues(this)
            val = this.cFrameRate.FixedValues;
        end
        function val = get.bFrameRateValuesFixed(this)
            val = this.cFrameRate.HasFixedValues;
        end
        function val = get.dFrameRateLimits(this)
            val = this.cFrameRate.Limits;
        end
        %% SoftAutoGain
        function set.TargetBrightness(this,val)
            this.cTargetBrightness = this.SetPropertyUsingStruct(this.cTargetBrightness,val);
            
            %run property update callback
            this.PropertyUpdate();
        end
        function val = get.TargetBrightness(this)
            val = this.cTargetBrightness.Value();
        end
        function val = get.bHasSoftAutoGain(this)
            val = this.cTargetBrightness.IsProp;
        end
        function val = get.bSoftAutoGain(this)
            val = this.GainAuto;
        end
        function val = get.SoftAutoGainIntensity(this)
            val = this.TargetBrightness;
        end
        function set.SoftAutoGainIntensity(this,val)
            this.TargetBrightness = val;
        end
        function val = get.SoftAutoGainLimits(this)
            val = this.cTargetBrightness.Limits;
        end
        %% Brightness
        function set.Offset(this,val)
            this.cOffset = this.SetPropertyUsingStruct(this.cOffset,val);
            
            %run property update callback
            this.PropertyUpdate();
        end
        function val = get.Offset(this)
            val = this.cOffset.Value;
        end
        function set.Brightness(this,val)
            this.Offset = val;
        end
        function val = get.Brightness(this)
            val = this.Offset;
        end
        function set.BlackLevel(this,val)
            this.Offset = val;
        end
        function val = get.BlackLevel(this)
            val = this.Offset;
        end
        function val = get.dBrightness(this)
            val = this.Offset;
        end
        function val = get.bBrightnessValuesFixed(this)
            val = this.cOffset.HasFixedValues;
        end
        function val = get.dBrightnessLimits(this)
            val = this.cOffset.Limits;
        end
        function val = get.csBrightnessValues(this)
            val = this.cOffset.FixedValues;
        end
        function val = get.bHasBrightness(this)
            val = this.cOffset.IsProp;
        end
    end
    methods % Legacy access Methods (so we don't break MultiMT too much)
        %% Exposure
        function val = getExposure(this)
            val = this.Exposure;
        end
        function setExposure(this,val)
            this.Exposure = val;
        end
        function setExposureAuto(this,val)
            this.ExposureAuto = val;
        end
        function val = getExposureAuto(this)
            val = this.ExposureAuto;
        end
        %% FrameRate
        function setFrameRate(this,val)
            this.FrameRate = val;
        end
        function val = getTargetFrameRate(this)
            val = this.FrameRate;
        end
        function val = getActualFrameRate(this)
            val = this.dActualFrameRate;
        end
        %% Gain
        function setGain(this,val)
            this.Gain = val;
        end
        function val = getGain(this)
            val = this.Gain;
        end
        function setGainAuto(this,val)
            this.GainAuto = val;
        end
        function val = getGainAuto(this)
            val = this.GainAuto;
        end
        %% SoftAutoGain
        function setSoftAutoGain(this,val)
            this.GainAuto = val;
        end
        function val = getSoftAutoGain(this)
            val = this.GainAuto;
        end
        function setSoftAutoGainIntensity(this,val)
            this.TargetBrightness = val;
        end
        function val = getSoftAutoGainIntensity(this)
            val = this.TargetBrightness;
        end
        function val = getSoftAutoGainLastI(this)
            val = NaN;
        end
        %% Brightness
        function setBrightness(this,val)
            this.Brightness = val;
        end
        function val = getBrightness(this)
            val = this.Brightness;
        end
    end
end

function PropStruct = InitPropByName(name)
[type,opt,~] = Pylon.PylonMEX_PropertyAllowedValues(name);

%disp('InitPropByName');
%disp(name)


PropStruct = struct('Keyword',name,...
                  'IsProp',true,...
                  'Type',type,...
                  'HasLimits',false,...
                  'Limits',[NaN,NaN],...
                  'HasFixedValues',false,...
                  'FixedValues',[],...
                  'Units','',...
                  'Value',Pylon.PylonMEX_GetProperty(name));
PropStruct(1).IsProp = true;
switch(type)
    case {'intfIInteger','intfIFloat'}
        PropStruct.HasLimits = true;
        PropStruct.Limits = opt;
    case 'intfIEnumeration'
        PropStruct.HasFixedValues = true;
        PropStruct.FixedValues = opt;
    case 'intfIBoolean'
        PropStruct.HasLimits = true;
        PropStruct.Limits =[0,1];
        PropStruct.HasFixedValues = true;
        PropStruct.FixedValues = [false,true];
end
end
function flag=isMultipleCall()
  flag = false; 
  % Get the stack
  s = dbstack();
  if numel(s)<=2
    % Stack too short for a multiple call
    return
  end
 
  % How many calls to the calling function are in the stack?
  names = {s(:).name};
  TF = strcmp(s(2).name,names);
  count = sum(TF);
  if count>1
    % More than 1
    flag = true; 
  end
end