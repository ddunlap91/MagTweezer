function varargout = MultiMTgui_MicroscopeControls(varargin)
%MULTIMTGUI_MICROSCOPECONTROLS M-file for MultiMTgui_MicroscopeControls.fig
%      MULTIMTGUI_MICROSCOPECONTROLS, by itself, creates a new MULTIMTGUI_MICROSCOPECONTROLS or raises the existing
%      singleton*.
%
%      H = MULTIMTGUI_MICROSCOPECONTROLS returns the handle to a new MULTIMTGUI_MICROSCOPECONTROLS or the handle to
%      the existing singleton*.
%
%      MULTIMTGUI_MICROSCOPECONTROLS('Property','Value',...) creates a new MULTIMTGUI_MICROSCOPECONTROLS using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to MultiMTgui_MicroscopeControls_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      MULTIMTGUI_MICROSCOPECONTROLS('CALLBACK') and MULTIMTGUI_MICROSCOPECONTROLS('CALLBACK',hObject,...) call the
%      local function named CALLBACK in MULTIMTGUI_MICROSCOPECONTROLS.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MultiMTgui_MicroscopeControls

% Last Modified by GUIDE v2.5 03-Feb-2021 01:50:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MultiMTgui_MicroscopeControls_OpeningFcn, ...
                   'gui_OutputFcn',  @MultiMTgui_MicroscopeControls_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before MultiMTgui_MicroscopeControls is made visible.
function MultiMTgui_MicroscopeControls_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for MultiMTgui_MicroscopeControls
handles.output = hObject;

if numel(varargin) < 1
    error('MultiMTgui_MicroscopeControls must be called by the main window.  It does not run on it own.');
end

%Initialize Figure Parent
ind = find(strcmpi(varargin,'MainHandle'));
if isempty(ind)
    error('could not find handle to main window use syntac ...MicroscopeControls("MainHandle",hMain)');
end
handles.hMainWindow = varargin{ind+1};
if ~ishandle(handles.hMainWindow)
    error('Specified handle is not valid');
end

% Update handles structure
guidata(hObject, handles);

%Setup gui
MultiMTgui_setupMicroscopeControls(hObject);



% UIWAIT makes MultiMTgui_MicroscopeControls wait for user response (see UIRESUME)
% uiwait(handles.hFig_MicroscopeControls);


% --- Outputs from this function are returned to the command line.
function varargout = MultiMTgui_MicroscopeControls_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes during object creation, after setting all properties.
function hEdt_Exposure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_Exposure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function hEdt_Gain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_Gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function hSld_Brightness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hSld_Brightness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% --- Executes during object creation, after setting all properties.
function hEdt_Brightness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_Brightness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function hSld_Gain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hSld_Gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function hSld_ObjectiveHeight_Callback(hObject, eventdata, handles)
% hObject    handle to hSld_ObjectiveHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
hMain  = handles.hMainWindow;

v = get(hObject,'value');

if ~isnan(v)
    setObjectivePosition(hMain,v);
else
    getObjectivePosition(hMain);
end

% --- Executes during object creation, after setting all properties.
function hSld_ObjectiveHeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hSld_ObjectiveHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function hEdt_ObjectiveHeight_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_ObjectiveHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_ObjectiveHeight as text
%        str2double(get(hObject,'String')) returns contents of hEdt_ObjectiveHeight as a double
hMain  = handles.hMainWindow;

v = get(hObject,'string');
v = str2double(v);
if ~isnan(v)
    setObjectivePosition(hMain,v);
else
    getObjectivePosition(hMain);
end

% --- Executes during object creation, after setting all properties.
function hEdt_ObjectiveHeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_ObjectiveHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hBtn_SetObjectiveMax.
function hBtn_SetObjectiveMax_Callback(hObject, eventdata, handles)
% hObject    handle to hBtn_SetObjectiveMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in hBtn_SetObjectiveMin.
function hBtn_SetObjectiveMin_Callback(hObject, eventdata, handles)
% hObject    handle to hBtn_SetObjectiveMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function hEdt_ObjectiveMax_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_ObjectiveMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_ObjectiveMax as text
%        str2double(get(hObject,'String')) returns contents of hEdt_ObjectiveMax as a double


