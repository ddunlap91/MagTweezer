function status = MultiMTgui_stopHardware(hMain)
%MultiMTgui_stopHardware(hObject) Stops microscope hardware
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
%   initstat = MultiMTgui_stopHardware(hObject);
%   if ~initstat
%       error('Did not stop hardware');
%   end
%
% Note: This function will update the guidata before returning

status = true;

stopCamera(hMain);

%get an updated copy of the handles data
handles = guidata(hMain);

try
    delete(handles.MotorObj);
catch
    warning('Could not delete Motor Object');
    status = false;
end

try
    delete(handles.PiezoObj);
catch
    warning('Could not delete Piezo Object');
end

try
    delete(handles.MMcam);
catch
    warning('Could not delete MMcam');
    status = false;
end

guidata(hMain,handles);

end