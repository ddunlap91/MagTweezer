function setCameraSoftAutoGainEnable(hMain,val)

handles = guidata(hMain);

if ~handles.MMcam.bHasSoftAutoGain
    return;
end

val = logical(val);

handles.MMcam.setSoftAutoGain(val);
getCameraSoftAutoGainEnable(hMain);
getCameraSoftAutoGainIntensity(hMain);

