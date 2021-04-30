function setCameraGain(hMain,val)

handles = guidata(hMain);

if ~handles.MMcam.bHasGain
    return;
end

if ~handles.MMcam.bHasGainAuto||~handles.MMcam.bGainAuto
    handles.MMcam.setGain(val);
end

if handles.controls_open
    getCameraGain(hMain);
end

