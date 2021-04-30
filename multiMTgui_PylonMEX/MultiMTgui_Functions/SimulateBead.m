function [CalStack, CalStackPos] = SimulateBead(hMain, nPos, nFrames, CalStack, hBar, CalStackPos)

%% constants
handles = guidata(hMain);
disp(nPos);
pxNoiseSD = 1; 
pxNoiseMean = 0;
kT = 4.1; 
pN = 2000; 
bp = 3000; 
cL = 0.34*bp; 
extension = 0.7*cL;
pixelCalibration = 7;
fluctuations = sqrt(kT*extension/pN)/pixelCalibration; 
x = linspace(0, 1088, 1088);
y = linspace(0, 2048, 2048); 
a = 125; 
b = 5;
Simulation = figure();
pause('on');
colormap('gray');
colorbar;
handles.Simulation = Simulation;
ax = Simulation.CurrentAxes;
for p=1:nPos
    drawnow;
    handles = guidata(hMain);
    img = getimg(a, b*(1+(p/nPos)), b, x, y);
    img = rescale(img, 0, 256);
    
    for n=1:nFrames
        handles = guidata(hMain);
        CalStackPos(n,p) = p;
        tmp = circshift(img,round(fluctuations*randn),1);
        tmp = circshift(tmp,round(fluctuations*randn),2);
        CalStack{n,p} = tmp + pxNoiseSD.*randn(1088,2048) + pxNoiseMean;
        image(ax, CalStack{n,p});
    end
    waitbar((p/nPos), hBar);
end
delete(hBar);
close(Simulation);
guidata(hMain, handles);



end


function R = getimg(A, B1, B2, X, Y)
R = zeros(1088, 2048);
for i = 1:1088
    for j = 1:2048
        bead1 = sqrt((X(i)-544)^2 + (Y(j)-1044)^2);
        bead2 = sqrt((X(i)-272)^2 + (Y(j)-522)^2);
        R(i,j) = A*sin(pi*bead1/B1)/(pi*bead1/B1) + A*sin(pi*bead2/B2)/(pi*bead2/B2);
    end
end
end

