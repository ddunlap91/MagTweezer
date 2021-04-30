function Z = particlez(img, XY, CAL, RefID)
%particelxyz - Locate spherical particle in an image
% This function looks for particles in an image and returns the appoximate 
% height based on calibrated refraction pattern.  This function is designed
% to work with forward-scattered brightfield images of microspheres.
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
%   RefID - array specifying which tracks in CAL a particle should be
%           referenced against
%
% Output:
%   Z = Particle locations
%=========================================================================
% Copyright 2015, Daniel T. Kovari
% All rights reserved.

numpart = size(XY,1);

if nargin<4
    if numel(CAL)==1
        RefID = ones(numpart,1);
    else
        RefID = 1:numpart;
        if numel(CAL)<numpart
            error('numel(CAL) must be same as number of rows in WIND or greater');
        end
    end
else
    if numel(CAL)<max(RefID)
        error('RefID cannot exceed numel(CAL)');
    end
end

if numel(RefID) ~= numpart
    error('must specify one RefID for each row in XY');
end
RefID = reshape(RefID,[],1);


%% Find particles to process
Z = NaN(numpart,1);
procZ = 1:numpart;
procZ(isnan(RefID)|isnan(XY(:,1))|isnan(XY(:,2))) = [];
procZ(~[CAL(RefID(procZ)).IsCalibrated]) = [];

if isempty(procZ)
    return;
end
%% calc radial function
Ir = imcross2radial_mex(img,XY(procZ,1),XY(procZ,2),[CAL(RefID(procZ)).Radius]);
if numel(procZ)==1
    Ir = {Ir};
end
%% calc z
for p = 1:numel(procZ)
     %normalize to last values
    %k = find(~isnan(Ir{p}),1,'last');
    %IrMid = nanmean(Ir{p}(k-5:k));
    
    if numel(Ir{p})<10
        start=1;
    else
        start=10;
    end
    IrMid = nanmean(Ir{p}(start:end));
    Ir{p} = Ir{p}/IrMid;

    Z(procZ(p)) = findz_ls_mex(Ir{p},CAL(RefID(procZ(p))).IrStack,CAL(RefID(procZ(p))).ZPos,50);
    if Z(procZ(p)) > max(CAL(RefID(procZ(p))).ZPos) || Z(procZ(p))<min(CAL(RefID(procZ(p))).ZPos) 
        Z(procZ(p)) = NaN;
    end
end
        

