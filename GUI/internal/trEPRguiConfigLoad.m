function conf = trEPRguiConfigLoad(guiname,varargin)
% TREPRGUICONFIGLOAD Read configuration parameters for a given GUI window.
%
% The idea is to minimise the files that contain the actual path to the
% config files, such as to make life easier if this changes.
%
% Usage
%   conf = trEPRguiConfigLoad(guiname)
%   conf = trEPRguiConfigLoad(guiname,module)
%
%   guiname - string
%             Valid mfilename of a GUI
%   module  - string (OPTIONAL)
%             Name of a module
%
%   conf    - struct
%             Contains all configuration parameters of the given GUI
%             Empty if no configuration could be read.
%
% See also GUICONFIGWRITE, GUICONFIGAPPLY, trEPRINIFILEREAD, trEPRINIFILEWRITE

% (c) 2011-12, Till Biskup
% 2012-06-19

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('guiname', @(x)ischar(x));
p.addOptional('module','',@(x)ischar(x));
p.parse(guiname,varargin{:});

try
    % Define config file
    if isempty(p.Results.module)
        confFile = fullfile(trEPRinfo('dir'),...
            'GUI','private','conf',[guiname '.ini']);
    else
        confFile = fullfile(trEPRinfo('dir'),'modules',...
            p.Results.module,'GUI','private','conf',[guiname '.ini']);
    end
    % If that file does not exist, try to create it from the
    % distributed config file sample
    if ~exist(confFile,'file')
        fprintf('Config file\n  %s\nseems not to exist. %s\n',...
            confFile,'Trying to create it from distributed file.');
        if isempty(p.Results.module)
            trEPRconf('create','overwrite',true,'file',confFile);
        else
            trEPRconf('create','overwrite',true,'file',confFile,...
                'module',p.Results.module);
        end
    end
    
    % Try to load and append configuration
    conf = trEPRiniFileRead(confFile,'typeConversion',true);
    if isempty(conf)
        return;
    end

catch exception
    % If this happens, something probably more serious went wrong...
    throw(exception);
end

end
