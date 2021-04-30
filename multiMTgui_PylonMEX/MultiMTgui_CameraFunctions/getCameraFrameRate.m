function getCameraFrameRate(hMain)

handles=guidata(hMain);

if ~handles.MMcam.bHasFrameRate
    return;
end

if handles.controls_open
    fps = handles.MMcam.getTargetFrameRate();
    if handles.MMcam.bFrameRateValuesFixed
        %find closest val in popup strings
        s = get(handles.hCtrl_FrameRate,'string');
        [~,ind]=nanmin(abs(str2double(s)-fps));
        set(handles.hCtrl_FrameRate,'value',ind);
    else
        set(handles.hCtrl_FrameRate,'string',num2str(fps,'%0.02f'));
    end
end

guidata(hMain,handles);