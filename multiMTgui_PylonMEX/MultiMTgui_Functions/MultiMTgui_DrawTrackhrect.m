function MultiMTgui_DrawTrackhrect(hMain,trkID)
%if the iamge figure has been closed or a hrect is messed up redraw it with
%this function

%Update gui data
%=========================
handles = guidata(hMain);

if ~handles.imagefig_open %if image window is closed, skip this
    return;
end

if trkID<1||trkID>handles.num_tracks
    return;
end

%disp('trkID:');
%disp(trkID);
%handles.track_hrect(trkID)
try
    delete(handles.track_hrect(trkID));
    delete(handles.track_xyzlabel(trkID));
catch
end

%position
p = handles.track_wind(trkID,:);
p=[p(1)-.5,p(3)-.5,p(2)-p(1)+1,p(4)-p(3)+1];

hrect = imrect2('Parent',handles.hAx_CameraImageAxes,...
                'LimMode','manual',...
                'HandleVisibility','callback',...
                'Color',handles.track_params(trkID).Color,...
                'ResizeFcn',{@MultiMTgui_TrackWINDResize,hMain},...
                'LockPosition',handles.track_params(trkID).Lock,...
                'position',p);
handles.track_hrect(trkID) = hrect;

ud = get(hrect,'userdata');
ud.trkID = trkID;
set(hrect,'userdata',ud);

%create label for x y z position
if strcmpi(handles.track_params(trkID).Type,'Reference')
    pre = 'Ref';
else
    pre = 'Meas';
end
str = sprintf([pre,': %0.0f Z:NaN'],trkID);
w=handles.track_wind(trkID,:);
handles.track_xyzlabel(trkID) = text(w(1),w(4),str,...
    'HorizontalAlignment','Left',...
    'VerticalAlignment','top',...
    'Margin',3,'Color','r',...
    'HandleVisibility','callback',...
    'PickableParts','none',...
    'Parent',handles.hAx_CameraImageAxes);

%update data
%==========
guidata(hMain,handles);