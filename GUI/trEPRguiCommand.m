function [status,warnings] = trEPRguiCommand(command,varargin)
% TREPRGUICOMMAND Helper function dealing with the command line of the
% trEPR GUI.
%
% Usage:
%   trEPRguiCommand(command)
%   [status,warnings] = trEPRguiCommand(command)
%
%   command - string
%             Command to be executed
%
%   status  - scalar
%             Return value for the exit status:
%              0: command successfully performed
%             -1: no trEPRgui window found
%             -2: trEPRgui window appdata don't contain necessary fields
%             -3: some other problems
%
%  warnings - cell array
%             Contains warnings/error messages if any, otherwise empty

% (c) 2013, Till Biskup
% 2013-02-05

status = 0;
warnings = cell(0);

% If called with no input arguments, just display help and exit
if (nargin==0)
    help trEPRguiCommand;
    return;
end

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('command', @(x)ischar(x));
%p.addOptional('command','',@(x)ischar(x));
p.parse(command,varargin{:});

% Is there currently a trEPRgui object?
mainWindow = trEPRguiGetWindowHandle();
if (isempty(mainWindow))
    warnings{end+1} = 'No trEPRgui window could be found.';
    status = -1;
    return;
end

% Get appdata from mainwindow
ad = getappdata(mainWindow);
% Get handles from main GUI
gh = guidata(mainWindow);

% For future use: parse command, split it at spaces, use first part as
% command, all other parts as options
input = regexp(command,' ','split');
cmd = input{1};
if (length(input) > 1)
    opt = input(2:end);
    % Remove empty opts
    opt = opt(~cellfun('isempty',opt));
    [cmdParserStatus,cmdParserWarnings] = trEPRguiCmdParser(cmd,opt);
else
    [cmdParserStatus,cmdParserWarnings] = trEPRguiCmdParser(cmd);
end

if cmdParserStatus
    warnings = [warnings cmdParserWarnings];
    status = -3;
end

end