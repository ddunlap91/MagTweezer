function MultiMTgui_updateCalibrationControls(hMain)

handles = guidata(hMain);

if ~handles.tracking_open||~ishandle(handles.hFig_TrackingControls)
    return;
end

tchandles = guidata(handles.hFig_TrackingControls);


%Set Values
%==========
set(tchandles.hEdt_CalibMin,'string',num2str(handles.CalStackMin,'%0.2f'));
set(tchandles.hEdt_CalibStep,'string',num2str(handles.CalStackStep,'%0.2f'));
set(tchandles.hEdt_CalibMax,'string',num2str(handles.CalStackMax,'%0.2f'));
set(tchandles.hEdt_CalibStepCount,'string',num2str(handles.CalStackStepCount,'%0.0f'));

%Enable/Disable during calibration
%calibrate button
if handles.CalibrationRunning
    set(tchandles.hBtn_StartStopCalibration,'string','STOP');
    set(tchandles.hBtn_StartStopCalibration,'ForegroundColor',[1,0,0]);
    %disable other controls
    set(tchandles.hBtn_AddTrack,'Enable','off');
    set(tchandles.hBtn_RemoveSelectedTrack,'Enable','off');
    set(tchandles.hEdt_CalibMin,'Enable','off');
    set(tchandles.hEdt_CalibStep,'Enable','off');
    set(tchandles.hEdt_CalibMax,'Enable','off');
    set(tchandles.hEdt_CalibStepCount,'Enable','off');
    %set(tchandles.hPnl_TrackingParameters,'Enable','inactive');
else
    set(tchandles.hBtn_StartStopCalibration,'string','Calibrate');
    set(tchandles.hBtn_StartStopCalibration,'ForegroundColor',[0,0,0]);
    %enable other controls
    set(tchandles.hBtn_AddTrack,'Enable','on');
    set(tchandles.hBtn_RemoveSelectedTrack,'Enable','on');
    set(tchandles.hEdt_CalibMin,'Enable','on');
    set(tchandles.hEdt_CalibStep,'Enable','on');
    set(tchandles.hEdt_CalibMax,'Enable','on');
    set(tchandles.hEdt_CalibStepCount,'Enable','on');
    %set(tchandles.hPnl_TrackingParameters,'Enable','on');
end

%Enable/disable controls
if handles.TrackingControlsEnabled
    set(tchandles.hBtn_AddTrack,'Enable','on');
    set(tchandles.hBtn_RemoveSelectedTrack,'Enable','on');
    set(tchandles.hBtn_StartStopCalibration,'Enable','on');
    set(tchandles.hEdt_CalibMin,'Enable','on');
    set(tchandles.hEdt_CalibStep,'Enable','on');
    set(tchandles.hEdt_CalibMax,'Enable','on');
    set(tchandles.hEdt_CalibStepCount,'Enable','on');
    %set(tchandles.hPnl_TrackingParameters,'Enable','on');
else
    set(tchandles.hBtn_AddTrack,'Enable','off');
    set(tchandles.hBtn_RemoveSelectedTrack,'Enable','off');
    set(tchandles.hBtn_StartStopCalibration,'Enable','off');
    set(tchandles.hEdt_CalibMin,'Enable','off');
    set(tchandles.hEdt_CalibStep,'Enable','off');
    set(tchandles.hEdt_CalibMax,'Enable','off');
    set(tchandles.hEdt_CalibStepCount,'Enable','off');
    %set(tchandles.hPnl_TrackingParameters,'Enable','inactive');
end