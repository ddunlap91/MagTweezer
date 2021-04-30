function setCameraExposure(hMain,val)

handles = guidata(hMain);

if ~handles.MMcam.bHasExposureAuto||~handles.MMcam.bExposureAuto
    handles.MMcam.setExposure(val);
end

if handles.controls_open
    getCameraExposure(hMain);
end
