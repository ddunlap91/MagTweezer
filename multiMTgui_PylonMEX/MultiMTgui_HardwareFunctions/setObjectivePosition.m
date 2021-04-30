function status = setObjectivePosition(hMain,pos)
%sets the position of the piezo
% Inputs:
%   hMain = handle to main gui figure (hFigure_Main)
%   pos = a double specifying absolute piezo position (in µm)
%       If pos is outside the limits of the piezo it will default to the
%       closest limit.
% Note: This function will update the guidata

%get gui data
handles = guidata(hMain);

pos = min(pos,handles.obj_zlim(2));
pos = max(pos,handles.obj_zlim(1));

%try to set the position, note we're reversing the direction of the piezo
%axes here
handles.PiezoObj.Axis.setPosition(pos);


%update the objective position variable
handles.obj_zpos = pos;

if handles.controls_open
    set(handles.hEdt_ObjectiveHeight,'string',num2str(handles.obj_zpos,'%0.02f'));
    set(handles.hSld_ObjectiveHeight,'value',pos);
end

%update guidata
guidata(hMain,handles);
end