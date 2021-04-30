%% Get Raw Z Data
Z_obj = [ExperimentData.meanZ_ABS];
Z_obj = Z_obj(2,:); %the measurement bead is track2

MAG = [ExperimentData.MagnetRotation];

figure(2);clf;
plot(MAG,Z_obj,'.-');
title('Raw Z from absolute calibration data')
xlabel('Magent Rotation');

%% Plot dZ data
Zo = 67.56;
dZ = Zo-Z_obj;
figure(3);clf;
plot(MAG,dZ,'.-');
title('dZ calculated with absolute calibration data')
xlabel('Magent Rotation');

%% Plot drift of reference bead
Z_drift = [ExperimentData.meanZ_ABS];
Z_drift = Z_drift(1,:); %the reference bead is track1

figure(4);clf;
plot(MAG,Z_drift,'.-');
title('drift (i.e reference bead z position)');
xlabel('Magent Rotation');

%% Plot with drift correction
Z_dc = Z_obj-Z_drift;
figure(5);clf;
plot(MAG,Z_dc,'.-');
title('Z data with drift correction');
xlabel('Magent Rotation');

%% Plot dZ with drift correction
Zo = max(Z_dc);
dZ_dc = Zo-Z_dc;
figure(6);clf;
plot(MAG,dZ_dc,'.-');
title('dZ data with drift correction');
xlabel('Magent Rotation');

%% Plot meanXY position
mX = [ExperimentData.meanX];
mY = [ExperimentData.meanY];

mX = bsxfun(@minus,mX,mX(:,1));
mY = bsxfun(@minus,mY,mY(:,1));


figure(7);clf;
subplot(2,1,1);
plot(MAG,mX(2,:),'-');
hold on;
plot(MAG,mX(1,:),'--');
legend({'Measurement','Reference'});

ylabel('X position');
xlabel('Magnet Position');
subplot(2,1,2);
plot(MAG,mY(2,:),'-');
hold on;
plot(MAG,mY(1,:),'--');
ylabel('Y position');
xlabel('Magnet Position');

% Plot Drift corrected scatter
mX_dc = mX(2,:) - mX(1,:);
mY_dc = mY(2,:)- mY(1,:);

figure(8);clf;
plot(mX_dc,mY_dc,'.');
axis equal;
title('drift corrected XY position')

