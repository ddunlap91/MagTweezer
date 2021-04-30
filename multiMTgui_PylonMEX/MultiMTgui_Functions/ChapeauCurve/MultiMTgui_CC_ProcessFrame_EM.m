function MultiMTgui_CC_ProcessFrame(hMain,X,Y,Z_REL,Z_ABS,dZ,UsingTilt)

handles = guidata(hMain);


%% init persistent vars
persistent CurrentFrame;
persistent CurrentStep;
persistent Xacc;
persistent Yacc;
persistent dZacc;

persistent avgdZ;
persistent stddZ;

%errorbar handles for figs
persistent hEBs_dZvRot;

if isempty(CurrentFrame)
    CurrentFrame = 1;
end
if isempty(CurrentStep)
    CurrentStep = 1;
end
if isempty(Xacc)
    Xacc = NaN(handles.CC_FrameCount,handles.num_tracks);
end
if isempty(Yacc)
    Yacc = NaN(handles.CC_FrameCount,handles.num_tracks);
end
if isempty(dZacc)
    dZacc = NaN(handles.CC_FrameCount,handles.num_tracks);
end

if isempty(avgdZ)
	avgdZ  = NaN(handles.CC_NumMagRot,handles.num_tracks);
	stddZ  = NaN(handles.CC_NumMagRot,handles.num_tracks);
end

%% update title
handles.MMcam.haxImageAxes.Title.String = ...
    sprintf('Magnet Rotation: %0.2f; Frame Count %i/%i',...
                        handles.CC_MagRot(CurrentStep),...
                        CurrentFrame,...
                        handles.CC_FrameCount);

%% xyz data
Xacc(CurrentFrame,:) = X;
Yacc(CurrentFrame,:) = Y;

%RefID = [handles.track_params.ZRef];
dZacc(CurrentFrame,:) = dZ;

%% setup record
thisRecord.Date = handles.MMcam.clkImageTime;
thisRecord.Step = CurrentStep;
thisRecord.FrameCount = CurrentFrame;
thisRecord.ObjectivePosition = handles.obj_zpos;
thisRecord.MagnetHeight = handles.mag_zpos;
thisRecord.MagnetRotation = handles.mag_rotpos;

thisRecord.X = X;
thisRecord.Y = Y;
thisRecord.Z_REL = Z_REL;
thisRecord.Z_ABS = Z_ABS;
thisRecord.dZ = dZ;
thisRecord.UsingTilt = UsingTilt;

thisRecord.Current = handles.CurrentObj.Axis(1).getCurrent();
thisRecord.Turns = handles.CurrentObj.Axis(1).getTurns();
thisRecord.Ang_Velocity = handles.CurrentObj.Axis(1).getVelocity();

mtdat_writerecord(handles.CC_FileID,handles.CC_Record,thisRecord);
CurrentFrame = CurrentFrame + 1;

if CurrentFrame > handles.CC_FrameCount
    stopCamera(hMain);
    CurrentFrame = 1;
    %captured all frames in this step

    %% Plot Data
    [~,filename,~] = fileparts(handles.CC_File);
    MeasTrks = find(strcmpi('Measurement',{handles.track_params.Type}));
    MeasTrkNames = cell_sprintf('Trk %d',MeasTrks);
    nMeas = numel(MeasTrks);
    
    avgdZ(CurrentStep,:) = nanmean(dZacc,1);
    stddZ(CurrentStep,:) = nanstd(dZacc,0,1);

    %update plots
    if handles.CC_plotChapeau
        if isempty(hEBs_dZvRot) || any(~isvalid(hEBs_dZvRot)) || numel(hEBs_dZvRot)~=nMeas
            try
                delete(hEBs_dZvRot);
            catch
            end
            [hEBs_dZvRot,hAx,~,hFig] = errorbar_selectable(...
                repmat(reshape(handles.CC_MagRot,[],1),1,nMeas),...
                avgdZ(:,MeasTrks),...
                [],[],...
                stddZ(:,MeasTrks),stddZ(:,MeasTrks),...
                MeasTrkNames);
            hAx.Title.String = '\DeltaZ vs Rotation';
            xlabel(hAx,'Rotation [turns]');
            ylabel(hAx,'Avg. Height (\DeltaZ) [µm]');
            hFig.Name = [filename,' dZ v Rotation'];
            hFig.NumberTitle = 'off';
        else
            for n=1:nMeas
                hEBs_dZvRot(n).YData = avgdZ(:,MeasTrks(n));
                hEBs_dZvRot(n).XData = reshape(handles.CC_MagRot,[],1);
                hEBs_dZvRot(n).YLowerData = stddZ(:,MeasTrks(n));
                hEBs_dZvRot(n).YUpperData = stddZ(:,MeasTrks(n));
            end
        end
    end

    %increment step
    CurrentStep= CurrentStep +1;
    if CurrentStep >handles.CC_NumMagRot
        MultiMTgui_stopChapeauCurve(hMain);
    else
        handles.CurrentObj.Axis(handles.magraxis).SetTurn(hMain, handles.CC_MagRot(CurrentStep));
        pause(handles.TC.StepPeriod);
    end
    startCamera(hMain);
end
