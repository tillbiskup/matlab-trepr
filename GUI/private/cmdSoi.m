function [status,warnings] = cmdSoi(handle,opt,varargin)
% CMDSOI Command line command of the trEPR GUI.
%
% Usage:
%   cmdSoi(handle,opt)
%   [status,warnings] = cmdSoi(handle,opt)
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

% (c) 2014, Till Biskup
% 2014-06-26

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

ad = getappdata(handle);

if isempty(ad.control.spectra.visible)
    warnings{end+1} = 'No visible datasets.';
    status = -3;
    return;
end

if strcmpi(ad.control.axis.displayType,'2d plot')
    warnings{end+1} = sprintf('%s: Cannot operate in "%s" display type.',...
        cmd,ad.control.spectra.displayType);
    status = -3;
    return;
end

active = ad.control.spectra.active;

% Get empty SOI structure
S = trEPRdataStructure();
soi = S.characteristics.soi;

% Set coordinates according to display mode
switch lower(ad.control.axis.displayType)
    case '1d along x'
        soi.coordinates = ad.data{active}.display.position.y;
        soi.direction = 'x';
    case '1d along y'
        soi.coordinates = ad.data{active}.display.position.x;
        soi.direction = 'y';
end

soiIndex = 0;
% Get number of current SOI entries
if isempty(ad.data{active}.characteristics.soi(1).coordinates)
    soiIndex = 1;
else
    % Check whether we have already a SOI entry for this slice
    for idx = 1:length(ad.data{active}.characteristics.soi)
        if strcmpi(ad.data{active}.characteristics.soi(idx).direction,...
                soi.direction) && ...
            ad.data{active}.characteristics.soi(idx).coordinates == ...
                soi.coordinates
            soiIndex = idx;
        end
    end
    if ~soiIndex
        soiIndex = length(ad.data{active}.characteristics.soi)+1;
    end
end

if soiIndex <= length(ad.data{active}.characteristics.soi) && ...
        ~isempty(ad.data{active}.characteristics.soi(soiIndex).coordinates)
    soi = ad.data{active}.characteristics.soi(soiIndex);
end

% Handle additional options
if ~isempty(opt)
    if length(opt) > 1
        switch lower(opt{1})
            case 'label'
                soi.label = strtrim(sprintf('%s ',opt{2:end}));
            case 'comment'
                soi.comment = strtrim(sprintf('%s ',opt{2:end}));
            case 'display'
                switch opt{2}
                    case 'true'
                        soi.display = true;
                    case 'false'
                        soi.display = false;
                    otherwise
                        displayOption = str2double(opt{2});
                        if isnan(displayOption)
                            soi.display = false;
                        else
                            soi.display = logical(displayOption);
                        end
                end
            case 'avgwindow'
                avgWindowOption = str2double(opt{2});
                if isnan(avgWindowOption)
                    soi.avgWindow = 1;
                else
                    soi.avgWindow = avgWindowOption;
                end
            otherwise
                soi.label = strtrim(sprintf('%s ',opt{:}));
        end
    else
        soi.label = opt{1};
    end
end

% Set SOI
ad.data{active}.characteristics.soi(soiIndex) = soi;

% Set appdata
setappdata(handle,'data',ad.data);

end

