function getCameraSoftAutoGainIntensity(hMain)

handles = guidata(hMain);

if ~handles.MMcam.bHasSoftAutoGain
    return;
end

I = handles.MMcam.getSoftAutoGainIntensity();

if handles.controls_open
    set(handles.hEdt_SoftAutoGain,'string',num2str(I,'%0.01f'));
    set(handles.hSld_SoftAutoGain,'value',I);
end