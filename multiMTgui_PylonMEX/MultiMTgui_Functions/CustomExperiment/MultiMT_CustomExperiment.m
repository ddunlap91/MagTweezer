function varargout = MultiMT_CustomExperiment(varargin)
% MULTIMT_CUSTOMEXPERIMENT MATLAB code for MultiMT_CustomExperiment.fig
%      MULTIMT_CUSTOMEXPERIMENT, by itself, creates a new MULTIMT_CUSTOMEXPERIMENT or raises the existing
%      singleton*.
%
%      H = MULTIMT_CUSTOMEXPERIMENT returns the handle to a new MULTIMT_CUSTOMEXPERIMENT or the handle to
%      the existing singleton*.
%
%      MULTIMT_CUSTOMEXPERIMENT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MULTIMT_CUSTOMEXPERIMENT.M with the given input arguments.
%
%      MULTIMT_CUSTOMEXPERIMENT('Property','Value',...) creates a new MULTIMT_CUSTOMEXPERIMENT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MultiMT_CustomExperiment_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MultiMT_CustomExperiment_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MultiMT_CustomExperiment

% Last Modified by GUIDE v2.5 06-Sep-2016 12:31:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MultiMT_CustomExperiment_OpeningFcn, ...
                   'gui_OutputFcn',  @MultiMT_CustomExperiment_OutputFcn, ...
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


% --- Executes just before MultiMT_CustomExperiment is made visible.
function MultiMT_CustomExperiment_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MultiMT_CustomExperiment (see VARARGIN)

% Choose default command line output for MultiMT_CustomExperiment
handles.output = hObject;

if numel(varargin) < 1
    warning('MultiMT_CustomExperiment must be called by the main window.  It does not run on it own.');
end

%Initialize Figure Parent
ind = find(strcmpi(varargin,'MainHandle'));
if isempty(ind)
    warning('could not find handle to main window use syntax ...MultiMT_CustomExperiment("MainHandle",hMain)');
else
    handles.hMainWindow = varargin{ind+1};
    if ~ishandle(handles.hMainWindow)
        error('Specified handle is not valid');
    end
end

% Update handles structure
guidata(hObject, handles);
MultiMT_setupCustomExperiment(hObject);

% UIWAIT makes MultiMT_CustomExperiment wait for user response (see UIRESUME)
% uiwait(handles.hFig_CustomExperiment);


% --- Outputs from this function are returned to the command line.
function varargout = MultiMT_CustomExperiment_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function hEdt_Dir_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_Dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_Dir as text
%        str2double(get(hObject,'String')) returns contents of hEdt_Dir as a double
mhandles = guidata(handles.hMainWindow);
mhandles.data_dir = get(hObject,'string');
guidata(handles.hMainWindow,mhandles);

% --- Executes during object creation, after setting all properties.
function hEdt_Dir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_Dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hBtn_ChooseDir.
function hBtn_ChooseDir_Callback(hObject, eventdata, handles)
% hObject    handle to hBtn_ChooseDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mhandles = guidata(handles.hMainWindow);
%if specified directory doesn't exist create it temporarily
d = uigetdir_mk(mhandles.data_dir,'Select Data Directory');
if d==0
    return;
end
set(handles.hEdt_Dir,'string',d);
mhandles.data_dir = d;
guidata(handles.hMainWindow,mhandles);


function hEdt_FileName_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_FileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_FileName as text
%        str2double(get(hObject,'String')) returns contents of hEdt_FileName as a double
mhandles = guidata(handles.hMainWindow);
mhandles.CustomExperiment_FileName = get(hObject,'string');
guidata(handles.hMainWindow,mhandles);

% --- Executes during object creation, after setting all properties.
function hEdt_FileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_FileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hChk_AutoName.
function hChk_AutoName_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_AutoName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_AutoName
mhandles = guidata(handles.hMainWindow);
mhandles.CustomExperiment_AutoName = get(hObject,'value');
[mhandles,handles] = MultiMT_updateCustomExperimentFileName(mhandles,handles);
guidata(handles.hMainWindow,mhandles);

function hEdt_Comments_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_Comments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_Comments as text
%        str2double(get(hObject,'String')) returns contents of hEdt_Comments as a double


% --- Executes during object creation, after setting all properties.
function hEdt_Comments_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_Comments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hBtn_StartPause.
function hBtn_StartPause_Callback(hObject, eventdata, handles)
% hObject    handle to hBtn_StartPause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmpi(hObject.String,'START')
    MultiMT_startCustomExperiment(handles.hMainWindow)
    return;
end
if strcmpi(hObject.String,'STOP')
    MultiMT_stopCustomExperiment(handles.hMainWindow)
    return;
end


% --- Executes on button press in hChk_MinimizeROI.
function hChk_MinimizeROI_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_MinimizeROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_MinimizeROI
mhandles = guidata(handles.hMainWindow);
mhandles.ExperimentScheme.MinimizeROI = get(hObject,'value');
guidata(handles.hMainWindow,mhandles);

