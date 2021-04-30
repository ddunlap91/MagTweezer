function getCameraExposureAuto(hMain)

handles=guidata(hMain);

if ~handles.MMcam.bHasExposureAuto
    return;
end

if handles.controls_open
    auto = handles.MMcam.getExposureAuto();
    set(handles.hChk_ExposureAuto,'value',auto);
    if auto
        set(handles.hEdt_Exposure,'Enable','off');
    else
        set(handles.hEdt_Exposure,'Enable','on');
    end
end

guidata(hMain,handles);