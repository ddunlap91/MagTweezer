function pos = getActualObjectivePosition(hMain)
%get the position of the piezo
% Note: This function will update the guidata

%get gui data
handles = guidata(hMain);

%try to get the position, note we're reversing the direction of the piezo
%axes here
pos = handles.PiezoObj.Axis.Position;

handles.obj_zpos = pos;

%pos = min(handles.obj_zlim(2),pos);
%pos = max(handles.obj_zlim(1),pos);

if handles.controls_open
    set(handles.hEdt_ActualObjectiveHeight,'string',num2str(handles.obj_zpos,'%0.03f'));
    %set(handles.hSld_ObjectiveHeight,'value',pos);
end

%update guidata
guidata(hMain,handles);
end