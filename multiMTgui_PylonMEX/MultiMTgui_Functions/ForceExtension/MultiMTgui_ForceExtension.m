function varargout = MultiMTgui_ForceExtension(varargin)
% MULTIMTGUI_FORCEEXTENSION MATLAB code for MultiMTgui_ForceExtension.fig
%      MULTIMTGUI_FORCEEXTENSION, by itself, creates a new MULTIMTGUI_FORCEEXTENSION or raises the existing
%      singleton*.
%
%      H = MULTIMTGUI_FORCEEXTENSION returns the handle to a new MULTIMTGUI_FORCEEXTENSION or the handle to
%      the existing singleton*.
%
%      MULTIMTGUI_FORCEEXTENSION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MULTIMTGUI_FORCEEXTENSION.M with the given input arguments.
%
%      MULTIMTGUI_FORCEEXTENSION('Property','Value',...) creates a new MULTIMTGUI_FORCEEXTENSION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MultiMTgui_ForceExtension_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MultiMTgui_ForceExtension_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MultiMTgui_ForceExtension

% Last Modified by GUIDE v2.5 11-Feb-2021 18:47:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MultiMTgui_ForceExtension_OpeningFcn, ...
                   'gui_OutputFcn',  @MultiMTgui_ForceExtension_OutputFcn, ...
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


% --- Executes just before MultiMTgui_ForceExtension is made visible.
function MultiMTgui_ForceExtension_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MultiMTgui_ForceExtension (see VARARGIN)

% Choose default command line output for MultiMTgui_ForceExtension
handles.output = hObject;

if numel(varargin) < 1
    warning('MultiMTgui_ForceExtension must be called by the main window.  It does not run on it own.');
end

%Initialize Figure Parent
ind = find(strcmpi(varargin,'MainHandle'));
if isempty(ind)
    warning('could not find handle to main window use syntax ...ForceExtension("MainHandle",hMain)');
else
    handles.hMainWindow = varargin{ind+1};
    if ~ishandle(handles.hMainWindow)
        error('Specified handle is not valid');
    end
end

% Update handles structure
guidata(hObject, handles);
setInFunctionFlag(handles.hMainWindow,true);
MultiMTgui_setupForceExtension(hObject);
setInFunctionFlag(handles.hMainWindow,false);

% UIWAIT makes MultiMTgui_ForceExtension wait for user response (see UIRESUME)
% uiwait(handles.hFig_ForceExtension);


% --- Outputs from this function are returned to the command line.
function varargout = MultiMTgui_ForceExtension_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in hBtn_FE_RunStop.
function hBtn_FE_RunStop_Callback(hObject, eventdata, handles)
% hObject    handle to hBtn_FE_RunStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mhandles = guidata(handles.hMainWindow);
if mhandles.ExperimentRunning&&strcmpi(mhandles.ExperimentType,'ForceExtension')
    MultiMTgui_stopForceExtension(handles.hMainWindow);
else
    MultiMTgui_startForceExtension(handles.hMainWindow);
end


function hEdt_FE_Start_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_FE_Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_FE_Start as text
%        str2double(get(hObject,'String')) returns contents of hEdt_FE_Start as a double
mhandles = guidata(handles.hMainWindow);
v = str2double(get(hObject,'String'));
if isnan(v)||v<mhandles.mag_zlim(1)||v>mhandles.mag_zlim(2)
    v = mhandles.FE_Start;
else
    mhandles.FE_Start = v;
    if mhandles.FE_Start<mhandles.FE_End
        mhandles.FE_Step = abs(mhandles.FE_Step);
    else
        mhandles.FE_Step = -abs(mhandles.FE_Step);
    end
end
set(handles.hEdt_FE_Step,'string',num2str(mhandles.FE_Step,'%0.2f'));
set(hObject,'string',num2str(v,'%0.2f'));
guidata(handles.hMainWindow,mhandles);

