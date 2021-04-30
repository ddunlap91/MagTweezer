function varargout = MultiMTgui_TrackingControls(varargin)
% MULTIMTGUI_TRACKINGCONTROLS MATLAB code for MultiMTgui_TrackingControls.fig
%      MULTIMTGUI_TRACKINGCONTROLS, by itself, creates a new MULTIMTGUI_TRACKINGCONTROLS or raises the existing
%      singleton*.
%
%      H = MULTIMTGUI_TRACKINGCONTROLS returns the handle to a new MULTIMTGUI_TRACKINGCONTROLS or the handle to
%      the existing singleton*.
%
%      MULTIMTGUI_TRACKINGCONTROLS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MULTIMTGUI_TRACKINGCONTROLS.M with the given input arguments.
%
%      MULTIMTGUI_TRACKINGCONTROLS('Property','Value',...) creates a new MULTIMTGUI_TRACKINGCONTROLS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MultiMTgui_TrackingControls_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MultiMTgui_TrackingControls_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MultiMTgui_TrackingControls

% Last Modified by GUIDE v2.5 16-Jan-2021 21:44:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MultiMTgui_TrackingControls_OpeningFcn, ...
                   'gui_OutputFcn',  @MultiMTgui_TrackingControls_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before MultiMTgui_TrackingControls is made visible.
function MultiMTgui_TrackingControls_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MultiMTgui_TrackingControls (see VARARGIN)

% Choose default command line output for MultiMTgui_TrackingControls
handles.output = hObject;

if numel(varargin) < 1
    warning('MultiMTgui_TrackingControls must be called by the main window.  It does not run on it own.');
end

%Initialize Figure Parent
ind = find(strcmpi(varargin,'MainHandle'));
if isempty(ind)
    warning('could not find handle to main window use syntax ...TrackingControls("MainHandle",hMain)');
else
    handles.hMainWindow = varargin{ind+1};
    if ~ishandle(handles.hMainWindow)
        error('Specified handle is not valid');
    end
end
mhandles = guidata(handles.hMainWindow);
mhandles.ProfileRadius = 50;
guidata(handles.hMainWindow, mhandles);
% Update handles structure
guidata(hObject, handles);
MultiMT_setupTrackingControls(hObject)


% UIWAIT makes MultiMTgui_TrackingControls wait for user response (see UIRESUME)
% uiwait(handles.hFig_TrackingControls);


% --- Outputs from this function are returned to the command line.
function varargout = MultiMTgui_TrackingControls_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in hBtn_AddTrack.
function hBtn_AddTrack_Callback(hObject, eventdata, handles)
% hObject    handle to hBtn_AddTrack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
persistent Lockout;
if isempty(Lockout)
    Lockout = 1;
    MultiMTgui_AddTrack(handles.hMainWindow);
end
Lockout = [];

% --- Executes on button press in hBtn_RemoveSelectedTrack.
function hBtn_RemoveSelectedTrack_Callback(hObject, eventdata, handles)
% hObject    handle to hBtn_RemoveSelectedTrack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mhandles = guidata(handles.hMainWindow);
%find selected
trkIDs = mhandles.current_track_selection;
if isempty(trkIDs)||any(isnan(trkIDs))
    return;
end
MultiMTgui_RemoveTrack(handles.hMainWindow,trkIDs);


% --- Executes on button press in hBtn_StartStopCalibration.
function hBtn_StartStopCalibration_Callback(hObject, eventdata, handles)
% hObject    handle to hBtn_StartStopCalibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMain = handles.hMainWindow;
mhandles = guidata(hMain);
if mhandles.CalibrationRunning
    mhandles.CalibrationRunning = false;
    guidata(hMain,mhandles);
    MultiMTgui_updateCalibrationControls(hMain);
else
    mhandles.CalibrationRunning = true;
    guidata(hMain,mhandles);
    MultiMTgui_updateCalibrationControls(hMain);
    MultiMT_RunCalibration(hMain);
    MultiMTgui_updateCalibrationControls(hMain);
end

function hEdt_CalibMin_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_CalibMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_CalibMin as text
%        str2double(get(hObject,'String')) returns contents of hEdt_CalibMin as a double
mhandles = guidata(handles.hMainWindow);
v = str2double(get(hObject,'String'));
if ~isnan(v)
    v = min(v,mhandles.obj_zlim(2));
    v = max(v,mhandles.obj_zlim(1));
    mhandles.CalStackMin = v;
end
guidata(handles.hMainWindow,mhandles);
MultiMTgui_updateCalibrationControls(handles.hMainWindow);

% --- Executes during object creation, after setting all properties.
function hEdt_CalibMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_CalibMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hEdt_CalibStep_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_CalibStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_CalibStep as text
%        str2double(get(hObject,'String')) returns contents of hEdt_CalibStep as a double
mhandles = guidata(handles.hMainWindow);
v = str2double(get(hObject,'String'));
if ~isnan(v)
    v=fix(100*v)/100;
    v = min(v,mhandles.CalStackMax-mhandles.CalStackMin);
    v = max(v,0.01);
    mhandles.CalStackStep = v;
end
guidata(handles.hMainWindow,mhandles);
MultiMTgui_updateCalibrationControls(handles.hMainWindow);

