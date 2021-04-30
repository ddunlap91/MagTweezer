function ExpData = MultiMT_updateCustomExperimentPlots(hMain, ExpData, StepsToCalc)
%plot/update data figures for custom experiment
%each plot is only updated if the associated figure handle is valid
%
%Figure handles
%   handles.hFig_CustExp_LvMH
%   handles.hFig_CustExp_LvMR
%	handles.hFig_CustExp_FvMH
%   handles.hFig_CustExp_FvMR
%   handles.hFig_CustExp_FvL

handles = guidata(hMain);
%% Calc ExpData averages
if nargin<3
    StepsToCalc = 1:numel(ExpData);
end
kBT=1.380648813e-23*(273.15+handles.Temperature)*10^6;
for n=reshape(StepsToCalc,1,[])
    %% mean dZ
    if isfield(ExpData(n).StepData,'dZ')
        ExpData(n).mean_dZ = nanmean([ExpData(n).StepData.dZ],2);
        ExpData(n).std_dZ =  nanstd([ExpData(n).StepData.dZ],0,2);
    end
    %% L
    if isfield(ExpData(n).StepData,'X')&&isfield(ExpData(n).StepData,'Y')&&isfield(ExpData(n).StepData,'dZ')
        ExpData(n).meanX = nanmean([ExpData(n).StepData.X],2);
        ExpData(n).stdX =  nanstd([ExpData(n).StepData.X],0,2);
        
        ExpData(n).meanY = nanmean([ExpData(n).StepData.Y],2);
        ExpData(n).stdY =  nanstd([ExpData(n).StepData.Y],0,2);

        X = bsxfun(@minus,[ExpData(n).StepData.X],ExpData(n).meanX)*handles.PxScale;
        Y = bsxfun(@minus,[ExpData(n).StepData.Y],ExpData(n).meanY)*handles.PxScale;
        L = sqrt(X.^2 + Y.^2 + [ExpData(n).StepData.dZ].^2);
        ExpData(n).meanL = nanmean(L,2);
        ExpData(n).stdL = nanstd(L,0,2);
        
        ExpData(n).Fx = kBT*ExpData(n).meanL./(ExpData(n).stdX*handles.PxScale).^2*10^12;
        ExpData(n).FxErr = kBT*ExpData(n).stdL./(ExpData(n).stdX*handles.PxScale).^2*10^12;
    end
end

MeasTrk = find(strcmpi({handles.track_params.Type},'Measurement'));
MeasNames = cell_sprintf('Trk %d',MeasTrk);
nMeas = numel(MeasTrk);
%RefTrk = find(strcmpi({handles.track_params.Type},'Reference'));

%% Data Points
MH = [ExpData.MagnetHeight]';
MR = [ExpData.MagnetRotation]';
mL = [ExpData.meanL]';
sL = [ExpData.stdL]';
Fx = [ExpData.Fx]';
FxErr = [ExpData.FxErr]';

%% Length v Magnet Height
if ishghandle(handles.hFig_CustExp_LvMH)
    if isappdata(handles.hFig_CustExp_LvMH,'hEb')
        hEb = getappdata(handles.hFig_CustExp_LvMH,'hEb');
    else
        hEb = [];
    end
    if isempty(hEb) || any(~isvalid(hEb)) || numel(hEb)~=nMeas
        clf(handles.hFig_CustExp_LvMH);
        [hEb,hAx,~,~] = errorbar_selectable(...
            repmat(MH,1,nMeas),...
            mL(:,MeasTrk),...
            [],[],...
            sL(:,MeasTrk),sL(:,MeasTrk),MeasNames,handles.hFig_CustExp_LvMH);
            hAx.Title.String = 'Length vs Magnet Height';
            xlabel(hAx,'Magnet Height [mm]');
            ylabel(hAx,'Avg. Tether Length [µm]');
        setappdata(handles.hFig_CustExp_LvMH,'hEb',hEb);
    else
        for n=1:nMeas
            set(hEb(n),...
                'XData',MH,...
                'YData',mL(:,MeasTrk(n)),...
                'YLowerData',sL(:,MeasTrk(n)), 'YUpperData',sL(:,MeasTrk(n)));
        end
    end
