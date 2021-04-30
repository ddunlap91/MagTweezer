function [Ir,rloc] = imradialaverage(I,xc,yc,dr,rloc)
%Radially average an image around the coordinate xc,yc with radial location
%having integer values
% Input:
%   I - the image
%   xc - the x coordinate
%        1 corresponds to the left most pixel
%        size(I,2) corresponds the right most pixel
%   yc - the y coordinate
%        1 corresponds to the top most pixel
%        size(I,1) corresponds the bottom most pixel
% Optional:
%   dr - the width of the radial bins, default is 1
%   rloc - specify radius locations
%---------------
% Output:
%   Ir - the radial average
%        The radial average is computed by averaging the pixels within a
%        distance +/- dr/2 of the location rloc(n), using a constant
%        weighting.
%   rloc - radius locations
%==========================================================================
% Copyright 2015 Daniel Kovari
% All rights reserved.

rmax = sqrt(max(...
    sum([(size(I)-[yc,xc]).^2;...
         ([1,1]-[yc,xc]).^2;...
         ([1,size(I,2)]-[yc,xc]).^2;...
         ([size(I,1),1]-[yc,xc]).^2],2)));

if nargin<4
    dr = 1;
end

if nargin>4
    if max(rloc)<rmax
        rmax = max(rloc);
        %crop the image
        limx = [floor(xc-rmax+dr/2),ceil(xc+rmax+dr/2)];
        limx(1) = max(limx(1),1);
        limx(2) = min(limx(2),size(I,2));
        limy = [floor(yc-rmax+dr/2),ceil(yc+rmax+dr/2)];
        limy(1) = max(limy(1),1);
        limy(2) = min(limy(2),size(I,1));
        xc=xc-limx(1)+1;
        yc=yc-limy(1)+1;
        I=I(limy(1):limy(2),limx(1):limx(2));
    end
else
    rloc = 0:dr:rmax;
end

I = double(I);

[xx,yy] = meshgrid(1:size(I,2),1:size(I,1));
rr = sqrt((xx-xc).^2+(yy-yc).^2);

Ir = bindata(rr,I,rloc,dr)';


function [b,n,s]=bindata(x,y,gx,binwidth)
% [b,n,s]=bindata(x,y,gx)
% Bins y(x) onto b(gx), gx defining centers of the bins. NaNs ignored.
% Optional return parameters are:
% n: number of points in each bin   
% s: standard deviation of data in each bin 
% A.S.

%[yr,yc]=size(y);

x=x(:);y=y(:);
idx = find(isnan(y));
x(idx) = [];
y(idx) = [];
if isempty(y)
    b=NaN(size(gx));
    n=NaN(size(gx));
    s=NaN(size(gx));
    return;
end

xx = gx(:)';
if nargin<4
    binwidth = diff(xx);
end
xx = [xx(1)-binwidth(1)/2, xx(1:end-1)+binwidth/2, xx(end)+binwidth(end)/2];

% Shift bins so the interval is "( ]" instead of "[ )".
bins = xx + max(eps,eps*abs(xx));

[nn,bin] = histc(x,bins,1);
nn=nn(1:end-1);
nn(nn==0)=NaN;

idx=find(bin>0);
sum=full(sparse(bin(idx),ones(size(idx)),y(idx)));
sum=[sum;NaN(length(gx)-length(sum),1)];% add NaN to the end
b=sum./nn;

if nargout>1
    n=nn;
end
if nargout>2
    sum=full(sparse(bin(idx),idx*0+1,y(idx).^2));
    sum=[sum;NaN(length(gx)-length(sum),1)];	% add NaN to the end
    s=sqrt(sum./(nn-1) - b.^2.*nn./(nn-1) );
end