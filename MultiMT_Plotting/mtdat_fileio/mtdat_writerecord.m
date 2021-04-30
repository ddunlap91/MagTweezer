function mtdat_writerecord(fid,RecordStruct,Record)

for n = 1:numel(RecordStruct)
    if ~isfield(Record,RecordStruct(n).parameter)
        error('Field: %s not found in Record',RecordStruct(n).parameter);
    end
    if any(RecordStruct(n).size ~= size(Record.(RecordStruct(n).parameter)))
        error('Record.(%s) does not match specified size',RecordStruct(n).parameter);
    end
    if isfield(RecordStruct,'machinefmt') && ~isempty(RecordStruct(n).machinefmt)
        fwrite(fid,Record.(RecordStruct(n).parameter),RecordStruct(n).format,RecordStruct(n).machinefmt);
    else
        fwrite(fid,Record.(RecordStruct(n).parameter),RecordStruct(n).format);
    end
end