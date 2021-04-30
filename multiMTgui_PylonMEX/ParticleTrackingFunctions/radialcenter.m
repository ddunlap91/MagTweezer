function [xc, yc] = radialcenter(I,WIND)
% Calculates the center of a 2D intensity distribution.
% Method: Considers lines passing through each half-pixel point with slope
% parallel to the gradient of the intensity at that point.  Considers the
% distance of closest approach between these lines and the coordinate
% origin, and determines (analytically) the origin that minimizes the
% weighted sum of these distances-squared.
%% 
% Inputs
%   I  : 2D intensity distribution (i.e. a grayscale image)
%   WIND: (optional) specify windows in which center should be calculated
%         If WIND is used, xc, yc have length of size(WIND,1);
%        WIND should be a Nx4 matrix of the form
%       WIND = [xi1,xf1,yi1,yf2
%                   ...        
%               xiN,xfN,yiN,yfN]
%%
% Outputs
%   xc, yc : the center of radial symmetry,
%            px, from px #1 = left/topmost pixel
%            So a shape centered in the middle of a 2*N+1 x 2*N+1
%            square (e.g. from make2Dgaussian.m with x0=y0=0) will return
%            a center value at x0=y0=N+1.
%            Note that y increases with increasing row number (i.e. "downward")
%
%% ========================================================================
% Based on the algorithm published in:
% R. Parthasarathy (2012) Nat. Methods. Vol 9, Iss 7, pp 724-6
% DOI: 0.1038/nmeth.2071
%
% Disclaimer / License  
%   This program is free software: you can redistribute it and/or 
%     modify it under the terms of the GNU General Public License as 
%     published by the Free Software Foundation, either version 3 of the 
%     License, or (at your option) any later version.
%   This set of programs is distributed in the hope that it will be useful, 
%   but WITHOUT ANY WARRANTY; without even the implied warranty of 
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU 
%   General Public License for more details.
%   You should have received a copy of the GNU General Public License 
%   (gpl.txt) along with this program.  If not, see <http://www.gnu.org/licenses/>.
%==========================================================================
%% Change Log:
% 2013-07-27 Dan Kovari, Emory University
%       This is now just a shell function for calling the mex version
%       see radialcenter_mex.cpp for sourcecode

%%
if nargin<2
    [xc,yc] = radialcenter_mex(double(I));
else
    [xc,yc] = radialcenter_mex(double(I),WIND);
end