function mtdatwriteheaderonly(file,header)
% Write Header to mtdat file
% Inputs:
%   file: Name (and path) of output file.
%   header:[struct] Configuration data to be written to file
% Note: Files can be read using mtdatread(...);
%==========================================================================
% Copyright 2016, Daniel T Kovari, Emory University
%  All rights reserved.
%==========================================================================
%% Change Log:
%   2016-08-11: DTK - File Creation.

%% Open File
fid = fopen(file,'w',machinefmt,encoding);
if fid==-1
    error('Could not open: %s',filename);
end

%% Create YAML String
yaml_str = YAML.dump(header);

%% Write Header
fprintf(fid,'%s\n','#!!#YAML_START');
fprintf(fid,'%s',yaml_str);
fprintf(fid,'%s\n','#!!#YAML_END');
%% close file
fclose(fid);