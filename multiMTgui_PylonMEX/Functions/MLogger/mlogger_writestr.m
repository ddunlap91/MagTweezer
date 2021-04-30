function outcell = mlogger_writestr(fileID,str)
%Write string to open log file
% Input:
%   fileID: ID to open log file (the return argument of mlogger_openfile)
%   str: char array or cell string specifying message to write
%       Note: char arrays are broken at new line characters and written as
%             separate lines in the log file.
%             Cell strings are treated as separate lines, indexed as a
%             single column vector (even if they are a matrix)
% Example File:
% # Date & Time           | Message Text
% #========================================================================
% 2016-07-25 09:25:30.015 | Message1 Line 1
%                         | Message1 Line 2
% #------------------------------------------------------------------------
% 2016-07-25 09:25:32.237 | Message2 Line 1
%                         | Message2 Line 2
%                         | Message2 Line 3
% #------------------------------------------------------------------------

if isempty(str)
    return;
end
outcell = {};
dstr = datestr(now,'yyyy-mm-dd HH:MM:SS.FFF');
if iscell(str)
    %write first line
    [token,remain] = strtok(str{1},char(10));
    fprintf(fileID,'%s | %s\n',dstr,token);
    outcell = [outcell;sprintf('%s | %s',dstr,token)];
    outcell = [outcell;write_str_nodate(fileID,remain)];
    for n = 2:numel(str)
        outcell = [outcell;write_str_nodate(fileID,str{n})];
    end
else
    [token,remain] = strtok(str,char(10));
    fprintf(fileID,'%s | %s\n',dstr,token);
    outcell = [outcell;sprintf('%s | %s',dstr,token)];
    outcell = [outcell;write_str_nodate(fileID,remain)];
end
%write last line (#----------...)
%fprintf(fileID,'#%s\n',repmat('-',1,75));
str = ['-----------------------|',repmat('-',1,51)];
fprintf(fileID,'#%s\n',str);
outcell = [outcell;sprintf('#%s',str)];


function outcell = write_str_nodate(fileID,str)
%subfunction handles only char array
token = str;
outcell = {};
while ~isempty(token)
    [token,remain] = strtok(token,char(10)); %break at newline
    fprintf(fileID,'                        | %s\n',token);
    outcell = [outcell;sprintf('                        | %s',token)];
    token = remain;
end

    
