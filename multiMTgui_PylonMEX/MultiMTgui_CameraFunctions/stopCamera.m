function stopCamera(hMain)

handles = guidata(hMain);

handles.MMcam.StopLiveMode();

set(handles.hTxt_ProgramStatus,'string','Camera live mode stopped.');