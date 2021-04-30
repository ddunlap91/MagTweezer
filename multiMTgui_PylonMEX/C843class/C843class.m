classdef (Sealed) C843class < handle
    %C843class - Interface to talk to a PI C843 PCI card using the GCS dll.
    % This class is implemented as a singleton. To get a copy of a running
    % version of this class use
    %     c843obj = C843class.getInstance();
    % If there is no currently running version of C843class it will create
    % one.
    %
    % Copyright Daniel Kovari, 2015 - All rights reserved.
    
    properties (SetAccess = private)
        thisdir = '';
        libfile = '';
        headerfile = '';
        lib = 'C843_DLL';
        connected = false;
        ID_c843 = -1;
        nAxes = 0;
        Axis=C843Axis.empty;
    end
    methods (Access=private)
        function this = C843class() %class constructor
            disp("asdasd")
            this.thisdir = fileparts(mfilename('fullpath'));
            switch computer('arch')
                case 'win64'
                    this.libfile = fullfile(this.thisdir,'C843_GCS_DLL_x64.dll');
                case 'win32'
                    this.libfile = fullfile(this.thisdir,'C843_GCS_DLL.dll');
                otherwise
                    error('The C843class is designed to work with windows 32 or 64 bit os');
            end
            this.headerfile = fullfile(this.thisdir,'C843_GCS_DLL.h');
            if(~libisloaded(this.lib))
                disp('Loading the C843 Library');
                loadlibrary (this.libfile,this.headerfile,'alias',this.lib);
            end
            % Try to initiate communication with the card
            sPCIList = blanks(255); %pre-initialize the variable
            [ret,sPCIList] = calllib(this.lib,'C843_ListPCI',sPCIList,numel(sPCIList)-1);
            if ret~=1
                warning('problem with C843_ListPCI');
                this.connected = false;
                return;
            end

            if str2double(sPCIList)<1
                warning('No C843 PIC cards found');
                this.connected = false;
                return;
            end

            %try to connect
            this.ID_c843 = calllib(this.lib,'C843_Connect',1);
            if this.ID_c843 < 0
                warning('Could not connect to C843');
                this.connected = false;
                return;
            else
                this.connected = true;
            end
            
            %get number of axes
            stages = blanks(1024);
            [ret,~,stages] = calllib(this.lib,'C843_qCST',this.ID_c843,'',stages,numel(stages)-1);
            if ~ret
                warning('Could not execute C843_qCST, something is wrong with C843')
            else
                x=textscan(sprintf(stages),'%c=%s');
                this.nAxes = numel(x{1});
                disp(this.nAxes);
                disp("ASDASDASDASDASDASDASD")
                %create axis objects
                for n=this.nAxes:-1:1
                    this.Axis(n) = C843Axis(this,x{1}(n));
                end
            end
        end
    end
    methods (Static)
        function obj = getInstance() %function to get or create an instance of C843class
            persistent localObj
            if isempty(localObj) || ~isvalid(localObj)
                localObj = C843class();
            end
            obj = localObj;
        end
    end
    methods
        function delete(this) %destructor
            calllib(this.lib,'C843_CloseConnection',this.ID_c843);
        end
    end
end