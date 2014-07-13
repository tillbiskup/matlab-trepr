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

% Copyright (c) 2014, Till Biskup
% 2014-06-14

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

if isempty(ad.control.spectra.visible)
    warnings{end+1} = 'No visible datasets.';
    status = -3;
    return;
end

% Get x and y values of spectra - FOR NOW assume identical x axes
switch lower(ad.control.axis.displayType)
    case '1d along x'
        % Preallocation
        yValues = zeros(length(ad.control.spectra.visible),...
            length(ad.data{ad.control.spectra.visible(1)}.axes.x.values));
        for idx=1:length(ad.control.spectra.visible)
            yValues(idx,:) = ...
                ad.data{ad.control.spectra.visible(idx)}.data(...
                ad.data{ad.control.spectra.visible(idx)}.display.position.y,:);
        end
    case '1d along y'
        % Preallocation
        yValues = zeros(length(ad.control.spectra.visible),...
            length(ad.data{ad.control.spectra.visible(1)}.axes.y.values));
        for idx=1:length(ad.control.spectra.visible)
            yValues(idx,:) = ...
                ad.data{ad.control.spectra.visible(idx)}.data(:,...
                ad.data{ad.control.spectra.visible(idx)}.display.position.x);
        end
end

% Reset displacement to zero for all traces
for idx = 1:length(ad.control.spectra.visible)
    ad.data{ad.control.spectra.visible(idx)}.display.displacement.z = 0;
end

% Set new axis limits
ad.control.axis.limits.z.max = max(max(yValues));
ad.control.axis.limits.auto = 1;

% Set appdata
setappdata(handle,'data',ad.data);
setappdata(handle,'control',ad.control);

% Update GUI
update_displayPanel();
update_mainAxis();

end

