classdef ComSelectorUI < extras.GraphicsChild
    % User interface for managing the com connection for
    % extras.SerialDevice type objects
    
    properties (SetAccess=protected)
        serialdevice
    end
    
    properties (Access=protected)
        OuterContainer
        com_popmenu;
        com_string = [];
        
        con_discon_button;
        
        ComListTimer = timer();
        
        SerialDeleteListener
        ConnectedListener
    end
    
    %% Create
    methods
        function this = ComSelectorUI(varargin)
        % Create ComSelectorUI
        %   obj = ComSelectorUI(serialdevice)
        %   obj = ComSelectorUI(parent,serialdevice)
        %           parent is the graphics parent in which ui is created
        %   obj = ComSelectorUI(serialdevice,'Parent',parent)
        %   obj =ComSelectorUI('SerialDevice',serialdevice,'Parent',parent)
        
            %initiate graphics parent related variables
            this@extras.GraphicsChild(@() figure('menubar','none'));
            %look for parent specified in arguments
            other_args = this.CheckParentInput(varargin{:});
            
            %% Look for serialdevice
            if numel(other_args)<1
                error('serialdevice not specified');
            end
            
            found_serialdevice = false;
            if isa(other_args{1},'extras.SerialDevice')
                this.serialdevice = other_args{1};
                other_args(1)=[];
                found_serialdevice = true;
            end
            
            if numel(other_args)>1
                ind = find(strcmpi('SerialDevice',varargin));
                if found_serialdevice && numel(ind)>0
                    error('First argument was a serial device and ''SerialDevice'' name-value pair was also specified');
                end

                if numel(ind)>1
                    error('''SerialDevice'' name-value pair was specified multiple times');
                end

                if numel(ind)==1
                    this.serialdevice = other_args{ind+1};
                    found_serialdevice = true;
                    other_args(ind:ind+1) = [];
                end
            end
            
            if ~found_serialdevice
                error('serial device was not specified in the arguments');
            end
            
            %% Create GUI Elements
            this.OuterContainer = uix.VBox('Parent',this.Parent);
            
            hb = uix.HBox('Parent',this.OuterContainer);
            this.OuterContainer.Heights = 40;
            
            uicontrol('Parent',hb,...
                'style','text',...
                'string','COM Port:');
            
            list = extras.SerialDevice.serialportlist();
            if isempty(list)
                list = ' ';
            end
            
            this.com_popmenu = uicontrol('Parent',hb,...
                'style','popupmenu',...
                'String',list,...
                'Enable','on',...
                'Callback',@(~,~) this.ChangePopMenu());
            
            this.con_discon_button = uicontrol('Parent',hb,...
                'style','pushbutton',...
                'String','Connect',...
                'Callback',@(~,~) this.ToggleConnect());
            
            hb.Widths = [70,-1,110];
            
            %% Listeners
            %for serial device delete
            this.SerialDeleteListener = addlistener(this.serialdevice,'ObjectBeingDestroyed',@(~,~) delete(this));
            
            %listener for connection change
            this.ConnectedListener = addlistener(this.serialdevice,'connected','PostSet',@(~,~) this.ConnectedChanged());
                
            
            %% Timer for com list
            this.ComListTimer = timer(...
                'BusyMode','drop',...
                'Period',2,...
                'ObjectVisibility','off',...
                'TimerFcn',@(~,~) this.UpdateComList());
            
            start(this.ComListTimer);

            
        end
        
        function delete(this)
            delete(this.SerialDeleteListener);
            delete(this.ConnectedListener);
            
            stop(this.ComListTimer);
            delete(this.ComListTimer);
            
            delete(this.OuterContainer);
            
        end
    end
    
    %% Callbacks
    methods (Hidden)
        function ToggleConnect(this)
            if ~this.serialdevice.connected %not connected, try to connect
                if isempty(this.com_string)
                    warndlg('Select COM Port before connecting','Select COM');
                    return;
                end
                
                this.serialdevice.ConnectCOM(this.com_string);
            else
                this.serialdevice.DisconnectCOM();
            end
        end
        
        function ConnectedChanged(this)
            if this.serialdevice.connected
                this.con_discon_button.String = 'Disconnect';
                this.com_popmenu.Enable = 'off';
            else
                this.con_discon_button.String = 'Connect';
                this.com_popmenu.Enable = 'on';
            end
        end
        
        function ChangePopMenu(this)
            this.com_string = this.com_popmenu.String{this.com_popmenu.Value};
        end
        
        function UpdateComList(this)
            if ~isvalid(this)
                return
            end
            list = extras.SerialDevice.serialportlist();
            if isempty(list)
                this.com_popmenu.String = ' ';
            else
                this.com_popmenu.String = list;
            end
        end
        
    end
end