% --- Executes during object creation, after setting all properties.
function hEdt_ObjectiveMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_ObjectiveMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hEdt_ObjectiveMin_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_ObjectiveMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_ObjectiveMin as text
%        str2double(get(hObject,'String')) returns contents of hEdt_ObjectiveMin as a double


% --- Executes during object creation, after setting all properties.
function hEdt_ObjectiveMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_ObjectiveMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function hSld_MagnetHeight_Callback(hObject, eventdata, handles)
% hObject    handle to hSld_MagnetHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
hMain  = handles.hMainWindow;

v = get(hObject,'value');

if ~isnan(v)
    setMagnetZPosition(hMain,v);
else
    getMagnetZPosition(hMain);
end

% --- Executes during object creation, after setting all properties.
function hSld_MagnetHeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hSld_MagnetHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function hEdt_MagnetHeight_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_MagnetHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_MagnetHeight as text
%        str2double(get(hObject,'String')) returns contents of hEdt_MagnetHeight as a double
hMain  = handles.hMainWindow;

v = get(hObject,'string');
v = str2double(v);
if ~isnan(v)
    setMagnetZPosition(hMain,v);
else
    getMagnetZPosition(hMain);
end

% --- Executes during object creation, after setting all properties.
function hEdt_MagnetHeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_MagnetHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hBtn_StopMotor.
function hBtn_StopMotor_Callback(hObject, eventdata, handles)
% hObject    handle to hBtn_StopMotor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function hEdt_MagnetHeightSpeed_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_MagnetHeightSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_MagnetHeightSpeed as text
%        str2double(get(hObject,'String')) returns contents of hEdt_MagnetHeightSpeed as a double
hMain  = handles.hMainWindow;

v = get(hObject,'string');
v = str2double(v);
if ~isnan(v)
    setMagnetZSpeed(hMain,v);
else
    getMagnetZSpeed(hMain);
end

% --- Executes during object creation, after setting all properties.
function hEdt_MagnetHeightSpeed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_MagnetHeightSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hEdt_MagnetRotation_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_MagnetRotation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_MagnetRotation as text
%        str2double(get(hObject,'String')) returns contents of hEdt_MagnetRotation as a double
hMain  = handles.hMainWindow;

v = get(hObject,'string');
v = str2double(v);
if ~isnan(v)
    setMagnetRotation(hMain,v);
else
    getMagnetRotation(hMain);
end

% --- Executes during object creation, after setting all properties.
function hEdt_MagnetRotation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_MagnetRotation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hEdt_MagnetRotationSpeed_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_MagnetRotationSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_MagnetRotationSpeed as text
%        str2double(get(hObject,'String')) returns contents of hEdt_MagnetRotationSpeed as a double
hMain  = handles.hMainWindow;

v = get(hObject,'string');
v = str2double(v);
if ~isnan(v)
    setMagnetRotSpeed(hMain,v);
else
    getMagnetRotSpeed(hMain);
end

% --- Executes during object creation, after setting all properties.
function hEdt_MagnetRotationSpeed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_MagnetRotationSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function hEdt_ActualFrameRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_ActualFrameRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close hFig_MicroscopeControls.
function hFig_MicroscopeControls_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to hFig_MicroscopeControls (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
%generally we will leave deleting the control window figure up to the main
%control program.
if ~ishandle(handles.hMainWindow) %only delete if main window is closed
    delete(hObject);
end


% --- Executes during object creation, after setting all properties.
function hCtrl_FrameRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hCtrl_FrameRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hEdt_ActualObjectiveHeight_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_ActualObjectiveHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_ActualObjectiveHeight as text
%        str2double(get(hObject,'String')) returns contents of hEdt_ActualObjectiveHeight as a double


% --- Executes during object creation, after setting all properties.
function hEdt_ActualObjectiveHeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_ActualObjectiveHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hBtn_SetZero.
function hBtn_SetZero_Callback(hObject, eventdata, handles)
% hObject    handle to hBtn_SetZero (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

resetMagnetRotation(handles.hMainWindow);
