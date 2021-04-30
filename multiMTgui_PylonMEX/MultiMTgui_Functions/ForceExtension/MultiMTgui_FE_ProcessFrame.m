function MultiMTgui_FE_ProcessFrame(hMain,X,Y,Z_REL,Z_ABS,dZ,UsingTilt)

handles = guidata(hMain);
if ~handles.ExperimentRunning
    return;
end

%% init persistent vars
persistent CurrentFrame;
persistent CurrentStep;
persistent Xacc;
persistent Yacc;
persistent dZacc;

%errorbar handles for figs
persistent hEBs_LvMag;
persistent hEBs_FvMag;
persistent hEBs_FvL;

persistent Fx;
persistent avgL;
persistent stdL
persistent FxErr;

if isempty(CurrentFrame)
    CurrentFrame = 1;
end
if isempty(CurrentStep)
    CurrentStep = 1;
end
if isempty(Xacc)
    Xacc = NaN(handles.FE_FrameCount,handles.num_tracks);
end
if isempty(Yacc)
    Yacc = NaN(handles.FE_FrameCount,handles.num_tracks);
end
if isempty(dZacc)
    dZacc = NaN(handles.FE_FrameCount,handles.num_tracks);
end

if isempty(Fx)
	Fx = NaN(handles.FE_NumMagPos,handles.num_tracks);
	avgL  = NaN(handles.FE_NumMagPos,handles.num_tracks);
	stdL  = NaN(handles.FE_NumMagPos,handles.num_tracks);
    FxErr  = NaN(handles.FE_NumMagPos,handles.num_tracks);
end
disp(CurrentStep);
disp(handles.FE_NumVoltages);
%% update title
handles.MMcam.haxImageAxes.Title.String = ...
    sprintf('Magnet Position: %0.2f; Frame Count %i/%i',...
                        handles.FE_MagPos(CurrentStep),...
                        CurrentFrame,...
                        handles.FE_FrameCount);

%% xyz data
Xacc(CurrentFrame,:) = X;
Yacc(CurrentFrame,:) = Y;

%RefID = [handles.track_params.ZRef];
dZacc(CurrentFrame,:) = dZ;%Z_ABS(RefID) - Z_REL;


%% setup record
thisRecord.Date = handles.MMcam.clkImageTime;
thisRecord.Step = CurrentStep;
thisRecord.FrameCount = CurrentFrame;
thisRecord.ObjectivePosition = handles.obj_zpos;
thisRecord.MagnetHeight = handles.mag_zpos;
thisRecord.MagnetRotation = handles.mag_rotpos;

thisRecord.X= X;
thisRecord.Y = Y;
thisRecord.Z_REL = Z_REL;
thisRecord.Z_ABS = Z_ABS;
thisRecord.dZ = dZ;
thisRecord.UsingTilt = UsingTilt;


disp(thisRecord.X);
disp(thisRecord.Y);
disp(thisRecord.Z_REL);
disp(thisRecord.Z_ABS);
disp(thisRecord.dZ);
disp(thisRecord.UsingTilt);
disp("_-------------------------------------");

mtdat_writerecord(handles.FE_FileID,handles.FE_Record,thisRecord);
CurrentFrame = CurrentFrame + 1;

