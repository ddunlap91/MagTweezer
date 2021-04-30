function MultiMTgui_DrawCallback(~,hMain) %1st arg is MMcam

%NOTE: NOT CURRENTLY USED


%Function called when camera LiveMode is drawing a new image.
%Default refresh rate is 10Hz

%% Global Variables - See: MultiMTgui_initializeVariables for all globals
%=========================================================================
%global gMT_track_XYZ; %Current bead positions
%global gMT_PlotMarkers; %handle to graphic markers for bead center

%updateHardwareInfo(hMain);

%handles = guidata(hMain);
%plot data cursors
% if handles.imagefig_open
%     %'in draw'
%     try
%         plot(handles.hAx_CameraImageAxes,gMT_track_XYZ(:,1),gMT_track_XYZ(:,2),'+r','MarkerSize',15);
% %         if ishghandle(gMT_PlotMarkers)
% %             set(gMT_PlotMarkers,'xdata',gMT_track_XYZ(:,1),'ydata',gMT_track_XYZ(:,2));
% %         else
% %             gMT_PlotMarkers = plot(handles.hAx_CameraImageAxes,gMT_track_XYZ(:,1),gMT_track_XYZ(:,2),'+r','MarkerSize',15);
% %         end
%     catch
%     end
%     for trkID=1:handles.num_tracks
%         if handles.track_params(trkID).ZRef==trkID
%             try
%             set(handles.track_xyzlabel(trkID),'string',...
%                 sprintf('Trk:%0.0f X:%3.2f Y:%3.2f Z:%3.2f',trkID,gMT_track_XYZ(trkID,:)));
%             catch
%             end
%         else
%             try
%             set(handles.track_xyzlabel(trkID),'string',...
%                 sprintf('Trk:%0.0f X:%3.2f Y:%3.2f \\DeltaZ:%3.2f',trkID,gMT_track_XYZ(trkID,1),gMT_track_XYZ(trkID,2),gMT_track_XYZ(handles.track_params(trkID).ZRef,3)-gMT_track_XYZ(trkID,3)));
%             catch
%             end
%         end
%     end
% end