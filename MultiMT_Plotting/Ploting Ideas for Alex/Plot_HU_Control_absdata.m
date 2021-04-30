% Rename Control data to ExperimentData_1

%% Plot Drift Corrected control data
Z1_obj = [ExperimentData_1.meanZ_ABS];
Z1_drift = Z1_obj(1,:); %the reference bead is track1
Z1_obj = Z1_obj(2,:); %the measurement bead is track2

MAG1 = [ExperimentData_1.MagnetRotation];

%z data
Z1_dc = Z1_obj-Z1_drift;
figure(1);clf;
plot(MAG1,max(Z1_dc)-Z1_dc,'.-','DisplayName','Control');
title('Z data with drift correction');
xlabel('Magent Rotation');

%xy data
mX1 = [ExperimentData_1.meanX];
mY1 = [ExperimentData_1.meanY];

%mX1 = bsxfun(@minus,mX1,mX1(:,1));
%mY1 = bsxfun(@minus,mY1,mY1(:,1));

mX1_dc = mX1(2,:) - mX1(1,:);
mY1_dc = mY1(2,:)- mY1(1,:);

figure(2);clf;
plot(mX1(2,:),mY1(2,:),'.','DisplayName','Control');
axis equal;
title('measured bead XY position');


%% Plot Drift Corrected HU data
Z_obj = [ExperimentData.meanZ_ABS];
Z_drift = Z_obj(1,:); %the reference bead is track1
Z_obj = Z_obj(2,:); %the measurement bead is track2

MAG = [ExperimentData.MagnetRotation];

%z data
Z_dc = Z_obj-Z_drift;
figure(1);hold on;
plot(MAG,max(Z_dc)-Z_dc,'.-','DisplayName','HU');
title('Z data with drift correction');
xlabel('Magent Rotation');
legend();

%xy data
mX = [ExperimentData.meanX];
mY = [ExperimentData.meanY];

%mX = bsxfun(@minus,mX,mX1(:,1));
%mY = bsxfun(@minus,mY,mY1(:,1));

mX_dc = mX(2,:) - mX(1,:);
mY_dc = mY(2,:)- mY(1,:);

figure(2);hold on;
plot(mX(2,:),mY(2,:),'.','DisplayName','HU');
axis equal
legend();


%% unwrapped data
figure(3);clf;
subplot(4,1,1);
plot(1:numel(Z1_dc),min(Z1_dc)-Z1_dc,'DisplayName','control');
hold on
plot(numel(Z1_dc)+(1:numel(Z_dc)),min(Z_dc)-Z_dc,'DisplayName','HU');
ylabel('dZ drift corrected');

subplot(4,1,2);
plot(1:numel(Z1_dc),Z1_drift,'DisplayName','control');
hold on
plot(numel(Z1_dc)+(1:numel(Z_dc)),Z_drift,'DisplayName','HU');
ylabel('Ref Bead Z');

subplot(4,1,3);
plot(1:numel(Z1_dc),mX1(2,:),'DisplayName','control');
hold on;
plot(numel(Z1_dc)+(1:numel(Z_dc)),mX(2,:),'DisplayName','HU');
ylabel('X position');

subplot(4,1,4);
plot(1:numel(Z1_dc),mY1(2,:),'DisplayName','control');
hold on;
plot(numel(Z1_dc)+(1:numel(Z_dc)),mY(2,:),'DisplayName','HU');
ylabel('Y position');


%% ref bead position
figure(4);clf;
plot(mX1(1,:),mY1(1,:),'.','DisplayName','Control Ref');
hold on;
plot(mX(1,:),mY(1,:),'.','DisplayName','HU Ref');
axis equal
title('Reference Position');






