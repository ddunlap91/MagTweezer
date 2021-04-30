% Rename Control data to ExperimentData_1

trk2 = 2% change trk if necessary

% load data
stdZ1_obj = [ExperimentData.stdZ_ABS];
stdZ1_drift = stdZ1_obj(1,:); %the reference bead is track1
stdZ1_obj = stdZ1_obj(trk2,:); %the measurement is track2


% calcualting individual point standard deviations
stdZ1 = stdZ1_obj.^2;
stdZ2 = stdZ1_drift.^2;
stdZ3 = [stdZ1;stdZ2];
stdZsum = (sum(stdZ3,1))/2;
stdZ4 = sqrt(stdZsum);

n1 = numel(stdZsum);
stdZover = (sum(stdZsum,2));
stdZ = sqrt((stdZover)/n);

disp(stdZ4);