% --- Executes during object creation, after setting all properties.
function hEdt_FE_Start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_FE_Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hEdt_FE_Step_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_FE_Step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_FE_Step as text
%        str2double(get(hObject,'String')) r100eturns contents of hEdt_FE_Step as a double
mhandles = guidata(handles.hMainWindow);
v = str2double(get(hObject,'String'));
if isnan(v)
    v = mhandles.FE_Step;
else
    if mhandles.FE_Start<mhandles.FE_End
        v = abs(v);
    else
        v = -abs(v);
    end
    mhandles.FE_Step = v;
end
set(hObject,'string',num2str(v,'%0.2f'));
guidata(handles.hMainWindow,mhandles);

% --- Executes during object creation, after setting all properties.
function hEdt_FE_Step_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_FE_Step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hEdt_FE_End_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_FE_End (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_FE_End as text
%        str2double(get(hObject,'String')) returns contents of hEdt_FE_End as a double
mhandles = guidata(handles.hMainWindow);
v = str2double(get(hObject,'String'));
if isnan(v)||v<mhandles.mag_zlim(1)||v>mhandles.mag_zlim(2)
    v = mhandles.FE_End;
else
    mhandles.FE_End = v;
    if mhandles.FE_Start<mhandles.FE_End
        mhandles.FE_Step = abs(mhandles.FE_Step);
    else
        mhandles.FE_Step = -abs(mhandles.FE_Step);
    end
end
set(handles.hEdt_FE_Step,'string',num2str(mhandles.FE_Step,'%0.2f'));
set(hObject,'string',num2str(v,'%0.2f'));
guidata(handles.hMainWindow,mhandles);

% --- Executes during object creation, after setting all properties.
function hEdt_FE_End_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_FE_End (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hEdt_FE_FrameCount_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_FE_FrameCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_FE_FrameCount as text
%        str2double(get(hObject,'String')) returns contents of hEdt_FE_FrameCount as a double
mhandles = guidata(handles.hMainWindow);
v = str2double(get(hObject,'String'));
if isnan(v)
    v = mhandles.FE_FrameCount;
else
    v=max(50,v);
    mhandles.FE_FrameCount = v;
end
set(hObject,'string',num2str(v,'%0.0f'));
guidata(handles.hMainWindow,mhandles);

% --- Executes during object creation, after setting all properties.
function hEdt_FE_FrameCount_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_FE_FrameCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hChk_FE_FwdRev.
function hChk_FE_FwdRev_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_FE_FwdRev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_FE_FwdRev
mhandles = guidata(handles.hMainWindow);
mhandles.FE_FwdRev = get(hObject,'Value');
guidata(handles.hMainWindow,mhandles);


function hEdt_FE_OutDir_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_FE_OutDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_FE_OutDir as text
%        str2double(get(hObject,'String')) returns contents of hEdt_FE_OutDir as a double
mhandles = guidata(handles.hMainWindow);
mhandles.data_dir = get(hObject,'string');
guidata(handles.hMainWindow,mhandles);

% --- Executes during object creation, after setting all properties.
function hEdt_FE_OutDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_FE_OutDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hBtn_FE_BrowseDir.
function hBtn_FE_BrowseDir_Callback(hObject, eventdata, handles)
% hObject    handle to hBtn_FE_BrowseDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mhandles = guidata(handles.hMainWindow);
%if specified directory doesn't exist create it temporarily
new_dir = {};
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
set(handles.hEdt_FE_OutDir,'string',d);
guidata(handles.hMainWindow,mhandles);



function hEdt_FE_File_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_FE_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_FE_File as text
%        str2double(get(hObject,'String')) returns contents of hEdt_FE_File as a double
mhandles = guidata(handles.hMainWindow);
mhandles.FE_File = get(hObject,'string');
guidata(handles.hMainWindow,mhandles);

% --- Executes during object creation, after setting all properties.
function hEdt_FE_File_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_FE_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hChk_FE_AutoName.
function hChk_FE_AutoName_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_FE_AutoName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_FE_AutoName
mhandles = guidata(handles.hMainWindow);
mhandles.FE_AutoName = get(hObject,'value');

if mhandles.FE_AutoName
    set(handles.hEdt_FE_File,'enable','off');
    mhandles.FE_File = [datestr(now,'yyyy-mm-dd'),'_ForceExtension'];
    %check if file exists, add number if needed
    flist = dir(fullfile(mhandles.data_dir,[mhandles.FE_File,'*.txt']));
    if numel(flist)>0
        mhandles.FE_File = [mhandles.FE_File,sprintf('_%03.0f',numel(flist)+1)];
    else
        mhandles.FE_File = [mhandles.FE_File,'_001'];
    end
    set(handles.hEdt_FE_File,'string',mhandles.FE_File);
else
    set(handles.hEdt_FE_File,'enable','on');
end
guidata(handles.hMainWindow,mhandles);

function hEdt_FE_Comments_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_FE_Comments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_FE_Comments as text
%        str2double(get(hObject,'String')) returns contents of hEdt_FE_Comments as a double


% --- Executes during object creation, after setting all properties.
function hEdt_FE_Comments_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_FE_Comments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hChk_FE_plotLvMag.
function hChk_FE_plotLvMag_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_FE_plotLvMag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_FE_plotLvMag
mhandles = guidata(handles.hMainWindow);
mhandles.FE_plotLvMag = get(hObject,'Value');
guidata(handles.hMainWindow,mhandles);

% --- Executes on button press in hChk_FE_plotFvMag.
function hChk_FE_plotFvMag_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_FE_plotFvMag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_FE_plotFvMag
mhandles = guidata(handles.hMainWindow);
mhandles.FE_plotFvMag = get(hObject,'Value');
guidata(handles.hMainWindow,mhandles);

% --- Executes on button press in hChk_FE_plotFvL.
function hChk_FE_plotFvL_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_FE_plotFvL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_FE_plotFvL
mhandles = guidata(handles.hMainWindow);
mhandles.FE_plotFvL = get(hObject,'Value');
guidata(handles.hMainWindow,mhandles);

% --- Executes on button press in hChk_FE_PlotZvM_EB.
function hChk_FE_PlotZvM_EB_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_FE_PlotZvM_EB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_FE_PlotZvM_EB


% --- Executes on button press in hChk_FE_FvM_EB.
function hChk_FE_FvM_EB_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_FE_FvM_EB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_FE_FvM_EB


% --- Executes on button press in hChk_FE_PlotFvZ_EB.
function hChk_FE_PlotFvZ_EB_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_FE_PlotFvZ_EB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_FE_PlotFvZ_EB


% --- Executes on button press in hChk_FE_WriteXYZ.
function hChk_FE_WriteXYZ_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_FE_WriteXYZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_FE_WriteXYZ
mhandles = guidata(handles.hMainWindow);
mhandles.FE_WriteXYZ = get(hObject,'Value');
guidata(handles.hMainWindow,mhandles);


% --- Executes when user attempts to close hFig_ForceExtension.
function hFig_ForceExtension_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to hFig_ForceExtension (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figurehandles = guidata(hMain);
mhandles = guidata(handles.hMainWindow);
if mhandles.ExperimentRunning&&strcmpi(mhandles.ExperimentType,'ForceExtension')
    return;
end
MultiMTgui_closeForceExtension(handles.hMainWindow);


% --- Executes on button press in hChk_FE_DriftCompensation.
function hChk_FE_DriftCompensation_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_FE_DriftCompensation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_FE_DriftCompensation
mhandles = guidata(handles.hMainWindow);
mhandles.FE_DriftCompensation = get(hObject,'Value');
guidata(handles.hMainWindow,mhandles);

% --- Executes on button press in hChk_FE_TiltCompensation.
function hChk_FE_TiltCompensation_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_FE_TiltCompensation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_FE_TiltCompensation
mhandles = guidata(handles.hMainWindow);
mhandles.FE_TiltCompensation = get(hObject,'Value');
guidata(handles.hMainWindow,mhandles);

% --- Executes when entered data in editable cell(s) in hTbl_FE_TrackParameters.
function hTbl_FE_TrackParameters_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to hTbl_FE_TrackParameters (see GCBO)
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
        mhandles.FE_SaveAbsZ(trkID) = eventdata.NewData;
end
guidata(handles.hMainWindow,mhandles);
MultiMT_updateTrackParameterTable(handles.hMainWindow);
setInFunctionFlag(handles.hMainWindow,false); %tell camera to process frames


% --- Executes on selection change in hPop_FE_CalcMethod.
function hPop_FE_CalcMethod_Callback(hObject, eventdata, handles)
% hObject    handle to hPop_FE_CalcMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hPop_FE_CalcMethod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hPop_FE_CalcMethod


% --- Executes during object creation, after setting all properties.
function hPop_FE_CalcMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hPop_FE_CalcMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object deletion, before destroying properties.
function hChk_FE_DriftCompensation_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to hChk_FE_DriftCompensation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function hEdt_FE_Start_EM_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_FE_Start_EM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.FE_VStart = str2double(get(hObject,'String'));
guidata(handles.hFig_ForceExtension, handles);
% Hints: get(hObject,'String') returns contents of hEdt_FE_Start_EM as text
%        str2double(get(hObject,'String')) returns contents of hEdt_FE_Start_EM as a double


% --- Executes during object creation, after setting all properties.
function hEdt_FE_Start_EM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_FE_Start_EM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hEdt_FE_Step_EM_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_FE_Step_EM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.FE_VStep = str2double(get(hObject,'String'));
handles.FE_VStep = round(handles.FE_VStep);
if handles.FE_VStep == 0
    handles.FE_VStep = 1;
end
set(handles.hEdt_FE_Step_EM, 'String', handles.FE_VStep);
guidata(handles.hFig_ForceExtension, handles);
% Hints: get(hObject,'String') returns contents of hEdt_FE_Step_EM as text
%        str2double(get(hObject,'String')) returns contents of hEdt_FE_Step_EM as a double


% --- Executes during object creation, after setting all properties.
function hEdt_FE_Step_EM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_FE_Step_EM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hEdt_FE_End_EM_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_FE_End_EM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.FE_VEnd = str2double(get(hObject,'String'));
guidata(handles.hFig_ForceExtension, handles);
% Hints: get(hObject,'String') returns contents of hEdt_FE_End_EM as text
%        str2double(get(hObject,'String')) returns contents of hEdt_FE_End_EM as a double


% --- Executes during object creation, after setting all properties.
function hEdt_FE_End_EM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_FE_End_EM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hEdt_FE_Speed_EM_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_FE_Speed_EM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.FE_EM_Speed = str2double(get(hObject,'String'));
guidata(handles.hFig_ForceExtension, handles);
% Hints: get(hObject,'String') returns contents of hEdt_FE_Speed_EM as text
%        str2double(get(hObject,'String')) returns contents of hEdt_FE_Speed_EM as a double


% --- Executes during object creation, after setting all properties.
function hEdt_FE_Speed_EM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_FE_Speed_EM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox14.
function checkbox14_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox14


% --- Executes on button press in hChk_FE_PlotLvCurrent.
function hChk_FE_PlotLvCurrent_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_FE_PlotLvCurrent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_FE_PlotLvCurrent
mhandles = guidata(handles.hMainWindow);
mhandles.FE_plotFvL = get(hObject,'Value');
guidata(handles.hMainWindow,mhandles);


% --- Executes on button press in hChk_FE_PlotFvCurrent.
function hChk_FE_PlotFvCurrent_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_FE_PlotFvCurrent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_FE_PlotFvCurrent
mhandles = guidata(handles.hMainWindow);
mhandles.FE_plotFvL = get(hObject,'Value');
guidata(handles.hMainWindow,mhandles);


% --- Executes on button press in hChk_FE_PlotFvL_EM.
function hChk_FE_PlotFvL_EM_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_FE_PlotFvL_EM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_FE_PlotFvL_EM
mhandles = guidata(handles.hMainWindow);
mhandles.FE_plotFvL = get(hObject,'Value');
guidata(handles.hMainWindow,mhandles);
