function setCameraFrameRate(hMain,fps)

handles = guidata(hMain);

if ~handles.MMcam.bHasFrameRate
    return;
end

handles.MMcam.setFrameRate(fps);
guidata(hMain,handles);
getCameraFrameRate(hMain);
getCameraExposure(hMain);
getCameraGain(hMain);