if CurrentFrame > handles.FE_FrameCount
    stopCamera(hMain);
    CurrentFrame = 1;
    %captured all frames in this step

    Xacc = Xacc*handles.PxScale;
    Yacc = Yacc*handles.PxScale;
    varX = nanvar(Xacc,0,1);
    %mean shift
    Xacc = bsxfun(@minus,Xacc,nanmean(Xacc,1));
    Yacc = bsxfun(@minus,Yacc,nanmean(Yacc,1));
    %tether length
    L = sqrt(Xacc.^2 + Yacc.^2 + dZacc.^2);
    %stats
    
    %varY = nanvar(Yacc,0,1);
    avgL(CurrentStep,:) = nanmean(L,1);
    stdL(CurrentStep,:) = nanstd(L,0,1);
    
    %RefTrks = find(strcmpi('Reference',{handles.track_params.Type}));
    %avgL(CurrentStep,RefTrks) = NaN;
    %stdL(CurrentStep,RefTrks) = NaN;

    %force
    kBT=1.380648813e-23*(273.15+handles.Temperature)*10^6;
    Fx(CurrentStep,:) = kBT*avgL(CurrentStep,:)./varX*10^12;
    FxErr(CurrentStep,:) = kBT*stdL(CurrentStep,:)./varX*10^12;

    %% Plot Data
    [~,filename,~] = fileparts(handles.FE_File);
    MeasTrks = find(strcmpi('Measurement',{handles.track_params.Type}));
    MeasTrkNames = cell_sprintf('Trk %d',MeasTrks);
    nMeas = numel(MeasTrks);
    if handles.FE_plotLvMag
        if isempty(hEBs_LvMag) || any(~isvalid(hEBs_LvMag)) || numel(hEBs_LvMag)~=nMeas
            try
                delete(hEBs_LvMag);
            catch
            end
            [hEBs_LvMag,hAx,~,hFig] = errorbar_selectable(...
                repmat(reshape(handles.FE_MagPos,[],1),1,nMeas),...
                avgL(:,MeasTrks),...
                [],[],...
                stdL(:,MeasTrks),stdL(:,MeasTrks),...
                MeasTrkNames);
            hAx.Title.String = 'Length vs Magnet Height';
            xlabel(hAx,'Magnet Height [mm]');
            ylabel(hAx,'Avg. Tether Length [µm]');
            hFig.Name = [filename,' Length v Magnet Height'];
            hFig.NumberTitle = 'off';
        else
            for n=1:nMeas
                hEBs_LvMag(n).YData = avgL(:,MeasTrks(n));
                hEBs_LvMag(n).XData = reshape(handles.FE_MagPos,[],1);
                hEBs_LvMag(n).YLowerData = stdL(:,MeasTrks(n));
                hEBs_LvMag(n).YUpperData = stdL(:,MeasTrks(n));
            end
        end
    end
    if handles.FE_plotFvMag
        if isempty(hEBs_FvMag) || any(~isvalid(hEBs_FvMag)) || numel(hEBs_FvMag)~=nMeas
            try
                delete(hEBs_FvMag);
            catch
            end
            [hEBs_FvMag,hAx,~,hFig] = errorbar_selectable(...
                repmat(reshape(handles.FE_MagPos,[],1),1,nMeas),...
                Fx(:,MeasTrks),...
                [],[],...
                FxErr(:,MeasTrks),FxErr(:,MeasTrks),...
                MeasTrkNames);
            hAx.Title.String = 'Force vs Magnet Height';
            xlabel(hAx,'Magnet Height [mm]');
            ylabel(hAx,'Force [pN]');
            %set(hAx,'yscale','log');
            hFig.Name = [filename,' Force v Magnet Height'];
            hFig.NumberTitle = 'off';
        else
            for n=1:numel(hEBs_FvMag)
                hEBs_FvMag(n).YData = Fx(:,MeasTrks(n));
                hEBs_FvMag(n).XData = reshape(handles.FE_MagPos,[],1);
                hEBs_FvMag(n).YLowerData = FxErr(:,MeasTrks(n));
                hEBs_FvMag(n).YUpperData = FxErr(:,MeasTrks(n));
            end
        end
    end
    if handles.FE_plotFvL
        if isempty(hEBs_FvL) || any(~isvalid(hEBs_FvL)) || numel(hEBs_FvL)~=numel(MeasTrks)
            try
                delete(hEBs_FvL);
            catch
            end
            [hEBs_FvL,~,~,hFig] = ForceExtension_selectable(...
                    avgL(:,MeasTrks),...
                    Fx(:,MeasTrks),...
                    stdL(:,MeasTrks),...
                    FxErr(:,MeasTrks),...
                    MeasTrkNames);
            hFig.Name = [filename,' Force v Length'];
            hFig.NumberTitle = 'off';
        else
            for n=1:numel(hEBs_FvL)
                hEBs_FvL(n).XData = avgL(:,MeasTrks(n));
                hEBs_FvL(n).YData = Fx(:,MeasTrks(n));
                hEBs_FvL(n).XLowerData = stdL(:,MeasTrks(n));
                hEBs_FvL(n).XUpperData = stdL(:,MeasTrks(n));
                hEBs_FvL(n).YLowerData = FxErr(:,MeasTrks(n));
                hEBs_FvL(n).YUpperData = FxErr(:,MeasTrks(n));
            end
        end
    end
    
    
    %increment step
    CurrentStep= CurrentStep +1;
    if CurrentStep >handles.FE_NumMagPos
        MultiMTgui_stopForceExtension(hMain);
    else
     
        if abs(handles.FE_MagPos(CurrentStep)-handles.MotorObj.Axis(handles.magzaxis).TargetPosition)>0.005
            setMagnetZPosition(hMain,handles.FE_MagPos(CurrentStep));
            waitForMagnetZPosition(hMain);
        end
    end
    startCamera(hMain);
end

end