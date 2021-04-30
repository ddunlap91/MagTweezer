function setCameraSoftAutoGainIntensity(hMain,val)

handles = guidata(hMain);

if ~handles.MMcam.bHasSoftAutoGain
    return;
end

handles.MMcam.setSoftAutoGainIntensity(val);

if handles.controls_open
    getCameraSoftAutoGainIntensity(hMain);
end