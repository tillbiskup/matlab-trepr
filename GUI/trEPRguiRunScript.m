function [status,warnings] = trEPRguiRunScript(script,varargin)
% TREPRGUIRUNSCRIPT Helper function executing scripts on the command line
% of the trEPR GUI.
%
% Usage:
%   trEPRguiRunScript(script)
%   [status,warnings] = trEPRguiRunScript(script)
%
%   script  - string
%             Name of the script to be executed
%
%   status  - scalar
%             Return value for the exit status:
%              0: script successfully executed
%             -1: no trEPRgui window found
%             -2: trEPRgui window appdata don't contain necessary fields
%             -3: some other problems
%
%  warnings - cell array
%             Contains warnings/error messages if any, otherwise empty

% (c) 2013-14, Till Biskup
% 2014-06-02

status = 0;
warnings = cell(0);

% If called with no input arguments, just display help and exit
if (nargin==0)
    help trEPRguiRunScript;
    return;
end

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('script', @(x)ischar(x));
%p.addOptional('command','',@(x)ischar(x));
p.parse(script,varargin{:});

% Is there currently a trEPRgui object?
mainWindow = trEPRguiGetWindowHandle();
if (isempty(mainWindow))
    warnings{end+1} = 'No trEPRgui window could be found.';
    status = -1;
    return;
end

if isempty(script)
    script = getFilename;
end

if isempty(script) || ~exist(script,'file')
    warnings{end+1} = 'Filename empty or file does not exist.';
    status = -3;
    return;
end

% Read script file
commands = textFileRead(script);

for k=1:length(commands)
    if ~strncmp(commands{k},'%',1)
        [cmdStat,cmdWarn] = trEPRguiCommand(commands{k});
        if cmdStat
            warnings{end+1} = cmdWarn; %#ok<AGROW>
        end
    end
end

end


function fileName = getFilename

mainWindow = trEPRguiGetWindowHandle();
ad = getappdata(mainWindow);

startDir = ad.control.dirs.lastLoad;
[fileName,pathName,~] = uigetfile(...
    '*.*',...
    'Get filename of script to execute on the trEPR GUI command line (CMD)',...
    'MultiSelect','off',...
    startDir...
    );
if fileName == 0
    fileName = '';
    return;
end
fileName = fullfile(pathName,fileName);
% Set path in GUI
if pathName ~= 0
    ad.control.dirs.lastLoad = pathName;
    setappdata(mainWindow,'control',ad.control);
end

end