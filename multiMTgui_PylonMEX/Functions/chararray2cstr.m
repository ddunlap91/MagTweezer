function c_str = chararray2cstr(s)
%convert string array to a c/c++ style char array with lines separated by
%the newline character;
%
% Input:
%   s:  char array, where each row represents a different line
%       trailing white space is removed
%       or cell array, where each cell becomes a new line
%
% Output:
%   c_str = c style array where lines are separeted by newline character

c_str = [];
if ischar(s)
    s = cellstr(s);
end
c_str = s{1};
for n=2:numel(s)
    c_str = [c_str,sprintf('%s\n',s{n})];
end
