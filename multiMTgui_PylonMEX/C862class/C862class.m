classdef (Sealed) C862class < handle
    %C862class - Interface to talk to a PI C862 rs323 Mercury Controller
    %Communication is handeled using the native command instructions
    %documented in C-862_User_MS74E843.pdf
    % This class is implemented as a singleton. To get a copy of a running
    % version of this class use
    %     c862obj = C862class.getInstance();
    % If there is no currently running version of C862class it will create
    % one.
    %
    % Copyright Daniel Kovari, 2015 - All rights reserved.
    
    properties (SetAccess = private)
        scom = [];
        PORT = '';
        BAUD = 9600;
        connected = false;
        nAxes = 0;
        ConnectedAxes = [];
        Axis=C862Axis.empty;
    end
    methods (Access=private)
        function this = C862class() %class constructor
            this.connected = false;
            
%             %get number of axes
%             stages = blanks(1024);
%             [ret,~,stages] = calllib(this.lib,'C843_qCST',this.ID_c843,'',stages,numel(stages)-1);
%             if ~ret
%                 warning('Could not execute C843_qCST, something is wrong with C843')
%             else
%                 x=textscan(sprintf(stages),'%c=%s');
%                 this.nAxes = numel(x{1});
%                 %create axis objects
%                 for n=this.nAxes:-1:1
%                     this.Axis(n) = C843Axis(this,x{1}(n));
%                 end
%             end
        end
    end
    methods (Static)
        function obj = getInstance() %function to get or create an instance of C843class
            persistent localObj
            if isempty(localObj) || ~isvalid(localObj)
                localObj = C862class();
            end
            obj = localObj;
        end
    end
    methods
        function status = ConnectCOM(this,PORT)
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
            %create serial port object
            this.scom = serial(PORT,'Baudrate',this.BAUD,'DataBits',8,'StopBits',1,'Parity','none');
            set(this.scom,'terminator',{3,'CR'}); %set terminator characters
            
            fopen(this.scom); %open com
            if strcmpi(this.scom.Status,'closed')
                this.connected = false;
                status = -1;
                disp('could not connect to serial port');
                return
            end
            this.PORT = PORT;
            %Scan for stages
            this.nAxes = 0;
            this.ConnectedAxes = [];
            
            fprintf('Scanning for Mercury Controllers on %s\n',PORT);
            for b = 15:-1:0
                str=[1,dec2hex(b),'xx'];
                fprintf(this.scom,str);
                fprintf(this.scom,'TB');
                t1=tic;
                while this.scom.BytesAvailable<=0
                    if toc(t1)>1
                        break;
                    end
                end
                if this.scom.BytesAvailable>0
                    resp = fgetl(this.scom);
                    %fprintf('Recieved: %s\n',resp);
                    fprintf('Found board: %d\n',b);
                    this.nAxes = this.nAxes+1;
                    this.ConnectedAxes = [b,this.ConnectedAxes];
                else
                    fprintf('Did not find board: %d\n',b);
                end
            end
            
            if this.nAxes == 0
                this.connected = false;
                status = false;
                disp('did not find any Mercury Contorllers');
                fprintf('Closing %s\n',PORT);
                fclose(this.scom);
                return;
            end
            
            %Setup Axes object for each found board
            for n=this.nAxes:-1:1
                this.Axis(n) = C862Axis(this,this.ConnectedAxes(n));
            end

            this.connected = true;
            status = true;
        end
        
        function delete(this) %destructor
            fprintf('Closing %s\n',this.PORT);
            fclose(this.scom);
        end
    end
end