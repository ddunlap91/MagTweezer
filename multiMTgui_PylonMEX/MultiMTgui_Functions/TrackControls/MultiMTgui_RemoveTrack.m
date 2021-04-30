function MultiMTgui_RemoveTrack(hMain,trkID)
stopCamera(hMain);
trkID = trkID(1); %force deleting only one track at a time.

handles = guidata(hMain);
if handles.ExperimentRunning
    warndlg('Cannot delete track while experiment is running.');
    setInFunctionFlag(hMain,false);
    return;
else
    stopCamera(hMain);
    setInFunctionFlag(hMain,true); %tell camera to stop processing frames so we can think
    handles = guidata(hMain);
end

trkID(trkID<1|trkID>handles.num_tracks) = [];
if isempty(trkID)
    return;
end

if handles.imagefig_open
    try
        delete(handles.track_hrect(trkID));
        delete(handles.track_xyzlabel(trkID));
        
        for n=trkID+1:handles.num_tracks
            ud = get(handles.track_hrect(n),'userdata');
            ud.trkID = ud.trkID-1;
            set(handles.track_hrect(n),'userdata',ud);
        end
        
    catch
    end
    try
        cla(handles.hAx_CameraImageAxes); %clear center markers from plot
    catch
    end
end

if numel(trkID)>=handles.num_tracks
    %delete all tracks
    handles.track_params = struct('Sel',{},'Type',{},'Radius',{},'Color',{},'Lock',{},'IsCalibrated',{},'ZRef',{}); %parameters used by TrackingContols GUI
    handles.track_calib = struct('IrStack',{},'Radius',{},'ZPos',{},'IsCalibrated',{});%calibration data
    handles.track_wind = NaN(0,4); %windows used by tracking function
    handles.track_XYZ = [];
    handles.FE_SaveAbsZ = [];
    handles.num_tracks = 0;
    
else %just delete tracks specified
    
    for n=1:handles.num_tracks
        %shift the ZRef trackID
        if handles.track_params(n).ZRef>trkID
            handles.track_params(n).ZRef = handles.track_params(n).ZRef-1;
        elseif handles.track_params(n).ZRef==trkID
            handles.track_params(n).ZRef = n;
        end
    end

    try
    %delete track
    handles.track_hrect(trkID) = [];
    handles.track_xyzlabel(trkID) = [];
    handles.track_params(trkID) = [];
    handles.track_wind(trkID,:) = [];
    handles.track_XYZ(trkID,:) = [];
    handles.track_calib(trkID) = [];
    handles.FE_SaveAbsZ(trkID) = [];
    catch
        disp('did not delete track')
    end
    handles.num_tracks = handles.num_tracks - 1;%numel(trkID);
end

%Update data
%=========
guidata(hMain,handles);
MultiMT_updateTiltControls(hMain);
MultiMT_updateTrackParameterTable(hMain);
setInFunctionFlag(hMain,false); %tell camera to process frames
startCamera(hMain);