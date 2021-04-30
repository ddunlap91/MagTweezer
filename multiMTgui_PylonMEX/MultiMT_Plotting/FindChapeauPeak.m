function OutArray = FindChapeauPeak2()
% FindChapeauPeak()
%  Prompts the user to load a Chapeau Curve data file (in mtdat format).
%  Once the file is loaded, the function estimates the location of the peak
%  in the curve by fitting the neighborhood of the maximum with a parabola.
%  The peak extension corresponds to the parabola's vertex.
%
% Results are plotted with a ~95% confidence error bar on the vertex fit.
% The user is also prompted to save the values to an excel file of their
% choosing.
%
% This file depends on errorbar2.m by Dan Kovari

OutArray = cell(0,9);
%Loop until user say when
OpenMore = 'Yes';
figure('name','FindChapeau','numbertitle','off');
legstrAll = {};
hEBAll = gobjects(0);

SLOPE_RANGE = [0.25,0.75];

while strcmp(OpenMore,'Yes')
    %load experiment data
    [header,ExperimentData,filepath] = LoadExperimentData();
    [~,filename] = fileparts(filepath);
    
    if isempty(header) %user canceled file selection
        break;
    end
    
    if ~isfield(ExperimentData,'StepData') || isempty(ExperimentData(1).StepData)
        warning('Data could not be loaded from file. Experiment might have been canceled or data could be corrupted.');
        continue;
    end
    
    %MagnetRot
    Turns = [ExperimentData.MagnetRotation];
    
    %% Calculate Drift-corrected absolute positions
    
    %average drift
    MeasTrk = find(strcmpi({header.TrackingInfo.Type},'Measurement'));
    RefTrk = find(strcmpi({header.TrackingInfo.Type},'Reference'));
    meanZ_ABS = [ExperimentData.meanZ_ABS];
    avgDriftZ_ABS = nanmean(meanZ_ABS(RefTrk,:),1);
    driftCorrected_meanZ = bsxfun(@minus,meanZ_ABS,avgDriftZ_ABS);
    
    %calculate dZ relative to minimum, for measured beads only
    maxMeanZ = max(driftCorrected_meanZ(MeasTrk,:),[],2);
    mean_dZ = -bsxfun(@minus,driftCorrected_meanZ(MeasTrk,:),max(driftCorrected_meanZ(MeasTrk,:),[],2));
    
    %find turn for max dZ
    [max_z,max_ind] = max(mean_dZ,[],2);

    %% fit w/ parabola and find vertex
    Vertex = NaN(numel(MeasTrk),1);
    VertexStd = NaN(numel(MeasTrk),1);
    EstMax = NaN(numel(MeasTrk),1);
    P = NaN(numel(MeasTrk),3);
    P_sig = NaN(numel(MeasTrk),3);
    Trn = cell(numel(MeasTrk),1);
    for n=1:numel(MeasTrk)
        %% Find all points in the curve above the half-max-height line
        ind = find(mean_dZ(n,:)>0.6*max(mean_dZ(n,:)));
        
        x = Turns(ind);
        Trn{n} = x;
        %P(n,:) = polyfit(Turns(indLow(n):indHigh(n)),mean_dZ(n,indLow(n):indHigh(n)),2);
        %% Fit with parabola
        X = [x.^2',x',ones(numel(x),1)];
        Y = mean_dZ(ind)';
        
