function folder_name = uigetdir_mk(start_path,dialog_title)
%Open folder selection dialog (see uigetdir)
%Create temporary start_path if it does not exist
% Input:
%   start_path: directory to start uigetdir in
%       If start_path does not exist it will be created. If the user
%       cancels before selecting a file, any new directory created will be
%       deleted.
%   dialog_title: title for dialog
% Output:
%   folder_name: chosen folder, if user hits cancel then folder_name==0
%==========================================================================
%% Copyright 2016 Daniel T. Kovari
% All rights reserved
if nargin<1
    folder_name = uigetdir();
    return;
end

new_dir = {};
if ~isempty(start_path)&&~exist(start_path,'dir');
    orig_dir = pathparts(start_path);
    for n=1:numel(orig_dir)
        if ~exist(fullfile(orig_dir{1:n}),'dir')
            new_dir = [new_dir;fullfile(orig_dir{1:n})];
        end
    end
end
if ~isempty(new_dir)
    mkdir(new_dir{end});
end
if nargin<2
    folder_name = uigetdir(start_path);
else
    folder_name = uigetdir(start_path,dialog_title);
end
    
if all(folder_name==0) %user canceled
    if ~isempty(new_dir) %delete temp directory if needed
        rmdir(new_dir{1},'s');
    end
    return;
end

if ~isempty(new_dir)
    for n=1:numel(new_dir)
        if ~strncmpi(new_dir{n},folder_name,numel(new_dir{n}))
            %user selected a directory that is not a sub-directory of the temp dir
            %delete the temp dir
            rmdir(new_dir{n},'s');
            break
        end
    end
end


function parts = pathparts(dirpath)
%Returns the parts of a file path as a cell array
% e.g. 'C:\dir1\dir2\file.tmp'->{'C:','dir1','dir2','file.tmp'}

parts={};

while ~isempty(dirpath)
    [t,dirpath]=strtok(dirpath,filesep);
    parts = cat(1,parts,t);
end