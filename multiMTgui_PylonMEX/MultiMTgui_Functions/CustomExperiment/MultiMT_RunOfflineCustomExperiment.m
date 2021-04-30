function MultiMT_RunOfflineCustomExperiment(hMain)
setInFunctionFlag(hMain,true);
handles = guidata(hMain);

%% Calculate Space requirements
[MaxMemory,ind] = max([handles.ExperimentScheme.ExperimentSteps.FrameCount]*handles.MMcam.BytesPerPixel*handles.MMcam.ROI(3)*handles.MMcam.ROI(4));

userview = memory;
if MaxMemory > 0.8*userview.MemAvailableAllArrays
    str = sprintf('Step: %d will require more memory than is available. Reduce the FrameCount/Duration.', ind);
    errordlg(str,'Insufficient Memory','modal');
    fclose(handles.CustomExperiment_FileID);
    try
        delete(fullfile(handles.data_dir,[handles.CustomExperiment_FileName,'.mtdat']));
    catch
    end
    return;
end

%% Stop camera
%stopCamera(hMain);

%% setup record
thisRecord.Date = [];
thisRecord.Step = [];
thisRecord.FrameCount = [];
thisRecord.ObjectivePosition = [];
thisRecord.MagnetHeight = [];
thisRecord.MagnetRotation = [];

if handles.ExperimentScheme.OutputX
    thisRecord.X= [];
end
if handles.ExperimentScheme.OutputY
    thisRecord.Y = [];
end
if handles.ExperimentScheme.OutputZ
    thisRecord.Z_REL = [];
    thisRecord.Z_ABS = [];
    thisRecord.dZ = [];
    thisRecord.UsingTilt = false;
end

RefTrks = find(strcmpi({handles.track_params.Type},'Reference'));


fields = fieldnames(handles.ExperimentScheme.ExperimentSteps);

handles.CustomExperiment_OfflineModeRunning = true;
handles.CustomExperiment_paused = false;

handles.CustExp_hWaitbar = waitbar(0,sprintf('Capturing Images\nStep 1/%d',numel(handles.ExperimentScheme.ExperimentSteps)));

guidata(hMain,handles);
%% data container for plots
ExpData = handles.CustomExperimentData;

%% calc particle tracking wind with ROI
wind = handles.track_wind;
if handles.MMcam.UsingROI
    wind(:,1:2) = wind(:,1:2)-handles.MMcam.ROI(1)+1; %change x_i, x_f to be relative to ROI
    wind(:,3:4) = wind(:,3:4)-handles.MMcam.ROI(2)+1; %change y_i,y_f to be relative to ROI
end

