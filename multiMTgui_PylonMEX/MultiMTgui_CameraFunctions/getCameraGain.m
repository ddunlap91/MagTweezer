function getCameraGain(hMain)

handles = guidata(hMain);

if ~handles.MMcam.bHasGain
    return;
end

gain = handles.MMcam.getGain();

if handles.controls_open
    if handles.MMcam.bGainValuesFixed
        %find closest val in popup strings
        s = get(handles.hEdt_Gain,'string');
        [~,ind]=nanmin(abs(str2double(s)-gain));
        set(handles.hEdt_Gain,'value',ind);
    else
        set(handles.hEdt_Gain,'string',num2str(gain,'%0.0f'));
        set(handles.hSld_Gain,'value',gain);
    end
end