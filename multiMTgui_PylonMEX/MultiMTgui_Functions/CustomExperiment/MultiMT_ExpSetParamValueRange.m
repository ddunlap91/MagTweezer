function MultiMT_ExpSetParamValueRange(hMain,hTbl)

handles = guidata(hMain);

col_name = hTbl.ColumnName{hTbl.ClickColumn};
sel_rows = hTbl.SelectedRows;

if numel(sel_rows)<2
    warndlg('Two or more rows must be selected','Set Range','modal');
    return;
end

if any(diff(sel_rows)>1)
    warndlg('Selected rows must be contiguous','Set Range','modal');
    return;
end

if any(strcmp(col_name,{'Step'}))
    return;
end

%% Gui Parameters
start_val = [];
end_val = [];
ok_pressed = false;

%% Build Dialog
row_height = 2;
fig_height = 4*row_height;
txt_offset = 0.5;
txt_height = 1;
row_pos = fig_height-1.25*row_height;
c1_pos  = 1;
label_w = 6;
c2_pos = 7.5;
box_w = 7;

fig_width = 7.5+7+1;

hDlg = figure('Name',col_name,...
    'units','characters',...
    'Resize','off',...
    'ToolBar','none',...
    'NumberTitle','off',...
    'DockControls','off',...
    'MenuBar','none');

% size figure
pos = get(hDlg,'position');
set(hDlg,'position',[pos(1),pos(2),fig_width,fig_height]);

%Start Value
    function start_callback(hObj,~)
        [bool,val] = MultiMT_ExpCheckVal(str2double(get(hObj,'string')),col_name,hMain);
        if bool
            start_val = val;
        end
        set(hObj,'string',num2str(start_val));
    end
uicontrol('Parent',hDlg,...
            'Style','text',...
            'units','characters',...
            'position',[c1_pos,row_pos+txt_offset,label_w,txt_height],...
            'HorizontalAlignment','right',...
            'String','Start:');
uicontrol('Parent',hDlg,...
            'Style','edit',...
            'units','characters',...
            'position',[c2_pos,row_pos,box_w,row_height],...
            'HorizontalAlignment','left',...
            'String',num2str(start_val),...
            'Callback',@start_callback);
row_pos = row_pos-row_height;
%End Value
    function end_callback(hObj,~)
        [bool,val] = MultiMT_ExpCheckVal(str2double(get(hObj,'string')),col_name,hMain);
        if bool
            end_val = val;
        end
        set(hObj,'string',num2str(end_val));
    end
uicontrol('Parent',hDlg,...
            'Style','text',...
            'units','characters',...
            'position',[c1_pos,row_pos+txt_offset,label_w,txt_height],...
            'HorizontalAlignment','right',...
            'String','End:');
uicontrol('Parent',hDlg,...
            'Style','edit',...
            'units','characters',...
            'position',[c2_pos,row_pos,box_w,row_height],...
            'HorizontalAlignment','left',...
            'String',num2str(end_val),...
            'Callback',@end_callback);
  
%ok button
row_pos = row_pos-1.1*row_height; 
    function ok_callback(~,~)
        ok_pressed = true;
        delete(hDlg);
    end

uicontrol('Parent',hDlg,...
            'Style','pushbutton',...
            'units','characters',...
            'position',[fig_width/2-5,row_pos,10,row_height],...
            'HorizontalAlignment','center',...
            'String','OK',...
            'Callback',@ok_callback);
        
%% wait for figure close
waitfor(hDlg);
if ~ok_pressed
    return;
end

%% Calculate range
range = linspace(start_val,end_val,numel(sel_rows));
%format values for the selected column
switch col_name
    case 'FrameCount'
        range = round(range);
    case 'Duration'
    case 'ObjectivePosition'
    case 'MagentHeight'
    case 'MagnetRotation'
end

%% set values
for n=1:numel(range)
    handles.ExperimentScheme.ExperimentSteps(sel_rows(n)).(col_name) = range(n);
end

%% Update
%update table data
MultiMT_ExpUpdateTableData(hTbl,handles.ExperimentScheme);

%Save data
guidata(hMain,handles);

end
