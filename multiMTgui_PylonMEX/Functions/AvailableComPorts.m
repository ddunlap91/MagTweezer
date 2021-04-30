function ports = AvailableComPorts()
%list avialable com ports (Windows only)

if ~ispc
    error('AvailableComPorts is only for windows');
end

try
    s=serial('IMPOSSIBLE_NAME_ON_PORT');fopen(s); 
catch
    lErrMsg = lasterr;
end

ports = regexp(lErrMsg,'COM\d+','match');
