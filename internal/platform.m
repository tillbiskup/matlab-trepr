function p = platform
%PLATFORM display general platform dependend information.
%   p = platform returns string p denoting the type of computer
%   on which MATLAB is executing.
%
%   See also: COMPUTER

% Copyright (c) 2007-12, Till Biskup
% 2012-06-26

% find platform OS

if exist('matlabroot','builtin')
    if ispc
        p = [system_dependent('getos'),' ',system_dependent('getwinsys')];
    elseif ( strfind(computer, 'MAC') == 1 )
        [fail, input] = unix('sw_vers');
        
        if ~fail
            p = strrep(input, 'ProductName:', '');
            p = strrep(p, sprintf('\t'), '');
            p = strrep(p, sprintf('\n'), ' ');
            p = strrep(p, 'ProductVersion:', ' Version: ');
            p = strrep(p, 'BuildVersion:', 'Build: ');
        else
            p = system_dependent('getos');
        end
    else
        [fail, input] = unix('uname -srmo');
        if ~fail
            p = input;
        else
            p = system_dependent('getos');
        end
    end
else
    if ispc
        p = computer();
    elseif strfind(computer,'apple')
        [fail, input] = unix('sw_vers');
        if ~fail
            p = strrep(input, 'ProductName:', '');
            p = strrep(p, sprintf('\t'), '');
            p = strrep(p, sprintf('\n'), ' ');
            p = strrep(p, 'ProductVersion:', ' Version: ');
            p = strrep(p, 'BuildVersion:', 'Build: ');
        else
            p = computer();
        end
    else
        [fail, input] = unix('uname -srmo');
        if ~fail
            p = input;
        else
            p = computer();
        end
    end
end
% Make sure there is no additional CR/LF
p = strtrim(p);
