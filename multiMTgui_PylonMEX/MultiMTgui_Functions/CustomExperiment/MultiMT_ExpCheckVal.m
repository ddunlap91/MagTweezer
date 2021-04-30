function [bool,val] =  MultiMT_ExpCheckVal(val,col_name,hMain)
handles = guidata(hMain);
bool = true;
if isnan(val)
    bool = false;
    return
end
switch(col_name)
    case 'Duration'
        if val<0
            bool = false;
        end
    case 'FrameCount'
        if val<0
            bool = false;
        end
        val = round(val);
    case 'ObjectivePosition'
        if val>handles.obj_zlim(2) || val<handles.obj_zlim(1)
            bool = false;
        end
        val = round(val*100)/100;
    case 'MagentHeight'
        if val>handles.mag_zlim(2) || val<handles.mag_zlim(1)
            bool = false;
        end
        val = round(val*100)/100;
    case 'MagnetRotation'
        %any value works
end