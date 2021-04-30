% Rename Control data to ExperimentData_1

trk = 2% change trk if necessary

%% Plot Drift control data

%Control
Z1_obj = [ExperimentData_1.meanZ_ABS];
Z1_drift = Z1_obj(1,:); %the reference bead is track1
Z1_obj = Z1_obj(trk,:); %the measurement bead is track2

stdZ1_obj = [ExperimentData_1.stdZ_ABS];
stdZ1_drift = stdZ1_obj(1,:); %the reference bead is track1
stdZ1_obj = stdZ1_obj(trk,:); %the measurement is track2

%HU
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

% Standard Deviation
stdZ1 = stdZ1_obj.^2;
stdZ2 = stdZ1_drift.^2;
stdZ3 = [stdZ1;stdZ2];
stdZsum = (sum(stdZ3,1))/2;
stdZover = sqrt(stdZsum);

std1 = stdZ_obj.^2;
std2 = stdZ_drift.^2;
std3 = [std1;std2];
stdsum = (sum(std3,1))./2;
stdover = sqrt(stdsum);

%% Figure 1

figure(1);clf
errorbar(MAG,Z11,stdZover,'o-','linewidth',1);
hold on;
errorbar(MAG,Z22,stdover,'o-','linewidth',1);
title('Z Data with Drift Correction');
xlabel('Magent Rotation');
legend('Control','HU');

%xy data
mX1 = [ExperimentData_1.meanX];
mY1 = [ExperimentData_1.meanY];

%mX1 = bsxfun(@minus,mX1,mX1(:,1));
%mY1 = bsxfun(@minus,mY1,mY1(:,1));

mX1_dc = mX1(trk,:) - mX1(1,:);
mY1_dc = mY1(trk,:)- mY1(1,:);

%% Plot Drift Corrected HU data
  
%xy data
mX = [ExperimentData.meanX];
mY = [ExperimentData.meanY];

%mX = bsxfun(@minus,mX,mX1(:,1));
%mY = bsxfun(@minus,mY,mY1(:,1));

mX_dc = mX(trk,:) - mX(1,:);
mY_dc = mY(trk,:)- mY(1,:);

%plot figure 2
figure(2);hold on;

subplot(2,1,1);
plot(mX1(trk,:),mY1(trk,:),'.','DisplayName','Control');
hold on;
plot(mX(trk,:),mY(trk,:),'.','DisplayName','HU');
axis equal
title('Tethered Bead XY Shift');
legend('Control','HU');
xlabel('Pixels X direction');
ylabel('Pixels Y direction');

subplot(2,1,2);
plot(mX1(1,:),mY1(1,:),'.','DisplayName','Control Ref');
hold on;
plot(mX(1,:),mY(1,:),'.','DisplayName','HU Ref');
axis equal
title('Reference Bead XY Shift');
legend('Control','HU');
xlabel('Pixels in X direction');
ylabel('Pixels Y direction');







