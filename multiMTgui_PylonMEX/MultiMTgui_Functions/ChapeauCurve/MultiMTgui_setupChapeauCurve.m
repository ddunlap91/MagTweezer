function MultiMTgui_setupChapeauCurve(hCC)

cchandles = guidata(hCC);
hMain = cchandles.hMainWindow;
stopCamera(hMain);
handles = guidata(hMain);

handles.hFig_ChapeauCurve = hCC;

%Other GUI Elements
%=============================
%setup gui
set(cchandles.hEdt_CC_OutDir,'String',handles.data_dir);

if handles.CC_AutoName||isempty(handles.CC_File)
    handles.CC_File = [datestr(now,'yyyy-mm-dd'),'_ChapeauCurve'];
end
%Data File
%==========================
fnum = 1;
FileName = [handles.CC_File,sprintf('_%03.0f',fnum)];
while exist(fullfile(handles.data_dir,[FileName,'.mtdat']),'file')
    fnum = fnum+1;
    FileName = [handles.CC_File,sprintf('_%03.0f',fnum)];
end
handles.CC_File = FileName;

set(cchandles.hEdt_CC_File,'string',handles.CC_File);

if handles.CC_AutoName
    set(cchandles.hEdt_CC_File,'enable','off');
    set(cchandles.hChk_CC_AutoName,'value',true);
else
    set(cchandles.hEdt_CC_File,'enable','on');
    set(cchandles.hChk_CC_AutoName,'value',false);
end

%% Init GUI Elements
%========================================================
set(cchandles.hEdt_CC_Comments,'string',handles.CC_Comments); %comments

set(cchandles.hEdt_CC_Start,'string',num2str(handles.CC_Start,'%0.2f'));
set(cchandles.hEdt_CC_Step,'string',num2str(handles.CC_Step,'%0.2f'));
set(cchandles.hEdt_CC_End,'string',num2str(handles.CC_End,'%0.2f'));
set(cchandles.hEdt_CC_FrameCount,'string',num2str(handles.CC_FrameCount,'%0.0f'));

set(cchandles.hChk_CC_FwdRev,'value',handles.CC_FwdRev);

%set plot checkboxes
set(cchandles.hChk_CC_plotChapeau,'value',handles.CC_plotChapeau);

%set flags
handles.CC_open = true;
handles.ExperimentWindowOpen = true;
set(handles.hMenu_MeasureChapeauCurve,'checked','on');

%display speed panel
if ~strcmpi('electromagnet', handles.MotorController)
    set(cchandles.hPnl_CC_Speed, 'visible', 'off');
end
%save data
guidata(hMain,handles);
MultiMT_updateTrackParameterTable(hMain);
startCamera(hMain);
