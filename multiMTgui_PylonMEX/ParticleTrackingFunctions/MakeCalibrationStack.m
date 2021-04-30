function CAL = MakeCalibrationStack(Istack,R_SIZE,WIND,ZPos)
% Inputs:
%   Istack - input image z-stack
%            this is a cell array of images
%   R_SIZE - Approximate Radius (in pixel of the outer most interference
%            ring
%   WIND - Window specifying region to seach in for a given particle
%          size(WIND) = Nparticles x 4
%           = [x1,x2,y1,y2;...]
% Output:
%   CAL - Calibration structure array
%==========================================================================
% Copyright 2015 Daniel Kovari
% All rights reserved.

if isempty(WIND)
    warning('no windows were passed to MakeCalibration. returning');
    CAL = struct('IrStack',[],'Radius',[],'ZPos',[]);
    return;
end

ncal = size(WIND,1);

CAL = struct('IrStack',[],'Radius',[],'ZPos',[],'IsCalibrated',num2cell(false(ncal,1)));
Nz = numel(Istack);
[Ny,Nx] = size(Istack{1});
WIND = max(1,WIND);
WIND(:,1:2) = min(Nx,WIND(:,1:2));
WIND(:,3:4) = min(Ny,WIND(:,3:4));

if numel(R_SIZE)==1
    R_SIZE = repmat(R_SIZE,ncal,1);
end
if numel(R_SIZE)~=ncal
    error('R_SIZE must contain same number of elements as rows in WIND');
end

%Istack = double(Istack);
hBar = waitbar(0,'Calculating Radial Profiles');

for n=1:ncal
    CAL(n).IrStack = NaN(Nz,R_SIZE(n)+1);
    CAL(n).Radius = R_SIZE(n);
end

%% Find particles in windows and calculate radial average using cross

for f=1:Nz
    [Xc,Yc] = radialcenter_mex(Istack{f},WIND);
    IrStack = imcross2radial_mex(Istack{f},Xc,Yc,[CAL.Radius]);
    %figure(99); clf;
    if ncal==1
        CAL(n).IrStack(f,:) = IrStack;
        %plot(IrStack);
    else
        for n=1:ncal
            %plot(IrStack{n});hold on;
            try 
                CAL(n).IrStack(f,:) = IrStack{n};
            catch
            end

        end
    end
    waitbar( f/Nz,hBar);
end

%% nomralize the data
%figure(100); clf;
for n=1:ncal
    %k = find( all(~isnan(CAL(n).IrStack),1),1,'last');
    %IrMid = nanmean(nanmean(CAL(n).IrStack(:,k-5:k),2),1);
    if size(CAL(n).IrStack,2)<10
        start=1;
    else
        start=10;
    end
    IrMid = nanmean(nanmean(CAL(n).IrStack(:,start:end),2),1);
    CAL(n).IrStack = CAL(n).IrStack/IrMid;
    %plot(CAL(n).IrStack); hold on;
end
delete(hBar);

%Average over duplicate z steps
% hBar = waitbar(0,'Average Duplate positions');
% for f=1:Nz
%     if f>numel(ZPos) %we've shortened the stack and now we're at the end
%         break;
%     end
%     k = find(round(ZPos,2)==round(ZPos(f),2));
%     for n=1:ncal
%         Is = CAL(n).IrStack(k,:);
%         CAL(n).IrStack(f,:) = nanmean(Is,1); %average the profiles
%         %delete duplicate locations
%         CAL(n).IrStack(k(2:end),:) = [];
%     end
%     ZPos(f) = nanmean(ZPos(k));
%     ZPos(k(2:end)) = [];
%     waitbar(f/Nz,hBar);
% end
% delete(hBar);

for n=1:ncal
    CAL(n).ZPos = ZPos;
    CAL(n).IsCalibrated = true;
end
    
    