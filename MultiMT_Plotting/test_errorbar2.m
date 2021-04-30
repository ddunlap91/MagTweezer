close all;
clc;
hAx = gca;
h1 = errorbar2(hAx,1:10,1:10,.25*ones(1,10),.5*ones(1,10),2*ones(1,10),4*ones(1,10));
hold on;
h2 = errorbar2(hAx,(1:10)',(10:-1:1)','color',lines(1));

%myerrorbar(hAx,1:10,4:14,'color',lines(1));

%delete(h2)
figure();


errorbar2(gca,1:10,1:10,.5*ones(1,10),.25*ones(1,10),(.5:10.5)/2,(.5:10.5)/2,'LineStyle','none','marker','s','color',lines(1));
set(gca,'yscale','log');
