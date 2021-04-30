function MultiMTgui_TrackWINDResize(hrect,hMain)
%update particle tracking window associated with the user drawn rectangle
%hrect.
%This function should be used as a callback for imrect2.
% Example:
%   imrect2(...,'ResizeFcn',{@MultiMTgui_TrackWINDResize,hMainWindow});

setInFunctionFlag(hMain,true); %tell camera to stop processing frames so we can think
handles = guidata(hMain);
ud = get(hrect,'userdata');
p = get(hrect,'position');

w = ceil([p(1),p(1)+p(3)-1,p(2),p(2)+p(4)-1]);
handles.track_wind(ud.trkID,:) = w;

%update text position
set(handles.track_xyzlabel(ud.trkID),'Position',[w(1),w(4)]);

%update data
%==================
guidata(hMain,handles);
setInFunctionFlag(hMain,false); %tell camera to process frames