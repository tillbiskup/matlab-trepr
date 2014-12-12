function [status,warnings] = cmdStack(handle,opt,varargin)
% CMDSTACK Command line command of the trEPR GUI.
%
% Usage:
%   cmdStack(handle,opt)
%   [status,warnings] = cmdStack(handle,opt)
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
% 2014-12-12

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
cmd = mfilename;
cmd = lower(cmd(4:end));

% Is there the GUI requested?
if (isempty(handle))
    warnings{end+1} = 'No GUI window could be found.';
    status = -1;
    return;
end

% Define percentage
percentage = 10;

ad = getappdata(handle);

if isempty(ad.control.data.visible)
    warnings{end+1} = 'No visible datasets.';
    status = -3;
    return;
end

if strcmpi(ad.control.axis.displayType,'2d plot')
    warnings{end+1} = sprintf('%s: Cannot operate in "%s" display type.',...
        cmd,ad.control.data.displayType);
    status = -3;
    return;
end

% Get x and y values of spectra - FOR NOW assume identical x axes
switch lower(ad.control.axis.displayType)
    case '1d along x'
        % Preallocation
        xValues = zeros(length(ad.control.data.visible),...
            length(ad.data{ad.control.data.visible(1)}.axes.x.values));
        yValues = zeros(length(xValues));
        for idx=1:length(ad.control.data.visible)
            xValues(idx,:) = ...
                ad.data{ad.control.data.visible(idx)}.axes.x.values;
            yValues(idx,:) = ...
                ad.data{ad.control.data.visible(idx)}.data(...
                ad.data{ad.control.data.visible(idx)}.display.position.y,:);
        end
        if length(ad.control.data.visible) > 1 ...
                && ~isequal(...
                repmat(xValues(1,:),[],size(xValues,1)),xValues)
            warnings{end+1} = sprintf('%s: Axes are not identical.',cmd);
            status = -3;
            return;
        end
    case '1d along y'
        % Preallocation
        xValues = zeros(length(ad.control.data.visible),...
            length(ad.data{ad.control.data.visible(1)}.axes.y.values));
        yValues = zeros(size(xValues));
        for idx=1:length(ad.control.data.visible)
            xValues(idx,:) = ...
                ad.data{ad.control.data.visible(idx)}.axes.y.values;
            yValues(idx,:) = ...
                ad.data{ad.control.data.visible(idx)}.data(:,...
                ad.data{ad.control.data.visible(idx)}.display.position.x);
        end
        if length(ad.control.data.visible) > 1 ...
                && ~isequal(...
                repmat(xValues(1,:),[],size(xValues,1)),xValues)
            warnings{end+1} = sprintf('%s: Axes are not identical.',cmd);
            status = -3;
            return;
        end
end

% Get deltas in y direction
deltas = abs(min(yValues(2:end,:)-yValues(1:end-1,:),[],2));

% Calculate a proper difference between each trace
% Therefore, calculate the overall space used and take a percentage of this
additionalDelta = ...
    (abs(min(yValues(1,:))) + max(yValues(end,:)) + sum(deltas)) * ...
    percentage/100;

% Add deltas and additionalDelta to traces
for delta = 1:length(deltas)
    ad.data{ad.control.data.visible(delta+1)}.display.displacement.data.z = ...
        sum(deltas(1:delta)) + delta*additionalDelta;
end

% Set new axis limits
ad.control.axis.limits.z.max = ...
    max(yValues(end,:)) + sum(deltas) + length(deltas)*additionalDelta;
ad.control.axis.limits.auto = 0;

% Set appdata
setappdata(handle,'data',ad.data);
setappdata(handle,'control',ad.control);

% Update GUI
update_displayPanel();
update_mainAxis();

end

