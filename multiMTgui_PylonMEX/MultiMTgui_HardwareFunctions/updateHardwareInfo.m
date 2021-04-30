function updateHardwareInfo(hMain)
persistent lasttime;

%hardware update function called by SettingsTimer

%persistent SettingsTimer;

if isempty(lasttime)||toc(lasttime)>0.5
    handles = guidata(hMain);
    getActualObjectivePosition(hMain);
    
    %set the actual framerate
    set(handles.hEdt_ActualFrameRate,'string',...
            num2str(handles.MMcam.dActualFrameRate,'%2.2f'));
        
    %update settings clock
    lasttime = tic;
end
