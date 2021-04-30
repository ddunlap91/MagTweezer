function status = MultiMTgui_closeGUI(hMain)
%MultiMTgui_closeGUI(hObject) Closes the MultiMT figures
% Input:
%   hMain - handle to main figure window
%       This function should be called after the guidata has been updated
% Output:
%   status - boolean true=initialized, false=error
% Example:
%   ...
%   %Update handles structure
%   guidata(hObject,handles);
%   ... (other functions which don't change or update hObject)
%   initstat = MultiMTgui_closeGUI(hObject);
%   if ~initstat
%       error('Could not close gui');
%   end
%
% Note: This function will update the guidata before returning
disp('closing...');
%stopCamera(hMain);

status = true;



%% Everything else
handles = guidata(hMain);


%% Hardware info timer
%===============================
try
    stop(handles.SettingsTimer);
    delete(handles.SettingsTimer);
catch
end

%% logger
handles.logger.close();
delete(handles.logger);

%% experiment windows
MultiMTgui_closeForceExtension(hMain);
MultiMTgui_closeChapeauCurve(hMain);
MultiMTgui_closeTrackingControls(hMain)
try
    delete(handles.hFig_ControlsWindow);
    handles.controls_open = false;
catch
    status = false;
end
try
    delete(handles.hFig_CommentsWindow);
catch
    status = false;
end
try
    delete(handles.hFig_CustomExperiment)
catch
end

try
	delete(handles.hFig_ImageWindow);
catch
    status = false;
    
end

try
    delete(handles.MC);
    delete(handles.TM);
    delete(handles.TC);
    delete(handles.TU);
catch
    status = false;
end

% try
%     p = gcp('nocreate');
%     delete(p);
% catch
% end

guidata(hMain,handles);

%% Clear Globals
clearvars -global gMT_track_XYZ; %Current bead positions
clearvars -global gMT_PlotMarkers; %handle to graphic markers for bead center
end