% --- Executes during object creation, after setting all properties.
function hEdt_CalibStep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_CalibStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hEdt_CalibMax_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_CalibMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_CalibMax as text
%        str2double(get(hObject,'String')) returns contents of hEdt_CalibMax as a double
mhandles = guidata(handles.hMainWindow);
v = str2double(get(hObject,'String'));
if ~isnan(v)
    v = min(v,mhandles.obj_zlim(2));
    v = max(v,mhandles.obj_zlim(1));
    mhandles.CalStackMax = v;
end
guidata(handles.hMainWindow,mhandles);
MultiMTgui_updateCalibrationControls(handles.hMainWindow);

% --- Executes during object creation, after setting all properties.
function hEdt_CalibMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_CalibMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hEdt_CalibStepCount_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_CalibStepCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_CalibStepCount as text
%        str2double(get(hObject,'String')) returns contents of hEdt_CalibStepCount as a double
mhandles = guidata(handles.hMainWindow);
v = str2double(get(hObject,'String'));
if ~isnan(v)
    v = max(v,1);
    v = fix(v);
    mhandles.CalStackStepCount = v;
end
guidata(handles.hMainWindow,mhandles);
MultiMTgui_updateCalibrationControls(handles.hMainWindow);

% --- Executes during object creation, after setting all properties.
function hEdt_CalibStepCount_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_CalibStepCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close hFig_TrackingControls.
function hFig_TrackingControls_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to hFig_TrackingControls (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    MultiMTgui_closeTrackingControls(handles.hMainWindow);
catch
    delete(hObject);
end
% Hint: delete(hObject) closes the figure
%delete(hObject);


% --- Executes on button press in hBtn_ShowCalStack.
function hBtn_ShowCalStack_Callback(hObject, eventdata, handles)
% hObject    handle to hBtn_ShowCalStack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%find selected

stopCamera(handles.hMainWindow); %stop camera to give us time to think

mhandles = guidata(handles.hMainWindow);
trkIDs = mhandles.current_track_selection;
if isempty(trkIDs)||any(isnan(trkIDs))
    startCamera(handles.hMainWindow); %restart camera
    return;
end

for t = trkIDs
    if mhandles.track_calib(t).IsCalibrated
        figure();
        him = imagesc(mhandles.track_calib(t).IrStack);
        axis xy;
        colormap gray;
        set(him,'xdata',[0,mhandles.track_calib(t).Radius]);
        set(him,'ydata',[mhandles.track_calib(t).ZPos(1),mhandles.track_calib(t).ZPos(end)]);
        title(sprintf('Track: %0.0f',t));
        xlabel('Radius [px]');
        ylabel('Z Position [µm]');
        axis tight;
    end
end
startCamera(handles.hMainWindow); %restart camera

% --- Executes when hFig_TrackingControls is resized.
function hFig_TrackingControls_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to hFig_TrackingControls (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes when hFig_TrackingControls is resized.

set(hObject,'units','pixels');
fig = get(hObject,'Position');
%fix the figure width to min of 250 px
fig(3)=max(fig(3),270);
fig(4)=max(fig(4),220);


%adjust placment of controls
try
set(handles.hPnl_TrackingParameters,'units','pixels');
set(handles.hPnl_TrackControlBtns,'units','pixels');
set(handles.hPnl_CalibrateControls,'units','pixels');
set(handles.hPnl_Tilt,'units','pixels');


% Track Contols Btns
trk = get(handles.hPnl_TrackControlBtns,'position');
trk = [5,fig(4)-5-trk(4),trk(3),trk(4)];

% calibration
cal = get(handles.hPnl_CalibrateControls,'position');
cal = [trk(1)+trk(3)+5,fig(4)-5-trk(4),cal(3),trk(4)];
cal(3) = fig(3)-cal(1)-5; %expand to remaining width

%tilt
tilt = get(handles.hPnl_Tilt,'position');
tilt = [5,trk(2)-5-tilt(4),fig(3)-10,tilt(4)];

%param
%param = get(handles.hPnl_TrackingParameters,'position');
param = [5,5,fig(3)-10,0];
param(4) = tilt(2)-5-param(2); %expand to remaining height


set(hObject,'Position',fig);
set(handles.hPnl_TrackControlBtns,'position',trk);
set(handles.hPnl_CalibrateControls,'position',cal);
set(handles.hPnl_Tilt,'position',tilt);
set(handles.hPnl_TrackingParameters,'position',param);

catch
end

% --- Executes when hPnl_CalibrateControls is resized.
function hPnl_CalibrateControls_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to hPnl_CalibrateControls (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in hChk_Tilt.
function hChk_Tilt_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_Tilt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_Tilt
mhandles = guidata(handles.hMainWindow);
mhandles.TiltCorrection = hObject.Value;
guidata(handles.hMainWindow,mhandles);

% --- Executes on selection change in hPop_TiltRefTrack.
function hPop_TiltRefTrack_Callback(hObject, eventdata, handles)
% hObject    handle to hPop_TiltRefTrack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hPop_TiltRefTrack contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hPop_TiltRefTrack
mhandles = guidata(handles.hMainWindow);

num = str2double(hObject.String{hObject.Value});
if ~isnan(num)
    mhandles.TiltCorrectionReference = num;
end
guidata(handles.hMainWindow,mhandles);

% --- Executes during object creation, after setting all properties.
function hPop_TiltRefTrack_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hPop_TiltRefTrack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
v = str2double(get(hObject,'String'));
v=round(v);
if v < 1
    v = 50;
end
mhandles = guidata(handles.hMainWindow);
mhandles.ProfileRadius = v;
guidata(handles.hMainWindow,mhandles);


% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
