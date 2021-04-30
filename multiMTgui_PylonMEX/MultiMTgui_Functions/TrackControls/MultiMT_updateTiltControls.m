function MultiMT_updateTiltControls(hMain)

handles = guidata(hMain);

%% Update Tilt Controls
RefTrk = find(strcmpi('Reference',{handles.track_params.Type}));
RTind = find(RefTrk(RefTrk==handles.TiltCorrectionReference));
if isempty(RTind) && ~isempty(RefTrk)
    RTind = 1;
    handles.TiltCorrectionReference = RefTrk(1);
end
if RefTrk < 3
    handles.TiltCorrection = false;
end
if handles.tracking_open&&ishandle(handles.hFig_TrackingControls)
    tchandles = guidata(handles.hFig_TrackingControls);
    if isempty(RTind)
        RTind = 1;
        str = {' '};
    else
        str = cell_sprintf('%d',RefTrk);
    end
    tchandles.hPop_TiltRefTrack.String = str;
    tchandles.hPop_TiltRefTrack.Value = RTind;
    tchandles.hChk_Tilt.Value = handles.TiltCorrection;
    if numel(RefTrk) < 3
        tchandles.hChk_Tilt.Enable = 'off';
        tchandles.hTxt_RTLabel.Enable = 'off';
        tchandles.hPop_TiltRefTrack.Enable = 'off';
    else
        tchandles.hChk_Tilt.Enable = 'on';
        tchandles.hTxt_RTLabel.Enable = 'on';
        tchandles.hPop_TiltRefTrack.Enable = 'on';
    end
end

guidata(hMain,handles);