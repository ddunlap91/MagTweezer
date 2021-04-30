classdef TargetValueItemUI < extras.GraphicsChild
    
    properties (AbortSet=true)
        Value;
        UIeditCallback;
    end
    
    properties (Dependent)
        Target;
        
        Min;
        Max;
        
        MinimumWidth;
        MinimumHeight;
        
        Label;
        UnitString;
        
        SliderStep
    end

    properties (Access=protected)
        TargetSlider;
        
        OuterBox;
        OuterHBox;
        OuterVBox;
        OuterGrid;
        ValueBox;
        
        LabelText;
        ValueEdit;
        UnitLabel;
        
        SizeChangeListener;
        SliderListener;
        
        %Horizontal_Height = 40;
        %Vertical_Width = 80;
        
        Vertical_LabelHeight = 30;
        Horizontal_LabelWidth = 60;
        
        %Horizontal_MinWidth = 150+60+60;
        %Vertical_MinHeight = 120+50+50;
        
        ValueBoxWidth = 60;
        ValueBoxHeight = 30;
        
        UnitLabelWidth = 20
        ValueEditHeight = 20;
        
        IsHorizontal = false;
        
        UIeditListner;
        
    end
    
    properties (Dependent,Hidden)
        %ValueBoxWidth;
        Horizontal_MinWidth; %TargetSlider.Horizontal_MinWidth + Horizontal_LabelWidth + ValueBoxWidth
        Vertical_MinHeight; % TargetSlider.Vertical_MinHeight + Vertical_LabelHeight + ValueBoxHeight
        Vertical_Width; %TargetSlider.Vertical_Width
        Horizontal_Height; %TargetSlider.Horizontal_Height
    end
    
    %% Dependent
    methods
        function val = get.SliderStep(this)
            val = this.TargetSlider.SliderStep;
        end
        function set.SliderStep(this,val)
            this.TargetSlider.SliderStep = val;
        end
    end
    
    %% get methods
    methods
        function val = get.Horizontal_MinWidth(this)
            val = this.TargetSlider.Horizontal_MinWidth + this.Horizontal_LabelWidth + this.ValueBoxWidth;
        end
        function val = get.Vertical_MinHeight(this)
            val = this.TargetSlider.Vertical_MinHeight + this.Vertical_LabelHeight + this.ValueBoxHeight;
        end
        function val = get.Vertical_Width(this)
            val = this.TargetSlider.Vertical_Width;
        end
        function val = get.Horizontal_Height(this)
            val = this.TargetSlider.Horizontal_Height;
        end
    end
    
    events
        ValueChangedByUI
    end
    %% Create/Delete
    methods
        function this = TargetValueItemUI(varargin)
            %% Setup Parent
            %initiate graphics parent related variables
            this@extras.GraphicsChild(@gcf);
            %look for parent specified in arguments
            varargin = this.CheckParentInput(varargin{:});
            
            %% 
            this.OuterBox = uix.HBox('Parent',this.Parent);
            this.OuterHBox = uix.HBox('Parent',this.OuterBox);
            this.OuterVBox = uix.VBox('Parent',this.OuterHBox);
            
            this.OuterGrid = uix.Grid('Parent',this.OuterVBox);
            
            this.LabelText = uicontrol('Parent',this.OuterGrid,...
                'Style','text',...
                'String','');
            
            OuterValueBox = uix.VBox('Parent',this.OuterGrid);
            
            uicontrol('Parent',OuterValueBox,...
                'style','text',...
                'string','Current Value',...
                'FontSize',7);
            this.ValueBox = uix.HBox('Parent',OuterValueBox);
            
            this.ValueEdit = uicontrol('Parent',this.ValueBox,...
                'style','edit',...
                'string',num2str(this.Value),...
                'Enable','inactive',...
                'TooltipString','Actual real-time value');
            this.UnitLabel = uicontrol('Parent',this.ValueBox,...
                'style','text',...
                'string','');
            
            this.ValueBox.Widths = [-1,this.UnitLabelWidth];
            OuterValueBox.Heights = [-1,this.ValueEditHeight];
            
            this.TargetSlider = extras.LabeledSlider('Parent',this.OuterGrid);
            
            %% setup sizing
           this.SizeChangedCallback();
 
            %% Size Change Listener
            this.SizeChangeListener = addlistener(this.OuterBox,'SizeChanged',@(~,~) this.SizeChangedCallback);
            
            %% Ui edit forwarder
            this.UIeditListner = addlistener(this.TargetSlider,'ValueChangedByUI',@(~,~) this.editFcn);
            
            %% Set other parameters
            set(this,varargin{:});
        end
        
        function delete(this)
            delete(this.SizeChangeListener);
            delete(this.UIeditListner);
        end
    end
    
    %% Callbacks
    methods (Hidden)
        
        function editFcn(this)
            notify(this,'ValueChangedByUI')
            if ~isempty(this.UIeditCallback)
                this.UIeditCallback(this,'uiedit');
            end
        end
        
        function SizeChangedCallback(this)
            this.OuterBox.Units = 'pixels';
            %'box pos'
            pos = this.OuterBox.Position;
            this.OuterBox.Units = 'normalized';
           % '%normalized'
           % p2 = this.OuterBox.Position
            
            %W = pos(3)%-pos(1)
            %H = pos(4)%-pos(2)
            %this.IsHorizontal = W>=H;
            this.IsHorizontal = pos(3)>=pos(4);
            
            if this.IsHorizontal %horizontal
                this.OuterHBox.Widths = -1; %scale to width of parent
                this.OuterHBox.MinimumWidths = this.Horizontal_MinWidth;

                this.OuterVBox.MinimumHeights = this.Horizontal_Height;
                this.OuterVBox.Heights = this.Horizontal_Height; %fix height
                
                set(this.OuterGrid,'Widths',[this.Horizontal_LabelWidth,this.ValueBoxWidth,-1],'Heights',-1);
            else %vertical
                set(this.OuterGrid,'Widths',-1,'Heights',[this.Vertical_LabelHeight,this.ValueBoxHeight,-1]);
                
                this.OuterHBox.MinimumWidths = this.Vertical_Width;
                this.OuterHBox.Widths = this.Vertical_Width;
                
                
                this.OuterVBox.Heights = -1;
                this.OuterVBox.MinimumHeights =this.Vertical_MinHeight;
            end
        end
    end
    
    %% Set methods
    methods
        function set.Target(this,val)
            this.TargetSlider.Value = val;
        end
        function val = get.Target(this)
            val = this.TargetSlider.Value;
        end
        
        function set.Value(this,val)
            this.ValueEdit.String = num2str(val);
            this.Value = val;
        end
        
        function set.Label(this,val)
            this.LabelText.String = val;
            if isempty(val)
                this.Vertical_LabelHeight = 1;
                this.Horizontal_LabelWidth = 1;
            else
                this.Vertical_LabelHeight = 30;
                this.Horizontal_LabelWidth = 60;
            end
            this.SizeChangedCallback();
        end
        function set.UnitString(this,val)
            this.UnitLabel.String = val;
            if isempty(val)
                this.UnitLabelWidth = 1;
            else
                this.UnitLabelWidth = 20;
            end
            this.ValueBox.Widths = [-1,this.UnitLabelWidth];
        end
        
        function val = get.Label(this)
            val = this.LabelText.String;
        end
        function val = get.UnitString(this)
            val = this.UnitLabel.String;
        end
        
        function val = get.MinimumWidth(this)
            val = this.OuterHBox.MinimumWidths;
        end
        function val = get.MinimumHeight(this)
            val = this.OuterVBox.MinimumHeights;
        end
        
        function set.Min(this,val)
            this.TargetSlider.Min = val;
        end
        function val = get.Min(this)
            val = this.TargetSlider.Min;
        end
        
        function set.Max(this,val)
            this.TargetSlider.Max = val;
        end
        function val = get.Max(this)
            val = this.TargetSlider.Max;
        end
        
    end
end