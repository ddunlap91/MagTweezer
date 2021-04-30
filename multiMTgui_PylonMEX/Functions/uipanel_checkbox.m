function [hPanel,hChk] = uipanel_checkbox(varargin)
%uipanel_checkbox - Create Panel with checkbox replacing title with a
%checkbox. The checkbox acts as an enable/disable button for the children
%of the panel.
%Syntax:
%   [p,c] = uipanel_checkbox() -- create panel with checkbox
%   [p,c] = uipanel_checkbox(Name,Value) -- set properties with name-value pairs 
%   [p,c] = uipanel_checkbox(parent) -- specify parent figure or panel
%   [p,c] = uipanel_checkbox(parent,Name,Value)
%Returns:
%   p: handle to panel
%   c: handle to checkbox
% Note: The checkbox is checked by default because you cannot automatically
% change the enable state for objects created inside the panel. To set the
% value of the checkbox programatically, simply call set(c,'value',__)
% It's a good idea to do this after you have added all the elements to the
% panel.
%Parameters:
% The function accepts all the parameters of uipanel and passes those on
% when calling the p = uipanel().
% Note:
%   The 'Title' parameter will be intercepted and used as the checkbox
%   string
% Discarded Properties
%   'TitlePosition' Checkbox will always be located at top-left
%
% Additionally, you can specify checkbox-specific properties
%   'Value', true/false: value of checkbox (default=true);
%   'Behavior', 
%       'enable': checkbox controls the enable/disable state of the panel
%       'Callback_only': checkbox simply calls the specified callback fn
%   'Callback',fun
%       Set the callback function executed by the checkbox
%       optionally include other arguments using MATLAB's standard cell
%       form:
%           e.g.  yourFN = {fn,arg3,arg4,...};
%           where: fn = @(hPanel,hChk,arg1,arg2,...) (YOUR FUNCTION HERE)
%       See: help Callback Definition for more info
%   'UseListener', true/false (default: true)
%       If 'UseListener' is true, then a listener function is attached to the
%       value of the checkbox.  If the value is changed the Enable/Disable
%       and Callback functions are called according to defined 'Behavior'
%       option. Consequently, changing the checkbox value in software (e.g.
%       hChk.Value = ___) will execute the callbacks.
%       If 'UseListener' is false, then the user specified callback 
%       functions is only executed when the checkbox is changed in the gui.
%       Setting the hChk.Value will only change the enable state of the
%       the panel's children
%=========================================================================
% Copyright 2016, Daniel T. Kovari, Emory University

p = inputParser;

p.CaseSensitive = false;
p.KeepUnmatched = true;

addParameter(p,'UseListener',true,@isscalar);
addParameter(p,'Behavior','enable',@(x) any(strcmpi(x,{'enable','Callback_only'})));
addParameter(p,'Callback',[],...
    @(x) isempty(x)||...
         isa(x,'function_handle')||...
         (iscell(x)&&isa(x{1},'function_handle')));
addParameter(p,'Title','',@ischar);
addParameter(p,'TitlePosition','lefttop');
%handle units and positon specially because order matters
addParameter(p,'Units',[]); 
addParameter(p,'Position',[]);
addParameter(p,'Value',true,@(x) isscalar(x));
if nargin>0 && ~ischar(varargin{1}) && isscalar(varargin{1}) && ishghandle(varargin{1})
    hParent = varargin{1};
    parse(p,varargin{2:end});
else
    addParameter(p,'Parent',[],@(x) isempty(x)||ishghandle(x));
    parse(p,varargin{:});
    hParent = p.Results.Parent;
end

%restructure unmatched args into name-value pairs
pnl_args = [reshape(fieldnames(p.Unmatched),1,[]);...
            reshape(struct2cell(p.Unmatched),1,[])];
%create panel

if isempty(hParent)
    hPanel = uipanel(pnl_args{:},'Title','-');
else
    
    hPanel = uipanel('parent',hParent,pnl_args{:},'Title','-');
end


if ~isempty(p.Results.Units)
    set(hPanel,'Units',p.Results.Units);
end
if ~isempty(p.Results.Position)
    set(hPanel,'Position',p.Results.Position);
end

