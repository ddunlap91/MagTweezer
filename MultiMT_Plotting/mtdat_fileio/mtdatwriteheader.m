function [fid,Record] = mtdatwriteheader(file,header,Record)
% Write Header to mtdat file
% Inputs:
%   file: Name (and path) of output file.
%   header:[struct] Configuration data to be written to file
%   record:[struct] Structure specifying the layout of the binary data in
%                   the file. Optionally this can be included in config.
%       Must contain the following fields
%           Record(:).--->
%               .parameter = 'ParamNameStr';
%               .format = 'TypeStr'; (e.g. 'double', see fwrite help)
%               .size = [#,#,#...]; (size of data)
%       May optionally include
%               .formatsz = ##; (number of bytes for specified type)
%               .machinefmt = 'FMT-STR'; (endian format used by fwrite)
%               .encoding = 'ENC-STR'; (encoding format for char type)
%       If the optional fields are not set then this function will
%       determinne them based on the machine defaults.
%
% Output:
%   fid = File ID for the open file. After calling this function the
%   file-pointer should be located after the "#!!#YAML_END\n" tag that
%   specifies the end of the configuration data
%
% Note: Files can be read using mtdatread(...);
%==========================================================================
% Copyright 2016, Daniel T Kovari, Emory University
%  All rights reserved.
%==========================================================================
%% Change Log:
%   2016-07-24: DTK - File Creation.

if nargin<3
    if isfield(header,'Record')
        Record = header.Record;
    else
        error('Record not specified, nor included in config.');
    end
end
%% Format Record Structure
if ~isfield(Record,'parameter')
    error('Record must contain "parameter" field');
end
if ~isfield(Record,'format')
    error('Record must contain "format" field');
end
if ~isfield(Record,'size')
    error('Record must contain "parameter" field');
end

if isfield(Record,'machinefmt')
    machinefmt = Record(1).machinefmt;
else
    machinefmt = 'n';
end
if isfield(Record,'encoding')
    encoding = Record(1).encoding;
else
    encoding = '';
end
%% Open File
fid = fopen(file,'w',machinefmt,encoding);
if fid==-1
    error('Could not open: %s',file);
end

[~,~,machinefmt,encoding] = fopen(fid);

if ~isfield(Record,'machinefmt')
    [Record(:).machinefmt] = deal(machinefmt);
end
if ~isfield(Record,'encoding')
    [Record(:).encoding] = deal(encoding);
end
if ~isfield(Record,'formatsz')
    for rec = Record
        rec.formatsz = fio_size(rec.format,rec.encoding);
    end
end

header.Record = Record;

%% Create YAML String
yaml_str = YAML.dump(header);

%% Write Header
fprintf(fid,'%s\n','#!!#YAML_START');
fprintf(fid,'%s',yaml_str);
fprintf(fid,'%s\n','#!!#YAML_END');

