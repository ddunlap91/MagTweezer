classdef GraphicsChild < matlab.mixin.SetGet
% Derivable class for graphics objects that are the children of figures,
% panels, or axes
%Usage:
%
% If constucted with no arguments:
%       obj = obj@extras.GraphicsChild()
%   default parent will be a gcf()
%
% For current axes
%       obj = obj@extras.GraphicsChild('axes')
%
% To create a new uipanel
%       obj = obj@extras.GraphicsChild('uipanel')
%
% You can also specify the default parent constructor using a function
% handle
%       obj = obj@extras.GraphicsChild(@() YOUR_FUNCTION() )
%   The function specified must return a graphics object
%
%
% After creating the GraphicsChild object, you can validate calling
% function inputs specifying the parent using:
%
% other_args = obj.CheckParentInput(varargin)
%   the function will search for the parent object in varargin and return
%   the argument list (without the parent field) to other_args
%
%   Examples
%       args = obj.CheckParentInput(parent,...)
%
%       args = obj.CheckParentInput(...,'Parent',parent);
%
%   CheckParentInput can only be called once

    properties
        Parent;
    end
    
    properties (SetAccess=protected)
        ParentFigure;
    end
    
    properties (Access=protected)
        ParentDeleteListener;
        DefaultParentType = 'figure';
    end
    
    properties(Access=protected)
        ParentInitialized = false;
        CreatedParent = false;
    end
    
    events
        ParentChanged;
    end
    
    %% internal methods
    methods (Access=protected)
        function CreateParent(this)
            if ischar(this.DefaultParentType)
                switch(this.DefaultParentType)
                    case 'figure'
                        this.Parent = gcf;
                    case 'axes'
                        this.Parent = gca;
                    case 'uipanel'
                        this.Parent = uipanel();
                    otherwise
                        error('Default Parent Type not implemented');
                end
            elseif isa(this.DefaultParentType,'function_handle')
                this.Parent = this.DefaultParentType();
            else
                error('Unknown Default Parent Type');
            end
            this.ParentFigure = ancestor(this.Parent,'figure');
            this.CreatedParent = true;
        end
    end
    
    %% Public methods
    methods
        function this = GraphicsChild(DefaultParentType)
            if nargin<1
                this.DefaultParentType = 'figure';
            elseif ischar(DefaultParentType)
                this.DefaultParentType = lower(DefaultParentType);
            else
                this.DefaultParentType = DefaultParentType;
            end
            
        end
        
        function other_args = CheckParentInput(this,varargin) %can only be called once, subsiquent calls do nothing
            % Look for partent input and set parent
            % Syntax:
            %   other_Arg = obj.CheckParentInput(); create in current figure/new figure
            %   other_Arg = obj.CheckParentInput(parent,...); create object in specified
            %   figure or panel
            %
            %   other_Arg = obj.CheckParentInput(...,'Parent',parent,...)
            
            if this.ParentInitialized
                other_args = varargin;
                return;
            end
            
            if numel(varargin)<1
                this.CreateParent();
            else
                found_parent = false;
                
                %check if first argument is a graphics object
                if isgraphics(varargin{1})
                    this.Parent = varargin{1};
                    this.ParentFigure = ancestor(this.Parent,'figure');
                    varargin(1) = []; %remove
                    found_parent = true;
                end
                
                %check remaining arguments for name-value pairs
                if numel(varargin)>1
                    ind = find(strcmpi('Parent',varargin));
                    if found_parent && numel(ind)>0
                        error('First argument was a graphics object and ''Parent'' name-value pair was also specified');
                    end

                    if numel(ind)>1
                        error('''Parent'' name-value pair was specified multiple times');
                    end

                    if numel(ind)==1
                        this.Parent = varargin{ind+1};
                        this.ParentFigure = ancestor(this.Parent,'figure');
                        found_parent = true;
                        varargin(ind:ind+1) = [];
                    end
                end
                
                %if axes required but figure or panel specified
                if found_parent && ischar(this.DefaultParentType) && strcmpi(this.DefaultParentType,'axes') && ~strcmpi(this.Parent.Type,'axes')
                    
                    if strcmpi(this.Parent.Type,'figure') %use gca for figure
                        figure(this.Parent);
                        cp=false;
                        if isempty(this.Parent.CurrentAxes)
                            cp = true;
                        end
                        this.Parent = gca;
                        this.CreatedParent = cp;
                    else %otherwise create new axes
                        this.Parent = axes('Parent',this.Parent);
                        this.CreatedParent = true;
                    end
                    
                end
                
                if ~found_parent
                    this.CreateParent();
                end
            end
            
            other_args = varargin;
            
            this.ParentInitialized = true;
                        
        end
        
        function delete(this) %called when object is deleted
            delete(this.ParentDeleteListener);
            
            if this.CreatedParent
                delete(this.Parent);
            end
        end
    end
    
    methods
        function set.Parent(this,parent)
            assert(isgraphics(parent),'new parent must be a graphics object');
            
            if eq(this.Parent,parent)
                return;
            end
            
            delete(this.ParentDeleteListener);
                       
            
            this.Parent = parent;
            this.CreatedParent = false;
            
            
            this.ParentDeleteListener =addlistener(this.Parent,'ObjectBeingDestroyed',@(~,~) delete(this));
            
            %execute ChangeParent function
            this.ChangedParent();
            
            notify(this,'ParentChanged');
        end
    end
    
    %% overloadable function called when parent is changed
    methods(Access=protected)
        function ChangedParent(this)
        end
    end
    
    
end