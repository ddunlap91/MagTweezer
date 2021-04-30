function setInFunctionFlag(hMain,val)
handles = guidata(hMain);
handles.InUserFunction = logical(val);
guidata(hMain,handles);