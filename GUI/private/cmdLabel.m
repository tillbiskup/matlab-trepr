function [status,warnings] = cmdLabel(handle,opt,varargin)
% CMDLABEL Command line command of the trEPR GUI.
%
% Usage:
%   cmdLabel(handle,opt)
%   [status,warnings] = cmdLabel(handle,opt)
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

% Copyright (c) 2013-14, Till Biskup
% 2014-06-07

status = 0;
warnings = cell(0);

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('handle', @(x)ishandle(x));
p.addRequired('opt', @(x)iscell(x));
%p.addOptional('opt',cell(0),@(x)iscell(x));
p.parse(handle,opt,varargin{:});
handle = p.Results.handle;
opt = p.Results.opt;

% Get command name from mfilename
cmd = mfilename;
cmd = cmd(4:end);

% Is there the GUI requested?
if (isempty(handle))
    warnings{end+1} = 'No GUI window could be found.';
    status = -1;
    return;
end

% Get appdata from handle
ad = getappdata(handle);

% For convenience and shorter lines
active = ad.control.data.active;

if ~active && isempty(opt)
    warnings{end+1} = ['Command "' lower(cmd) '" needs an active dataset.'];
    status = -3;
    return;
end

if isempty(opt)
    ad.data{active}.label = trEPRgui_setLabelWindow(ad.data{active}.label);
else
    datasetId = active;
    if ~isnan(str2double(opt{1}))
        datasetId = str2double(opt{1});
        % Check if datasetId is possible, otherwise return
        if datasetId > length(ad.data)
            warnings{end+1} = sprintf('Dataset "%i" doesn''t exist.',datasetId);
            status = -3;
            return;
        end
        if length(opt)==1
            ad.data{datasetId}.label = ...
                trEPRgui_setLabelWindow(ad.data{datasetId}.label);
            return;
        else
            opt(1) = [];
        end
    end
    opt = cellfun(@(x)[x ' '],opt,'UniformOutput',false);
    ad.data{datasetId}.label = strtrim([opt{:}]);
end

setappdata(handle,'data',ad.data);
update_mainAxis();
update_visibleSpectra();
update_invisibleSpectra();

end
