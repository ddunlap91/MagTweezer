function [sz,bits] = fio_size(precision,encoding)
%Returns the size (in number of bytes) the type specified by precision will
%be when written/read by MATLAB's fwrite(...,precision) and fread(...,precision)

if nargin<2
    if strcmpi(precision,'char')
        file = ['tmp.',num2str(now)];
        fid=fopen(file,'w');
        [~,~,~,encoding] = fopen(fid);
        fclose(fid);
        delete(file);
    else
        encoding = '';
    end
end

if strncmpi('ubit',precision,4)
    bits = sscanf(precision,'ubit%d');
    sz = bits/8;
    return;
end
if strncmpi('bit',precision,3)
    bits = sscanf(precision,'bit%d');
    sz = bits/8;
    return;
end
switch(lower(precision))
    case 'uint'
        sz = 4;
    case 'uint8'
        sz = 1;
    case 'uint16'
        sz = 2;
    case 'uint32'
        sz = 4;
    case 'uint64'
        sz = 8;
    case 'uchar'
        sz = 1;
    case 'unsigned char'
        sz = 1;
    case 'ushort'
        sz = 2;
    case 'ulong'
        sz = 4;
    case 'int'
        sz = 4;
    case 'int8'
        sz = 1;
    case 'int16'
        sz = 2;
    case 'int32'
        sz = 4;
    case 'int64'
        sz = 8;
    case 'integer*1'
        sz = 1;
    case 'integer*2'
        sz = 2;
    case 'integer*4'
        sz = 4';
    case 'integer*8'
        sz = 8;
    case 'schar'
        sz = 1;
    case 'signed char'
        sz = 1;
    case 'short'
        sz = 2;
    case 'long'
        sz = 4;
    case 'single'
        sz = 4;
    case 'double'
        sz = 8;
    case 'float'
        sz = 4;
    case 'float32'
        sz = 4;
    case 'float64'
        sz = 8;
    case 'real*4'
        sz = 4;
    case 'real*8'
        sz = 8;
    case 'char*1'
        sz = 1;
    case 'char'
        if strncmpi('windows',encoding,7)
            sz = NaN;
        elseif strncmpi('UTF',encoding,3)
            sz = NaN;
        elseif strcmpi('Shift_JIS',encoding)
            sz = NaN;
        else
        sz = numel(unicode2native('1',encoding));
        end
end

bits = sz*8;
        