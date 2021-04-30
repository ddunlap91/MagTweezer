function parts = pathparts(dirpath)
%Returns the parts of a file path as a cell array
% e.g. 'C:\dir1\dir2\file.tmp'->{'C:','dir1','dir2','file.tmp'}

parts={};

while ~isempty(dirpath)
    [t,dirpath]=strtok(dirpath,filesep);
    parts = cat(1,parts,t);
end