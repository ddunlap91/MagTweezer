function [fileID,filename,hFigure,hEdit_LoggerField,hEdit_LoggerHistory] = MLogger_GUI(file)
% Opens GUI terminal for reading and writing to a MLogger log file


if nargin<1
    file = ['MLogger - ',datestr(now,'yyyy-mm-dd HH-MM-SS'),'.log'];
    file = mlogger_openfile(file);
end

%% Setup GUI
edit_height = 2; %characters
padding = 0.3;

hFigure = figure('Name','MLogger',...
    'MenuBar','none',...
    'ToolBar','none');
set(hFigure,'units','characters');
fig_pos = get(hFigure,'position');
e_p = [padding,padding,fig_pos(3)-2*padding,edit_height];
l_p = [padding,e_p(2)+e_p(4)+padding,fig_pos(3)-2*padding,fig_pos(4)-(e_p(2)+e_p(4)+2*padding)];

hEdit_LoggerField = uicontrol('Parent',hFigure,...
                              'Style','edit',...
                              'Enable','on',...
                              'Min',0,...
                              'Max',2,...
                              'TooltipString','Press Ctrl+Enter to write text to log.',...
                              'Selected','on',...
                              'HorizontalAlignment','left',...
                              'units','characters',...
                              'position',e_p);
                              

hEdit_LoggerHistory = uicontrol('Parent',hFigure,...
                                'Style','listbox',...
                                'Enable','inactive',...
                                'SelectionHighlight','off',...
                                'FontName','FixedWidth',...
                                'Min',0,...
                                'Max',2,...
                                'HorizontalAlignment','left',...
                                'units','characters',...
                                'position',l_p);
    function ResizeFig(hFig,~)
        old_units = get(hFig,'units');
        set(hFig,'units','characters');
        fp = get(hFig,'position');
        ep = [padding,padding,fp(3)-2*padding,edit_height];
        lp = [padding,ep(2)+ep(4)+padding,fp(3)-2*padding,fp(4)-(ep(2)+ep(4)+2*padding)];
        set(hEdit_LoggerField,'units','characters','position',ep);
        set(hEdit_LoggerHistory,'units','characters','position',lp);
        set(hFig,'units',old_units);
    end
set(hFigure,'SizeChangedFcn',@ResizeFig);

%Add uicontrol handles to guidata so that end user can talk to them via hFigure
handles = guidata(hFigure);
handles.hEdit_LoggerField = hEdit_LoggerField;
handles.hEdit_LoggerHistory  = hEdit_LoggerHistory ;
guidata(hFigure,handles);

%% Setup File
if ~ischar(file)
    filename = fopen(file);
    if isempty(filename)
        error('Specified fileID is not currently open.');
    end
    fclose(file); %close file so we can reopen it in read mode
else
    filename = file;
end
if exist(filename,'file')
    [fileID,Err] = fopen(filename,'r');
    if fileID == -1
        error('Could not open %s for reading. Error: %s',filename,Err);
    end
    %read text and add to log history
    str = {};
    while ~feof(fileID)
        str = [str;fgetl(fileID)];
    end
    set(hEdit_LoggerHistory,'string',str);
    set(hEdit_LoggerHistory,'value',numel(str));
    fclose(fileID);
end
fileID = mlogger_openfile(filename);

    function EditCallback(hEdt,~)
        outcell = mlogger_writestr(fileID,cellstr(get(hEdt,'string')));
        Lstr = get(hEdit_LoggerHistory,'string');
        Lstr = [Lstr;outcell];
        set(hEdit_LoggerHistory,'string',Lstr);
        set(hEdt,'string','');
        %scroll to bottom
        set(hEdit_LoggerHistory,'value',numel(Lstr)-1);
        %[obs,nobs] = getListenable(hEdit_LoggerHistory)
    end
set(hEdit_LoggerField,'Callback',@EditCallback);
                                
end