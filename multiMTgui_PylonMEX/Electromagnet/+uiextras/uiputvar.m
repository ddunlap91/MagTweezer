function uiputvar(var1,defaultName)
% UIPUTVAR
% Put a copy of a variable on to the base workspace.
% Generates a menu prompting the user to specifiy a name to save the
% variable specified as in the base workspace.
%
% Input:
%   variable or 'VariableName' to save to the WS
%
%   defaultName: (optional) specify string to use as default variable name
%               if not included default name will be variable name passed
%               as var1.
%               if var1 is not a variable but the return argument of a
%               function then the default name is 'var1'

if nargin>1 && ischar(defaultName) %user specified a default name
    varname = defaultName;
else
    varname = inputname(1);
    if isempty(varname)
        if ischar(var1)
            if ~ismember(var1,evalin('caller','who'))
                warning('PUTVAR:novariable', ...
              ['Did not assign input variable', ...
              ' as no caller workspace variable was available for that input.']);
                return;
            end
            varname = var1;
            var1 = evalin('caller',varname);
        else %user passed some complicated argument as var1
            varname = 'var1';
        end
    end
end

%create dialog with variable list or 
basevars = evalin('base','who'); %variables in base

if ismember(varname,basevars)
    LstVal = find(strcmp(varname,basevars));
else
    LstVal = 1;
end

hDlg = dialog('Name','Specify Output Variable',...
    'units','characters',...
    'position',[0,0,50,30],...
    'CloseRequestFcn',@CancelCB);
movegui(hDlg,'center');

%% create dialog elements
uicontrol('parent',hDlg,...
                 'style','pushbutton',...
                 'units','characters',...
                 'position',[0,0,24.5,2],...
                 'string','OK',...
                 'Callback',@OKCB);
uicontrol('parent',hDlg,...
                 'style','pushbutton',...
                 'units','characters',...
                 'position',[25.5,0,24.5,2],...
                 'string','Cancel',...
                 'Callback',@CancelCB);

uicontrol('parent',hDlg,...
    'style','text',...
    'units','characters',...
    'position',[0,2.4,10,1.2],...
    'string','Name:');

hStr = uicontrol('parent',hDlg,...
                 'style','edit',...
                 'units','characters',...
                 'String',varname,...
                 'position',[10.5,2,39.5,2],...
                 'Callback',@EditCB);

hLst = uicontrol('parent',hDlg,...
            'style','listbox',...
            'units','characters',...
            'position',[0,5,50,30-5],...
            'String',basevars,...
            'value',LstVal,...
            'max',1,'min',0,...
            'Callback',@ListCB);

%% wait for dialog to close, then save data to workspace
uiwait(hDlg);

if ~isempty(varname)
    assignin('base',varname,var1);
end
%% callbacks        
    function OKCB(~,~)
        varname = get(hStr,'string');
        delete(hDlg);
    end
            
    function CancelCB(~,~)
        varname = [];
        delete(hDlg);
    end
    
    function ListCB(~,~)
        set(hStr,'String',basevars{get(hLst,'Value')});
    end
    function EditCB(~,~)
        %set(hLst,'Value',[]);
    end
end