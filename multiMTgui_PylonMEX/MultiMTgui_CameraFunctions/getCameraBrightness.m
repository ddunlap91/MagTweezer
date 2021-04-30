function getCameraBrightness(hMain)

handles = guidata(hMain);

if ~handles.MMcam.bHasBrightness
    return;
end

b = handles.MMcam.getBrightness();

if handles.controls_open
    
    if handles.MMcam.bBrightnessValuesFixed
        %find closest val in popup strings
        s = get(handles.hEdt_Brightness,'string');
        [~,ind]=nanmin(abs(str2double(s)-b));
        set(handles.hEdt_Brightness,'value',ind);
    else
        set(handles.hEdt_Brightness,'string',num2str(b,'%0.0f'));
        set(handles.hSld_Brightness,'value',b);
    end
end

guidata(hMain,handles);