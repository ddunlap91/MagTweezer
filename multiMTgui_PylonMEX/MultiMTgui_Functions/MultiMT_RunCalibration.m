function MultiMT_RunCalibration(hMain)

%get gui data
%===========================
handles = guidata(hMain);

if handles.num_tracks ==0
    handles.CalibrationRunning = false;
    guidata(hMain,handles);
    MultiMT_updateTrackingControls(hMain);
    return;
end

%clear plot points from live image
try
    cla(handles.hAx_CameraImageAxes);
catch
end

%initialize stack positions
CalStackPos = handles.CalStackMin:handles.CalStackStep:handles.CalStackMax;

nPos = numel(CalStackPos);
nFrames = handles.CalStackStepCount;
%duplicate for number of frames
CalStackPos = repmat(CalStackPos,nFrames,1);


%init image stack
%pre-allocate memory for the image stack. keep the image as a uint8 until
%we process each frame so that we don't run out of memory
CalStack = cell(nFrames,nPos);%zeros(handles.MMcam.dImageHeight,handles.MMcam.dImageWidth,NumFrames,'uint8');
%loop over z and snap images
loop_break=false;
hBar = waitbar(0,'Capturing Calibration Images');
%stopCamera(hMain);

switch handles.MotorController
    %case 'ELECTROMAGNET'
    %    [CalStack, CalStackPos] = SimulateBead(hMain, nPos, nFrames, CalStack, hBar, CalStackPos);
    %    try
    %       delete(hBar);
    %    catch
    %    end
    %  
    otherwise
        setObjectivePosition(hMain,CalStackPos(1,1));
        handles.PiezoObj.Axis.WaitForOnTarget(); %wait for objective to stop moving
        pause(0.3);

        %% stop live mode
        stopCamera(hMain);
        pause(0.01);

        for p=1:nPos
            drawnow; %process any callbacks that were triggered since the last cycle
            handles = guidata(hMain); %update handles
            if ~handles.CalibrationRunning %if nolonger running break
                loop_break=true;
                break;
            end
            %set z position
            setObjectivePosition(hMain,CalStackPos(1,p));
            handles.PiezoObj.Axis.WaitForOnTarget(); %wait for objective to stop moving
            pause(0.01); %wait a little longer for things to settle
            for n=1:nFrames
                CalStackPos(n,p) = handles.PiezoObj.Axis.Position; %get actual position
                %get image
                CalStack{n,p} = handles.MMcam.SnapImage(1);
            end
    
            %pos2 = handles.PiezoObj.Axis.Position; %get position to actual position
            %CalStackPos(:,p) = (pos1+pos2)/2;%take average before and after images as true position
            try
                waitbar(p/nPos,hBar);
            catch
            end
        end
        try
        delete(hBar);
        catch
        end
end


if ~loop_break %if the calibration wasn't canceled
    %stop live mode, give us time to process the image without
    %being interupted
    guidata(hMain,handles);
    stopCamera(hMain);
    handles = guidata(hMain);
    CalStackPos = reshape(CalStackPos,[],1); %reshape to get frame number in ascending order
    CalStack = reshape(CalStack,[],1);
    
    %stackfig(CalStack);
    %handles.CalStack = CalStack;
    %handles.CalStackPos = CalStackPos;
    Radius = [handles.track_params.Radius]';
    
    wind = handles.track_wind;
    if handles.MMcam.UsingROI
        wind(:,1:2) = wind(:,1:2)-handles.MMcam.ROI(1)+1; %change x_i, x_f to be relative to ROI
        wind(:,3:4) = wind(:,3:4)-handles.MMcam.ROI(2)+1; %change y_i,y_f to be relative to ROI
    end
    handles.track_calib = MakeCalibrationStack(CalStack,Radius,wind,CalStackPos);
    %update track param data
    for n=1:numel(handles.track_calib)
        handles.track_params(n).IsCalibrated = handles.track_calib(n).IsCalibrated;
    end
    
    %interpolate stack to have original target locations, that way the
    %stack won't be really big if the user selected a large numebr of
    %frame/step and the piezo doesn't hit the same location at each point
    if handles.CalStackStepCount>1
        new_ZPos = handles.CalStackMin:handles.CalStackStep:handles.CalStackMax;
        %handles.CalStackPos = new_ZPos;
        for n=1:numel(handles.track_calib)
            [rr,zz] = meshgrid(0:Radius(n),handles.track_calib(n).ZPos);
            [rq,zq] = meshgrid(0:Radius(n),new_ZPos);
            F = scatteredInterpolant(rr(:),zz(:),handles.track_calib(n).IrStack(:),'natural','nearest');            
            handles.track_calib(n).IrStack = F(rq,zq);
            handles.track_calib(n).IrStack = imgaussfilt(handles.track_calib(n).IrStack,1); 
            handles.track_calib(n).ZPos = new_ZPos;
        end
    end
        
    
end

handles.CalibrationRunning = false;

%Update data
%=========
guidata(hMain,handles);

%move to half way through calibration range
setObjectivePosition(hMain,mean([handles.CalStackMax,handles.CalStackMin]));

setInFunctionFlag(hMain,true);
MultiMT_updateTrackParameterTable(hMain);
%restart camera livemode if needed.
stopCamera(hMain);
pause(0.01);
startCamera(hMain);
setInFunctionFlag(hMain,false);

