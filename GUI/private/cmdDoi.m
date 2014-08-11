function [status,warnings] = cmdDoi(handle,opt,varargin)
% CMDDOI Command line command of the trEPR GUI.
%
% Usage:
%   cmdDoi(handle,opt)
%   [status,warnings] = cmdDoi(handle,opt)
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

% Get empty doi structure
S = trEPRdataStructure();
doi = S.characteristics.doi;

% Set coordinates
doi.parameters.coordinates = [ ad.data{active}.display.measure.point(1).index ; ...
    ad.data{active}.display.measure.point(2).index ];

% Set default label
doi.label = sprintf('Dx = %e %s; Dy = %e %s',...
    diff(ad.data{active}.axes.x.values(doi.parameters.coordinates(:,1))),...
    ad.data{active}.axes.x.unit,...
    diff(ad.data{active}.axes.y.values(doi.parameters.coordinates(:,2))),...
    ad.data{active}.axes.y.unit...
    );

doiIndex = 0;
% Get number of current doi entries
if isempty(ad.data{active}.characteristics.doi(1).parameters.coordinates)
    doiIndex = 1;
else
    % Check whether we have already a doi entry for this coordinates
    for idx = 1:length(ad.data{active}.characteristics.doi)
        if ad.data{active}.characteristics.doi(idx).parameters.coordinates == ...
                doi.parameters.coordinates
            doiIndex = idx;
        end
    end
    if ~doiIndex
        doiIndex = length(ad.data{active}.characteristics.doi)+1;
    end
end

if doiIndex <= length(ad.data{active}.characteristics.doi) && ...
        ~isempty(ad.data{active}.characteristics.doi(doiIndex).parameters.coordinates)
    doi = ad.data{active}.characteristics.doi(doiIndex);
end

% Handle additional options
if ~isempty(opt)
    if length(opt) > 1
        switch lower(opt{1})
            case 'label'
                doi.label = strtrim(sprintf('%s ',opt{2:end}));
            case 'comment'
                doi.comment = strtrim(sprintf('%s ',opt{2:end}));
            case 'display'
                switch opt{2}
                    case 'true'
                        doi.display = true;
                    case 'false'
                        doi.display = false;
                    otherwise
                        displayOption = str2double(opt{2});
                        if isnan(displayOption)
                            doi.display = false;
                        else
                            doi.display = logical(displayOption);
                        end
                end
            otherwise
                doi.label = strtrim(sprintf('%s ',opt{:}));
        end
    else
        doi.label = opt{1};
    end
end

% Set doi
ad.data{active}.characteristics.doi(doiIndex) = doi;

% Set appdata
setappdata(handle,'data',ad.data);

end

