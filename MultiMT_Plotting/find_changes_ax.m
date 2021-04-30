clc;
close all;
plot(1:10,1:10)
hAxes = gca;
md = ?matlab.graphics.axis.Axes;
eventNames = {md.EventList.Name};
for iEvent = 1:numel(eventNames)
    addlistener(hAxes, eventNames{iEvent}, @(~,~) disp(eventNames{iEvent}));
end