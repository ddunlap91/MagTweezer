[FileName,PathName,~] = uigetfile('*.txt','MultiSelect','On');
if iscell(FileName)
    nFiles = size(FileName,2);
    vertices = zeros(nFiles,2);
        FileList = FileName';
    for i = 1:nFiles
        vertices(i,1:2) = (findVertex(PathName, FileList(i));
    end;
else
    vertices(1,1:2) = findVertex(PathName, FileName);
end;

avgSC = mean(vertices(:,1));
avgHeight = mean(vertices(:,2));


function vertex = findVertex(path, file)

% build file name from path and file name
fName = strcat(path,file);

% load data into MatLab to give vectors Zavg and Twist
load(fName);

% find the maxumim for the HAT curve
[ZavgOfMax,indexOfMax] = max(Zavg);
% build subset arrays of the points surrounding the maximum
ZavgSubArray = Zavg(indexOfMax-5:indexOfMax+5);
scSubArray = sc(indexOfMax-5:indexOfMax+5);

% fit a parabola to the subarray
p = polyfit(scSubArray, ZavgSubArray,2);
vertex(1) = -p(2)/(2*p(1)); % the X value
vertex(2) = (4*p(1)*p(3)-p(2)^2)/(4*p(1)); % the Y value
end
