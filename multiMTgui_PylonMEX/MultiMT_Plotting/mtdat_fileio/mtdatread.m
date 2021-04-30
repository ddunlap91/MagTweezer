function [header,data] = mtdatread(filename,varargin)
%Load data from mtdat file.
% Inputs:
%   filename: name of file to read
% Optional Parameters:
%   'HeaderOnly', true/false (default=fase)
%       Load only the the data header. If second output (data) is not
%       specified, HeaderOnly defaults to true.
%
% Output:
%   header = struct containing data read from YAML header string
%   data = struct array for containing binary data. Organization of data is
%          interpreted based on the "Record" struct included in the YAML
%          header.
%==========================================================================
% Copyright 2016 Daniel T. Kovari, Emory University
% All rights reserved.

%% Version History
% 2016-08-11: Daniel Kovari
%   Added option to only read data header.

%% parse data
p = inputParser;
p.CaseSensitive = false;

addParameter(p,'HeaderOnly',false',@isscalar);

parse(p,varargin{:});

if nargout<2
    warning('No output variable for data. Only reading header');
    p.Results.HeaderOnly = true;
end

if nargin<1
    [filename,pathname] = uigetfile('*.*','Select MTDat File');
    if filename==0
        header = [];
        data = [];
        return;
    end
    filename = fullfile(pathname,filename);
end

%% Check file
FileInfo = dir(filename);
if isempty(FileInfo)
    error('Could not find file:%s',filename);
end
%% Open File
fid = fopen(filename,'r');
if fid==-1
    error('Could not open: %s',filename);
end
%% Look for YAML start
while true
    if feof(fid)
        fclose(fid);
        error('End of File reached before finding "#!!#YAML_START". Are you sure this is a mtdat file?');
    end
    tline = fgetl(fid);
    if strcmpi('#!!#YAML_START',tline)
        break
    end
end
%% copy data to buffer and look for YAML end
yaml_str = [];
read_data = true;
while true
    if feof(fid)
        if ~p.Results.HeaderOnly
            warning('Reached end of file before finding "#!!#YAML_END". No Data will be read');
        end
        read_data = false;
        break;
    end
    tline = fgets(fid);
    if strncmpi('#!!#YAML_END',tline,12)
        break;
    end
    yaml_str = [yaml_str,tline];
end
%% Convert YAML to struct
header = YAML.load(yaml_str);
if p.Results.HeaderOnly
    data = [];
    return;
end

if ~isfield(header,'Record')
    fclose(fid);
    error('Did not parse "Record" field from YAML data. File cannot be read.');
end
data = [];
if ~read_data
    fclose(fid);
    return;
end
%% Create empty data structure
data = struct('tmp',{});
for rec = header.Record
    [data(:).(rec.parameter)] = deal();
end
data = rmfield(data,'tmp');

%% Read binary data
%create waitbar
hWB = waitbar(0,'Reading Binary Data',...
              'CreateCancelBtn',...
              'setappdata(gcbf,''canceling'',1)');
setappdata(hWB,'canceling',0);
f_start = ftell(fid);
rec_count = 1;

% Estimate Data length
rec_bytes = 0;
for rec = header.Record
    sz = fio_size(rec.format,rec.encoding);
    if isnan(sz) %data type size is nan (prob a unicode/windows character)
        sz=4; %assume character is max unicode size (4bytes)
    end
    rec_bytes = rec_bytes + sz*prod(rec.size);
end
data_bytes = FileInfo.bytes-f_start;
n_rec = ceil(data_bytes/rec_bytes);

if n_rec<1
    warning('No records were found in file');
else
    %pre-allocate data -- not sure if this is actually making things faster
    data(n_rec).(header.Record(1).parameter) = [];
    %disp(size(data));

    while fseek(fid,1,'cof')==0%try to advance to next byte to check for eof
        fseek(fid,-1,'cof'); %rewind 1 byte
        %deal with waitbar
        if getappdata(hWB,'canceling')
            warning('Canceled before reaching end of file');
            break;
        end
        waitbar((ftell(fid)-f_start)/(data_bytes),hWB);
        %Read each element of the record
        for rec = header.Record
           [data(rec_count).(rec.parameter), nRead] = fread(fid,rec.size,rec.format,rec.machinefmt);
           if nRead ~= prod(rec.size)
               warning('Could not read complete data for Record(%d).%s. File could be corrupted.',rec_count,rec.parameter);
               break
           end
        end
        rec_count = rec_count+1; 
    end
    %erase record elements that weren't read
    data(rec_count:end) = [];
end
delete(hWB);
fclose(fid);