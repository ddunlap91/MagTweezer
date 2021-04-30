function [X,Y,Zrel,Zabs] = particle_xy_ZRel_ZAbs(img, CAL, WIND, RefID)
%particle_xy_ZRel_ZAbs - Locate spherical particle in an image
% This function looks for particles in an image and returns the particle
% center (x,y) as well as the appoximate height based on calibrated
% refraction pattern.  This function is designed to work with
% forward-scattered brightfield images of microspheres.
% This function will return the location of as many particles as are
% specified.
%=========================================================================
% Input:
%   img - The image to be processed (should be a grayscale image)
%   CAL - Calibration data
%         numel(CAL) = number of particle to track
%           CAL(n).IrStack = Radial Profile stack
%           CAL(n).Radius = maximum radius of the calibration stack
%           CAL(n).ZPos = position of each z-slice
%           CAL(n).IsCalibrated = T/F, specify if particle has been
%                                 calibrated.
%         if numel(CAL)==1 then all windows are referenced against that
%         calibration data
%   WIND - Windows where the algorithm should expect to find a particle
%           Rows correspond to different particles
%       WIND = [xi1,xf1,yi1,yf2
%                   ...        
%               xiN,xfN,yiN,yfN]
%   RefID - array specifying which tracks in CAL a particle should be
%           referenced against
%
% Output:
%   X,Y = Particle locations in image (in pixels)
% If a particle is not found, the values for xy are all NaN
%       X,Y => [npart x 1]
%  Zrel = particle z-position calculated using the specified RefID
%  Zabs = particel z-positions calculated relative to their own calibration
%  data
%=========================================================================
% Copyright 2015-2016, Daniel T. Kovari
% All rights reserved.

numpart = size(WIND,1);

if numel(CAL)<numpart 
    error('not enough calibration structured: numel(CAL)!=size(WIND,1)');
end

if numpart==0
    X  = [];
    Y = [];
    Zabs = [];
    Zrel = [];
    return;
end


CalcZabs = true;
if nargin<4
    if numel(CAL)==1
        RefID = ones(size(WIND,1),1);
        CalcZabs = false;
    else
        RefID = 1:numpart;
        if numel(CAL)<size(WIND,1)
            error('numel(CAL) must be same as number of rows in WIND or greater');
        end
        CalcZabs = false;
    end
else
    if numel(CAL)<max(RefID)
        error('RefID cannot exceed numel(CAL)');
    end
end

%img = double(img);

%crop wind to image limits
WIND(:,1) = max(WIND(:,1),1);
WIND(:,2) = min(WIND(:,2),size(img,2));
WIND(:,3) = max(WIND(:,3),1);
WIND(:,4) = min(WIND(:,4),size(img,1));

Zrel = NaN(numpart,1);
Zabs = NaN(numpart,1);
[X,Y] = radialcenter_mex(img,WIND);


if CalcZabs
    %CAL
    procZ = find([CAL(RefID).IsCalibrated]|[CAL(1:numpart).IsCalibrated]);
    %[CAL(RefID(procZ)).Radius]
    %[CAL(procZ).Radius]
    %r = CAL(3).Radius
    Radius = max([CAL(RefID(procZ)).Radius],[CAL(procZ).Radius]);
else
    procZ = find([CAL(RefID).IsCalibrated]);
    Radius = [CAL(RefID(procZ)).Radius];
end

if isempty(procZ)
    return;
end
%X(procZ)
%Y(procZ)
%[CAL(RefID(procZ)).Radius]

Ir = imcross2radial_mex(img,X(procZ),Y(procZ),Radius);

if numel(procZ)==1
    Ir = {Ir};
end
for p = 1:numel(procZ)
    if isempty(Ir{p}) %x or y was nan
        continue;
    end
     %normalize to last values
    if numel(Ir{p})<10
        start=1;
    else
        start=10;
    end
    IrMid = nanmean(Ir{p}(start:end));
    
    Ir{p} = Ir{p}/IrMid;
    
    if CAL(RefID(procZ(p))).IsCalibrated
        Zrel(procZ(p)) = findz_ls_mex( Ir{p}(1:CAL(RefID(procZ(p))).Radius+1),...
                                        CAL(RefID(procZ(p))).IrStack,...
                                        CAL(RefID(procZ(p))).ZPos,50);
        if Zrel(procZ(p)) > max(CAL(RefID(procZ(p))).ZPos) || Zrel(procZ(p))<min(CAL(RefID(procZ(p))).ZPos) 
            Zrel(procZ(p)) = NaN;
        end
    end
    if CalcZabs && CAL(procZ(p)).IsCalibrated && RefID(procZ(p))~=procZ(p)
        Zabs(procZ(p)) = findz_ls_mex( Ir{p}(1:CAL(procZ(p)).Radius+1),...
                                        CAL(procZ(p)).IrStack,...
                                        CAL(procZ(p)).ZPos,50);
        if Zabs(procZ(p)) > max(CAL(procZ(p)).ZPos) || Zabs(procZ(p))<min(CAL(procZ(p)).ZPos) 
            Zabs(procZ(p)) = NaN;
        end
    elseif RefID(procZ(p))==procZ(p)
        Zabs(procZ(p)) = Zrel(procZ(p));
    end
end
