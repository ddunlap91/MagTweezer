function varargout = MultiMTgui_ChapeauCurve(varargin)
% MULTIMTGUI_CHAPEAUCURVE MATLAB code for MultiMTgui_ChapeauCurve.fig
%      MULTIMTGUI_CHAPEAUCURVE, by itself, creates a new MULTIMTGUI_CHAPEAUCURVE or raises the existing
%      singleton*.
%
%      H = MULTIMTGUI_CHAPEAUCURVE returns the handle to a new MULTIMTGUI_CHAPEAUCURVE or the handle to
%      the existing singleton*.
%
%      MULTIMTGUI_CHAPEAUCURVE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MULTIMTGUI_CHAPEAUCURVE.M with the given input arguments.
%
%      MULTIMTGUI_CHAPEAUCURVE('Property','Value',...) creates a new MULTIMTGUI_CHAPEAUCURVE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MultiMTgui_ChapeauCurve_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MultiMTgui_ChapeauCurve_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MultiMTgui_ChapeauCurve

% Last Modified by GUIDE v2.5 15-Feb-2021 22:08:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MultiMTgui_ChapeauCurve_OpeningFcn, ...
                   'gui_OutputFcn',  @MultiMTgui_ChapeauCurve_OutputFcn, ...
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


% --- Executes just before MultiMTgui_ChapeauCurve is made visible.
function MultiMTgui_ChapeauCurve_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MultiMTgui_ChapeauCurve (see VARARGIN)

% Choose default command line output for MultiMTgui_ChapeauCurve
handles.output = hObject;

if numel(varargin) < 1
    warning('MultiMTgui_ChapeauCurve must be called by the main window.  It does not run on it own.');
end

%Initialize Figure Parent
ind = find(strcmpi(varargin,'MainHandle'));
if isempty(ind)
    warning('could not find handle to main window use syntax ...ChapeauCurve("MainHandle",hMain)');
else
    handles.hMainWindow = varargin{ind+1};
    if ~ishandle(handles.hMainWindow)
        error('Specified handle is not valid');
    end
end

% Update handles structure
guidata(hObject, handles);
setInFunctionFlag(handles.hMainWindow,true);
MultiMTgui_setupChapeauCurve(hObject);
setInFunctionFlag(handles.hMainWindow,false);

% UIWAIT makes MultiMTgui_ChapeauCurve wait for user response (see UIRESUME)
% uiwait(handles.hFig_ChapeauCurve);


