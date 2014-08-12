function [status,warnings] = cmdVoi(handle,opt,varargin)
% CMDVOI Command line command of the trEPR GUI.
%
% Usage:
%   cmdVoi(handle,opt)
%   [status,warnings] = cmdVoi(handle,opt)
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
% 2014-08-12

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

% if strcmpi(ad.control.axis.displayType,'2d plot')
%     warnings{end+1} = sprintf('%s: Cannot operate in "%s" display type.',...
%         cmd,ad.control.spectra.displayType);
%     status = -3;
%     return;
% end

active = ad.control.spectra.active;

% Get empty VOI structure
S = trEPRdataStructure();
voi = S.characteristics.voi;

% Get parameters from GUI appdata
voi.parameters = ad.control.axis.vis3d;

% Check for an open 3Drepresentation figure window
figureWindow = findobj('Tag','trEPRgui_3Drepresentation');
if ~isempty(figureWindow)
    view = get(findall(figureWindow,'type','axes'),'view');
    if iscell(view)
        voi.parameters.view.azimuth = view{1}(1);
        voi.parameters.view.elevation = view{1}(2);
    else
        voi.parameters.view.azimuth = view(1);
        voi.parameters.view.elevation = view(2);
    end
end

% Set default label
[dimy,dimx] = size(ad.data{active}.data);
voi.label = sprintf('%s (size: %ix%i, offset: %i;%i) az: %5.2f el: %5.2f',...
    voi.parameters.type,floor(dimx/voi.parameters.reduction.x),...
    floor(dimy/voi.parameters.reduction.y),...
    voi.parameters.offset.x,voi.parameters.offset.y,...
    voi.parameters.view.azimuth,voi.parameters.view.elevation ...
    );

voiIndex = 0;
% Get number of current VOI entries
% Use a trick here to identify the empty default value: reduction.x = 0
if ~ad.data{active}.characteristics.voi(1).parameters.reduction.x
    voiIndex = 1;
else
    % Check whether we have already a VOI entry for this view
    for idx = 1:length(ad.data{active}.characteristics.voi)
        if isequaln(ad.data{active}.characteristics.voi(idx).parameters,...
                voi.parameters)
            voiIndex = idx;
        end
    end
    if ~voiIndex
        voiIndex = length(ad.data{active}.characteristics.voi)+1;
    end
end

if voiIndex <= length(ad.data{active}.characteristics.voi) && ...
        ad.data{active}.characteristics.voi(voiIndex).parameters.reduction.x
    voi = ad.data{active}.characteristics.voi(voiIndex);
end

% Handle additional options
if ~isempty(opt)
    if length(opt) > 1
        switch lower(opt{1})
            case 'label'
                voi.label = strtrim(sprintf('%s ',opt{2:end}));
            case 'comment'
                voi.comment = strtrim(sprintf('%s ',opt{2:end}));
            otherwise
                voi.label = strtrim(sprintf('%s ',opt{:}));
        end
    else
        voi.label = opt{1};
    end
end

% Set VOI
ad.data{active}.characteristics.voi(voiIndex) = voi;

% Set appdata
setappdata(handle,'data',ad.data);

end
