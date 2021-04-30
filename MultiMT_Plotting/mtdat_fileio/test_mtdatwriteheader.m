function test_mtdatwriteheader()

file = 'test_header.mtdat';

s.MicroscopeName = 'Black Tweezer';
s.CameraID = 'BaslerPylonUSB...';
s.CameraWidth = 1024;
s.CameraHeight = 768;
s.CameraPixelSize = 5.68;
s.CameraPixelSizeUnits = 'um';
s.ObjectiveName = 'Nikon 100x Oil...';
s.ObjectiveMagnification = 100;
s.ObjectiveTubeLength = 200;
s.TubeLensFocalLength = 150;
s.PixelScale = 0.1678234;
s.PixelScaleUnits = 'um/px';

Piezo.Type = 'ObjectivePiezo';
Piezo.Model = 'PI###';
Piezo.ControllerName = 'PI E-665';
Piezo.ControllerPort = 'COM5';
Piezo.ControllerBaud = '9600';
Piezo.ControllerAxisID = 1;
Piezo.Range = [0,100];
Piezo.Units = 'um';

Motor.Type = 'MagnetHeight';
Motor.Model = 'M-126.PD2';
Motor.ControllerName = 'PI C-863';
Motor.ControllerPort = 'COM6';
Motor.ControllerBaud = '9600';
Motor.ControllerAxisID = 1;
Motor.Range = [0,20];
Motor.Units = 'mm';

s.AttachedHardware(1) = Piezo;
s.AttachedHardware(2) = Motor;


d.parameter = 'Date';
d.format = 'double'; %could be any of the fread/fwrite precision strings
d.size = [1,1];

h.parameter = 'MagnetHeight';
h.format = 'double';
h.size = [1,1];


xyz1.parameter = 'XYZ_trk1';
xyz1.format = 'double';
xyz1.size = [1,4];

xyz2.parameter = 'XYZ_trk2';
xyz2.format = 'double';
xyz2.size = [1,4];


Record = [d,h,xyz1,xyz2];

fid = mtdatwriteheader(file,s,Record);
fwrite(fid,ones(1000*10,1),'double');
fclose(fid);
[cfg,data] = mtdatread(file)
disp('data(1000) =');
disp(data(1000));