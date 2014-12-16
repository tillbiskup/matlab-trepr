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
% 2014-12-16

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

% Check for display type
if ~strncmpi(ad.control.axis.displayType,'1d',2)
    warnings{end+1} = 'Stacking works only in 1D modes.';
    status = -3;
    return;
end

% Get display dimension (1D along <dimension>)
dimension = lower(ad.control.axis.displayType(end));

% Apply displacement, normalisation, scaling
corrDatasets = cell(1,length(ad.control.data.visible));
for dataset = 1:length(ad.control.data.visible)
    corrDatasets{dataset} = trEPRdatasetApplyDisplacement(...
        ad.data{ad.control.data.visible(dataset)});
    normalisationParameters = ad.control.axis.normalisation;
    normalisationParameters.displayType = dimension;
    corrDatasets{dataset} = trEPRdatasetApplyNormalisation(...
        ad.data{ad.control.data.visible(dataset)},...
        normalisationParameters);
    corrDatasets{dataset} = trEPRdatasetApplyScaling(...
        ad.data{ad.control.data.visible(dataset)});
end

% Get minimum and maximum in z direction (y direction of plot)
switch dimension
    case 'x'
        zMin = min(...
            corrDatasets{1}.data(corrDatasets{1}.display.position.y,:));
        zMax = max(...
            corrDatasets{end}.data(corrDatasets{end}.display.position.y,:));
    case 'y'
        zMin = min(...
            corrDatasets{1}.data(:,corrDatasets{1}.display.position.x));
        zMax = max(...
            corrDatasets{end}.data(:,corrDatasets{end}.display.position.x));
end

deltas = zeros(1,length(ad.control.data.visible)-1);
for dataset = 1:length(ad.control.data.visible)-1
    % Match datasets in given dimension
    tmpDatasets = trEPRdatasetMatch(corrDatasets([dataset,dataset+1]),...
        'dimension',dimension);
    switch dimension
        case 'x'
            deltas(dataset) = abs(min(...
                tmpDatasets{2}.data(tmpDatasets{2}.display.position.y,:)- ...
                tmpDatasets{1}.data(tmpDatasets{1}.display.position.y,:)));
        case 'y'
            deltas(dataset) = abs(min(...
                tmpDatasets{2}.data(:,tmpDatasets{2}.display.position.x)- ...
                tmpDatasets{1}.data(:,tmpDatasets{1}.display.position.x)));
    end
end

% Calculate a proper difference between each trace
% Therefore, calculate the overall space used and take a percentage of this
additionalDelta = (zMin + zMax + sum(deltas)) * percentage/100;

% Add deltas and additionalDelta to traces
for delta = 1:length(deltas)
    ad.data{ad.control.data.visible(delta+1)}.display.displacement.data.z = ...
        sum(deltas(1:delta)) + delta*additionalDelta;
end

% Set new axis limits
ad.control.axis.limits.z.min = zMin - additionalDelta;
ad.control.axis.limits.z.max = ...
    zMax + sum(deltas) + (length(deltas)+1)*additionalDelta;
ad.control.axis.limits.auto = 0;

% Set appdata
setappdata(handle,'data',ad.data);
setappdata(handle,'control',ad.control);

% Update GUI
update_displayPanel();
update_mainAxis();

end

