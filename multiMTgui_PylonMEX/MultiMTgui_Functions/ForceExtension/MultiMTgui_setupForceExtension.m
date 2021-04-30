function MultiMTgui_setupForceExtension(hFE)

fehandles = guidata(hFE);
hMain = fehandles.hMainWindow;
handles = guidata(hMain);

handles.hFig_ForceExtension = hFE;


%Othe GUI Elements
%=================================
set(fehandles.hEdt_FE_OutDir,'String',handles.data_dir);

if handles.FE_AutoName||isempty(handles.FE_File)
    handles.FE_File = [datestr(now,'yyyy-mm-dd'),'_ForceExtension'];
end

%Force Data File
%==========================
fnum = 1;
FileName = [handles.FE_File,sprintf('_%03.0f',fnum)];
while exist(fullfile(handles.data_dir,[FileName,'.mtdat']),'file')
    fnum = fnum+1;
    FileName = [handles.FE_File,sprintf('_%03.0f',fnum)];
end
handles.FE_File = FileName;

set(fehandles.hEdt_FE_File,'string',handles.FE_File);

if handles.FE_AutoName
    set(fehandles.hEdt_FE_File,'enable','off');
    set(fehandles.hChk_FE_AutoName,'value',true);
else
    set(fehandles.hEdt_FE_File,'enable','on');
    set(fehandles.hChk_FE_AutoName,'value',false);
end

%% Hard-Code EM Defaults

fehandles.FE_VStart = 0;
fehandles.FE_VStep = 1;
fehandles.FE_VEnd = 255;
fehandles.FE_EM_Speed = 5;


%% Initialize GUI Elements
%====================================================
set(fehandles.hEdt_FE_Comments,'string',handles.FE_Comments); %comments

if strcmpi(handles.MotorController, 'ELECTROMAGNET')
    set(fehandles.text_start, 'visible', 'off');
    set(fehandles.text_step, 'visible', 'off');
    set(fehandles.text_end, 'visible', 'off');
    set(fehandles.text_mag_height, 'string', 'Magnet Height (mm)', 'visible', 'off');
    set(fehandles.hEdt_FE_Start,'string',num2str(handles.FE_Start,'%0.2f'), 'visible', 'off');
    set(fehandles.hEdt_FE_Step,'string',num2str(handles.FE_Step,'%0.2f'), 'visible', 'off');
    set(fehandles.hEdt_FE_End,'string',num2str(handles.FE_End,'%0.2f'), 'visible', 'off');
    set(fehandles.hChk_FE_plotLvMag, 'visible', 'off');
    set(fehandles.hChk_FE_plotFvMag, 'visible', 'off');
    set(fehandles.hChk_FE_plotFvL, 'visible', 'off');
    
    set(fehandles.hEdt_FE_Start_EM, 'value', 0);
    set(fehandles.hEdt_FE_Step_EM, 'value', 1);
    set(fehandles.hEdt_FE_End_EM, 'value', 255);
else
    set(fehandles.text_start_em, 'visible', 'off');
    set(fehandles.text_step_em, 'visible', 'off');
    set(fehandles.text_end_em, 'visible', 'off');
    set(fehandles.text_current_pwm, 'Visible', 'off', 'String', 'Current (PWM)');
    set(fehandles.hEdt_FE_Start_EM, 'visible', 'off');
    set(fehandles.hEdt_FE_Step_EM, 'visible', 'off');
    set(fehandles.hEdt_FE_End_EM, 'visible', 'off');
    
    set(fehandles.hChk_FE_PlotLvCurrent, 'visible', 'off');
    set(fehandles.hChk_FE_PlotFvCurrent, 'visible', 'off');
    set(fehandles.hChk_FE_PlotFvL_EM, 'visible', 'off');
end


set(fehandles.hEdt_FE_FrameCount,'string',num2str(handles.FE_FrameCount,'%0.0f'));

set(fehandles.hChk_FE_FwdRev,'value',handles.FE_FwdRev);

%set plot checkboxes
if ~strcmpi(handles.MotorController, 'electromagnet')
    set(fehandles.hChk_FE_plotLvMag,'value',handles.FE_plotLvMag);
    set(fehandles.hChk_FE_plotFvMag,'value',handles.FE_plotFvMag);
    set(fehandles.hChk_FE_plotFvL,'value',handles.FE_plotFvL);
else
    set(fehandles.hChk_FE_PlotLvCurrent, 'value', 1);
    set(fehandles.hChk_FE_PlotFvCurrent, 'value', 1);
    set(fehandles.hChk_FE_PlotFvL_EM, 'value', 1);
end

%set flags
handles.FE_open = true;
handles.ExperimentWindowOpen = true;
set(handles.hMenu_MeasureForceExtension,'checked','on');

%display speed
if ~strcmpi(handles.MotorController, 'electromagnet')
    set(fehandles.hEdt_FE_Speed_EM, 'visible', 'off');
    set(fehandles.text24, 'visible', 'off');
end
%save data
guidata(hMain,handles);
guidata(hFE, fehandles);
%MultiMT_updateTrackParameterTable(hMain);
