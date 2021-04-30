function MultiMTgui_FE_ProcessFrame_EM(hMain,X,Y,Z_REL,Z_ABS,dZ,UsingTilt)

handles = guidata(hMain);
fehandles = guidata(handles.hFig_ForceExtension);

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
persistent hEBs_LvCurrent;
persistent hEBs_FvCurrent;
persistent hEBs_FvL_EM;

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
	Fx = NaN(handles.FE_NumVoltages,handles.num_tracks);
	avgL  = NaN(handles.FE_NumVoltages,handles.num_tracks);
	stdL  = NaN(handles.FE_NumVoltages,handles.num_tracks);
    FxErr  = NaN(handles.FE_NumVoltages,handles.num_tracks);
end

%% update title
handles.MMcam.haxImageAxes.Title.String = ...
    sprintf('Current (PWM): %0.2f; Frame Count %i/%i',...
                        handles.FE_Voltage(CurrentStep),...
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

thisRecord.Current = handles.CurrentObj.Axis(2).getCurrent();
thisRecord.Turns = handles.CurrentObj.Axis(2).getTurns();
thisRecord.Velocity = handles.CurrentObj.Axis(2).getVelocity();

thisRecord.X= X;
thisRecord.Y = Y;
thisRecord.Z_REL = Z_REL;
thisRecord.Z_ABS = Z_ABS;
thisRecord.dZ = dZ;
thisRecord.UsingTilt = UsingTilt;


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
    if fehandles.hChk_FE_PlotLvCurrent.Value
        if isempty(hEBs_LvCurrent) || any(~isvalid(hEBs_LvCurrent)) || numel(hEBs_LvCurrent)~=nMeas
            try
                delete(hEBs_LvCurrent);
            catch
            end
            [hEBs_LvCurrent,hAx,~,hFig] = errorbar_selectable(...
                repmat(reshape(handles.FE_Voltage,[],1),1,nMeas),...
                avgL(:,MeasTrks),...
                [],[],...
                stdL(:,MeasTrks),stdL(:,MeasTrks),...
                MeasTrkNames);
            hAx.Title.String = 'Length vs Current';
            xlabel(hAx,'Current [PWM]');
            ylabel(hAx,'Avg. Tether Length [µm]');
            hFig.Name = [filename,' Length v Current'];
            hFig.NumberTitle = 'off';
            hold(hAx, 'on');
        else
            for n=1:nMeas
                hEBs_LvCurrent(n).YData = avgL(:,MeasTrks(n));
                hEBs_LvCurrent(n).XData = reshape(handles.FE_Voltage,[],1);
                hEBs_LvCurrent(n).YLowerData = stdL(:,MeasTrks(n));
                hEBs_LvCurrent(n).YUpperData = stdL(:,MeasTrks(n));
            end
        end
    end
    if fehandles.hChk_FE_PlotFvCurrent.Value
        if isempty(hEBs_FvCurrent) || any(~isvalid(hEBs_FvCurrent)) || numel(hEBs_FvCurrent)~=nMeas
            try
                delete(hEBs_FvCurrent);
            catch
            end
            [hEBs_FvCurrent,hAx,~,hFig] = errorbar_selectable(...
                repmat(reshape(handles.FE_Voltage,[],1),1,nMeas),...
                Fx(:,MeasTrks),...
                [],[],...
                FxErr(:,MeasTrks),FxErr(:,MeasTrks),...
                MeasTrkNames);
            hAx.Title.String = 'Force vs Current';
            xlabel(hAx,'Current [PWM]');
            ylabel(hAx,'Force [pN]');
            %set(hAx,'yscale','log');
            hFig.Name = [filename,' Force v Current'];
            hFig.NumberTitle = 'off';
            hold(hAx, 'on');
        else
            for n=1:numel(hEBs_FvCurrent)
                hEBs_FvCurrent(n).YData = Fx(:,MeasTrks(n));
                hEBs_FvCurrent(n).XData = reshape(handles.FE_Voltage,[],1);
                hEBs_FvCurrent(n).YLowerData = FxErr(:,MeasTrks(n));
                hEBs_FvCurrent(n).YUpperData = FxErr(:,MeasTrks(n));
            end
        end
    end
    if fehandles.hChk_FE_PlotFvL_EM.Value
        if isempty(hEBs_FvL_EM) || any(~isvalid(hEBs_FvL_EM)) || numel(hEBs_FvL_EM)~=numel(MeasTrks)
            try
                delete(hEBs_FvL_EM);
            catch
            end
            [hEBs_FvL_EM,~,~,hFig] = ForceExtension_selectable(...
                    avgL(:,MeasTrks),...
                    Fx(:,MeasTrks),...
                    stdL(:,MeasTrks),...
                    FxErr(:,MeasTrks),...
                    MeasTrkNames);
            hFig.Name = [filename,' Force v Length'];
            hFig.NumberTitle = 'off';
            hold(hAx, 'on');
        else
            for n=1:numel(hEBs_FvL_EM)
                hEBs_FvL_EM(n).XData = avgL(:,MeasTrks(n));
                hEBs_FvL_EM(n).YData = Fx(:,MeasTrks(n));
                hEBs_FvL_EM(n).XLowerData = stdL(:,MeasTrks(n));
                hEBs_FvL_EM(n).XUpperData = stdL(:,MeasTrks(n));
                hEBs_FvL_EM(n).YLowerData = FxErr(:,MeasTrks(n));
                hEBs_FvL_EM(n).YUpperData = FxErr(:,MeasTrks(n));
            end
        end
    end
    
    
    %increment step
    CurrentStep= CurrentStep +1;
    if CurrentStep >handles.FE_NumVoltages
        MultiMTgui_stopForceExtension(hMain);
    else
        if handles.FE_Voltage(CurrentStep) ~= handles.CurrentObj.Axis(handles.magzaxis).TargetPosition(hMain)
            if handles.FE_Voltage(CurrentStep) > handles.FE_Voltage(CurrentStep-1)
                for i=handles.MC.Controller.Target+1:handles.FE_Voltage(CurrentStep)
                    handles.CurrentObj.Axis(handles.magzaxis).SetCurrent(i, hMain);
                end
            elseif handles.FE_Voltage(CurrentStep) < handles.FE_Voltage(CurrentStep-1)
                for i=handles.MC.Controller.Target-1:-1:handles.FE_Voltage(CurrentStep)
                    handles.CurrentObj.Axis(handles.magzaxis).SetCurrent(i, hMain);
                end
            end
        end
    end
    startCamera(hMain);
end

end