%create checkbox
hChk = uicontrol('Style','checkbox','HandleVisibility','callback','Parent',get(hPanel,'parent'),'String',p.Results.Title,'Value',logical(p.Results.Value));
%set font styles same as panel
set(hChk,...
    'FontName',get(hPanel,'FontName'),...
    'FontSize',get(hPanel,'FontSize'),...
    'FontUnits',get(hPanel,'FontUnits'),...
    'FontWeight',get(hPanel,'FontWeight'),...
    'FontAngle',get(hPanel,'FontAngle'));

pnl_origunits = get(hPanel,'units');
set(hPanel,'units','pixels');
set(hChk,'units','pixels');
pnl_pos = get(hPanel,'position');
chk_pos = get(hChk,'position');

if isempty(get(hChk,'string'))
    chk_pos(3) = chk_pos(4);
end

set(hChk,'position',[pnl_pos(1)+5,pnl_pos(2)+pnl_pos(4)-chk_pos(4)+2,chk_pos(3),chk_pos(4)]);
set(hPanel,'units',pnl_origunits);

%delete checkbox with pane
set(hPanel,'DeleteFcn',@(src,~) delete([src,hChk]));
set(hPanel,'ResizeFcn',@(src,evt)PanelPosChange(src,evt,hChk));

%Set checkbox callback
    function BothFn(~,~)
        CheckCallbackToggleEnable(hPanel,hChk);
        if isa(p.Results.Callback,'function_handle')
            p.Results.Callback(hPanel,hChk);
        elseif iscell(p.Results.Callback)
            p.Results.Callback{1}(hPanel,hChk,p.Results.Callback{2:end});
        end
    end
CBfn = [];
if p.Results.UseListener
    switch(lower(p.Results.Behavior))
        case 'enable'
            CBfn = @BothFn;
        case 'callback_only'
            if isa(p.Results.Callback,'function_handle')
                CBfn = @(~,~) p.Results.Callback(hPanel,hChk);
            elseif iscell(p.Results.Callback)
                CBfn = @(~,~) p.Results.Callback{1}(hPanel,hChk, p.Results.Callback{2:end});
            end
    end
else
    if strcmpi(p.Results.Behavior,'enable')
        CBfn = @(~,~) CheckCallbackToggleEnable(hPanel,hChk);
    end
    if isa(p.Results.Callback,'function_handle')
        set(hChk,'Callback',@(~,~) p.Results.Callback(hPanel,hChk))
    elseif iscell(p.Results.Callback)
        set(hChk,'Callback',@(~,~) p.Results.Callback{1}(hPanel,hChk, p.Results.Callback{2:end}));
    end
end
%set(hChk,'Callback',CBfn);
addlistener(hChk,'Value','PostSet',CBfn);

set(hChk,'Value',1);

end

function CheckCallbackToggleEnable(hPanel,hChk)
%disp('toggle');
pnl_children = get(hPanel,'children');

if ~get(hChk,'Value') %unchecked
    for n=1:numel(pnl_children)%child = pnl_children
        RecursiveDisable(pnl_children(n));
    end
else %checked
    for n=1:numel(pnl_children)%child = pnl_children
        RecursiveEnable(pnl_children(n));
    end
end
end

function RecursiveDisable(hObj)
if isprop(hObj,'Children')
    for child = get(hObj,'Children')
        RecursiveDisable(child);
    end
end
if isprop(hObj,'Enable')
    %hObj
    ud = get(hObj,'userdata');
    %if isempty(ud)
    %    ud = struct('prev_enable',0)
    %end
    %get(hObj,'Enable')
    ud.prev_enable = get(hObj,'Enable');
    set(hObj,'userdata',ud);
    set(hObj,'Enable','off');
end
end

function RecursiveEnable(hObj)
if isprop(hObj,'Children')
    for child = get(hObj,'Children')
        RecursiveEnable(child);
    end
end
if isprop(hObj,'Enable')
    ud = get(hObj,'userdata');
    if isfield(ud,'prev_enable')
        set(hObj,'Enable',ud.prev_enable);
    end
end
end


function PanelPosChange(hPanel,~,hChk)
%disp('in pnl pos change');
pnl_origunits = get(hPanel,'units');
set(hPanel,'units','pixels');
set(hChk,'units','pixels');
pnl_pos = get(hPanel,'position');
chk_pos = get(hChk,'position');
set(hChk,'position',[pnl_pos(1)+5,pnl_pos(2)+pnl_pos(4)-chk_pos(4)+2,chk_pos(3),chk_pos(4)]);
set(hPanel,'units',pnl_origunits);
end
