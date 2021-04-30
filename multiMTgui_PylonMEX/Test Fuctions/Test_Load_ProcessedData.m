%Load Processed force data
File = 'D:\DATA\Magnetic Tweezers\Experiments\2015-09-25 - Experiment 2\2015-09-25_ForceExtension_005.txt';
fid = fopen(File,'r');

while ~feof(fid)
    tline = fgetl(fid);
    if strncmp(tline,'DATE',4);
        break;
    end
    if strncmp(tline,'TotalTracks',11)
        num_tracks = sscanf(tline,'TotalTracks:\t%d',1);
    end
    if strncmp(tline,'RefenenceTracks',15)
        ref_tracks = str2num(tline(17:end));
    end  
end
if feof(fid)
    error('could not find any data in the file');
end

%loop over lines and collect data
DateVec = [];
MagH = [];
Data = [];
while ~feof(fid)
    tline = fgetl(fid);
    %                      yr- mm- dd   hh: mm: ss  mag
    ldata = sscanf(tline,'%4d-%2d-%2d\t%2d:%2d:%6f\t%5f',7);
    if numel(ldata)~=7
        disp('could not read line');
        break;
    end
    fdata = str2num(tline(31:end));
    fdata = reshape(fdata,1,5,[]); %rehape data to [[L1,Fx1,Fx2,dx1,dy1],[[L2,Fx2,Fx2,dx2,dy2],...]
    DateVec = [DateVec;ldata(1:6)'];
    MagH = [MagH;ldata(7)];
    Data = [Data;fdata];
end
fclose(fid);

if size(Data,3)~=num_tracks
    error('size of data does not match number of tracks specified');
end

%Plot data
%====================================
mt = 1:num_tracks; %make a list of measurement tracks
mt(ref_tracks) = [];

%plot force vs length
figure(99);clf;hold on;
colors = lines(numel(mt));
leg_str = {};

%fit model
ft = fittype('log10(4.11/P*(1/4*(1-x/Lo)^(-2)-1/4+x/Lo))');

for t=numel(mt)
    %Fx
    plot(Data(:,1,mt(t)),Data(:,2,mt(t))/1e-12,'o',...
        'color',colors(t,:),...
        'MarkerSize',5,...
        'MarkerFaceColor',colors(t,:),...
        'MarkerEdgeColor',colors(t,:)*0.5,...
        'LineWidth',1);
    leg_str = [leg_str,sprintf('Trk %i F_X',mt(t))];
    
    %WLC Fit
    fo = fit(Data(:,1,mt(t)),log10(Data(:,2,mt(t))/1e-12),ft,...
        'StartPoint',[10,1],...
        'Lower',[0,0],...
        'Upper',[10,300]);
    
    coef = coeffvalues(fo);
    coefint = confint(fo);
    ll = linspace(min(Data(:,1,mt(t))),coef(1));
    Fx = feval(fo,ll);
    
    leg_str = [leg_str,...
        sprintf('L_0=%0.2f[%0.2f,%0.2f]µm L_p=%0.1f[%0.1f,%0.1f]nm',coef(1),coefint(1,1),coefint(2,1),coef(2),coefint(1,2),coefint(2,2))];
    plot(ll,10.^Fx,'--',...
        'color',colors(t,:)*.7,...
        'MarkerSize',5,...
        'MarkerFaceColor',colors(t,:),...
        'MarkerEdgeColor',colors(t,:)*0.5,...
        'LineWidth',1);
    %Fy
%     plot(Data(:,1,mt(t)),Data(:,3,mt(t))/1e-12,'d-.',...
%         'color',colors(t,:),...
%         'MarkerSize',5,...
%         'MarkerFaceColor',colors(t,:),...
%         'MarkerEdgeColor',colors(t,:)*0.5,...
%         'LineWidth',1);
%     leg_str = [leg_str,sprintf('Trk %i Fy',mt(t))];
end
xlabel('L_{ext} [µm]','FontSize',11);
ylabel('Force [pN]','FontSize',11);
legend(leg_str,'location','northwest');
title('WLC Force-Extension','FontSize',11,'FontWeight','bold');
%format axes
set(gca,...
    'box','off',...
    'tickdir','out',...
    'YScale','log',...
    'ygrid','on',...
    'GridLineStyle',':',...
    'minorgridlinestyle','none',...
    'ycolor',[0.2,0.2,0.2],...
    'xcolor',[0.2,0.2,0.2],...
    'XMinorTick'  , 'on'      , ...
    'YMinorTick'  , 'on'      , ...
    'LineWidth',1);
    


