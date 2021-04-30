function MultiMTgui_closeChapeauCurve(hMain)

handles = guidata(hMain);

try
    delete(handles.hFig_ChapeauCurve);
catch
end
handles.CC_open = false;
if ~handles.FE_open
    handles.ExperimentWindowOpen = false;
end
set(handles.hMenu_MeasureChapeauCurve,'checked','off');
%save data
guidata(hMain,handles);