function getCameraGainAuto(hMain)

handles=guidata(hMain);

if ~handles.MMcam.bHasGainAuto
    return;
end

if handles.controls_open
    auto = handles.MMcam.getGainAuto();
    set(handles.hChk_GainAuto,'value',auto);
    if auto
        set(handles.hEdt_Gain,'Enable','off');
        set(handles.hSld_Gain,'Enable','off');
    else
        set(handles.hEdt_Gain,'Enable','on');
        set(handles.hSld_Gain,'Enable','on');
    end
end

guidata(hMain,handles);