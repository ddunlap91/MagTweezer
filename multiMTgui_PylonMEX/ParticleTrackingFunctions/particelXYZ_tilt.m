function [X,Y,Zrel,Zabs,dZ,UsingTilt,abc] = particelXYZ_tilt(img,calib,wind,ZRef,TiltCorrection,RefTrks)
% track x,y,dz with option to use tilt correction
% if using tilt correction ZRef should be be either a num_tracks x 1 vector
% with all elements equal to the track used as the zero-point reference
% Also, for tilt correction the number of refernce tracks must be >2
% specify which tracks are reference tracks using RefTrks

[X,Y,Zrel,Zabs] = particle_xy_ZRel_ZAbs(img,calib,wind,ZRef);

%% Calculate dZ
dZ = Zabs(ZRef) - Zrel;
UsingTilt = false;
abc = NaN(3,1);
if TiltCorrection && numel(RefTrks)>2
    dZref = Zabs(ZRef(RefTrks)) - Zrel(RefTrks);
    %remove tracks that couldn't be processed
    RefTrks(isnan(dZref)) = [];
    dZref(isnan(dZref)) = [];
    if numel(dZref)<3
        warning('less than 3 reference particles were successfully tracked, not using Tilt Compensation');
    else
        abc = mldivide([X(RefTrks),Y(RefTrks),ones(numel(RefTrks),1)],dZref);
        dZ = dZ - [X,Y,ones(size(X))]*abc;
        UsingTilt = true;
    end
end