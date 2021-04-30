classdef stackviewer < extras.GraphicsChild
    
    %% Public properties
    properties (SetObservable=true,AbortSet=true)
        StackData
        CurrentFrame = 1;
    end
    
    
    properties (SetAccess=protected,SetObservable=true,AbortSet=true)
        NumberOfFrames = 0;
    end
    
    %% dependent
    properties (Dependent)
        
        CurrentImageData
        %XData
        %YData
    end
    methods        
        function val = get.CurrentImageData(this)
            if isempty(this.StackData)
                val = [];
            elseif iscell(this.StackData)
                val = this.StackData{this.CurrentFrame};
            elseif isnumeric(this.StackData) && ndims(this.StackData)==3
                val = this.StackData(:,:,this.CurrentFrame);
            elseif isnumeric(this.StackData) && ndims(this.StackData)==4
                val = this.StackData(:,:,:,this.CurrentFrame);
            else
                warning('StackData is not properly initialized, Current Frame cannot be returned');
                val = [];
            end
        end
    end
    
    %% Internal Set
    properties (SetAccess=protected)
        Image
        ImageAxes
        Slider
        OuterVBox
        
        LevelsUI
        
        
    end
    
    %% Create/Delete
    methods
        function this = stackviewer(varargin)
            %% Setup Parent
            %initiate graphics parent related variables
            this@extras.GraphicsChild(@() figure());
            %look for parent specified in arguments
            varargin = this.CheckParentInput(varargin{:});
            
            %% Create Custom Toolbar button for histogram levels
            tbh = findall(this.ParentFigure,'Type','uitoolbar');
            uipushtool(tbh,'CData',extras.ImageLevelsUI.ToolbarIcon,...
                'HandleVisibility','Callback',...
                'TooltipString','Image Levels Tool',...
                'ClickedCallback',@(~,~) this.showLevelsUI());
            
            %% Create Graphical elements
            this.OuterVBox = uix.VBox('Parent',this.Parent);
            
            
            %create slider
            this.Slider = extras.LabeledSlider('Parent',this.OuterVBox,'Callback',@(~,~) this.UIchangeframe(),'Min',0,'Max',1,'Value',1,'SliderStep',[1,1]);
            
            %imagebox = uix.Panel('Parent',this.OuterVBox,'BorderType','none','BorderWidth',0);
            
            %Create image
            this.ImageAxes = axes('Parent',this.OuterVBox,'NextPlot','replacechildren');
            
            this.ParentFigure.CurrentAxes = this.ImageAxes;
            
            this.Image = imagesc('Parent',this.ImageAxes,'HandleVisibility','off');
            
            axis(this.ImageAxes,'image');
            
            %Set heights
            this.OuterVBox.Heights = [this.Slider.Horizontal_Height,-1];
            
            %% look for StackData
            found_data = false;
            if isnumeric(varargin{1}) || iscell(varargin{1})
                found_data = true;
                this.StackData = varargin{1};
                varargin(1) = [];
            end
            %parse remaining inputs
            if numel(varargin)>1
                for n=1:numel(varargin)-1
                    if ischar(varargin{n}) && strcmpi(varargin{n},'StackData')
                        if found_data
                            error('Stack data was specified more than once');
                        end
                        found_data = true;
                        this.StackData = varargin{n+1};
                    end
                end
            end
            
        end
        
        function delete(this)
            delete(this.Image);
            delete(this.LevelsUI);
            delete(this.ImageAxes);
            delete(this.OuterVBox);
        end
    end
    
    %% Internal Use
    methods(Access=protected)
        function UpdateImage(this)
            this.Image.CData = this.CurrentImageData;
        end
    end
    
    %% Callbacks
    methods (Hidden)
        function showLevelsUI(this)
            if isempty(this.LevelsUI) || ~isvalid(this.LevelsUI)
                this.LevelsUI = extras.ImageLevelsUI(this.Image);
            end
            lf = ancestor(this.LevelsUI.Parent,'figure');
            figure(lf);
        end
        
        function UIchangeframe(this)
            this.CurrentFrame = this.Slider.Value;
        end
    end
    
    %% Set Methods
    methods
        function set.StackData(this,val)
            assert(iscell(val)||...
                (isnumeric(val)&&(ndims(val)==2 || ndims(val)==3 || ndims(val)==4)),...
                'StackData must be a cell array of images, 3-d numeric array [Y,X,FRAMES], or 4-d numeric array [Y,X,RGB,FRAMES]');
            
            if isnumeric(val)&&ndims(val)==2
                sz = size(val);
                val = reshape(val,[sz,1]);
            end
            
            %% NumOfFrames
            if isempty(val)
                this.NumberOfFrames = 0;
            elseif iscell(val)
                this.NumberOfFrames = numel(val);
            elseif isnumeric(val) && ndims(val)==3
                this.NumberOfFrames = size(val,3);
            elseif isnumeric(val) && ndims(val)==4
                this.NumberOfFrames = size(val,4);
            else
                warning('StackData is not properly initialized, NumberOfFrames cannot be determined');
                this.NumberOfFrames = NaN;
            end
            
            %% Set Data
            this.StackData = val;
            
            %% Current Frame => calls ChangeFrame Functions, updates display
            this.CurrentFrame = max(1,min(this.CurrentFrame,this.NumberOfFrames));
            
            %% Update Display again in case CurentFrame did't actually change
            this.UpdateImage();
            
        end
        
        function set.NumberOfFrames(this,val)
            this.NumberOfFrames = val;
            
            set(this.Slider,'Min',1,'Max',this.NumberOfFrames,...
                'SliderStep',[1/this.NumberOfFrames,max(0.1,10/this.NumberOfFrames)]);
        end
        
        function set.CurrentFrame(this,val)
            this.CurrentFrame = max(1,min(round(val),this.NumberOfFrames));
            
            this.Slider.Value = this.CurrentFrame;
            
            this.UpdateImage();
        end
    end
end