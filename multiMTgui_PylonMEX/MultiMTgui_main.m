function varargout = MultiMTgui_main(varargin)
% MULTIMTGUI_MAIN MATLAB code for MultiMTgui_main.fig
%      MULTIMTGUI_MAIN, by itself, creates a new MULTIMTGUI_MAIN or raises the existing
%      singleton*.
%
%      H = MULTIMTGUI_MAIN returns the handle to a new MULTIMTGUI_MAIN or the handle to
%      the existing singleton*.
%
%      MULTIMTGUI_MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MULTIMTGUI_MAIN.M with the given input arguments.
%
%      MULTIMTGUI_MAIN('Property','Value',...) creates a new MULTIMTGUI_MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MultiMTgui_main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MultiMTgui_main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MultiMTgui_main

% Last Modified by GUIDE v2.5 08-Aug-2016 11:55:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MultiMTgui_main_OpeningFcn, ...
                   'gui_OutputFcn',  @MultiMTgui_main_OutputFcn, ...
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


% --- Executes just before MultiMTgui_main is made visible.
function MultiMTgui_main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MultiMTgui_main (see VARARGIN)

% Choose default command line output for MultiMTgui_main
handles.output = hObject;

%add dependents to paWth
guiscript = mfilename('fullpath')
handles.guipath = fileparts(guiscript);
handles.OrigPath = addpath(handles.guipath,...
    fullfile(handles.guipath,'Functions'),...
    fullfile(handles.guipath,'MultiMT_Plotting'),...
    fullfile(handles.guipath,'Functions','mtdat_fileio'),...
    fullfile(handles.guipath,'Functions','MLogger'),...
    fullfile(handles.guipath,'MultiMTgui_Functions'),...
    fullfile(handles.guipath,'MultiMTgui_Functions','ForceExtension'),...
    fullfile(handles.guipath,'MultiMTgui_Functions','ChapeauCurve'),...
    fullfile(handles.guipath,'MultiMTgui_Functions','MicroscopeControls'),...
    fullfile(handles.guipath,'MultiMTgui_Functions','TrackControls'),...
    fullfile(handles.guipath,'MultiMTgui_Functions','HardwareSettings'),...
    fullfile(handles.guipath,'MultiMTgui_Functions','RecordXYZ'),...
    fullfile(handles.guipath,'MultiMTgui_Functions','CustomExperiment'),...
    fullfile(handles.guipath,'PylonCamera'),...
    fullfile(handles.guipath,'MultiMTgui_HardwareFunctions'),...
    fullfile(handles.guipath,'MultiMTgui_CameraFunctions'),...
    fullfile(handles.guipath,'C843class'),...
    fullfile(handles.guipath,'C862class'),...
    fullfile(handles.guipath,'E816class'),...
    fullfile(handles.guipath,'ParticleTrackingFunctions'),...
    fullfile(handles.guipath, 'Electromagnet'),...
    fullfile(handles.guipath, 'ElectromagnetClass'));

% Add Java path for jTable and YAML
YAML.UpdateJavapath();
uiextras.jTable.loadJavaCustomizations();

% Update handles structure
guidata(hObject, handles);

%Initialize Shared Variables
initstat = MultiMTgui_initializeVariables(hObject);
if ~initstat
    error('Did not initialize variables');
end

%Initialize the microscope
initstat = MultiMTgui_initializeHardware(hObject);
if ~initstat
    error('Did not initialize hardware');
end
%Init GUI, including default layout
initstat = MultiMTgui_initializeGUI(hObject);
if ~initstat
    error('Did not initialize GUI');
end


% UIWAIT makes MultiMTgui_main wait for user response (see UIRESUME)
% uiwait(handles.hFig_Main);


