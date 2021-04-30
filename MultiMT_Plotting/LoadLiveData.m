function [header,LiveData,filepath] = LoadLiveData(filepath)

persistent lastdir;
if nargin< 1
    [filename,pathname] = uigetfile(fullfile(lastdir,'*.mtdat'),'Choose Experiment Data File');
    if filename==0
        header = [];
        LiveData = [];
        return;
    end
    lastdir = pathname;
    filepath = fullfile(pathname,filename);
end

%% load data
opath = addpath(fullfile(fileparts(mfilename('fullpath')),'mtdat_fileio'));
[header,LiveData] = mtdatread(filepath);


%% Return Output
if nargout<1
    putvar(header,LiveData);
    clear header;
    clear LiveData;
end

path(opath);