% --- Executes on button press in hChk_CaptureOffline.
function hChk_CaptureOffline_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_CaptureOffline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_CaptureOffline
mhandles = guidata(handles.hMainWindow);
mhandles.ExperimentScheme.CaptureOffline = get(hObject,'value');
guidata(handles.hMainWindow,mhandles);


% --- Executes on button press in hRad_FixedFrameCount.
function hRad_FixedFrameCount_Callback(hObject, eventdata, handles)
% hObject    handle to hRad_FixedFrameCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hRad_FixedFrameCount
mhandles = guidata(handles.hMainWindow);
mhandles.ExperimentScheme.FixedDuration = ~get(hObject,'value');
handles.hRad_FixedDuration.Value = mhandles.ExperimentScheme.FixedDuration;
MultiMT_ExpUpdateTableData(handles.hTbl_ExperimentScheme,mhandles.ExperimentScheme);
guidata(handles.hMainWindow,mhandles);

% --- Executes on button press in hRad_FixedDuration.
function hRad_FixedDuration_Callback(hObject, eventdata, handles)
% hObject    handle to hRad_FixedDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hRad_FixedDuration
mhandles = guidata(handles.hMainWindow);
mhandles.ExperimentScheme.FixedDuration = get(hObject,'value');
handles.hRad_FixedFrameCount.Value = ~mhandles.ExperimentScheme.FixedDuration;
MultiMT_ExpUpdateTableData(handles.hTbl_ExperimentScheme,mhandles.ExperimentScheme);
guidata(handles.hMainWindow,mhandles);

% --- Executes on button press in hBtn_AddRow.
function hBtn_AddRow_Callback(hObject, eventdata, handles)
% hObject    handle to hBtn_AddRow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in hBtn_DeleteRow.
function hBtn_DeleteRow_Callback(hObject, eventdata, handles)
% hObject    handle to hBtn_DeleteRow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in hBtn_InsertRow.
function hBtn_InsertRow_Callback(hObject, eventdata, handles)
% hObject    handle to hBtn_InsertRow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in hBtn_ClearAll.
function hBtn_ClearAll_Callback(hObject, eventdata, handles)
% hObject    handle to hBtn_ClearAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mhandles = guidata(handles.hMainWindow);

mhandles.ExperimentScheme.ExperimentSteps(:) = [];
guidata(handles.hMainWindow,mhandles);
%update table
MultiMT_ExpUpdateTableData(handles.hTbl_ExperimentScheme,mhandles.ExperimentScheme);




% --- Executes on button press in hChk_OutputX.
function hChk_OutputX_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_OutputX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_OutputX
mhandles = guidata(handles.hMainWindow);
mhandles.ExperimentScheme.OutputX = get(hObject,'Value');
guidata(handles.hMainWindow,mhandles);

% --- Executes on button press in hChk_OutputY.
function hChk_OutputY_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_OutputY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_OutputY
mhandles = guidata(handles.hMainWindow);
mhandles.ExperimentScheme.OutputY = get(hObject,'Value');
guidata(handles.hMainWindow,mhandles);

% --- Executes on button press in hChk_OutputZ.
function hChk_OutputZ_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_OutputZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_OutputZ
mhandles = guidata(handles.hMainWindow);
mhandles.ExperimentScheme.OutputZrel = get(hObject,'Value');
guidata(handles.hMainWindow,mhandles);

% --- Executes on button press in hChk_OutputZabs.
function hChk_OutputZabs_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_OutputZabs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_OutputZabs
mhandles = guidata(handles.hMainWindow);
mhandles.ExperimentScheme.OutputZabs = get(hObject,'Value');
guidata(handles.hMainWindow,mhandles);

% --- Executes on selection change in hLst_DataPlots.
function hLst_DataPlots_Callback(hObject, eventdata, handles)
% hObject    handle to hLst_DataPlots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hLst_DataPlots contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hLst_DataPlots


% --- Executes during object creation, after setting all properties.
function hLst_DataPlots_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hLst_DataPlots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hBtn_ShowSelectedPlots.
function hBtn_ShowSelectedPlots_Callback(hObject, eventdata, handles)
% hObject    handle to hBtn_ShowSelectedPlots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
MultiMT_CustomExperimentShowPlots(hObject);


% --------------------------------------------------------------------
function hMenu_CustExp_Experiment_Callback(hObject, eventdata, handles)
% hObject    handle to hMenu_CustExp_Experiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function hMenu_CustExp_LoadExpScheme_Callback(hObject, eventdata, handles)
% hObject    handle to hMenu_CustExp_LoadExpScheme (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function hMenu_CustExp_SaveExpScheme_Callback(hObject, eventdata, handles)
% hObject    handle to hMenu_CustExp_SaveExpScheme (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in hBtn_CustExp_AddParameter.
function hBtn_CustExp_AddParameter_Callback(hObject, eventdata, handles)
% hObject    handle to hBtn_CustExp_AddParameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in hBtn_SelectParameter.
function hBtn_SelectParameter_Callback(hObject, eventdata, handles)
% hObject    handle to hBtn_SelectParameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when user attempts to close hFig_CustomExperiment.
function hFig_CustomExperiment_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to hFig_CustomExperiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
MultiMT_closeCustomExperiment(handles.hMainWindow,hObject);