% --- Outputs from this function are returned to the command line.
function varargout = MultiMTgui_main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function hMenu_File_Callback(hObject, eventdata, handles)
% hObject    handle to hMenu_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function hMenu_Settings_Callback(hObject, eventdata, handles)
% hObject    handle to hMenu_Settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function hMenu_Experiment_Callback(hObject, eventdata, handles)
% hObject    handle to hMenu_Experiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function hMenu_Windows_Callback(hObject, eventdata, handles)
% hObject    handle to hMenu_Windows (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function hMenu_Controls_Callback(hObject, eventdata, handles)
% hObject    handle to hMenu_Controls (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(handles.hFig_ControlsWindow);

% --------------------------------------------------------------------
function hMenu_ImagePreview_Callback(hObject, eventdata, handles)
% hObject    handle to hMenu_ImagePreview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(hObject,'checked')
    case 'on'
        figure(handles.hFig_ImageWindow);
    case 'off'
        ImageWindow_Open(hObject);
end
        

% --------------------------------------------------------------------
function hMenu_LogTerminal_Callback(hObject, eventdata, handles)
% hObject    handle to hMenu_LogTerminal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.logger.ShowGUI();

% --------------------------------------------------------------------
function hMenu_LvMagPos_Callback(hObject, eventdata, handles)
% hObject    handle to hMenu_LvMagPos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function hMenu_ChapeauCurvePlot_Callback(hObject, eventdata, handles)
% hObject    handle to hMenu_ChapeauCurvePlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function hMenu_RunCalibrate_Callback(hObject, eventdata, handles)
% hObject    handle to hMenu_RunCalibrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function hMenu_MeasureForceExtension_Callback(hObject, eventdata, handles)
% hObject    handle to hMenu_MeasureForceExtension (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(hObject,'checked')
    case 'on'
        figure(handles.hFig_ForceExtension);
    case 'off'
        MultiMTgui_ForceExtension('MainHandle',hObject);
end

% --------------------------------------------------------------------
function hMenu_MeasureChapeauCurve_Callback(hObject, eventdata, handles)
% hObject    handle to hMenu_MeasureChapeauCurve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(hObject,'checked')
    case 'on'
        figure(handles.hFig_ChapeauCurve);
    case 'off'
        MultiMTgui_ChapeauCurve('MainHandle',hObject);
end

% --------------------------------------------------------------------
function hMenu_MagMotorDriver_Callback(hObject, eventdata, handles)
% hObject    handle to hMenu_MagMotorDriver (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function hMenu_MotorLimits_Callback(hObject, eventdata, handles)
% hObject    handle to hMenu_MotorLimits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function hMenu_PiezoDriver_Callback(hObject, eventdata, handles)
% hObject    handle to hMenu_PiezoDriver (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function hMenu_CameraDriver_Callback(hObject, eventdata, handles)
% hObject    handle to hMenu_CameraDriver (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function hMenu_PixelScale_Callback(hObject, eventdata, handles)
% hObject    handle to hMenu_PixelScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%prompt user for new PxScale
PxScale = NaN;
while isnan(PxScale)||PxScale<=0
    str = inputdlg('PxScale (µm/px)','PxScale',1,{num2str(handles.PxScale,'%0.8f')});
    if isempty(str)
        return;
    end
    PxScale = str2double(str);
end
handles.PxScale = PxScale;
save(handles.CFG_FILE,'PxScale','-append');
guidata(hObject,handles);
    


% --------------------------------------------------------------------
function hMenu_ChooseOutputDir_Callback(hObject, eventdata, handles)
% hObject    handle to hMenu_ChooseOutputDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function hMenu_SaveExperimentData_Callback(hObject, eventdata, handles)
% hObject    handle to hMenu_SaveExperimentData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function hMenu_LoadExperiment_Callback(hObject, eventdata, handles)
% hObject    handle to hMenu_LoadExperiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function hMenu_FitWindows_Callback(hObject, eventdata, handles)
% hObject    handle to hMenu_FitWindows (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.hFig_Main,'units','pixels')
set(handles.hFig_ControlsWindow,'units','pixels')
if handles.imagefig_open
    set(handles.hFig_ImageWindow,'units','pixels')
end

%move main window to top of the screen
movegui(handles.hFig_Main,'northwest');

main_op = get(handles.hFig_Main,'OuterPosition');

%move controls to left, under main window
movegui(handles.hFig_ControlsWindow,[0,-main_op(4)]);

ctrl_op = get(handles.hFig_ControlsWindow,'OuterPosition');

sz = get(0,'ScreenSize');
%move image window
if ~handles.imagefig_open
    ImageWindow_Open(hObject);
    handles = guidata(hObject);
    set(handles.hFig_ImageWindow,'units','pixels')
end
movegui(handles.hFig_ImageWindow,[ctrl_op(1)+ctrl_op(3),40]);
op = get(handles.hFig_ImageWindow,'OuterPosition');
set(handles.hFig_ImageWindow,'OuterPosition',...
    [op(1),op(2),...
    sz(3)-op(1),...
    main_op(2)-op(2)]);

if ~handles.tracking_open
    set(handles.hMenu_TrackingControls,'Checked','on');
    MultiMTgui_TrackingControls('MainHandle',hObject);
    handles = guidata(hObject); %get update copy of handles now that we've opened TrackingControls
end
movegui(handles.hFig_TrackingControls,'southwest');
ctrl_op = get(handles.hFig_ControlsWindow,'OuterPosition');
trk_op = get(handles.hFig_TrackingControls,'OuterPosition');
set(handles.hFig_TrackingControls,'OuterPosition',...
    [trk_op(1),trk_op(2)+40,...
     ctrl_op(3),...
     sz(4)-ctrl_op(2)-trk_op(2)-130]);
% --- Executes when user attempts to close hFig_Main.
function hFig_Main_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to hFig_Main (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

%Update handles structure
guidata(hObject,handles);
... (other functions which don't change or update hObject)
initstat = MultiMTgui_stopHardware(hObject);
if ~initstat
  error('Did not stop hardware');
end

%Update handles structure
guidata(hObject,handles);
... (other functions which don't change or update hObject)
initstat = MultiMTgui_closeGUI(hObject);
if ~initstat
  warning('Could not close GUI');
end

path(handles.OrigPath); %reset the path before exiting
delete(hObject);


% --------------------------------------------------------------------
function hMenu_ExportStack_Callback(hObject, eventdata, handles)
% hObject    handle to hMenu_ExportStack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
MultiMTgui_ExportStack('MainHandle',hObject);


% --------------------------------------------------------------------
function hMenu_TrackingControls_Callback(hObject, eventdata, handles)
% hObject    handle to hMenu_TrackingControls (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.tracking_open
    set(handles.hMenu_TrackingControls,'Checked','on');
    figure(handles.hFig_TrackingControls);
else
    set(handles.hMenu_TrackingControls,'Checked','on');
    MultiMTgui_TrackingControls('MainHandle',hObject);
end


% --------------------------------------------------------------------
function hMenu_PauseResume_Callback(hObject, eventdata, handles)
% hObject    handle to hMenu_PauseResume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.PauseSystem
    MultiMTgui_resume(hObject);
else
    MultiMTgui_pause(hObject);
end


% --------------------------------------------------------------------
function hMenu_HardwareSettings_Callback(hObject, eventdata, handles)
% hObject    handle to hMenu_HardwareSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function hMenu_RestartCamera_Callback(hObject, eventdata, handles)
% hObject    handle to hMenu_RestartCamera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stopCamera(hObject);
pause(1);
startCamera(hObject);


% --------------------------------------------------------------------
function hMenu_RecordXYZ_Callback(hObject, eventdata, handles)
% hObject    handle to hMenu_RecordXYZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(hObject,'checked')
    case 'on'
        figure(handles.hFig_RecordXYZ);
    case 'off'
        MultiMTgui_RecordXYZ('MainHandle',hObject);
end


% --------------------------------------------------------------------
function hMenu_CustomExperiment_Callback(hObject, eventdata, handles)
% hObject    handle to hMenu_CustomExperiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(hObject,'checked')
    case 'on'
        figure(handles.hFig_CustomExperiment);
    case 'off'
        MultiMT_CustomExperiment('MainHandle',hObject);
end
