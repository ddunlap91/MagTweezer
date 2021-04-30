function MulitMTgui_UseROI_Callback(hPanel,hChk)

phandles = guidata(hPanel);
hMain = phandles.hMainWindow;
handles = guidata(hMain);

if isprop(handles.MMcam,'HasROI')&&handles.MMcam.HasROI
    if ~hChk.Value
        if handles.MMcam.UsingROI %true->false change
            %save last ROI so user can just re-check box to bring back roi
            handles.ROI_lastpos = handles.MMcam.ROI;
        end
        try
            delete(handles.ROI_hrect);
        catch
        end
        handles.ROI_hrect = [];
        handles.MMcam.ClearROI();
        guidata(hMain,handles);
        return
    end
    if hChk.Value
        if ~isempty(handles.ROI_lastpos)
            handles.MMcam.ROI = handles.ROI_lastpos; %set ROI back to last value used
            MultiMTgui_DrawROIRect(hMain); %draw the ROI if the screen is displayed
            return;
        end
    end
end