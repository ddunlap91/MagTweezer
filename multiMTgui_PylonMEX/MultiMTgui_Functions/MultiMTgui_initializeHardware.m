function status = MultiMTgui_initializeHardware(hMain)
%MultiMTgui_initializeHardware(hObject) Initialize microscope hardware
% Input:
%   hMain - handle to main figure window
%       This function should be called after the guidata has been updated
% Output:
%   status - boolean true=initialized, false=error
% Example:
%   ...
%   %Update handles structure
%   guidata(hObject,handles);
%   ... (other functions which don't change or update hObject)
%   initstat = MultiMTgui_initializeHardware(hObject);
%   if ~initstat
%       error('Did not initialize hardware');
%   end
%
% Note: This function will update the guidata before returning
status = false;

%get an updated copy of the handles data
handles = guidata(hMain);

%% Initialize the MotorPI C-843
switch handles.MotorController
    case 'PI C-843 (PCI)'
        handles.MotorObj = C843class.getInstance();
    case 'PI C-862 (RS232)'
        handles.MotorObj = C862class.getInstance();
        handles.MotorObj.ConnectCOM(handles.MotorCOM);
    case 'ELECTROMAGNET'
        [MC, TM, TC, ~] = launch_Controller;
        handles.MC = MC;
        handles.TM = TM;
        handles.TC = TC;
        disp("Electromagnetic Set Up is On Its Way!");
        handles.MotorObj = C862class.getInstance();
        handles.MotorObj.ConnectCOM(handles.MotorCOM);
        handles.CurrentObj = ElectromagnetClass();
        
    otherwise
        error('%s is not a valid motor controller',handles.MotorController);
end
handles.MotorObj.Axis(handles.magzaxis).setAxisType(handles.magztype);
handles.MotorObj.Axis(handles.magraxis).setAxisType(handles.magrtype);

handles.MotorObj.Axis(handles.magzaxis).setAcceleration(15);
handles.MotorObj.Axis(handles.magzaxis).setDeceleration(15);

handles.MotorObj.Axis(handles.magraxis).setAcceleration(15*handles.mag_rotscale);
handles.MotorObj.Axis(handles.magraxis).setDeceleration(15*handles.mag_rotscale);


disp("SCOOB");
%% reference Motor
handles.MotorObj.Axis(handles.magzaxis).Reference;
disp("SCOOB");
%% Setup HW defaults
handles.MotorObj.Axis(handles.magzaxis).setVelocity(2);
handles.MotorObj.Axis(handles.magraxis).setVelocity(1*handles.mag_rotscale);

%initialize hardware specs for gui
fprintf('mag z: [%f,%f]\n',handles.MotorObj.Axis(handles.magzaxis).Limits);
handles.mag_zlim = handles.MotorObj.Axis(handles.magzaxis).Limits;
handles.mag_zpos = handles.MotorObj.Axis(handles.magzaxis).Position;
handles.mag_zspeed = handles.MotorObj.Axis(handles.magzaxis).Velocity;

handles.mag_rotpos = handles.MotorObj.Axis(handles.magraxis).Position/handles.mag_rotscale;
handles.mag_rotspeed = handles.MotorObj.Axis(handles.magraxis).Velocity/handles.mag_rotscale;

disp("SCOOB");
%% Initialize the Piezo Controller
switch handles.PiezoController
    case 'PI E-665.CR'
        handles.PiezoObj = E816class.getInstance();
        stat = handles.PiezoObj.ConnectCOM(handles.PiezoCOM,handles.PiezoBAUD);
        if stat == 0
            error('could not connect to com for piezo');
        end
    otherwise
        error('%s is not a valid piezo controller',handles.PiezoController);
end

%init hw specs
handles.obj_zlim = handles.PiezoObj.Axis.Limits;
handles.obj_zpos = handles.PiezoObj.Axis.Position;

%% Setup Camera
try
%     switch lower(handles.CameraInterface)
%         case 'tis_dcam'
%             handles.MMcam = MMcamera.getInstance();
%         case 'gige'
%             handles.MMcam = MMcamera_GigE.getInstance();
%         otherwise
%             error('CameraInterface: %s is not valid',handles.CameraInterface);
%     end
    handles.MMcam = PylonMEX.getInstance();
    %'here'
    
catch ME
    
    delete(handles.MotorObj);
    delete(handles.PiezoObj);
    handles.HardwareInitialized = false;
    guidata(hMain,handles);
    disp('Could not create camera object.');
    rethrow(ME);
    %return;
end


handles.ImageWidth = handles.MMcam.dImageWidth;
handles.ImageHeight = handles.MMcam.dImageHeight;

handles.HardwareInitialized = true;

%change status message
set(handles.hTxt_ProgramStatus,'String','Hardware is initialized');


%% Save guidata

status = true;
guidata(hMain,handles);


end

