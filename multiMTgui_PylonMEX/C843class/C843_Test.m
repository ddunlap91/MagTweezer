%% C-843 Test Script

%% Load the DLL
% specify DLL name and alias
shrlib = 'C843_GCS_DLL_x64.dll';
hfile = 'C843_GCS_DLL.h';
lib = 'C843_GCS_DLL';
% only load dll if it wasn't loaded before
if(~libisloaded(lib))
    loadlibrary (shrlib,hfile,'alias',lib);
end
disp('Library Functions:');
%libfunctionsview(libname) %list available functions

%% Try to initiate communication with the card
sPCIList = blanks(255); %pre-initialize the variable
[ret,sPCIList] = calllib(lib,'C843_ListPCI',sPCIList,numel(sPCIList)-1);
if ret~=1
    error('problem with ListPCI')
end
disp(sPCIList)

if str2double(sPCIList)<1
    error('No PIC cards found');
end

%try to connect
ID_c843 = calllib(lib,'C843_Connect',1);
if ID_c843 < 0
    error('Could not connect to C843')
end

%test
stages = blanks(1024);
[ret,~,stages] = calllib(lib,'C843_qCST',ID_c843,'',stages,numel(stages)-1);
disp('Stage configurations:')
disp(stages);

%test
str = blanks(1024);
[ret,str] = calllib(lib,'C843_qTVI',ID_c843,str,numel(str)-1);
disp('Stag chars:')
disp(str);

% Try to setup the rotatation motor
ret = calllib(lib, 'C843_CST',ID_c843,'2','C-150.PD') %try to set motor 2 to rot stage
ret = calllib(lib, 'C843_INI',ID_c843,'2'); %try to initialize rot motor

%is rotary stage?


%has limits?
disp('rot limit?')
[ret,~,haslim] = calllib(lib,'C843_qLIM',ID_c843,'2',false)

disp('rot low limit')
[ret,~,lowlim] = calllib(lib, 'C843_qTMN',ID_c843,'2',0)
[ret,~,hilim] = calllib(lib, 'C843_qTMX',ID_c843,'2',0)

%% Connect a motor to the card on axis 1
ret = calllib(lib,'C843_CST',ID_c843,'1','M-126.PD2')
ret = calllib(lib, 'C843_INI',ID_c843,'1'); %try to initialize linear motor

disp('lin limit?')
[ret,~,haslim] = calllib(lib,'C843_qLIM',ID_c843,'1',false)

disp('lin low limit')
[ret,~,lowlim] = calllib(lib, 'C843_qTMN',ID_c843,'1',0)
[ret,~,hilim] = calllib(lib, 'C843_qTMX',ID_c843,'1',0)


calllib(lib, 'C843_SPA',ID_c843,'1',11,2160,''); %max accel
%qspa
disp('lin rot?')
[ret,~,~,val] = calllib(lib, 'C843_qSPA',ID_c843,'1',19,0,'',1)
disp('rot rot?')
[ret,~,~,val] = calllib(lib, 'C843_qSPA',ID_c843,'2',19,0,'',1)


%%Disconnect
calllib(lib,'C843_CloseConnection',ID_c843);
%% Unload the library
%unloadlibrary(libname);