%% Capture, Loop over each step
for n=1:numel(handles.ExperimentScheme.ExperimentSteps)
    drawnow;
    %% check if experiment has been stopped
    handles = guidata(hMain);
    if ~handles.CustomExperiment_OfflineModeRunning
        break;
    end
    if ~ishandle(handles.CustExp_hWaitbar) %|| getappdata(handles.CustExp_hWaitbar,'canceling')
        handles.CustomExperiment_OfflineModeRunning = false;
        break;
    end
    
    %% get current microscope info
    for f=reshape(fields,1,[])
        switch f{1}
            case 'ObjectivePosition'
                setObjectivePosition(hMain,handles.ExperimentScheme.ExperimentSteps(n).ObjectivePosition);
                waitForMagnetRotation(hMain);
            case 'MagnetHeight'
                setMagnetZPosition(hMain,handles.ExperimentScheme.ExperimentSteps(n).MagnetHeight);
                waitForMagnetZPosition(hMain);
            case 'MagnetRotation'
                setMagnetRotation(hMain,handles.ExperimentScheme.ExperimentSteps(n).MagnetRotation);
        end
    end
    thisRecord.ObjectivePosition = getActualObjectivePosition(hMain);
    thisRecord.MagnetHeight = getMagnetZPosition(hMain);
    thisRecord.MagnetRotation = getMagnetRotation(hMain);
    
    %% setup CustomExperimentData container
    
    ExpData(n).MagnetHeight = thisRecord.MagnetHeight;
    ExpData(n).MagnetRotation = thisRecord.MagnetRotation;
    
    %% Grab images
    [img,time,Ngrabbed] = handles.MMcam.SnapImage(handles.ExperimentScheme.ExperimentSteps(n).FrameCount);
    waitbar(n/numel(handles.ExperimentScheme.ExperimentSteps),handles.CustExp_hWaitbar, sprintf('Capturing Images\nStep %d/%d',n,numel(handles.ExperimentScheme.ExperimentSteps)) );
    
    if Ngrabbed ~= handles.ExperimentScheme.ExperimentSteps(n).FrameCount
        warning('Experiment Step: %d, Only captured %d of %d',n,Ngrabbed,handles.ExperimentScheme.ExperimentSteps(n).FrameCount);
    end
    %% Process image
    hWait = waitbar(0,'Processing Images');
    stopCamera(hMain);
    
    for f = 1:Ngrabbed
        thisRecord.Date = time(f);
        thisRecord.Step = n;
        thisRecord.FrameCount = f;
        %% calc XYZ
        if handles.ExperimentScheme.OutputZ
            %% Calc x,y,z,dz
            %ZRef - if using tilt correction all particles are reference to one track
            if handles.TiltCorrection
                ZRef = repmat(handles.TiltCorrectionReference,1,handles.num_tracks);
            else
                ZRef = [handles.track_params.ZRef];
            end
            
            [X,Y,Zrel,Zabs,dZ,UsingTilt] = particelXYZ_tilt(...
                                                img{f},...
                                                handles.track_calib,...
                                                wind,...
                                                ZRef,...
                                                handles.TiltCorrection,...
                                                RefTrks);

            if handles.MMcam.UsingROI %change back to being relative to full image size
                X = X + handles.MMcam.ROI(1) - 1;
                Y = Y + handles.MMcam.ROI(2) - 1;
            end
            
            %% set record
            thisRecord.dZ = dZ;
            thisRecord.Z_REL = Zrel;
            thisRecord.Z_ABS = Zabs;
            thisRecord.UsingTilt = UsingTilt;

            if handles.ExperimentScheme.OutputX
                thisRecord.X = X;
            end
            if handles.ExperimentScheme.OutputY
                thisRecord.Y = Y;
            end

            
        elseif handles.ExperimentScheme.OutputX||handles.ExperimentScheme.OutputY %XY
            %% XY only
            [X,Y] = particlexy(img{f},wind);
            
            if handles.ExperimentScheme.OutputX
                if handles.MMcam.UsingROI
                    thisRecord.X = X + handles.MMcam.ROI(1)-1;
                else
                    thisRecord.X = X;
                end
            end
            if handles.ExperimentScheme.OutputY
                if handles.MMcam.UsingROI
                    thisRecord.Y = Y + handles.MMcam.ROI(2)-1;
                else
                    thisRecord.Y = Y;
                end
            end
        end

        %% write data to file
        mtdat_writerecord(handles.CustomExperiment_FileID,handles.CustomExperiment_Record,thisRecord);
        %% put record in ExpData container used for plotting
        ExpData(n).StepData(f) = thisRecord;
        waitbar(f/Ngrabbed,hWait);
    end
    delete(hWait);
    waitbar(n/numel(handles.ExperimentScheme.ExperimentSteps),handles.CustExp_hWaitbar, sprintf('Capturing Images\nStep %d/%d',n+1,numel(handles.ExperimentScheme.ExperimentSteps)) );
    
    %% UpdatePlots
    ExpData = MultiMT_updateCustomExperimentPlots(hMain,ExpData,n);
    
    %% finialize loop, restart camera?
    %startCamera(hMain); %restart camera Is this a good idea???? maybe it will slow things down
end

handles.CustomExperimentData = ExpData;
guidata(hMain,handles);
MultiMT_stopCustomExperiment(hMain);
%% restart camera
%startCamera(hMain);
setInFunctionFlag(hMain,false);