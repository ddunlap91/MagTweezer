function [XY,Y] = particlexy(img, WIND)
%particelxyz - Locate spherical particle in an image
% This function looks for particles in an image and returns the particle
% center (x,y) 
% This function will return the location of as many particles as are
% specified by size(WIND,1).
%=========================================================================
% Input:
%   img - The image to be processed (should be a grayscale image)

%   WIND - Windows where the algorithm should expect to find a particle
%           Rows correspond to different particles
%       WIND = [xi1,xf1,yi1,yf2
%                   ...        
%               xiN,xfN,yiN,yfN]
%   RefID - array specifying which tracks in CAL a particle should be
%           referenced against
%
% Output:
%   XY = Particle locations
%       size(XY) => [nparts,2)
%   XY = [x1,y1;...;xn,yn];
%     If a particle is not found, the values for xy are all NaN
%     Output XY values are in units of pixels
%     Example: XY = [10.2, 13.7]
%
%   [X,Y] = particlexy(img, WIND)
%       if two output arguments are passed, then X and Y are split into two
%       variables:
%           X = [x1;x2...]
%           Y = [y1;y2...]
%=========================================================================
% Copyright 2015, Daniel T. Kovari
% All rights reserved.

img = double(img);

%crop wind to image limits
WIND(:,1) = max(WIND(:,1),1);
WIND(:,2) = min(WIND(:,2),size(img,2));
WIND(:,3) = max(WIND(:,3),1);
WIND(:,4) = min(WIND(:,4),size(img,1));

[XY,Y] = radialcenter_mex(img,WIND);
if nargout<2
    XY = [XY,Y];
end
        

