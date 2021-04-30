classdef SerialDevice < matlab.mixin.SetGet & matlab.mixin.Heterogeneous
    % simple class for managing a single serial device
    % extend this class to add functionality
    
    properties (SetAccess=protected)
        Port = '';
    end
    
    properties (SetAccess=protected,Hidden=true)
        scom = [];
        
        BaudRate = 9600;
        DataBits = 8;
        StopBits = 1;
        Parity = 'none';
        Terminator = 'CR';
        
        BytesAvailableFcnMode = 'terminator';
        Timeout = 10;
        ByteOrder = 'littleEndian';
    end
    
    properties (Dependent)
        BytesAvailable
    end
    
    properties (Access=protected)
        BytesAvailableFcn;
    end
    
    events
        DataRecieved
    end
    
    properties (SetAccess=protected,SetObservable=true,AbortSet=true)
        connected = false;
    end
    
    %% default object
    methods (Static, Sealed, Access = protected)
       function default_object = getDefaultScalarElement
           default_object = SerialDevice;
       end
    end
    
    %% Create/Delete
    methods
        function this = SerialDevice(port,varargin)
            % obj = SerialDevice(port)
            %       SerialDevice(port,'Name',value,...)
            %       SerialDevice('Port',Portvalue,...)
            
            this.connected = false;
            this.BytesAvailableFcn = @(so,evt) notify(this,'DataRecieved',extras.hardware.serialevent(so,evt));
            
            %% Look for port in input arguments
            if nargin<1
                return;
            end
            
            if nargin == 1
                assert(ischar(port),'Specified Port must be a char array');
                this.Port = port;
            elseif ischar(port) && ~strcmpi(port,'port')
                this.Port = port;
            else
                assert(ischar(port),'first argument must be char array, either string specifying port value (e.g. ''COM1'') or atart of Name-Value pair');
                varargin = [port,varargin];
            end
            
            %% set other arguments
            set(this,varargin{:});
            
            %% If port specified, start serial
            if ~isempty(this.Port)
                this.ConnectCOM(this.Port);
            end
        end
        
        function delete(this)
            this.DisconnectCOM();
        end
        
    end
    
    %% Get Methods
    methods
        function val = get.BytesAvailable(this)
            if ~isvalid(this.scom)
                warning('serial device has not been initiated, cannot get BytesAvailable');
                val = 0;
                return;
            end
            val = this.scom.BytesAvailable;
        end
    end
    
    %% Set Methods
    methods
        function set.Port(this,port)
            assert(ischar(port),'Port must be a char array specifying com port name (e.g. ''COM4'')');
            this.Port = port;
        end
    end
    
    %% Overload f___() functions
    methods (Hidden) %Hidden because we don't want to advertise they are here
        function varargout = fgetl(this,varargin)
            [varargout{:}] = fgetl(this.scom,varargin{:});
        end
        function varargout = fgets(this,varargin)
            [varargout{:}] = fgets(this.scom,varargin{:});
        end
        function varargout = fread(this,varargin)
            [varargout{:}] = fread(this.scom,varargin{:});
        end
        function varargout = fscanf(this,varargin)
            [varargout{:}] = fscanf(this.scom,varargin{:});
        end
        function fwrite(this,varargin)
            fwrite(this.scom,varargin{:});
        end
        function fprintf(this,varargin)
            fprintf(this.scom,varargin{:});
        end
    end
    
    %% Connect/Disconnect Functions
    methods
        function ConnectCOM(this,PORT)
            if this.connected
                %already connected, disconnect and reconnect
                disp('Serial Port alread connected, trying to disconnect and reconnect');
                try
                    fclose(this.scom);
                catch
                    error('could not close scom');
                end
                this.connected = false;  
            end
            
            if nargin<2
                PORT = this.Port;
            end
            
            if isempty(PORT) || ~ischar(PORT)
                error('PORT must be char array specifying valid serial port (e.g. ''COM4'')');
            end
            
            %create serial port object
            this.scom = serial(PORT,...
                'Baudrate',this.BaudRate,...
                'DataBits',this.DataBits,...
                'StopBits',this.StopBits,...
                'Parity',this.Parity,...
                'Terminator',this.Terminator,...
                'ReadAsyncMode','continuous',...
                'BytesAvailableFcnMode',this.BytesAvailableFcnMode,...
                'Timeout',this.Timeout,...
                'ByteOrder',this.ByteOrder,...
                'BytesAvailableFcn',this.BytesAvailableFcn);

            try
                fopen(this.scom); %open com
            catch
                try
                   fclose(instrfind('Port',PORT));
                   fopen(this.scom);
                   assert(strcmpi(this.scom.Status,'open'));
                catch
                    this.connected = false;
                    %status = -1;
                    disp('could not connect to serial port');
                    return
                end
            end

            if strcmpi(this.scom.Status,'closed')
                this.connected = false;
                %status = -1;
                disp('could not connect to serial port');
                return                
            end
            this.Port = PORT;
            
            %% Call overloadable validation function
            try
                this.validateConnection();
            catch ME
                disp(ME.getReport());
                this.connected = false;
                %status = -1;
                disp('validation function threw an error');
                return;
            end
            
            %% statue good
            this.connected = true;
        end
        
        function DisconnectCOM(this)
            if this.connected
                fclose(this.scom);
                this.scom = [];
                this.connected = false;
            end
        end
    end
    
    %% static
    methods (Static)
        function lCOM_Port = serialportlist()
        % serialportlist - List available serial ports
        %   Function should work for older version of matlab
        % Output:
        %   Returns cell array of available serial ports.
        %   If none are available returns empty cell
        
        lCOM_Port = convertStringsToChars(seriallist);
        if ischar(lCOM_Port)
            lCOM_Port = {lCOM_Port};
        end
        
        %% OLD CODE
%             try
%                 s=serial('IMPOSSIBLE_NAME_ON_PORT');fopen(s); 
%             catch MExcept
%                 %disp(MExcept)
%                 lErrMsg = MExcept.message;
%             end
% 
%             %Start of the COM available port
%             lIndex1 = strfind(lErrMsg,'COM');
%             %End of COM available port
%             lIndex2 = strfind(lErrMsg,'Use')-3;
% 
%             lComStr = lErrMsg(lIndex1:lIndex2);
% 
%             %Parse the resulting string
%             lIndexDot = strfind(lComStr,',');
% 
%             % If no Port are available
%             if isempty(lIndex1)
%                 lCOM_Port = {};
%                 return;
%             end
% 
%             % If only one Port is available
%             if isempty(lIndexDot)
%                 lCOM_Port{1}=lComStr;
%                 return;
%             end
% 
%             lCOM_Port = cell(numel(lIndexDot)+1,1);%lComStr(1:lIndexDot(1)-1);
% 
%             for i=1:numel(lIndexDot)+1
%                 % First One
%                 if (i==1)
%                     lCOM_Port{1} = lComStr(1:lIndexDot(i)-1);
%                 % Last One
%                 elseif (i==numel(lIndexDot)+1)
%                     lCOM_Port{i} = lComStr(lIndexDot(i-1)+2:end);       
%                 % Others
%                 else
%                     lCOM_Port{i} = lComStr(lIndexDot(i-1)+2:lIndexDot(i)-1);
%                 end
%             end
         end
    end
    
    %% overload these functions to change behavior
    methods (Access=protected)
        function validateConnection(this)
            %do nothing
        end
    end
    
    %% Sealed
    methods (Sealed)
        function tf = eq(A,B)
            tf = eq@handle(A,B);
        end
        function tf = ne(A,B)
            tf = ne@handle(A,B);
        end
    end
end