%         Trn{n} = Turns(ind);
%         
%         %% Max a flattened array of all data points for each of those turns
%         Y =[];
%         x = [];
%         for j=1:numel(ind)
%             Zall = [ExperimentData(ind(j)).StepData.Z_ABS]; %get raw data for this step
%             thisZ = Zall(n,:); %select only current track
%             thisZ = thisZ - avgDriftZ_ABS(ind(j)); %account for drift using the time-averaged meanZ_abs of ref trks calculated above
%             dZ = thisZ-maxMeanZ(n); %convert to dZ using max value measured for chapeau curve
%             
%             Y = [Y;dZ']; %concat data
%             x = [x;repmat(Turns(ind(j)),numel(dZ),1)];
%         end
%         
%         
%         %P(n,:) = polyfit(Turns(indLow(n):indHigh(n)),mean_dZ(n,indLow(n):indHigh(n)),2);
%         %% Fit with parabola
%         X = [x.^2,x,ones(numel(x),1)];
%         %Y = mean_dZ(n,ind)';
        
        P(n,:) = X\Y; %just solving P = (X'*X)^-1*X'*Y
        
        %% Calculate veriance of fit relative to measured points
        sig2 = sum((Y-X*(P(n,:)')).^2)/(numel(Y)-3);
        %% calculate sqrt of fit parameter variance i.e. confidence limit = P +/- z*sqrt(Var(P))
        Cov = sig2*(X'*X)^-1;
        P_sig(n,:) = sqrt(diag(Cov));
        
        %Check for problems with the fit
        if P(n,1) >= 0
            warning('Could not find vertex for track %d',MeasTrk(n));
            continue;
        end
        %% calc vertex and vertex-fit standard deviation
        Vertex(n) = -P(n,2)/(2*P(n,1));
        VertexStd(n) = abs(Vertex(n))*sqrt( (P_sig(n,1)/P(n,1))^2 + (P_sig(n,2)/P(n,2))^2  );
        % Calc value at vertex
        EstMax(n) = polyval(P(n,:),Vertex(n));
        
        %calc vertical error bar
        EstMaxStd(n) = sqrt(sig2);
        
        
        
        
    end
    
    %% Plot
    sdZ = [ExperimentData.stdZ_ABS];
    
    legstr=cell(numel(MeasTrk),1);
    hEB = gobjects(numel(MeasTrk),1);
    for n=1:numel(MeasTrk)
        %plot the curve data
        %hEB(n) = errorbar(Turns',mean_dZ(n,:)',sdZ(MeasTrk(n),:)');
        hEB(n) = plot(Turns',mean_dZ(n,:)','.:');
        hold on;
        legstr{n} = sprintf('%s: Track %d',filename,MeasTrk(n));
        %plot(Vertex(n),EstMax(n),'x','Color',hEB(n).Color);
        errorbar2(Vertex(n),EstMax(n),2*VertexStd(n),2*VertexStd(n),'Marker','x','MarkerSize',12,'Color',hEB(n).Color);
        
        %plot vertex fit line
        T = linspace(min(Trn{n}),max(Trn{n}));
        plot(T,polyval(P(n,:),T),'-.','color',hEB(n).Color);
        
        
        
        %% calc slope at half max on left
        
        LeftFitInd = find( mean_dZ(n,:)>=SLOPE_RANGE(1)*max_z(n) & mean_dZ(n,:)<=SLOPE_RANGE(2)*max_z(n) & Turns<Vertex(n));
        PL = polyfit(Turns(LeftFitInd),mean_dZ(n,LeftFitInd),1);
        
        EstLeftSlope(n) = PL(1);
        
        %% calc slope at half max on right
        RightFitInd = find( mean_dZ(n,:)>=SLOPE_RANGE(1)*max_z(n) & mean_dZ(n,:)<=SLOPE_RANGE(2)*max_z(n) & Turns>Vertex(n));
        PR = polyfit(Turns(RightFitInd),mean_dZ(n,RightFitInd),1);
        
        EstRightSlope(n) = PR(1);
        
        plot(Turns(LeftFitInd),polyval(PL,Turns(LeftFitInd)),'-','color',hEB(n).Color)
        plot(Turns(RightFitInd),polyval(PR,Turns(RightFitInd)),'-','color',hEB(n).Color)
        
    end
    
    %append legend text for the new lines
    hEBAll = [hEBAll;hEB];
    legstrAll = [legstrAll;legstr];
    
    legend(hEBAll,legstrAll,'Location','eastoutside','Interpreter','none');
    xlabel('Magnet Rotation [Turns]')
    ylabel('Tether Length [µm]');
    

    %% Add data to outarray
    for n=1:numel(MeasTrk)
        OutArray=[OutArray;...
            {filepath,MeasTrk(n),Turns(max_ind(n)),max_z(n),Vertex(n),EstMax(n),VertexStd(n),EstLeftSlope(n),EstRightSlope(n)}];
    end
    
    %% Open More?
    OpenMore = questdlg('Do you want to open another file','Open?','Yes','No','Yes');
end

if isempty(OutArray)
    return;
end

%% Write out to file
Pth = fileparts(filepath);
[FileName,PathName] = uiputfile(fullfile(Pth,'*.xlsx'),'Save Excel File');
if FileName~=0
    %add header to output data
    h = { 'FileName','TrackID','Magnet Rot. of Max','Max Z','Vertex Rotation','Max of Vertex','Std. Dev. of Vertex Rot.','Left Slope','Right Slope'};
    OutArray = [h;OutArray];
    %write to excel file
    xlswrite(fullfile(PathName,FileName),OutArray);
end

%% if user didn't specify a return variable, supress output at the terminal
if nargout<1
    clear OutArray;
end


