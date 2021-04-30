function varargout = MultiMTgui_RecordXYZ(varargin)
% MULTIMTGUI_RECORDXYZ MATLAB code for MultiMTgui_RecordXYZ.fig
%      MULTIMTGUI_RECORDXYZ, by itself, creates a new MULTIMTGUI_RECORDXYZ or raises the existing
%      singleton*.
%
%      H = MULTIMTGUI_RECORDXYZ returns the handle to a new MULTIMTGUI_RECORDXYZ or the handle to
%      the existing singleton*.
%
%      MULTIMTGUI_RECORDXYZ('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MULTIMTGUI_RECORDXYZ.M with the given input arguments.
%
%      MULTIMTGUI_RECORDXYZ('Property','Value',...) creates a new MULTIMTGUI_RECORDXYZ or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MultiMTgui_RecordXYZ_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MultiMTgui_RecordXYZ_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MultiMTgui_RecordXYZ

% Last Modified by GUIDE v2.5 09-Sep-2016 19:05:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MultiMTgui_RecordXYZ_OpeningFcn, ...
                   'gui_OutputFcn',  @MultiMTgui_RecordXYZ_OutputFcn, ...
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


% --- Executes just before MultiMTgui_RecordXYZ is made visible.
function MultiMTgui_RecordXYZ_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MultiMTgui_RecordXYZ (see VARARGIN)

% Choose default command line output for MultiMTgui_RecordXYZ
handles.output = hObject;

if numel(varargin) < 1
    warning('MultiMTgui_RecordXYZ must be called by the main window.  It does not run on it own.');
end

%Initialize Figure Parent
ind = find(strcmpi(varargin,'MainHandle'));
if isempty(ind)
    warning('could not find handle to main window use syntax ...RecordXYZ("MainHandle",hMain)');
else
    handles.hMainWindow = varargin{ind+1};
    if ~ishandle(handles.hMainWindow)
        error('Specified handle is not valid');
    end
end

% Update handles structure
guidata(hObject, handles);
setInFunctionFlag(handles.hMainWindow,true);
MultiMTgui_setupRecordXYZ(hObject);
setInFunctionFlag(handles.hMainWindow,false);

% UIWAIT makes MultiMTgui_ForceExtension wait for user response (see UIRESUME)
% uiwait(handles.hFig_ForceExtension);


% --- Outputs from this function are returned to the command line.
function varargout = MultiMTgui_RecordXYZ_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in hChk_RecXYZ_ShowPlot.
function hChk_RecXYZ_ShowPlot_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_RecXYZ_ShowPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_RecXYZ_ShowPlot
mhandles = guidata(handles.hMainWindow);
mhandles.RecXYZ_PlotShow = get(hObject,'Value');
guidata(handles.hMainWindow,mhandles);

% --- Executes on button press in checkbox11.
function checkbox11_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox11


% --- Executes on button press in hChk_RecXYZ_PlotX.
function hChk_RecXYZ_PlotX_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_RecXYZ_PlotX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_RecXYZ_PlotX


% --- Executes on button press in hChk_RecXYZ_PlotY.
function hChk_RecXYZ_PlotY_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_RecXYZ_PlotY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_RecXYZ_PlotY


% --- Executes on button press in hChk_RecXYZ_PlotZ.
function hChk_RecXYZ_PlotZ_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_RecXYZ_PlotZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_RecXYZ_PlotZ


% --- Executes on button press in hBtn_RecXYZ_StartStopRecord.
function hBtn_RecXYZ_StartStopRecord_Callback(hObject, eventdata, handles)
% hObject    handle to hBtn_RecXYZ_StartStopRecord (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mhandles = guidata(handles.hMainWindow);
if mhandles.RecXYZ_Recording
    MultiMTgui_stopRecording(handles.hMainWindow);
else
    MultiMTgui_startRecording(handles.hMainWindow);
end


function hEdt_RecXYZ_OutDir_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_RecXYZ_OutDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_RecXYZ_OutDir as text
%        str2double(get(hObject,'String')) returns contents of hEdt_RecXYZ_OutDir as a double
mhandles = guidata(handles.hMainWindow);
mhandles.data_dir = get(hObject,'string');
guidata(handles.hMainWindow,mhandles);

% --- Executes during object creation, after setting all properties.
function hEdt_RecXYZ_OutDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_RecXYZ_OutDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hBtn_RecXYZ_OutDir.
function hBtn_RecXYZ_OutDir_Callback(hObject, eventdata, handles)
% hObject    handle to hBtn_RecXYZ_OutDir (see GCBO)
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
set(handles.hEdt_RecXYZ_OutDir,'string',d);
guidata(handles.hMainWindow,mhandles);


function hEdt_RecXYZ_File_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_RecXYZ_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_RecXYZ_File as text
%        str2double(get(hObject,'String')) returns contents of hEdt_RecXYZ_File as a double
mhandles = guidata(handles.hMainWindow);
mhandles.RecXYZ_File = get(hObject,'string');
guidata(handles.hMainWindow,mhandles);

% --- Executes during object creation, after setting all properties.
function hEdt_RecXYZ_File_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_RecXYZ_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hChk_RecXYZ_AutoName.
function hChk_RecXYZ_AutoName_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_RecXYZ_AutoName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_RecXYZ_AutoName
mhandles = guidata(handles.hMainWindow);
mhandles.RecXYZ_AutoName = get(hObject,'value');

if mhandles.RecXYZ_AutoName
    set(handles.hEdt_RecXYZ_File,'enable','off');
    mhandles.RecXYZ_File = [datestr(now,'yyyy-mm-dd'),'_LiveXYZData'];
    %check if file exists, add number if needed
    flist = dir(fullfile(mhandles.data_dir,[mhandles.RecXYZ_File,'*.bin']));
    if numel(flist)>0
        mhandles.RecXYZ_File = [mhandles.RecXYZ_File,sprintf('_%03.0f',numel(flist)+1)];
    else
        mhandles.RecXYZ_File = [mhandles.RecXYZ_File,'_001'];
    end
    set(handles.hEdt_RecXYZ_File,'string',mhandles.RecXYZ_File);
else
    set(handles.hEdt_RecXYZ_File,'enable','on');
end
guidata(handles.hMainWindow,mhandles);


function hEdt_RecXYZ_Comments_Callback(hObject, eventdata, handles)
% hObject    handle to hEdt_RecXYZ_Comments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdt_RecXYZ_Comments as text
%        str2double(get(hObject,'String')) returns contents of hEdt_RecXYZ_Comments as a double


% --- Executes during object creation, after setting all properties.
function hEdt_RecXYZ_Comments_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdt_RecXYZ_Comments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hRBtn_RecXYZ_AppendData.
function hRBtn_RecXYZ_AppendData_Callback(hObject, eventdata, handles)
% hObject    handle to hRBtn_RecXYZ_AppendData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hRBtn_RecXYZ_AppendData


% --- Executes on button press in hRBtn_RecXYZ_SaveNewData.
function hRBtn_RecXYZ_SaveNewData_Callback(hObject, eventdata, handles)
% hObject    handle to hRBtn_RecXYZ_SaveNewData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hRBtn_RecXYZ_SaveNewData


% --- Executes when user attempts to close hFig_RecordXYZ.
function hFig_RecordXYZ_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to hFig_RecordXYZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
mhandles = guidata(handles.hMainWindow);
mhandles.RecXYZ_open = false;
set(mhandles.hMenu_RecordXYZ,'checked','off');
guidata(handles.hMainWindow,mhandles);
delete(hObject);


% --- Executes on button press in hBtn_RecXYZ_ShowPlot.
function hBtn_RecXYZ_ShowPlot_Callback(hObject, eventdata, handles)
% hObject    handle to hBtn_RecXYZ_ShowPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mhandles = guidata(handles.hMainWindow);
if isempty(mhandles.hFig_RecXYZPlot)||~ishandle(mhandles.hFig_RecXYZPlot)
        mhandles.hFig_RecXYZPlot = figure();
else
    figure(mhandles.hFig_RecXYZPlot);
end
guidata(handles.hMainWindow,mhandles);


% --- Executes on button press in hBtn_ShowZPlot.
function hBtn_ShowZPlot_Callback(hObject, eventdata, handles)
% hObject    handle to hBtn_ShowZPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mhandles = guidata(handles.hMainWindow);
if isempty(mhandles.hFig_LiveZPlot) || ~ishghandle(mhandles.hFig_LiveZPlot)
    mhandles.hFig_LiveZPlot = figure('Name','Live Z','NumberTitle','off');
    hAx = axes(mhandles.hFig_LiveZPlot);
    hold(hAx,'on');
    xlabel(hAx,'Time [min]');
    ylabel(hAx,'\DeltaZ [µm]');
    title(hAx,'\DeltaZ vs. Time');
    guidata(handles.hMainWindow,mhandles);
else
    figure(mhandles.hFig_LiveZPlot);
end

% --- Executes on button press in hBtn_ShowXYPlot.
function hBtn_ShowXYPlot_Callback(hObject, eventdata, handles)
% hObject    handle to hBtn_ShowXYPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mhandles = guidata(handles.hMainWindow);
if isempty(mhandles.hFig_LiveXYPlot) || ~ishghandle(mhandles.hFig_LiveXYPlot)
    mhandles.hFig_LiveXYPlot = figure('Name','Live XY','NumberTitle','off');
    hAx = axes(mhandles.hFig_LiveXYPlot);
    hold(hAx,'on');
    axis(hAx,'equal');
    xlim(hAx,[0,mhandles.MMcam.WidthMax]);
    ylim(hAx,[0,mhandles.MMcam.HeightMax]);
    hAx.YDir = 'reverse';
    xlabel(hAx,'X [px]');
    ylabel(hAx,'Y [px]');
    title(hAx,'Particle Position');
    guidata(handles.hMainWindow,mhandles);
else
    figure(mhandles.hFig_LiveXYPlot);
end

% --- Executes on button press in hChk_UpdateZPlot.
function hChk_UpdateZPlot_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_UpdateZPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_UpdateZPlot
mhandles = guidata(handles.hMainWindow);
mhandles.UpdateLiveZPlot = get(hObject,'Value');
guidata(handles.hMainWindow,mhandles);

% --- Executes on button press in hChk_UpdateXYPlot.
function hChk_UpdateXYPlot_Callback(hObject, eventdata, handles)
% hObject    handle to hChk_UpdateXYPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hChk_UpdateXYPlot
mhandles = guidata(handles.hMainWindow);
mhandles.UpdateLiveXYPlot = get(hObject,'Value');
guidata(handles.hMainWindow,mhandles);
