function MultiMTgui_closeForceExtension(hMain)

handles = guidata(hMain);

try
    delete(handles.hFig_ForceExtension);
catch
end
handles.FE_open = false;
if ~handles.CC_open
    handles.ExperimentWindowOpen = false;
end
set(handles.hMenu_MeasureForceExtension,'checked','off');
%save data
guidata(hMain,handles);