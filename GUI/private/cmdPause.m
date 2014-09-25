function [status,warnings] = cmdPause(handle,opt,varargin)
% cmdPause Command line command of the trEPR GUI.
%
% Usage:
%   cmdPause(handle,opt)
%   [status,warnings] = cmdPause(handle,opt)
%
%   handle  - handle
%             Handle of the window the command should be performed for
%
%   opt     - cell array
%             Options of the command
%
%   status  - scalar
%             Return value for the exit status:
%              0: command successfully performed
%             -1: no GUI window found
%             -2: missing options
%             -3: some other problems
%
%  warnings - cell array
%             Contains warnings/error messages if any, otherwise empty

% Copyright (c) 2014, Till Biskup
% 2014-09-24

status = 0;
warnings = cell(0);

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('handle', @(x)ishandle(x));
p.addRequired('opt', @(x)iscell(x));
%p.addOptional('opt',cell(0),@(x)iscell(x));
p.parse(handle,opt,varargin{:});
handle = p.Results.handle;
opt = p.Results.opt;

% Get command name from mfilename
cmd = mfilename;
cmd = lower(cmd(4:end));

% Is there the GUI requested?
if (isempty(handle))
    warnings{end+1} = 'No GUI window could be found.';
    status = -1;
    return;
end

if isempty(opt)
    warnings{end+1} = sprintf(...
        'Command "%s": Not enough options. Use "help %s" to get some help.',cmd,cmd);
    status = -2;
    return;
end

% Check state of "pause" to restore it afterwards
state = pause('query');
if ~strcmpi(state,'on')
    pause on;
end

% Check option
delayTime = str2double(opt{1});

if isnan(delayTime) || delayTime < 0
    warnings{end+1} = sprintf(...
        'Command "%s": Option "%s" not understood.',cmd,opt{1});
    status = -3;
    return;
end

pause(delayTime);

% Restore "pause" state to restore it if necessary
if ~strcmpi(state,'on');
    pause off;
end

end
