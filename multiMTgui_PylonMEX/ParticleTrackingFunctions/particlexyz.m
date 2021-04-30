function XYZ = particlexyz(img, CAL, WIND, RefID)
%particelxyz - Locate spherical particle in an image
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
%   XYZ = Particle locations
%       size(XYZout) => [nparts,3)
%   XYZ = [x1,y1,z1;
%           ...;
%          xn,yn,zn];
%       If a particle is not found, the values for xyz are all NaN
%     Output XY values are in units of pixels
%     Z values correspond units of the calibration data
%     The values also include subpixel/subindex information
%     Example: XYZ = [10.2, 13.7, 4.5]
%=========================================================================
% Copyright 2015, Daniel T. Kovari
% All rights reserved.

numpart = size(WIND,1);

if numpart==0
    XYZ = [];
    return;
end

if nargin<4
    if numel(CAL)==1
        RefID = ones(size(WIND,1),1);
    else
        RefID = 1:numpart;
        if numel(CAL)<size(WIND,1)
            error('numel(CAL) must be same as number of rows in WIND or greater');
        end
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

XYZ = NaN(numpart,3);

[X,Y] = radialcenter_mex(img,WIND);
XYZ(:,1) = X;
XYZ(:,2) = Y;

procZ = find([CAL(RefID).IsCalibrated]);

if isempty(procZ)
    return;
end
%X(procZ)
%Y(procZ)
%[CAL(RefID(procZ)).Radius]

Ir = imcross2radial_mex(img,X(procZ),Y(procZ),[CAL(RefID(procZ)).Radius]);

if numel(procZ)==1
    Ir = {Ir};
end
for p = 1:numel(procZ)
     %normalize to last values
    if numel(Ir{p})<10
        start=1;
    else
        start=10;
    end
    IrMid = nanmean(Ir{p}(start:end));
    
    Ir{p} = Ir{p}/IrMid;
    
    %XYZ(procZ(p),3) = findz_ls(Ir{p},CAL(RefID(procZ(p))).IrStack,CAL(RefID(procZ(p))).ZPos);
    XYZ(procZ(p),3) = findz_ls_mex(Ir{p},CAL(RefID(procZ(p))).IrStack,CAL(RefID(procZ(p))).ZPos,50);
    if XYZ(procZ(p),3) > max(CAL(RefID(procZ(p))).ZPos) || XYZ(procZ(p),3)<min(CAL(RefID(procZ(p))).ZPos) 
        XYZ(procZ(p),3) = NaN;
    end
end
