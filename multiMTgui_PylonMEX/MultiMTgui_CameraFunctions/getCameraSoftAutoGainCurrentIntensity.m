function getCameraSoftAutoGainCurrentIntensity(hMain)

handles = guidata(hMain);

if ~handles.MMcam.bHasSoftAutoGain
    return;
end

if handles.controls_open
    I = handles.MMcam.SoftAutoGainLastI;
    set(handles.hEdt_SoftAutoGainIntensity,'string',sprintf('%0.01f',I));
end




