classdef LabeledSlider < extras.GraphicsChild
    
    properties
        Min = 0;
        Max = 1;
        Value = 0.5;
        TooltipString = '';
        
        Callback = []
    end
    
    properties (Dependent)
        SliderStep
        
    end
    
    properties (Hidden,SetAccess=protected)
        OuterBox;
        OuterHBox;
        OuterVBox;
        OuterGrid;
        
        LabelsGrid;
        
        MinLabel;
        MaxLabel;
        ValueEdit;
        Slider;
        
        Vertical_Width = 70;
        Vertical_MinHeight = 120;
        ScrollSize = 20;
        
        Horizontal_Height = 40;
        Horizontal_MinWidth = 3*40;
        
        TextWidth = 40;
        TextHeight = 25;
        
        
        IsHorizontal = true;
        
        SizeChangeListener;

    end
    
    events
        ValueChangedByUI;
    end
    
    %% Create/Delete
    methods 
        function this = LabeledSlider(varargin)
            %% Setup Parent
            %initiate graphics parent related variables
            this@extras.GraphicsChild(@gcf);
            %look for parent specified in arguments
            varargin = this.CheckParentInput(varargin{:});
            
            %% Create GUI elements
            this.OuterBox = uix.HBox('Parent',this.Parent);
            this.OuterHBox = uix.HBox('Parent',this.OuterBox);
            this.OuterVBox = uix.VBox('Parent',this.OuterHBox);
            
            this.OuterGrid = uix.Grid('Parent',this.OuterVBox);
            
            % Create labels
            this.LabelsGrid = uix.Grid('Parent',this.OuterGrid);
            
            this.MinLabel = uicontrol('Parent',this.LabelsGrid,...
                'Style','text',...
                'String',num2str(this.Min),...
                'ToolTipString','Minimum Value');
            
            %spacer
            uix.Empty('Parent',this.LabelsGrid);
            
            this.ValueEdit = uicontrol('Parent',this.LabelsGrid,...
                'Style','edit',...
                'String',num2str(this.Value),...
                'TooltipString',this.TooltipString,...
                'Callback',@(~,~) this.EditCallback);
                
            uix.Empty('Parent',this.LabelsGrid);
            
            this.MaxLabel = uicontrol('Parent',this.LabelsGrid,...
                'Style','text',...
                'String',num2str(this.Max),...
                'ToolTipString','Maximum Value');
            
            % Slider
            this.Slider = uicontrol('Parent',this.OuterGrid,...
                'Style','slider',...
                'Min',this.Min,...
                'Max',this.Max,...
                'Value',this.Value,...
                'TooltipString',this.TooltipString,...
                'Callback',@(~,~) this.SliderCallback);
            
            %% Initial horizontal orientation
            this.IsHorizontal = true;
            
            this.OuterHBox.Widths = -1; %scale to width of parent
            this.OuterHBox.MinimumWidths = this.Horizontal_MinWidth;
            
            this.OuterVBox.Heights = this.Horizontal_Height; %fix height
            this.OuterVBox.MinimumHeights = this.Horizontal_Height;
            
            set(this.OuterGrid,'Widths',-1,'Heights',[-1,this.ScrollSize]);
            set(this.LabelsGrid,'Widths',[this.TextWidth,-1,this.TextWidth,-1,this.TextWidth],'Heights',-1);
            
            
            %% Setup SizeChangeListener
            this.SizeChangeListener = addlistener(this.OuterBox,'SizeChanged',@(~,~) this.SizeChangedCallback);

            %% set other options from arguments
            set(this,varargin{:});
            
        end
        
        function delete(this)
            delete(this.SizeChangeListener)
            delete(this.OuterBox);
        end
    end
    
    %% Callbacks
    methods (Hidden)
        function EditCallback(this)
            val = str2double(this.ValueEdit.String);
            if ~isnan(val)
                val = max(this.Min,min(val,this.Max));
                this.Value = val;
                if ~isempty(this.Callback)
                    this.Callback(this,'EditChanged');
                end
                notify(this,'ValueChangedByUI');
            else
                this.ValueEdit.String = num2str(this.Value);
            end
        end
        
        function SliderCallback(this)
            this.Value = this.Slider.Value;
            notify(this,'ValueChangedByUI');
            if ~isempty(this.Callback)
                this.Callback(this,'SliderChanged');
            end
        end
        
        function SizeChangedCallback(this)
            this.OuterBox.Units = 'pixels';
            pos = this.OuterBox.Position;
            this.OuterBox.Units = 'normalized';
            
            if pos(4)>=pos(3) && this.IsHorizontal % was horizontal, now vertical
                if this.LabelsGrid.Contents(1)~=this.MaxLabel
                    this.LabelsGrid.Contents = flip(this.LabelsGrid.Contents);
                end
                this.IsHorizontal = false;
                
                set(this.LabelsGrid,'Heights',[this.TextHeight,-1,this.TextHeight,-1,this.TextHeight],'Widths',-1);

                set(this.OuterGrid,'Widths',[-1,this.ScrollSize],'Heights',-1);
                
                this.OuterHBox.MinimumWidths = 1;
                this.OuterHBox.Widths = this.Vertical_Width;
                
                
                this.OuterVBox.Heights = -1;
                this.OuterVBox.MinimumHeights =this.Vertical_MinHeight;
                
            elseif pos(3)>=pos(4) && ~this.IsHorizontal %was vertical, now horizontal
                
                this.IsHorizontal = true;
                
                if this.LabelsGrid.Contents(1)~=this.MinLabel
                    this.LabelsGrid.Contents = flip(this.LabelsGrid.Contents);
                end
                
                this.OuterHBox.Widths = -1; %scale to width of parent
                this.OuterHBox.MinimumWidths = this.Horizontal_MinWidth;

                this.OuterVBox.MinimumHeights = 1;
                this.OuterVBox.Heights = this.Horizontal_Height; %fix height
                
                
                set(this.OuterGrid,'Widths',-1,'Heights',[-1,this.ScrollSize]);
                set(this.LabelsGrid,'Widths',[this.TextWidth,-1,this.TextWidth,-1,this.TextWidth],'Heights',-1);
            end
        end
    end
    
    %% Set Methods
    methods
        function set.Min(this,val)
            this.Slider.Min = val;
            this.MinLabel.String = num2str(val);
            this.Min = val;
        end
        
        function set.Max(this,val)
            this.Slider.Max = val;
            this.MaxLabel.String = num2str(val);
            this.Max = val;
        end
        
        function set.Value(this,val)
            this.Slider.Value = val;
            this.ValueEdit.String = num2str(val);
            this.Value = val;
        end
        
        function set.TooltipString(this,val)
            this.Slider.TooltipString = val;
            this.Edit.TooltipString = num2str(val);
            this.TooltipString = val;
        end
    end
    
    %% Dependent
    methods
        function val = get.SliderStep(this)
            val = this.Slider.SliderStep;
        end
        function set.SliderStep(this,val)
            this.Slider.SliderStep = val;
        end
    end
end