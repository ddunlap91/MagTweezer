%%//n//function pylontest2()
clc;
cam = PylonMEX.getInstance();

cam.setupAxes([],true);
%pause();
cam.StartLiveMode();


set(cam.hfigImageFig,'DeleteFcn',@(~,~)delete(cam));

%pause;
%error('test error');