end

%% Length v Magnet Rotation
if ishghandle(handles.hFig_CustExp_LvMR)
    if isappdata(handles.hFig_CustExp_LvMR,'hEb')
        hEb = getappdata(handles.hFig_CustExp_LvMR,'hEb');
    else
        hEb = [];
    end
    if isempty(hEb) || any(~isvalid(hEb)) || numel(hEb)~=nMeas
        clf(handles.hFig_CustExp_LvMR);
        [hEb,hAx,~,~] = errorbar_selectable(...
            repmat(MR,1,nMeas),...
            mL(:,MeasTrk),...
            [],[],...
            sL(:,MeasTrk),sL(:,MeasTrk),MeasNames,handles.hFig_CustExp_LvMR);
            hAx.Title.String = 'Length vs Magnet Rotation';
            xlabel(hAx,'Magnet Rotation [turns]');
            ylabel(hAx,'Avg. Tether Length [µm]');
        setappdata(handles.hFig_CustExp_LvMR,'hEb',hEb);
    else
        for n=1:nMeas
            set(hEb(n),...
                'XData',MR,...
                'YData',mL(:,MeasTrk(n)),...
                'YLowerData',sL(:,MeasTrk(n)), 'YUpperData',sL(:,MeasTrk(n)));
        end
    end
end
%% Force v Magnet Height
if ishghandle(handles.hFig_CustExp_FvMH)
    if isappdata(handles.hFig_CustExp_FvMH,'hEb')
        hEb = getappdata(handles.hFig_CustExp_FvMH,'hEb');
    else
        hEb = [];
    end
    if isempty(hEb) || any(~isvalid(hEb)) || numel(hEb)~=nMeas
        clf(handles.hFig_CustExp_FvMH);
        [hEb,hAx,~,~] = errorbar_selectable(...
            repmat(MH,1,nMeas),...
            Fx(:,MeasTrk),...
            [],[],...
            FxErr(:,MeasTrk),FxErr(:,MeasTrk),MeasNames,handles.hFig_CustExp_FvMH);
            hAx.Title.String = 'Forcevs Magnet Height';
            xlabel(hAx,'Magnet Height [mm]');
            ylabel(hAx,'Force [pN]');
        setappdata(handles.hFig_CustExp_FvMH,'hEb',hEb);
    else
        for n=1:nMeas
            set(hEb(n),...
                'XData',MH,...
                'YData',Fx(:,MeasTrk(n)),...
                'YLowerData',FxErr(:,MeasTrk(n)), 'YUpperData',FxErr(:,MeasTrk(n)));
        end
    end
end
%% Force v Length
if ishghandle(handles.hFig_CustExp_FvL)
    if isappdata(handles.hFig_CustExp_FvL,'hEb')
        hEb = getappdata(handles.hFig_CustExp_FvL,'hEb');
    else
        hEb = [];
    end
    if isempty(hEb) || any(~isvalid(hEb)) || numel(hEb)~=nMeas
        clf(handles.hFig_CustExp_FvL);
        [hEb,hAx,~,~] = ForceExtension_selectable(...
            mL(:,MeasTrk),...
            Fx(:,MeasTrk),...
            sL(:,MeasTrk),...
            FxErr(:,MeasTrk),...
            MeasNames,handles.hFig_CustExp_FvL);

            hAx.Title.String = 'Force vs Length';
            xlabel(hAx,'Tether Length [µm]');
            ylabel(hAx,'Force [pN]');
        setappdata(handles.hFig_CustExp_FvL,'hEb',hEb);
    else
        for n=1:nMeas
            set(hEb(n),...
                'XData',mL(:,MeasTrk(n)),...
                'YData',Fx(:,MeasTrk(n)),...
                'XLowerData',sL(:,MeasTrk(n)), 'XUpperData',sL(:,MeasTrk(n)),...
                'YLowerData',FxErr(:,MeasTrk(n)), 'YUpperData',FxErr(:,MeasTrk(n)));
        end
    end
end
%% Scatter Plot Histogram Contours