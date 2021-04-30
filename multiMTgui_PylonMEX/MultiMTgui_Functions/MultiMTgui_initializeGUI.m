function status = MultiMTgui_initializeGUI(hMain)
%MultiMTgui_initializeGUI(hObject) Initialize GUI
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
%   initstat = MultiMTgui_initializeGUI(hObject);
%   if ~initstat
%       error('Did not initialize GUI');
%   end
%
% Note: This function will update the guidata before returning
status = true;

%% Microscope Controls
%=====================================
hFig_ControlsWindow = MultiMTgui_MicroscopeControls('MainHandle',hMain);
%get guidata
handles = guidata(hMain);
handles.hFig_ControlsWindow = hFig_ControlsWindow;
%save guidata
guidata(hMain,handles);

%% ImageWindow
%==========================
ImageWindow_Open(hMain);

%% Tracking Controls
%==============================
handles = guidata(hMain);
handles.tracking_open = false;
set(handles.hMenu_TrackingControls,'Checked','off');

%% Camera & Hardware Interface Callbacks
%=======================================
handles.MMcam.setFrameCallback({@MultiMTgui_CameraCallback,hMain});
handles.MMcam.setPropertyUpdateCallback({@MultiMTgui_CameraPropertiesUpdateCallback, hMain});
%handles.MMcam.setDrawCallback({@MultiMTgui_DrawCallback, hMain});

%start camera
handles = guidata(hMain);
handles.MMcam.StartLiveMode();

%% Hardware info timer
%===============================
% try
%     stop(handles.SettingsTimer);
%     delete(handles.SettingsTimer);
% catch
% end
% handles.SettingsTimer = timer('BusyMode','drop',...
%                                 'ExecutionMode','fixedSpacing',...
%                                 'TimerFcn',@(~,~) updateHardwareInfo(hMain),...
%                                 'period',0.5,...
%                                 'name','SettingsTimer');
% start(handles.SettingsTimer);

                                
% guidata(hMain,handles);
    

end

