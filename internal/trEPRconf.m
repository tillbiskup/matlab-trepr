function varargout = trEPRconf(action,varargin)
% TREPRCONF Handling configuration of trEPR toolbox
%
% Usage
%   trEPRconf(action)
%   files = trEPRconf('files')
%   trEPRconf('create',...)
%
%   action    - string
%               Action to perform. 
%               Currently one of 'create', 'files'
%
%   files     - cell array
%               Cell array of strings with the full file names (including
%               paths) of the config files.
%
%   You can add parameter-value pairs. For possible parameters see below.
%
% Actions
%
%   create    - Creating trEPR toolbox configuration files from distributed
%               templates.
%
%   files     - Return full file names (including paths) of all recognised
%               config files
%
% Parameters
%
%   overwrite - logical (true/false)
%               Whether or not to overwrite local config file(s)
%
%   file      - string
%               Act only on specified config file
%               The filename here is that of the local config file, not of
%               the distributed config file (i.e., "<basename>.ini", not
%               "<basename>.ini.dist").

% (c) 2011-12, Till Biskup
% 2012-02-01

% If none or the wrong input parameter, display help and exit
if nargin == 0 || isempty(action) || ~ischar(action)
    help trEPRconf;
    return;
end

% Parse input arguments using the inputParser functionality
p = inputParser;            % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true;     % Enable errors on unmatched arguments
p.StructExpand = true;      % Enable passing arguments in a structure
% Add required input argument "action"
p.addRequired('action', @(x)ischar(x));
% Add a few optional parameters, with default values
p.addParamValue('overwrite',logical(false),@islogical);
p.addParamValue('file','',@(x) ischar(x));
% Parse input arguments
p.parse(action,varargin{:});

try
    % Save current directory
    PWD = pwd;
    switch lower(action)
        case 'create'
            % Change to config directory
            confDir = fullfile(trEPRinfo('dir'),'GUI','private','conf');
            if ~exist(confDir,'dir')
                fprintf('%s:\n  %s\n%s\n',...
                    'Serious problem: Config dir',...
                    confDir,...
                    'doesn''t exist.');
                return;
            end
            cd(confDir);
            % Do stuff
            confDistFiles = dir('*.ini.dist');
            if isempty(p.Results.file)
                for k=1:length(confDistFiles)
                    % Check whether ini file exists already, and if not,
                    % create it by copying from the "ini.dist" file.
                    if ~exist(confDistFiles(k).name(1:end-5),'file') ...
                            || p.Results.overwrite
                        conf = trEPRiniFileRead(confDistFiles(k).name,...
                            'typeConversion',true);
                        header = 'Configuration file for trEPR toolbox';
                        trEPRiniFileWrite(confDistFiles(k).name(1:end-5),...
                            conf,'header',header,'overwrite',true);
                    end
                end
            else % If there is a nonempty "file" input argument
                % Check whether corresponding dist file exists and whether
                % overwrite is true - and only then write file.
                if exist([p.Results.file '.dist'],'file') ...
                        && p.Results.overwrite
                    conf = trEPRiniFileRead([p.Results.file '.dist']);
                    header = 'Configuration file for trEPR toolbox';
                    trEPRiniFileWrite(p.Results.file,conf,'header',header,...
                        'overwrite',true);
                end
            end
            % Change directory back to original directory
            cd(PWD);
        case 'files'
            confFiles = dir(...
                fullfile(trEPRinfo('dir'),'GUI','private','conf','*.ini'));
            if isempty(confFiles)
                varargout{1} = cell(0);
                return;
            end
            confFileNames = cell(length(confFiles),1);
            for k=1:length(confFiles)
                confFileNames{k} = fullfile(...
                    trEPRinfo('dir'),'GUI','private','conf',confFiles(k).name);
            end
            varargout{1} = confFileNames;
        case 'check'
            % IDEA: Check all/selected config file(s) for consistency, aka
            % compare fields in distributed and local config file.
            % Return a structure with two fields (that are each a structure
            % or a cell array themselves): 
            % missing - missing fields from distributed in local
            % additional - additional fields in local not in distributed
            fprintf('%s: Not yet implemented action: %s\n',mfilename,action);
        otherwise
            fprintf('%s: Unknown action: %s\n',mfilename,action);
    end
catch exception
    % Be kind: Try to change directory back
    if exist('PWD','var')
        cd(PWD);
    end
    throw(exception);
end
