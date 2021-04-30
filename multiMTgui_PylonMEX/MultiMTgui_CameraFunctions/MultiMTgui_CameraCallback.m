function MultiMTgui_CameraCallback(MMcam,hMain)
%Function called when camera LiveMode captures a new image

%% Global Variables - refer to MultiMTgui_initializeVariables for first declaration
%==================================
%global gMT_track_XYZ; %Current bead positions

%% Function Start
%=====================
persistent hLine;
persistent hTilt;
%persistent lastPlotTime;
try
    
%% Update Hardware Readouts
updateHardwareInfo(hMain);

%get handles data
handles = guidata(hMain);

%Special States
%====================================================
if handles.num_tracks ==0 %no tracks do nothing
    return;
end
if handles.PauseSystem %master pause function is on
    try
        delete(hLine);
    catch
    end
    return;
end
if handles.CalibrationRunning
    %Currently in calibration mode
    %==============================
    return;
end
if handles.InUserFunction %currently processing a user interface callback, give the cpu time to think
    return;
end

%Default Process
%=================================================================
%if we made it here, process image normally
wind = handles.track_wind;
if MMcam.UsingROI
    wind(:,1:2) = wind(:,1:2)-MMcam.ROI(1)+1; %change x_i, x_f to be relative to ROI
    wind(:,3:4) = wind(:,3:4)-MMcam.ROI(2)+1; %change y_i,y_f to be relative to ROI
end

RefTrks = find(strcmpi({handles.track_params.Type},'Reference'));
if handles.TiltCorrection && numel(RefTrks)>2 %setup ZRef
    ZRef = repmat(handles.TiltCorrectionReference,1,handles.num_tracks);
else
    ZRef = [handles.track_params.ZRef];
end

[X,Y,Zrel,Zabs,dZ,UsingTilt,TiltABC] = particelXYZ_tilt(...
                                    MMcam.ImageData,...
                                    handles.track_calib,...
                                    wind,...
                                    ZRef,...
                                    handles.TiltCorrection,...
                                    RefTrks);

if MMcam.UsingROI %change back to being relative to full image size
    X = X + handles.MMcam.ROI(1) - 1;
    Y = Y + handles.MMcam.ROI(2) - 1;
end

%% Plot data
if ishghandle(MMcam.haxImageAxes)
    %lastPlotTime = MMcam.clkImageTime;
    if isempty(hLine)||~ishghandle(hLine)
        cla(MMcam.haxImageAxes);
        hLine=line(MMcam.haxImageAxes,'Xdata',X,'YData',Y,'LineStyle','none','color','r','marker','+','MarkerSize',15);
    else
        set(hLine,'Xdata',X,'YData',Y);
    end
    
    for t=1:handles.num_tracks
        if strcmpi(handles.track_params(t).Type,'Reference')
            pre = 'Ref';
        else
            pre = 'Meas';
        end
        if ~UsingTilt&&ZRef(t)==t
            try
            set(handles.track_xyzlabel(t),'string',...
                sprintf([pre,': %0.0f Z:%2.2f'],t,Zrel(t)));
            catch
            end
        else
            try
            set(handles.track_xyzlabel(t),'string',...
                sprintf([pre,': %0.0f \\DeltaZ:%2.2f'],t,dZ(t)));
            catch
            end
        end
    end
    
    if UsingTilt
        if isempty(hTilt) || ~ishghandle(hTilt)
            hTilt = text(MMcam.haxImageAxes,10,10,sprintf('Z=%0.6fx + %0.6fy + %0.3f',TiltABC),'Color','y');
        else
            hTilt.String = sprintf('Z=%0.6fx + %0.6fy + %0.3f',TiltABC);
        end
    else
        try
            delete(hTilt)
            hTilt = [];
        catch
        end
    end
end

%% Simple Experiments
if handles.ExperimentRunning && strcmpi(handles.ExperimentType,'ForceExtension')
    %% Force Extension
    if ~strcmp(handles.MotorController, 'ELECTROMAGNET')
        MultiMTgui_FE_ProcessFrame(hMain,X,Y,Zrel,Zabs,dZ,UsingTilt);
    else
        MultiMTgui_FE_ProcessFrame_EM(hMain,X,Y,Zrel,Zabs,dZ,UsingTilt);
    end

elseif handles.ExperimentRunning && strcmpi(handles.ExperimentType,'ChapeauCurve')
    %% Chapeau Curve
    if ~strcmpi(handles.MotorController, 'ELECTROMAGNET')
        MultiMTgui_CC_ProcessFrame(hMain,X,Y,Zrel,Zabs,dZ,UsingTilt)
    else
        MultiMTgui_CC_ProcessFrame_EM(hMain,X,Y,Zrel,Zabs,dZ,UsingTilt)
    end
end
%% Record XYZ
if handles.RecXYZ_Recording
    MultiMTgui_RecordXYZFrame(hMain,X,Y,Zrel,Zabs,dZ,UsingTilt);
end

catch exception
    disp '***** Camera Callback ERROR *****'
    disp('message:')
    disp (exception.message)
    disp('stack')
    disp (exception.stack)
    for k=1:numel(exception.stack)
        disp(exception.stack(k).file)
        disp(exception.stack(k).name)
        disp(exception.stack(k).line)
    end
    disp '***********************************************'
    
    %reset camera
    stopCamera(hMain);
    startCamera(hMain);
    
    error('something wrong in CameraCallback');
end


