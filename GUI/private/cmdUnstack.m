function [status,warnings] = cmdUnstack(handle,opt,varargin)
% CMDUNSTACK Command line command of the trEPR GUI.
%
% Usage:
%   cmdUnstack(handle,opt)
%   [status,warnings] = cmdUnstack(handle,opt)
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
%             -1: GUI window found
%             -2: missing options
%             -3: some other problems
%
%  warnings - cell array
%             Contains warnings/error messages if any, otherwise empty

% Copyright (c) 2014-15, Till Biskup
% 2015-06-17

status = 0;
warnings = cell(0);

% Parse input arguments using the inputParser functionality
p = inputParser;            % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Include function name in error messages
p.KeepUnmatched = true;     % Enable errors on unmatched arguments
p.StructExpand = true;      % Enable passing arguments in a structure

p.addRequired('handle', @(x)ishandle(x));
p.addRequired('opt', @(x)iscell(x));
p.parse(handle,opt,varargin{:});
handle = p.Results.handle;
opt = p.Results.opt;

% Get command name from mfilename
% cmd = mfilename;
% cmd = lower(cmd(4:end));

% Is there the GUI requested?
if (isempty(handle))
    warnings{end+1} = 'No GUI window could be found.';
    status = -1;
    return;
end

ad = getappdata(handle);

if isempty(ad.control.data.visible)
    warnings{end+1} = 'No visible datasets.';
    status = -3;
    return;
end

% Check for display type
if ~strncmpi(ad.control.axis.displayType,'1d',2)
    warnings{end+1} = 'Stacking works only in 1D modes.';
    status = -3;
    return;
end

% Get maxima of z values
% Preallocation
maxima = zeros(length(ad.control.data.visible),1);
dimension = strcmpi(ad.control.axis.displayType(end),{'x','y'});
for idx=1:length(ad.control.data.visible)
    maxima(idx) = max(...
        ad.data{ad.control.data.visible(idx)}.data(...
        ad.data{ad.control.data.visible(idx)}.display.position.data(dimension),:));
end

% Reset displacement to zero for all traces
for idx = 1:length(ad.control.data.visible)
    ad.data{ad.control.data.visible(idx)}.display.displacement.data(3) = 0;
end

% Set new axis limits
ad.control.axis.limits.z.max = max(maxima);
ad.control.axis.limits.auto = 1;

% Set appdata
setappdata(handle,'data',ad.data);
setappdata(handle,'control',ad.control);

% Update GUI
update_displayPanel();
update_mainAxis();

end

