function MultiMT_setupTrackingControls(hTracking)

tchandles = guidata(hTracking);
%add window to main handles
hMain = tchandles.hMainWindow;
stopCamera(hMain);
handles = guidata(tchandles.hMainWindow);
handles.hFig_TrackingControls = hTracking;

%Create TrackingParameter Table (using jTable extension)
tchandles.hTbl_TrackingParameters = ...
    uiextras.jTable.Table(...
        'parent',tchandles.hPnl_TrackingParameters,...
        'ColumnName',{'Track','Calibrated','Color','Reference','Type','Radius'},...
        'ColumnFormat',{'integer','boolean','popup',  'popup', 'popup','integer'},...
        'ColumnEditable',[false, false,     true,   true,       true,  false],...
        'ColumnPreferredWidth',[40,40,50,50,100,50],...
        'CellEditCallback',{@MultiMTgui_editTrackingParameters,tchandles.hMainWindow},...
        'CellSelectionCallback',{@MultiMTgui_selectTrackingParameters,tchandles.hMainWindow});
drawnow;
%setup dropdown data
tchandles.hTbl_TrackingParameters.ColumnFormatData{3} = {'y','m','c','r','g','b'};
tchandles.hTbl_TrackingParameters.ColumnFormatData{4} = cell_sprintf('%d',1:handles.num_tracks);
tchandles.hTbl_TrackingParameters.ColumnFormatData{5} = {'Reference','Measurement'};
%Setup tracking parameter data
data = cell(handles.num_tracks,6);
data(:,1) = num2cell((1:handles.num_tracks)');
data(:,2) = {handles.track_params.IsCalibrated};
data(:,3) = {handles.track_params.Color};
data(:,4) = cell_sprintf('%d',[handles.track_params.ZRef]);
data(:,5) = {handles.track_params.Type};
data(:,6) = {handles.track_params.Radius};

tchandles.hTbl_TrackingParameters.Data = data;

handles.tracking_open = true;
set(handles.hMenu_TrackingControls,'Checked','on');


%save data
guidata(hTracking,tchandles);
guidata(hMain,handles);

MultiMTgui_updateCalibrationControls(hMain);
MultiMT_updateTiltControls(hMain);
drawnow;
startCamera(hMain);