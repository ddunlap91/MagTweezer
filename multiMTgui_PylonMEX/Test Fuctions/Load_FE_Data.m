% Force Extension
DIR = 'D:\DATA\Magnetic Tweezers\Experiments\';
FOLDER = '2015-09-25 - Experiment 2';
FILE = '2015-09-25_ForceExtension_004';

%XY
file = fullfile(DIR,FOLDER,[FILE,'_XY.bin']);
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
fclose(fid);

%Z
file = fullfile(DIR,FOLDER,[FILE,'_Z.bin']);
fid=fopen(file,'r');
num_tracks = fread(fid,1,'uint8');
num_ref_tracks = fread(fid,1,'uint8');
if num_ref_tracks>0
    ref_tracks = fread(fid,num_ref_tracks,'uint8');
end
%get refID for each track (specifies which track was used for Z-referencing
refID = fread(fid,num_tracks,'uint8');
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
fclose(fid);