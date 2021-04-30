function getCameraSoftAutoGainEnable(hMain)

handles = guidata(hMain);

if ~handles.MMcam.bHasSoftAutoGain
    return;
end

if handles.controls_open
    auto = handles.MMcam.getSoftAutoGain();
    set(handles.hChk_SoftAutoGain,'value',auto);
    if ~auto
        set(handles.hEdt_SoftAutoGain,'Enable','off');
        set(handles.hSld_SoftAutoGain,'Enable','off');
        
        if ~handles.MMcam.bHasGainAuto||~handles.MMcam.bGainAuto
            set(handles.hEdt_Gain,'Enable','on');
            set(handles.hSld_Gain,'Enable','on');
        end
    else
        set(handles.hEdt_SoftAutoGain,'Enable','on');
        set(handles.hSld_SoftAutoGain,'Enable','on');
        
        set(handles.hEdt_Gain,'Enable','off');
        set(handles.hSld_Gain,'Enable','off');
        
    end
end