function getCameraExposure(hMain)

handles=guidata(hMain);

exp = handles.MMcam.getExposure();

if handles.controls_open
    set(handles.hEdt_Exposure,'string',num2str(exp,'%0.03f'));
    if handles.MMcam.bHasExposureLimits&&ishandle(handles.hSld_Exposure)
        set(handles.hSld_Exposure,'value',exp);
    end 
end

guidata(hMain,handles);