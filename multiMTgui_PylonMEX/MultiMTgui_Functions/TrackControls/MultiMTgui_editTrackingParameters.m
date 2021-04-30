function MultiMTgui_editTrackingParameters(hTable,event,hMain)
% setInFunctionFlag(hMain,true);
stopCamera(hMain);
handles = guidata(hMain);
%disp('here');
trkID = event.Indices(1);
col = event.Indices(2);
edit_val = hTable.Data(trkID,col);
%disp('before switch');
switch hTable.ColumnName{col}
    case 'Color'
        handles.track_params(trkID).Color = edit_val{1};
        guidata(hMain,handles);
        MultiMTgui_DrawTrackhrect(hMain,trkID);
        return;
    case 'Reference'
        handles.track_params(trkID).ZRef = str2double(edit_val{1});
    case 'Type'
        handles.track_params(trkID).Type = edit_val{1};
end
%disp('before guidata');
guidata(hMain,handles);
%disp('after guidata');
MultiMT_updateTiltControls(hMain);
MultiMT_updateTrackParameterTable(hMain);
% setInFunctionFlag(hMain,false);
startCamera(hMain);