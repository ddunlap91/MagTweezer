classdef (Sealed) E816class < handle
    %E816class - Interface to talk to a PI E816 RS232 Interface using dll.
    % This class is implemented as a singleton. To get a copy of a running
    % version of this class use
    %     e816obj = E816class.getInstance();
    % If there is no currently running version of E816class it will create
    % one.
    %
    % Copyright Daniel Kovari, 2015 - All rights reserved.
    
    properties (SetAccess = private)
        thisdir = '';
        libfile = '';
        headerfile = '';
        lib = 'E816_DLL';
        ID_e816 = -1;
        nAxes = 0;
        Axis=E816Axis.empty;
        COM = 0;
        BAUD = 0;
        connected = false;
    end
    methods (Access=private)
        function this = E816class() %class constructor
            this.thisdir = fileparts(mfilename('fullpath'));
            switch computer('arch')
                case 'win64'
                    this.libfile = fullfile(this.thisdir,'E816_DLL_x64.dll');
                case 'win32'
                    this.libfile = fullfile(this.thisdir,'E816_DLL.dll');
                otherwise
                    error('The E816class is designed to work with windows 32 or 64 bit os');
            end
            this.headerfile = fullfile(this.thisdir,'E816_DLL.h');
            if(~libisloaded(this.lib))
                disp('Loading the E816 Library');
                loadlibrary (this.libfile,this.headerfile,'alias',this.lib);
            end
            this.connected = false;
        end
        
    end
    methods (Static)
        function obj = getInstance() %function to get or create an instance of E816class
            persistent localObj
            if isempty(localObj) || ~isvalid(localObj)
                localObj = E816class();
            end
            obj = localObj;
        end
    end
    methods
        function status = ConnectCOM(this,PORT,BAUD)
            if this.connected
                %already connected, disconnect and reconnect
                disp('Closing connection to E816');
                calllib(this.lib, 'E816_CloseConnection',this.ID_e816);
                this.connected = false;  
            end
            %try to connect to the piezo
            if ischar(PORT)
                old_PORT = PORT;
                PORT = sscanf(upper(PORT),'COM%d');
                if isempty(PORT)
                    error('Couldnt read port: %s',old_PORT);
                end
            end
            fprintf('Attempting to connect to E816 on COM%d at BAUD=%d\n',PORT,BAUD);
            this.ID_e816 = calllib(this.lib, 'E816_ConnectRS232',PORT,BAUD);
            if this.ID_e816 == -1
                warning('Could not connect to E816. Make sure it is plugged in. Check device manager to make sure COM%d is listed',PORT);
                status = false;
                return;
            end
            this.COM = PORT;
            this.BAUD = BAUD;

            %query the piezo controller to make sure everything is working
            % preload return variable
            idn = blanks(100);
            % query Identification string
            [~,idn] = calllib(this.lib,'E816_qIDN',this.ID_e816,idn,100);
            fprintf('Connected to %s\n',idn);
            % query baud rate
            bdr = 0;
            [~,bdr] = calllib(this.lib,'E816_qBDR',this.ID_e816,bdr);
            fprintf('Connection speed: %d baud\n',bdr);
            this.BAUD = bdr;
            
            this.connected = true;
            
            %Setup Axis
            this.Axis = E816Axis(this,'A');
            status = true;
        end
        function delete(this) %destructor
            calllib(this.lib,'E816_CloseConnection',this.ID_e816);
        end
    end
end