function MultiMTgui_CameraPropertiesUpdateCallback(MMcam,hMain)
%Function called when any of the camera properties are changed.

handles = guidata(hMain);
mchandles = guidata(handles.hFig_MicroscopeControls);

%% FrameRate
set(mchandles.hChk_UseFrameRate,'value',MMcam.UseFrameRate);
if(mchandles.hChk_UseFrameRate.Value)
    mchandles.hCtrl_FrameRate.Enable = 'on';
else
    mchandles.hCtrl_FrameRate.Enable = 'off';
end
%set(mchandles.hCtrl_FrameRate,'string',num2str(MMcam.TargetFrameRate));

%% ROI
set(mchandles.hChk_UseROI,'value',MMcam.UsingROI);
set(mchandles.hEdt_ROIWidth,'string',num2str(MMcam.ROI(3)));
set(mchandles.hEdt_ROIHeight,'string',num2str(MMcam.ROI(4)));
set(mchandles.hEdt_ROIOffsetX,'string',num2str(MMcam.ROI(1)));
set(mchandles.hEdt_ROIOffsetY,'string',num2str(MMcam.ROI(2)));

%% Brightness

%% Exposure
if MMcam.bHasExposureAuto&&MMcam.getExposureAuto();
    getCameraExposure(hMain);
end

%% Gain
if MMcam.bHasGain&&...
        ( (MMcam.bHasGainAuto&&MMcam.getGainAuto()) || ...
          (MMcam.bHasSoftAutoGain&&MMcam.getSoftAutoGain()) )
    getCameraGain(hMain);
end
if MMcam.bHasSoftAutoGain
    getCameraSoftAutoGainCurrentIntensity(hMain);
end

