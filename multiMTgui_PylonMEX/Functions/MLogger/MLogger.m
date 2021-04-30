classdef MLogger < handle
%MLogger - Class for opening and writing to a log file
% Using MLogger, you can open a log file, write to the log file, and create
% a GUI that lets users write to the log file using a simple terminal.
%
% Usage:
%   logger = MLogger('YOUR FILE NAME');
%               If don't enter a name, a default name containg the date and
%               time is used.
%  logger.open(file); Closes the currently file and opens a new file
%                     specified by file.
%  logger.write(str): writes str to the file
%                     str can be a char array or a cell array containing
%                     strings. Each element of the cell arrray is written
%                     as a different line.
%  logger.ShowGUI(): opens the interactive GUI terminal
%  logger.close(): closes the current log file;
%
%  This class has a delete method, so it should close the file and GUI when
%  it goes out of scope. However, becasue there's a callback for the figure
%  that references the class, objects will live past their scope if the GUI
%  is left open. In testing, it appears that MATLAB does delete the object
%  and close the file once the GUI is closed. To ensure that everything
%  closes when your program terminates you should call logger.close()
%  before exiting.
%
% This class depends on the following functions:
%       mlogger_openfile.m
%       mlogger_writestr.m
%       MLogger_GUI.m
% Make sure they are accessible from matlab path.
%==========================================================================
% Copyright 2016, Daniel T Kovari
% All rights reserved.

    properties
        hFigure = [];
        hHistory = [];
        hEdit = [];
        hMenuItem = [];
    end
    properties (SetAccess=private)
        fileID = [];
        filename = [];
    end    
    methods
        function delete(this)
            %'in delete'
            this.close();
        end
        function this = MLogger(file)
            if nargin<1 || isempty(file)
                file = ['MLogger - ',datestr(now,'yyyy-mm-dd HH-MM-SS'),'.log'];
            end
            this.open(file);
            
        end
        function write(this,str)
            outcell = mlogger_writestr(this.fileID,str);
            if ishghandle(this.hHistory)
                Lstr = get(this.hHistory,'string');
                Lstr = [Lstr;outcell];
                set(this.hHistory,'string',Lstr);
                set(this.hHistory,'value',numel(Lstr)-1);
            end
        end
        function open(this,file)
            was_gui_open = ishghandle(this.hFigure);
            if ~isempty(this.fileID)&&~isempty(fopen(this.fileID))
                this.close();
            end
            if ~ischar(file)
                [this.filename,permission] = fopen(file);
                if isempty(this.filename)
                    error('Specified fileID:%d is not currently open.',file);
                end
                if ~any(strncmpi(permission,{'w','a'},1))
                    warning('File was not opened for writing. Closing and reopening');
                    fclose(file);
                    file = mlogger_openfile(this.filename);
                end
                this.fileID = file;
            else
                this.filename = file;
                this.fileID = mlogger_openfile(this.filename);
            end
            if was_gui_open
                this.ShowGUI();
            end
        end
        function close(this)
            try
                delete(this.hFigure);
            catch
                %'did not close fig'
            end
            try
                fclose(this.fileID);
                this.filename = '';
            catch
                %'did not close file'
            end
        end
        function ShowGUI(this)
            if ishghandle(this.hFigure)
                figure(this.hFigure);
                return;
            end
            [this.fileID,this.filename,this.hFigure,this.hEdit,this.hHistory] = MLogger_GUI(this.fileID);
            %Add a menu to change the file
            % NOTE: This causes the class to live past it's scope.
            %       We may want to remove this feature or change how it is
            %       implemented. So far I haven't figured out a way around
            %       the problem.
            %       I've tried:
            %           using 'userdata' to pass the reference
            %           using anonymous functions
            %           using nested functions
            %       None seem to fix the problem.
            hMenu = uimenu(this.hFigure,'Label','File');
             this.hMenuItem = uimenu(hMenu,'Label','Change Log File','Callback',@change_file);
             set(this.hMenuItem,'userdata',this);
        end
        function change_file_gui(this,~,~)
            [file,path] = uiputfile('*.log','Select new log file',this.filename);
            if file==0
                return;
            end
            this.open(fullfile(path,file));
        end
    end
    
end

function change_file(hMenu,~)
logger=get(hMenu,'userdata');
logger.change_file_gui()
end


