% Rename Control data to ExperimentData_1

trk = 2% change trk if necessary

%% setup

%Reference Bead
Z1_obj = [ExperimentData_1.meanZ_ABS];
Z1_drift = Z1_obj(1,:); %the reference bead is track1
Z1_obj = Z1_obj(trk,:); %the measurement bead is track2

stdZ1_obj = [ExperimentData_1.stdZ_ABS];
stdZ1_drift = stdZ1_obj(1,:); %the reference bead is track1
stdZ1_obj = stdZ1_obj(trk,:); %the measurement is track2

%Tethered Bead
Z_obj = [ExperimentData.meanZ_ABS];
Z_drift = Z_obj(1,:); %the reference bead is track1
Z_obj = Z_obj(trk,:); %the measurement bead is track2

stdZ_obj = [ExperimentData.stdZ_ABS];
stdZ_drift = stdZ_obj(1,:); %the reference bead is track1
stdZ_obj = stdZ_obj(trk,:); %the measurement is track2

%Drift Correction
Z1_dc = Z1_obj-Z1_drift;
Z_dc = Z_obj-Z_drift;

Z11 = (max(Z1_dc)-Z1_dc)';
Z22 = (max(Z_dc)-Z_dc)';

MAG = [ExperimentData_1.MagnetRotation];
MAG = MAG(1,:)';

%% plots figure

figure(3);clf;
f = fit(MAG,Z11,'gauss2');
plot(f,MAG,Z11); hold on;
f2 = fit(MAG,Z22,'gauss2')
plot(f2,MAG,Z22);

figure(1);clf;
std1 = stdZ_obj.^2;
std2 = stdZ_drift.^2;
stdsum = sum(std1 + std2);
n = numel(std1)
stdover = sqrt(stdsum/n);
plot(MAG,stdover,'o-');

figure(2);clf;
plot(MAG,stdZ_obj); hold on;
plot(MAG,stdZ_drift,'x-'); hold on;

disp(stdover);















