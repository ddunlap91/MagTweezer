function varargout = MultiMTgui_HardwareSettings(varargin)
% MULTIMTGUI_HARDWARESETTINGS MATLAB code for MultiMTgui_HardwareSettings.fig
%      MULTIMTGUI_HARDWARESETTINGS, by itself, creates a new MULTIMTGUI_HARDWARESETTINGS or raises the existing
%      singleton*.
%
%      H = MULTIMTGUI_HARDWARESETTINGS returns the handle to a new MULTIMTGUI_HARDWARESETTINGS or the handle to
%      the existing singleton*.
%
%      MULTIMTGUI_HARDWARESETTINGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MULTIMTGUI_HARDWARESETTINGS.M with the given input arguments.
%
%      MULTIMTGUI_HARDWARESETTINGS('Property','Value',...) creates a new MULTIMTGUI_HARDWARESETTINGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MultiMTgui_HardwareSettings_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MultiMTgui_HardwareSettings_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MultiMTgui_HardwareSettings

% Last Modified by GUIDE v2.5 19-Oct-2015 11:23:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MultiMTgui_HardwareSettings_OpeningFcn, ...
                   'gui_OutputFcn',  @MultiMTgui_HardwareSettings_OutputFcn, ...
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


% --- Executes just before MultiMTgui_HardwareSettings is made visible.
function MultiMTgui_HardwareSettings_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MultiMTgui_HardwareSettings (see VARARGIN)

% Choose default command line output for MultiMTgui_HardwareSettings
handles.output = hObject;

if numel(varargin) < 1
    warning('MultiMTgui_HarwdareSettings must be called by the main window.  It does not run on it own.');
end

%Initialize Figure Parent
ind = find(strcmpi(varargin,'MainHandle'));
if isempty(ind)
    warning('could not find handle to main window use syntax ...HardwareSettings("MainHandle",hMain)');
else
    handles.hMainWindow = varargin{ind+1};
    if ~ishandle(handles.hMainWindow)
        error('Specified handle is not valid');
    end
end

% Update handles structure
guidata(hObject, handles);
MultiMTgui_setupHardwareSettings(hObject);

% UIWAIT makes MultiMTgui_HardwareSettings wait for user response (see UIRESUME)
% uiwait(handles.hFig_HardwareSettings);


% --- Outputs from this function are returned to the command line.
function varargout = MultiMTgui_HardwareSettings_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in hBtn_Save.
function hBtn_Save_Callback(hObject, eventdata, handles)
% hObject    handle to hBtn_Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in hBtn_Cancel.
function hBtn_Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to hBtn_Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in hPop_PiezoController.
function hPop_PiezoController_Callback(hObject, eventdata, handles)
% hObject    handle to hPop_PiezoController (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hPop_PiezoController contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hPop_PiezoController


% --- Executes during object creation, after setting all properties.
function hPop_PiezoController_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hPop_PiezoController (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in hPop_PiezoCOM.
function hPop_PiezoCOM_Callback(hObject, eventdata, handles)
% hObject    handle to hPop_PiezoCOM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hPop_PiezoCOM contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hPop_PiezoCOM


% --- Executes during object creation, after setting all properties.
function hPop_PiezoCOM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hPop_PiezoCOM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in hPop_CameraModel.
function hPop_CameraModel_Callback(hObject, eventdata, handles)
% hObject    handle to hPop_CameraModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hPop_CameraModel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hPop_CameraModel


% --- Executes during object creation, after setting all properties.
function hPop_CameraModel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hPop_CameraModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in hPop_MotorCOM.
function hPop_MotorCOM_Callback(hObject, eventdata, handles)
% hObject    handle to hPop_MotorCOM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hPop_MotorCOM contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hPop_MotorCOM


% --- Executes during object creation, after setting all properties.
function hPop_MotorCOM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hPop_MotorCOM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in hPop_MotorBAUD.
function hPop_MotorBAUD_Callback(hObject, eventdata, handles)
% hObject    handle to hPop_MotorBAUD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hPop_MotorBAUD contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hPop_MotorBAUD


% --- Executes during object creation, after setting all properties.
function hPop_MotorBAUD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hPop_MotorBAUD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hEdt_LinearMotorType_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_LinearMotorType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_LinearMotorType as text
%        str2double(get(hObject,'String')) returns contents of hEdt_LinearMotorType as a double


% --- Executes during object creation, after setting all properties.
function hEdt_LinearMotorType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_LinearMotorType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in hPop_MotorController.
function hPop_MotorController_Callback(hObject, eventdata, handles)
% hObject    handle to hPop_MotorController (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hPop_MotorController contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hPop_MotorController


% --- Executes during object creation, after setting all properties.
function hPop_MotorController_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hPop_MotorController (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in hPop_LinearMotorID.
function hPop_LinearMotorID_Callback(hObject, eventdata, handles)
% hObject    handle to hPop_LinearMotorID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hPop_LinearMotorID contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hPop_LinearMotorID


% --- Executes during object creation, after setting all properties.
function hPop_LinearMotorID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hPop_LinearMotorID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hEdt_RotationMotorType_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_RotationMotorType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_RotationMotorType as text
%        str2double(get(hObject,'String')) returns contents of hEdt_RotationMotorType as a double


% --- Executes during object creation, after setting all properties.
function hEdt_RotationMotorType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_RotationMotorType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in hPop_RotationMotorID.
function hPop_RotationMotorID_Callback(hObject, eventdata, handles)
% hObject    handle to hPop_RotationMotorID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hPop_RotationMotorID contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hPop_RotationMotorID


% --- Executes during object creation, after setting all properties.
function hPop_RotationMotorID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hPop_RotationMotorID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in hPop_PiezoBAUD.
function hPop_PiezoBAUD_Callback(hObject, eventdata, handles)
% hObject    handle to hPop_PiezoBAUD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hPop_PiezoBAUD contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hPop_PiezoBAUD


% --- Executes during object creation, after setting all properties.
function hPop_PiezoBAUD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hPop_PiezoBAUD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hEdt_PiezoLowerLimit_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_PiezoLowerLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_PiezoLowerLimit as text
%        str2double(get(hObject,'String')) returns contents of hEdt_PiezoLowerLimit as a double


% --- Executes during object creation, after setting all properties.
function hEdt_PiezoLowerLimit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_PiezoLowerLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hEdt_PiezoUpperLimit_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_PiezoUpperLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_PiezoUpperLimit as text
%        str2double(get(hObject,'String')) returns contents of hEdt_PiezoUpperLimit as a double


% --- Executes during object creation, after setting all properties.
function hEdt_PiezoUpperLimit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_PiezoUpperLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hEdt_RotationScale_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_RotationScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_RotationScale as text
%        str2double(get(hObject,'String')) returns contents of hEdt_RotationScale as a double


% --- Executes during object creation, after setting all properties.
function hEdt_RotationScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_RotationScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
