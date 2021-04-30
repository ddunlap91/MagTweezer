function MultiMTgui_editCCTrackTable(hTable,event,hMain)

handles = guidata(hMain);

trkID = event.Indices(1);
col = event.Indices(2);
edit_val = hTable.Data(trkID,col);
switch col
    case 1 %Type
        handles.track_params(trkID).Type = edit_val{1};
    case 2 %Reference
        handles.track_params(trkID).ZRef = str2double(edit_val{1});
    case 3 %save abs z
        handles.FE_SaveAbsZ(trkID) = edit_val{1}; %just use same SaveAbsZ for both FE and CC
    otherwise
        error('Something went wrong editing the table');
end

guidata(hMain,handles);
MultiMT_updateTrackParameterTable(hMain);