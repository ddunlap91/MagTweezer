classdef TargetValueDeviceUI < extras.GraphicsChild
    
    %% Internal Set
    properties (SetAccess=protected)
        Device;
    end
    
    properties (Dependent)
        SliderStep
    end
    
    %% Internal Only
    properties (Access=protected)
        UIcontrols = extras.hardware.TargetValueItemUI.empty;
        LabelText;
        ValueEdit;
        UnitLabel;
        
        OuterScrollPanel;
        OuterGrid;
        SizeChangeListener;
        DeviceDeleteListener;
        
        %% Value Listeners
        DeviceValueListener;
        DeviceTargetListener;
        DeviceLimitListener;
        DeviceValueSizeListener;
        DeviceNameListener;
        DeviceValueLabelsListener;
    end
    
    %% Dependent
    methods
        function val = get.SliderStep(this)
            if numel(this.UIcontrols) == 1
                val = this.UIcontrols.SliderStep;
            else
                val = cell(1,numel(this.UIcontrols));
                for n=1:numel(this.UIcontrols)
                    val{n} = this.UIcontrols(n).SliderStep;
                end
            end
        end
        function set.SliderStep(this,val)
            if isnumeric(val)
                assert(numel(val)==2,'SliderStep must either be a 1x2 numeric or a cell array');
                for n=1:numel(this.UIcontrols)
                    this.UIcontrols.SliderStep = val;
                end
            elseif iscell(val)
                assert(numel(val)==numel(this.UIcontrols),'specifying Slider using cell array requires cell array be same size as Device ValueSize');
                for n=1:numel(this.UIcontrols)
                    this.UIcontrols.SliderStep = val{n};
                end
            else
                error('SliderStep must either be a 1x2 numeric or a cell array');
            end
        end
    end
    
    %% Create/Delete
    methods
        function this = TargetValueDeviceUI(varargin)
            %initiate graphics parent related variables
            this@extras.GraphicsChild(@() figure('Name','Controls','MenuBar','none','NumberTitle','off'));
            %look for parent specified in arguments
            varargin = this.CheckParentInput(varargin{:});
            
            %% Look for device
            if numel(varargin)<1
                error('Device must be specified');
            end
            
            found_dev = false;
            if isa(varargin{1},'extras.hardware.TargetValueDevice')
                this.Device = varargin{1};
                varargin(1) = [];
                found_dev = true;
            end
            
            found_at = [];
            for n=1:numel(varargin)-1
                if ischar(varargin{n}) && strcmpi(varargin{n},'Device')
                    if found_dev
                        error('Device was specified twice')
                    end
                    found_at = n:n+1;
                    found_dev = true;
                    this.Device = varargin{n+1};
                    assert(isa(this.Device,'extras.hardware.TargetValueDevice'),'Device must be an extras.hardware.TargetValueDevice type object');
                end
            end
            varargin(found_at) = [];
            
            if ~found_dev
                error('Device must be specified');
            end
            
            % dev delete listener
            this.DeviceDeleteListener = addlistener(this.Device,'ObjectBeingDestroyed',@(~,~) delete(this));
            
            if this.CreatedParent
                this.Parent.Name = this.Device.DeviceName;
            end
            
            %% Create Panels
            this.OuterScrollPanel = uix.ScrollingPanel('Parent',this.Parent);
            
            this.OuterGrid = uix.Grid('Parent',this.OuterScrollPanel);
            
            %% Create GUI elements
            this.NumValuesChanged();
            
            
            %% addapt size
            this.SizeChangedCallback();
            
            %% SizeChange Listener
            this.SizeChangeListener = addlistener(this.OuterScrollPanel,'SizeChanged',@(~,~) this.SizeChangedCallback);
            
            %% Value listeners
            this.DeviceValueListener = addlistener(this.Device,'Value','PostSet',@(~,~) this.UpdateValues);
            this.DeviceTargetListener = addlistener(this.Device,'Target','PostSet',@(~,~) this.UpdateTarget);
            
            %Limits = [-Inf,Inf];
            this.DeviceLimitListener = addlistener(this.Device,'Limits','PostSet',@(~,~) this.UpdateLimits);
            %ValueSize = [1,1];
            this.DeviceValueSizeListener = addlistener(this.Device,'ValueSize','PostSet',@(~,~) this.UpdateValueSize);
            %DeviceName='Device';
            this.DeviceNameListener = addlistener(this.Device,'DeviceName','PostSet',@(~,~) this.UpdateDeviceName);
            %ValueLabels = '';
            this.DeviceValueLabelsListener = addlistener(this.Device,'ValueLabels','PostSet',@(~,~) this.UpdateValueLabels);
            
            
            %% addapt size again to force formatting
            this.SizeChangedCallback();
            
            %% Set other properties
            set(this,varargin{:});
        end
        
        function delete(this)
            
            %% Value Listeners
            delete(this.DeviceValueListener);
            delete(this.DeviceTargetListener);
            delete(this.DeviceLimitListener);
            delete(this.DeviceValueSizeListener);
            delete(this.DeviceNameListener);
            delete(this.DeviceValueLabelsListener);
            
            
            delete(this.SizeChangeListener);
            delete(this.UIcontrols);
            delete(this.OuterScrollPanel);
            delete(this.DeviceDeleteListener);
            
            
        end
    end
    
    
    %% Callbacks
    methods (Hidden)
        function SizeChangedCallback(this)
            this.OuterScrollPanel.Units = 'pixels';
            pos = this.OuterScrollPanel.Position;
            this.OuterScrollPanel.Units = 'normalized';
            
            nC = numel(this.UIcontrols);
            
            %Check if children will be horizontal or vertical
            %HciH = pos(3)/nC >= pos(4) %grid horizontal children horizontal?
            %VciH = pos(3) >= pos(4)/nC %grid horizontal children vertical?
            
            IH = pos(3) >= pos(4);
            IsHorizontal = false;
           
            if numel(this.UIcontrols)>0
                
                % if box is wide, perfer to stack horizontally as long as
                % controls fit
                if IH && nC*this.UIcontrols(1).Horizontal_MinWidth < pos(3)
                    IsHorizontal = true;
                end
                    
                
                
                minH = this.UIcontrols(1).MinimumHeight;
                minW = this.UIcontrols(1).MinimumWidth;
                for n=2:numel(this.UIcontrols)
                    if IsHorizontal
                        minW = minW + this.UIcontrols(n).MinimumWidth;
                    else
                       minH = minH + this.UIcontrols(n).MinimumHeight;
                    end
                end
            else
                minH = 10;
                minW = 10;
            end
            
            set(this.OuterScrollPanel,'MinimumHeights',minH,'MinimumWidths',minW);                
        end
        
        function NumValuesChanged(this)
            NumVals = prod(this.Device.ValueSize);
            
            if NumVals > numel(this.UIcontrols)
                delete(this.UIcontrols(NumVals+1:end));
                this.UIcontrols(NumVals+1:end) = [];
            end
            
            for n = 1:NumVals
                
                if numel(this.UIcontrols) < n %create
                    
                    %% Get Label
                    if isempty(this.Device.ValueLabels)||ischar(this.Device.ValueLabels)
                        Label = this.Device.ValueLabels;
                    elseif iscell(this.Device.ValueLabels)&&numel(this.Device.ValueLabels)==1
                        Label = this.Device.ValueLabels{1};
                    else
                        Label = this.Device.ValueLabels{n};
                    end
                    %% Get Limits
                    if isnumeric(this.Device.Limits)
                        Min = this.Device.Limits(1);
                        Max = this.Device.Limits(2);
                    else
                        Min = this.Device.Limits{n}(1);
                        Max = this.Device.Limits{n}(2);
                    end
                    
                    %% Create Control
                    this.UIcontrols(n) = extras.hardware.TargetValueItemUI('Parent',this.OuterGrid,...
                        'UIeditCallback',@(~,~) this.UIeditCB(n),...
                        'Value',this.Device.Value(n),...
                        'Min',Min,...
                        'Max',Max,...
                        'Target',this.Device.Target(n),...
                        'Label',Label,...
                        'UnitString',this.Device.Units);
                %else %change settings?
                end
            end
            
        end
        
        function UIeditCB(this,ID)
            this.Device.Target(ID) = this.UIcontrols(ID).Target;
        end
        
        function UpdateValues(this)
            for n=1:numel(this.UIcontrols)
                this.UIcontrols(n).Value = this.Device.Value(n);
            end
        end
        
        function UpdateTarget(this)
            for n=1:numel(this.UIcontrols)
                this.UIcontrols(n).Target = this.Device.Target(n);
            end
        end
        
        function UpdateLimits(this)
            for n=1:numel(this.UIcontrols)
                %% Get Limits
                if isnumeric(this.Device.Limits)
                    Min = this.Device.Limits(1);
                    Max = this.Device.Limits(2);
                else
                    Min = this.Device.Limits{n}(1);
                    Max = this.Device.Limits{n}(2);
                end
                set(this.UIcontrols(n),'Min',Min,'Max',Max);
            end
        end
        function UpdateValueSize(this)
            this.NumValuesChanged();
        end
        function UpdateDeviceName(this)
            if this.CreatedParent
                this.Parent.Name = this.Device.DeviceName;
            end
        end
        function UpdateValueLabels(this)
            for n=1:numel(this.UIcontrols)
                %% Get Label
                    if isempty(this.Device.ValueLabels)||ischar(this.Device.ValueLabels)
                        Label = this.Device.ValueLabels;
                    elseif iscell(this.Device.ValueLabels)&&numel(this.Device.ValueLabels)==1
                        Label = this.Device.ValueLabels{1};
                    else
                        Label = this.Device.ValueLabels{n};
                    end
                set(this.UIcontrols(n),'Label',Label);
            end
        end
    end
    
    
end