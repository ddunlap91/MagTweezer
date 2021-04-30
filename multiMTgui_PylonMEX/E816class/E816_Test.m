%% Initialize the Piezo Controller
piezolib = 'E816_DLL_x64.dll';
piezoheader = 'E816_DLL.h';
piezolibname = 'E816_DLL';

piezo_com = 2;
piezo_baud = 9600;
piezo_axes = 'A';
if(~libisloaded(piezolibname))
    disp('Loading the E816 Driver');
    [notfound,warnings] = loadlibrary (piezolib,piezoheader,'alias',piezolibname);
end

%try to connect to the piezo
fprintf('Attempting to connect to E816 on COM%d at BAUD=%d\n',piezo_com,piezo_baud); 
%ID_e816 = calllib(piezolibname, 'E816_FindOnRS',piezo_com,piezo_baud);
ID_e816 = calllib('E816_DLL', 'E816_ConnectRS232',piezo_com,piezo_baud);
if ID_e816 == -1
    warning('Could not connect to E816. Make sure it is plugged in and that a COM port is listed in device manager');
    status = false;
    return;
end

%query the piezo controller to make sure everything is working
% preload return variable
idn = blanks(100);
% query Identification string
[~,idn] = calllib(piezolibname,'E816_qIDN',ID_e816,idn,100);
fprintf('Connected to %s\n',idn);
% query baud rate
bdr = 0;
[~,bdr] = calllib(piezolibname,'E816_qBDR',ID_e816,bdr);
fprintf('Connection speed: %d baud\n',bdr);

%set limits
obj_lim = [0,100];

%servo status
svo = true;
[~,~,svo] = calllib(piezolibname,'E816_SVO',ID_e816,piezo_axes,svo);
disp('set servo status')
disp(svo)

%servo status
svo = false;
[~,~,svo] = calllib(piezolibname,'E816_qSVO',ID_e816,piezo_axes,svo);
disp('servo status')
disp(svo)

%servo position
pos = 0;
[~,~,pos] = calllib(piezolibname,'E816_qPOS',ID_e816,piezo_axes,pos);
disp('position')
disp(pos)

%move
pos = 25;
[~,~,pos] = calllib(piezolibname,'E816_MOV',ID_e816,piezo_axes,pos);
disp('mov position')
disp(pos)

%servo position
pos = 0;
[~,~,pos] = calllib(piezolibname,'E816_qPOS',ID_e816,piezo_axes,pos);
disp('position')
disp(pos)


%close connection
disp('Disconnecting from E816');
calllib(piezolibname,'E816_CloseConnection',ID_e816);
disp('Unloading E816_DLL');
unloadlibrary(piezolibname);