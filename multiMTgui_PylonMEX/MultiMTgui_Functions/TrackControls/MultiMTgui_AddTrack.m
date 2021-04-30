function MultiMTgui_AddTrack(hMain)

%get gui data
%===========================
stopCamera(hMain);
pause(0.01);
setInFunctionFlag(hMain,true); %tell camera to stop processing frames so we can think
handles = guidata(hMain);


if handles.ExperimentRunning
    warning('There is an experiment already running. Cannot add track.');
    setInFunctionFlag(hMain,false);
    startCamera(hMain);
    pause(0.01);
    return;
end

wasrecording = handles.RecXYZ_Recording;
if wasrecording
    warning('Restarting Live Recording to add track');
    MultiMTgui_stopRecording(hMain);
end

if ~handles.imagefig_open %if image window is closed, open it
    ImageWindow_Open(hMain);
    handles = guidata(hMain);
end
figure(handles.hFig_ImageWindow); %bring image figure to front
%startCamera(hMain);
pause(0.01);

hrect = imrect2('Parent',handles.hAx_CameraImageAxes,...
                'LimMode','manual',...
                'HandleVisibility','callback',...
                'Color',ind2colorstr(handles.num_tracks+1),...
                'ResizeFcn',{@MultiMTgui_TrackWINDResize,hMain});
            
if isempty(hrect) %user didn't select a window
    return;
end

if hrect.Position(3)==0 || hrect.Position(4)==4
    warndlg('Window had zero width, not adding track','Zero Width','modal');
    try
        delete(hrect);
    catch
    end
    return;
end
%%% Program updated to ask for profile radius beforehand, defaults to 50 pixels%%%
%{
rad = NaN;
while isnan(rad)
    rad = inputdlg('Profile Radius in pixels','Radius?');
    if isempty(rad) %user clicked cancel
        delete(hrect);
        return;
    end
    rad = str2double(rad);
    if rad<1
        rad=NaN;
    end
end
%}
rad = handles.ProfileRadius;
%add a new track to the list of tracks

trkID = handles.num_tracks+1;
handles.track_hrect(trkID) = hrect;
handles.track_params(trkID) = struct('Sel',false,'Type','Measurement','Radius',rad,'Color',ind2colorstr(trkID),'Lock',false,'IsCalibrated',false,'ZRef',trkID);
handles.track_calib(trkID) = struct('IrStack',[],'Radius',[],'ZPos',[],'IsCalibrated',false);
handles.track_calib(trkID).Radius = rad;
handles.track_XYZ(trkID,:) = NaN(1,3);
%wind
p = get(hrect,'position');
w = ceil([p(1),p(1)+p(3)-1,p(2),p(2)+p(4)-1]);
handles.track_wind(trkID,:) = w;

handles.FE_SaveAbsZ(trkID) = false;
% trkID
% size(handles.track_wind)
% size(handles.track_calib)

%set trackID. note: if hrect is deleted and recreated we will need to set
%this again.
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


%Update data
%=========
handles.num_tracks = handles.num_tracks+1;

%stopCamera(hMain);
pause(0.01);

%% SAVE DATA
guidata(hMain,handles);
MultiMT_updateTiltControls(hMain);
MultiMT_updateTrackParameterTable(hMain);
startCamera(hMain);
pause(0.01);
setInFunctionFlag(hMain,false); %tell camera it's ok to processing frames
if wasrecording
    MultiMTgui_startRecording(hMain);
end

function s = ind2colorstr(ind)
c = 'ymcrgb';
ind = mod(ind,numel(c));
if ind==0
    ind=numel(c);
end
s=c(ind);