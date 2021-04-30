function MultiMT_updateTrackParameterTable(hMain)
drawnow;
%get gui data
handles = guidata(hMain);

%================================
if handles.tracking_open&&ishandle(handles.hFig_TrackingControls)
    tchandles = guidata(handles.hFig_TrackingControls);
    %% Update Tracking Control Table
    %update dropdown menu
    tchandles.hTbl_TrackingParameters.ColumnFormatData{3} = cell_sprintf('%d',1:handles.num_tracks);

    %updata table data
    data = cell(handles.num_tracks,6);
    1:handles.num_tracks
    data(:,1) = num2cell((1:handles.num_tracks)')
    data(:,2) = {handles.track_params.IsCalibrated}
    data(:,3) = {handles.track_params.Color}
    data(:,4) = cell_sprintf('%d',[handles.track_params.ZRef])
    data(:,5) = {handles.track_params.Type}
    data(:,6) = {handles.track_params.Radius}
    try
    tchandles.hTbl_TrackingParameters.Data = data;
    catch
        'error setting data'
    end
    try
        tchandles.hTbl_TrackingParameters.ColumnFormatData{3} = {'y','m','c','r','g','b'};
        tchandles.hTbl_TrackingParameters.ColumnFormatData{4} = cell_sprintf('%d',1:handles.num_tracks);
        tchandles.hTbl_TrackingParameters.ColumnFormatData{5} = {'Reference','Measurement'};
    catch
        'error updating col format'
    end

end
drawnow;