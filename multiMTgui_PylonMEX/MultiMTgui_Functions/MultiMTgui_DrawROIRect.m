function MultiMTgui_DrawROIRect(hMain)
%Draw ROI rect if needed
%Saves guidata, so call handles=guidata(hMain) after calling if you need to
%use current handles values
handles = guidata(hMain);

if ~isprop(handles.MMcam,'HasROI') || ~handles.MMcam.HasROI
    return
end

if ishghandle(handles.MMcam.haxImageAxes)
    if handles.MMcam.UsingROI
        try
            delete(handles.ROI_hrect);
        catch
        end
        handles.ROI_hrect = ...
            imrect2('Parent',handles.MMcam.haxImageAxes,...
                    'HandleVisibility','callback',...
                    'LimMode','manual',...
                    'Color','r',...
                    'LineStyle',':',...
                    'LineWidth',1.5,...
                    'MarkerSize',6,...
                    'Position',handles.MMcam.ROI,...
                    'ResizeFcn',{@MultiMTgui_ROIRectResize,hMain});
        handles.ROI_lastpos = handles.MMcam.ROI;
        guidata(hMain,handles);
    end
end
                    
        