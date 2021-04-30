function MultiMT_CustomExperimentShowPlots(hCustExp)

cehandles = guidata(hCustExp);
handles = guidata(cehandles.hMainWindow);

for n=reshape(cehandles.hLst_DataPlots.Value,1,[])
    switch(cehandles.hLst_DataPlots.String{n})
        case 'Length v. Mag. Height'
            if isempty(handles.hFig_CustExp_LvMH) || ~ishghandle(handles.hFig_CustExp_LvMH)
                handles.hFig_CustExp_LvMH = figure();
                hAx = axes(handles.hFig_CustExp_LvMH);
                title(hAx,'Length v. Mag. Height');
            end
            figure(handles.hFig_CustExp_LvMH);
        case 'Length v. Mag. Rotation'
            if isempty(handles.hFig_CustExp_LvMR) || ~ishghandle(handles.hFig_CustExp_LvMR)
                handles.hFig_CustExp_LvMR = figure();
                hAx = axes(handles.hFig_CustExp_LvMR );
                title(hAx,'Length v. Mag. Rotation');
            end
            figure(handles.hFig_CustExp_LvMR);
        case 'Force v. Mag. Height'
            if isempty(handles.hFig_CustExp_FvMH) || ~ishghandle(handles.hFig_CustExp_FvMH)
                handles.hFig_CustExp_FvMH = figure();
                hAx = axes(handles.hFig_CustExp_FvMH );
                title(hAx,'Force v. Mag. Height');
            end
            figure(handles.hFig_CustExp_FvMH);
        case 'Force v. Mag. Rotation'
            if isempty(handles.hFig_CustExp_FvMR) || ~ishghandle(handles.hFig_CustExp_FvMR)
                handles.hFig_CustExp_FvMR = figure();
                hAx = axes(handles.hFig_CustExp_FvMR);
                title(hAx,'Force v. Mag. Rotation');
            end
            figure(handles.hFig_CustExp_FvMH);
        case 'Force v. Length'
            if isempty(handles.hFig_CustExp_FvL) || ~ishghandle(handles.hFig_CustExp_FvL)
                handles.hFig_CustExp_FvL = figure();
                hAx = axes(handles.hFig_CustExp_FvL);
                title(hAx,'Force v. Length');
            end
            figure(handles.hFig_CustExp_FvL);
    end
end
%handles.CustomExperimentData = MultiMT_updateCustomExperimentPlots(cehandles.hMainWindow, handles.CustomExperimentData);
guidata(cehandles.hMainWindow,handles);
MultiMT_updateCustomExperimentPlots(cehandles.hMainWindow, handles.CustomExperimentData,[]);