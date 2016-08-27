function [status,warnings] = trEPRgui_cmd_saveHistory2File(varargin)
% TREPRGUI_CMD_SAVEHISTORY2FILE Writing command history to file
%
% Usage:
%   trEPRgui_cmd_saveHistory2File()
%   [status,warnings] = trEPRgui_cmd_saveHistory2File()
%
%   status  - scalar
%             Return value for the exit status:
%              0: command successfully saved
%             -1: no trEPRgui window found
%             -2: trEPRgui window appdata don't contain necessary fields
%             -3: some other problems
%
%  warnings - cell array
%             Contains warnings/error messages if any, otherwise empty

% Copyright (c) 2013-16, Till Biskup
% 2016-08-27

status = 0;
warnings = cell(0);

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

%p.addRequired('history', @(x)iscell(x));
%p.addOptional('command','',@(x)ischar(x));
p.parse(varargin{:});

% Is there currently a trEPRgui object?
mainWindow = trEPRguiGetWindowHandle();
if (isempty(mainWindow))
    warnings{end+1} = 'No trEPRgui window could be found.';
    status = -1;
    return;
end

% Get appdata from mainwindow
ad = getappdata(mainWindow);

if isempty(ad.control.cmd.history)
    return;
end

if ~isfield(ad.control.cmd,'historyfile')
    warnings{end+1} = 'trEPRgui window appdata miss necessary field.';
    status = -2;
end

% Fallback: If historyfile is not set, use default
if isempty(ad.control.cmd.historyfile)
    ad.control.cmd.historyfile = '~/.trepr/history';
    setappdata(mainWindow,'control',ad.control);
end

% Actual write of file
textFileWrite(trEPRparseDir(ad.control.cmd.historyfile),...
    ad.control.cmd.history);

end
