function [status,warnings] = cmdPoi(handle,opt,varargin)
% CMDPOI Command line command of the trEPR GUI.
%
% Usage:
%   cmdPoi(handle,opt)
%   [status,warnings] = cmdPoi(handle,opt)
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
% 2014-08-11

status = 0;
warnings = cell(0);

% Parse input arguments using the inputParser functionality
try
    p = inputParser;            % Create inputParser object.
    p.FunctionName = mfilename; % Function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('handle', @(x)ishandle(x));
    p.addRequired('opt', @(x)iscell(x));
    p.parse(handle,opt,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

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

ad = getappdata(handle);

if isempty(ad.control.spectra.visible)
    warnings{end+1} = 'No visible datasets.';
    status = -3;
    return;
end

active = ad.control.spectra.active;
if isempty(ad.data{active}.display.measure.point(1).index)
    warnings{end+1} = 'Active dataset contains no measurement.';
    status = -3;
    return;
end

% Get empty POI structure
S = trEPRdataStructure();
poi = S.characteristics.poi;

% Set coordinates
poi.parameters.coordinates = ad.data{active}.display.measure.point(1).index;

% Set default label
poi.label = sprintf('x = %e %s; y = %e %s',...
    ad.data{active}.axes.x.values(poi.parameters.coordinates(1)),...
    ad.data{active}.axes.x.unit,...
    ad.data{active}.axes.y.values(poi.parameters.coordinates(2)),...
    ad.data{active}.axes.y.unit);

poiIndex = 0;
% Get number of current POI entries
if isempty(ad.data{active}.characteristics.poi(1).parameters.coordinates)
    poiIndex = 1;
else
    % Check whether we have already a POI entry for this coordinates
    for idx = 1:length(ad.data{active}.characteristics.poi)
        if ad.data{active}.characteristics.poi(idx).parameters.coordinates == ...
                poi.parameters.coordinates
            poiIndex = idx;
        end
    end
    if ~poiIndex
        poiIndex = length(ad.data{active}.characteristics.poi)+1;
    end
end

if poiIndex <= length(ad.data{active}.characteristics.poi) && ...
        ~isempty(ad.data{active}.characteristics.poi(poiIndex).parameters.coordinates)
    poi = ad.data{active}.characteristics.poi(poiIndex);
end

% Handle additional options
if ~isempty(opt)
    if length(opt) > 1
        switch lower(opt{1})
            case 'label'
                poi.label = strtrim(sprintf('%s ',opt{2:end}));
            case 'comment'
                poi.comment = strtrim(sprintf('%s ',opt{2:end}));
            case 'display'
                switch opt{2}
                    case 'true'
                        poi.display = true;
                    case 'false'
                        poi.display = false;
                    otherwise
                        displayOption = str2double(opt{2});
                        if isnan(displayOption)
                            poi.display = false;
                        else
                            poi.display = logical(displayOption);
                        end
                end
            otherwise
                poi.label = strtrim(sprintf('%s ',opt{:}));
        end
    else
        poi.label = opt{1};
    end
end

% Set POI
ad.data{active}.characteristics.poi(poiIndex) = poi;

% Set appdata
setappdata(handle,'data',ad.data);

end

