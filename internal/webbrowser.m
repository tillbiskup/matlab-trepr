function webbrowser(varargin)
% WEBBROWSER Launch system webbrowser.
%
% Usage
%   webbrowser
%   webbrowser(url)
%
%   url - string
%         URL of webpage to load

% Copyright (c) 2014, Till Biskup
% 2014-07-10

% Parse input arguments using the inputParser functionality
p = inputParser;            % Create an instance of the inputParser class.
p.FunctionName = mfilename; % include function name in error messages
p.KeepUnmatched = true;     % Enable errors on unmatched arguments
p.StructExpand = true;      % Enable passing arguments in a structure

p.addOptional('url','',@(x)ischar(x));
p.parse(varargin{:});

url = p.Results.url;

if any(strfind(platform,'Windows'))
    dos(['start ' url]);
else
    if any(strfind(platform,'Linux'))
        oldldlibrarypath = getenv('LD_LIBRARY_PATH');
        setenv('LD_LIBRARY_PATH','');
    end
    webstat = web(url,'-browser');
    switch webstat
        case 1
            trEPRmsg('Could not find system browser','warning');
        case 2
            trEPRmsg('Could not launch system browser','warning');
        otherwise
    end
    if any(strfind(platform,'Linux')) && exist('oldlibrarypath','var')
        setenv('LD_LIBRARY_PATH',oldldlibrarypath);
    end
end

end
