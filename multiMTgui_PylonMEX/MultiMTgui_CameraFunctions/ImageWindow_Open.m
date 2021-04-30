function ImageWindow_Open(hMain)
%creates an image window for the camera (if needed).
stopCamera(hMain)
handles = guidata(hMain);

if ishandle(handles.hFig_ImageWindow)
    %window is already open...just return
    return;
end

%setup figure
handles.hFig_ImageWindow = figure();
set(handles.hFig_ImageWindow,'CloseRequestFcn',{@ImageWindow_CloseRequest,hMain});

handles.imagefig_open = true;

handles.hAx_CameraImageAxes = gca;
handles.MMcam.setupAxes(handles.hAx_CameraImageAxes);
handles.MMcam.setDrawImage(true);
%set(handles.hAx_CameraImageAxes,'YDir','normal');

%turn check mark on in gui menu
set(handles.hMenu_ImagePreview,'checked','on');
%save guidata
guidata(hMain,handles);

%draw tracking rectangles
try
    delete(handles.track_hrect)
catch
end
for t=1:handles.num_tracks
    MultiMTgui_DrawTrackhrect(hMain,t);
end
startCamera(hMain)
