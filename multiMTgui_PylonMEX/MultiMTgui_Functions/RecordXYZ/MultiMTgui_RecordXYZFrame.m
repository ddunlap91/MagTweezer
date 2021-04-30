function MultiMTgui_RecordXYZFrame(hMain,X,Y,Z_REL,Z_ABS,dZ,UsingTilt)

handles = guidata(hMain);

%% setup record
thisRecord.Date = handles.MMcam.clkImageTime;
thisRecord.ObjectivePosition = handles.obj_zpos;
thisRecord.MagnetHeight = handles.mag_zpos;
thisRecord.MagnetRotation = handles.mag_rotpos;

thisRecord.X= X;
thisRecord.Y = Y;
thisRecord.Z_REL = Z_REL;
thisRecord.Z_ABS = Z_ABS;
thisRecord.dZ = dZ;
thisRecord.UsingTilt = UsingTilt;

if strcmpi(handles.MotorController, 'electromagnet')
    thisRecord.Current = handles.CurrentObj.Axis(2).getCurrent();
    thisRecord.Turns = handles.CurrentObj.Axis(1).getTurns();
    thisRecord.Velocity = handles.CurrentObj.Axis(1).getVelocity();
    thisRecord.Ang_Velocity = handles.CurrentObj.Axis(2).getVelocity();
end

%% write record
mtdat_writerecord(handles.RecXYZ_FileID,handles.RecXYZ_Record,thisRecord);

%% Plots
%list of relative tracks

colors = lines(handles.num_tracks);
%% Z Plot
if ~isempty(handles.hFig_LiveZPlot) && ishghandle(handles.hFig_LiveZPlot)
    if UsingTilt
        RelTrks = find((1:handles.num_tracks)~=handles.TiltCorrectionReference);
    else
        RelTrks = find([handles.track_params.ZRef]~=1:handles.num_tracks);
    end
    if isempty(handles.hAnimLine_ZPlot) || any(~ishghandle(handles.hAnimLine_ZPlot)) || numel(handles.hAnimLine_ZPlot) ~= numel(RelTrks)
        try
            delete(handles.hAnimLine_ZPlot);
            handles.hAnimLine_ZPlot = gobjects(numel(RelTrks),1);
        catch
        end
        
        [handles.hAnimLine_ZPlot,hAx,~,handles.hFig_LiveZPlot] = plot_selectable(...
            NaN(1,numel(RelTrks)),...
            NaN(1,numel(RelTrks)),...
            cell_sprintf('Trk %d',RelTrks),...
            handles.hFig_LiveZPlot,colors(RelTrks,:));
        xlabel(hAx,'Time [min]');
        ylabel(hAx,'\DeltaZ [µm]');
        title(hAx,'\DeltaZ vs. Time');
        handles.hFig_LiveZPlot.Name = [handles.RecXYZ_File,' LiveZ'];
        guidata(hMain,handles); %save changes to handles
    end
    if handles.UpdateLiveZPlot
        time = (handles.MMcam.clkImageTime - handles.RecXYZ_StartTime)*1440;
        %time = datetime(datevec(handles.MMcam.clkImageTime));
        %dZ = Z_ABS(refID) - Z_REL;
        for n=1:numel(RelTrks)
            handles.hAnimLine_ZPlot(n).XData(end+1) = time;
            handles.hAnimLine_ZPlot(n).YData(end+1) = dZ(RelTrks(n));
            %handles.hAnimLine_ZPlot(n).addpoints(time,dZ(RelTrks(n)));
            %h = handles.hAnimLine_ZPlot(n)
            %addpoints(handles.hAnimLine_ZPlot(n),time,dZ(RelTrks(n)));
            
        end
    end
end
%% XY Plot
if ~isempty(handles.hFig_LiveXYPlot) && ishghandle(handles.hFig_LiveXYPlot)
    if isempty(handles.hAnimLine_XYPlot) || any(~ishghandle(handles.hAnimLine_XYPlot)) || numel(handles.hAnimLine_XYPlot)~=handles.num_tracks
        try
            delete(handles.hAnimLine_XYPlot)
            handles.hAnimLine_XYPlot = gobjects(handles.num_tracks,1);
        catch
        end
        figure(handles.hFig_LiveXYPlot)
        hAx = gca();
        for n=1:handles.num_tracks
            handles.hAnimLine_XYPlot(n) = animatedline(hAx,'Color',colors(n,:));
        end
        legend(hAx,cell_sprintf('Trk %d',1:handles.num_tracks));
        guidata(hMain,handles); %save changes to handles
    end
    if handles.UpdateLiveXYPlot
        for n=1:handles.num_tracks
            addpoints(handles.hAnimLine_XYPlot(n),X(n),Y(n));
        end
    end
end