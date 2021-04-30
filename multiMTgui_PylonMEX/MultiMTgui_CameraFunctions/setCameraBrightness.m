function setCameraBrightness(hMain,val)

handles = guidata(hMain);

if ~handles.MMcam.bHasBrightness
    return;
end

handles.MMcam.setBrightness(val);

if handles.controls_open
    getCameraBrightness(hMain);
end

