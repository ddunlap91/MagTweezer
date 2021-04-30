%Load Force Extension Raw Data
%%=========================================
close all;
%XY Data
DIR = 'D:\DATA\Magnetic Tweezers\Experiments\';
FOLDER = '2015-09-23'
FILE = '2015-09-23_ForceExtension_002_XY.bin'

file=fullfile(DIR,FOLDER,FILE);
fid=fopen(file,'r');
num_tracks = fread(fid,1,'uint8');
num_ref_tracks = fread(fid,1,'uint8');
if num_ref_tracks>0
    ref_tracks = fread(fid,num_ref_tracks,'uint8');
end
%data is save in row-order
%XYdata(frame1,:) = [time,X1,Y1,X2,Y2,...Xn,Yn]
idx = 1;
Time = [];
XY = [];
while ~feof(fid)
     t = fread(fid,1,'double');
     if isempty(t)
         break;
     end
    Time(idx) = t;
    XY(:,idx) = fread(fid,2*num_tracks,'double');
    idx=idx+1;
end
Time = Time';
XY = XY';


% dXY = XY(:,1:2);
% for t=1:num_tracks
%     XY(:,2*(t-1)+1) = XY(:,2*(t-1)+1) - dXY(:,1);
%     XY(:,2*(t-1)+2) = XY(:,2*(t-1)+2) - dXY(:,2);
% end
%XY = bsxfun(@minus,XY,mean(XY,1));
figure();
plot(Time,XY(:,1),'-b');
hold on;
plot(Time,XY(:,2),'-r');

%plot(Time,XY(:,3),'-c');
%plot(Time,XY(:,4),'-m');

fclose(fid);

%Z Data
DIR = 'D:\DATA\Magnetic Tweezers\Experiments\';
FOLDER = '2015-09-23'
FILE = '2015-09-23_ForceExtension_002_Z.bin'

file=fullfile(DIR,FOLDER,FILE);
fid=fopen(file,'r');
num_tracks = fread(fid,1,'uint8');
num_ref_tracks = fread(fid,1,'uint8');
if num_ref_tracks>0
    ref_tracks = fread(fid,num_ref_tracks,'uint8');
end
%get refID for each track (specifies which track was used for Z-referencing
refID = fread(fid,num_tracks,'uint8');

%data is save in row-order
%XYdata(frame1,:) = [time,Zrel1,Zabs1,...Zreln,Zabsn]
idx = 1;
TimeZ = [];
Z = [];
while ~feof(fid)
     t = fread(fid,1,'double');
     if isempty(t)
         break;
     end
    TimeZ(idx) = t;
    Z(:,idx) = fread(fid,2*num_tracks,'double');
    idx=idx+1;
end
TimeZ = TimeZ';
Z = Z';
% dZ = Z(:,1);
% Zdrift =  bsxfun(@minus,Z,dZ);
% Zext = Zdrift(:,1)-Zdrift(:,3);

figure();
plot(TimeZ,Z,'-');
hold on
size(Zext)
Zavg = [];
T=[];
for f=1:300:numel(TimeZ)
    Zavg = [Zavg;mean(Zext(f:f+299))];
    T = [T;TimeZ(f+149)];
end
plot(T,Zavg,'.-R');
plot(TimeZ,Z(:,1)-Z(1,1),'-m');
plot(TimeZ,-Z(:,3)+Z(1,3),'-c');


fclose(fid);