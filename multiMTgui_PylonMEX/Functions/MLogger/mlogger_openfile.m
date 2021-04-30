function fid = mlogger_openfile(filename)
% Opens file used for mlogger.
% If file does not exist it creates it and writes a header to the file.
% Otherwise, the logger opens the file with 'a' permissions
%
% Write to the file using mlogger_writestr()
%
% When done, simply close the file with fclose(fid)

if ~ischar(filename)
    error('Expected input must be a character string specifying a file path.');
end

new_file = true;
if exist(filename,'file') %open with a
    [fid,err] = fopen(filename,'a');
    if ftell(fid)>0 %File was not empty. Don't write header
        new_file = false;
    end
else
    pth = fileparts(filename);
    if ~exist(pth,'dir')
        [status,msg] = mkdir(pth);
        if status==0
            error('could not create directory: %s. Error: %s',pth,msg);
        end
    end
    [fid,err] = fopen(filename,'w');
end

if fid==-1
    error('Could not open file. Error: %s',err);
end

if new_file %write a header to the file
    fprintf(fid,'%s\n',...
        '# MLogger File --------------------------------------------------');
    fprintf(fid,'%s\n',...
        ['# Created: ',datestr(now,'yyyy-mm-dd HH:MM:SS.FFF')]);
    fprintf(fid,'#\n');
    fprintf(fid,'%s\n',...
        '# Date & Time           | Message Text');
        %yyyy-mm-dd HH:MM:SS.FFF |
    fprintf(fid,'#%s\n',repmat('=',1,75));
end
