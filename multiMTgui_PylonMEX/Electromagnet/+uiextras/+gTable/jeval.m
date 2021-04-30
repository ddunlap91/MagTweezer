function jeval(fn_str,varargin)
%disp('in jeval');
fh = str2func(fn_str);
fh(varargin{:});