% --- Outputs from this function are returned to the command line.
function varargout = MultiMTgui_ChapeauCurve_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in hChk_CC_plotChapeau.
function hChk_CC_plotChapeau_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_CC_plotChapeau (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_CC_plotChapeau
mhandles = guidata(handles.hMainWindow);
mhandles.CC_plotChapeau = get(hObject,'Value');
guidata(handles.hMainWindow,mhandles);

% --- Executes on button press in hChk_CC_plotChapeauErrorBars.
function hChk_CC_plotChapeauErrorBars_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_CC_plotChapeauErrorBars (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_CC_plotChapeauErrorBars
mhandles = guidata(handles.hMainWindow);
mhandles.CC_plotChapeauErrorBars = get(hObject,'Value');
guidata(handles.hMainWindow,mhandles);

% --- Executes on button press in hChk_CC_DriftCompensation.
function hChk_CC_DriftCompensation_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_CC_DriftCompensation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_CC_DriftCompensation
mhandles = guidata(handles.hMainWindow);
mhandles.CC_DriftCompensation = get(hObject,'Value');
guidata(handles.hMainWindow,mhandles);

% --- Executes on button press in hChk_CC_TiltCompensation.
function hChk_CC_TiltCompensation_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_CC_TiltCompensation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_CC_TiltCompensation
mhandles = guidata(handles.hMainWindow);
mhandles.CC_TiltCompensation = get(hObject,'Value');
guidata(handles.hMainWindow,mhandles);

% --- Executes on button press in hBtn_CC_RunStop.
function hBtn_CC_RunStop_Callback(hObject, eventdata, handles)
% hObject    handle to hBtn_CC_RunStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mhandles = guidata(handles.hMainWindow);
if mhandles.ExperimentRunning&&strcmpi(mhandles.ExperimentType,'ChapeauCurve')
    MultiMTgui_stopChapeauCurve(handles.hMainWindow);
else
    MultiMTgui_startChapeauCurve(handles.hMainWindow);
end


function hEdt_CC_Start_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_CC_Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_CC_Start as text
%        str2double(get(hObject,'String')) returns contents of hEdt_CC_Start as a double
mhandles = guidata(handles.hMainWindow);
v = str2double(get(hObject,'String'));
if isnan(v)
    v = mhandles.CC_Start;
else
    mhandles.CC_Start = v;
    if mhandles.CC_Start<mhandles.CC_End
        mhandles.CC_Step = abs(mhandles.CC_Step);
    else
        mhandles.CC_Step = -abs(mhandles.CC_Step);
    end
end
set(handles.hEdt_CC_Step,'string',num2str(mhandles.CC_Step,'%0.2f'));
set(hObject,'string',num2str(v,'%0.2f'));
guidata(handles.hMainWindow,mhandles);

% --- Executes during object creation, after setting all properties.
function hEdt_CC_Start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_CC_Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hEdt_CC_Step_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_CC_Step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_CC_Step as text
%        str2double(get(hObject,'String')) returns contents of hEdt_CC_Step as a double
mhandles = guidata(handles.hMainWindow);
v = str2double(get(hObject,'String'));
if isnan(v)
    v = mhandles.CC_Step;
else
    if mhandles.CC_Start<mhandles.CC_End
        v = abs(v);
        v = min(0.5, v);
    else
        v = -abs(v);
        v = max(-0.5, v);
    end
end
mhandles.CC_Step = v;
disp(v)
set(hObject,'string',num2str(v,'%0.2f'));
guidata(handles.hMainWindow,mhandles);

% --- Executes during object creation, after setting all properties.
function hEdt_CC_Step_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_CC_Step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hEdt_CC_End_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_CC_End (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_CC_End as text
%        str2double(get(hObject,'String')) returns contents of hEdt_CC_End as a double
mhandles = guidata(handles.hMainWindow);
v = str2double(get(hObject,'String'));
if isnan(v)
    v = mhandles.CC_End;
else
    mhandles.CC_End = v;
    if mhandles.CC_Start<mhandles.CC_End
        mhandles.CC_Step = abs(mhandles.CC_Step);
    else
        mhandles.CC_Step = -abs(mhandles.CC_Step);
    end
end
set(handles.hEdt_CC_Step,'string',num2str(mhandles.CC_Step,'%0.2f'));
set(hObject,'string',num2str(v,'%0.2f'));
guidata(handles.hMainWindow,mhandles);

% --- Executes during object creation, after setting all properties.
function hEdt_CC_End_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_CC_End (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hEdt_CC_FrameCount_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_CC_FrameCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_CC_FrameCount as text
%        str2double(get(hObject,'String')) returns contents of hEdt_CC_FrameCount as a double
mhandles = guidata(handles.hMainWindow);
v = str2double(get(hObject,'String'));
if isnan(v)
    v = mhandles.CC_FrameCount;
else
    v=max(50,v);
    mhandles.CC_FrameCount = v;
end
set(hObject,'string',num2str(v,'%0.0f'));
guidata(handles.hMainWindow,mhandles);

% --- Executes during object creation, after setting all properties.
function hEdt_CC_FrameCount_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_CC_FrameCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hChk_CC_FwdRev.
function hChk_CC_FwdRev_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_CC_FwdRev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_CC_FwdRev
mhandles = guidata(handles.hMainWindow);
mhandles.CC_FwdRev = get(hObject,'Value');
guidata(handles.hMainWindow,mhandles);


function hEdt_CC_OutDir_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_CC_OutDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_CC_OutDir as text
%        str2double(get(hObject,'String')) returns contents of hEdt_CC_OutDir as a double
mhandles = guidata(handles.hMainWindow);
mhandles.data_dir = get(hObject,'string');
guidata(handles.hMainWindow,mhandles);

% --- Executes during object creation, after setting all properties.
function hEdt_CC_OutDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_CC_OutDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hBtn_CC_BrowseDir.
function hBtn_CC_BrowseDir_Callback(hObject, eventdata, handles)
% hObject    handle to hBtn_CC_BrowseDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mhandles = guidata(handles.hMainWindow);
%if specified directory doesn't exist create it temporarily
new_dir = '';
if ~isempty(mhandles.data_dir)&&~exist(mhandles.data_dir,'dir');
    orig_dir = pathparts(mhandles.data_dir);
    for n=1:numel(orig_dir)
        if ~exist(fullfile(orig_dir{1:n}),'dir')
            new_dir = [new_dir;fullfile(orig_dir{1:n})];
        end
    end
end
if ~isempty(new_dir)
    mkdir(new_dir{end});
end

d = uigetdir(mhandles.data_dir);
if all(d==0) %user canceled
    if ~isempty(new_dir) %delete temp directory if needed
        rmdir(new_dir{1},'s');
    end
    return;
end
mhandles.data_dir = d;
if ~isempty(new_dir)
    for n=1:numel(new_dir)
        if ~strncmpi(new_dir{n},d,numel(new_dir{n}))
            %user selected a directory that is not a sub-directory of the temp dir
            %delete the temp dir
            rmdir(new_dir{n},'s');
            break
        end
    end
end
set(handles.hEdt_CC_OutDir,'string',d);
guidata(handles.hMainWindow,mhandles);


function hEdt_CC_File_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_CC_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_CC_File as text
%        str2double(get(hObject,'String')) returns contents of hEdt_CC_File as a double
mhandles = guidata(handles.hMainWindow);
mhandles.CC_File = get(hObject,'string');
guidata(handles.hMainWindow,mhandles);

% --- Executes during object creation, after setting all properties.
function hEdt_CC_File_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_CC_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hChk_CC_AutoName.
function hChk_CC_AutoName_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_CC_AutoName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_CC_AutoName
mhandles = guidata(handles.hMainWindow);
mhandles.CC_AutoName = get(hObject,'value');

if mhandles.CC_AutoName
    set(handles.hEdt_CC_File,'enable','off');
    mhandles.CC_File = [datestr(now,'yyyy-mm-dd'),'_ChapeauCurve'];
    %check if file exists, add number if needed
    flist = dir(fullfile(mhandles.data_dir,[mhandles.CC_File,'*.txt']));
    if numel(flist)>0
        mhandles.CC_File = [mhandles.CC_File,sprintf('_%03.0f',numel(flist)+1)];
    else
        mhandles.CC_File = [mhandles.CC_File,'_001'];
    end
    set(handles.hEdt_CC_File,'string',mhandles.CC_File);
else
    set(handles.hEdt_CC_File,'enable','on');
end
guidata(handles.hMainWindow,mhandles);


function hEdt_CC_Comments_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_CC_Comments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_CC_Comments as text
%        str2double(get(hObject,'String')) returns contents of hEdt_CC_Comments as a double


% --- Executes during object creation, after setting all properties.
function hEdt_CC_Comments_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_CC_Comments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hChk_CC_WriteXYZ.
function hChk_CC_WriteXYZ_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_CC_WriteXYZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_CC_WriteXYZ
mhandles = guidata(handles.hMainWindow);
mhandles.CC_WriteXYZ = get(hObject,'Value');
guidata(handles.hMainWindow,mhandles);


% --- Executes when entered data in editable cell(s) in hTbl_CC_TrackParameters.
function hTbl_CC_TrackParameters_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to hTbl_CC_TrackParameters (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
setInFunctionFlag(handles.hMainWindow,true); %tell camera to stop processing frames so we can think
mhandles = guidata(handles.hMainWindow);
trkID = eventdata.Indices(1);
colname = get(hObject,'ColumnName');
switch colname{eventdata.Indices(2)}
    case 'Type'
        %eventdata.NewData
        mhandles.track_params(trkID).Type = eventdata.NewData;
    case 'Ref Trk'
        mhandles.track_params(trkID).ZRef = str2double(eventdata.NewData);
    case 'Save Abs. Z'
        %eventdata.NewData
        %mhandles.FE_SaveAbsZ
        mhandles.CC_SaveAbsZ(trkID) = eventdata.NewData;
end
guidata(handles.hMainWindow,mhandles);
MultiMT_updateTrackParameterTable(handles.hMainWindow);
setInFunctionFlag(handles.hMainWindow,false); %tell camera to process frames


% --- Executes when user attempts to close hFig_ChapeauCurve.
function hFig_ChapeauCurve_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to hFig_ChapeauCurve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
mhandles = guidata(handles.hMainWindow);
if mhandles.ExperimentRunning&&strcmpi(mhandles.ExperimentType,'ChapeauCurve')
    return;
end
MultiMTgui_closeChapeauCurve(handles.hMainWindow);



function hEdt_CC_turn_speed_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_CC_turn_speed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_CC_turn_speed as text
%        str2double(get(hObject,'String')) returns contents of hEdt_CC_turn_speed as a double
mhandles = guidata(handles.hMainWindow);
mhandles.CC_Turn_Speed = str2double(get(hObject, 'String'));
guidata(handles.hMainWindow, mhandles);

% --- Executes during object creation, after setting all properties.
function hEdt_CC_turn_speed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_CC_turn_speed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
