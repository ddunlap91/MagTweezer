function MultiMTgui_setupHardwareSettings(hHardwareSettings)
%Multigui_setupHardwareSettings
% Input:
%   hHardwareSettings - the handle to the Micrscope control figure
%       This function should be called by the HardwareSettings figure
%       after the guidata has been updated.
% Example:
%   ...
%   %Update handles structure
%   guidata(hObject,handles);
%   %Setup GUI
%   MultiMTgui_setupHardwareSettings(hObject);
%
% Note: This function will update the guidata before exiting.

%A handle to the main window is included with this object as hMainWindow

hshandles = guidata(hMicroscopeControls); %get guidata for the Control widow
hMain = hshandles.hMainWindow; %handle to main window
handles = guidata(hMain); %get guidata for the mani window

