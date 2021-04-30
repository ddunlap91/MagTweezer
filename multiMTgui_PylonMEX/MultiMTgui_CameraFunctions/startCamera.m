function startCamera(hMain)

handles = guidata(hMain);

handles.MMcam.StartLiveMode();

set(handles.hTxt_ProgramStatus,'string','Camera live mode running.');

