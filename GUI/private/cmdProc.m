function [status,warnings] = cmdProc(handle,opt,varargin)
% CMDPROC Command line command of the trEPR GUI.
%
% Usage:
%   cmdProc(handle,opt)
%   [status,warnings] = cmdProc(handle,opt)
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
% 2014-09-24

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
cmd = cmd(4:end);

% Is there the GUI requested?
if (isempty(handle))
    warnings{end+1} = 'No GUI window could be found.';
    status = -1;
    return;
end

% Get appdata from handle
ad = getappdata(handle);

if isempty(ad.data)
    warnings{end+1} = ['Command "' lower(cmd) '" needs datasets.'];
    return;
end

if ~isempty(opt)
    numDataset = ad.control.data.active;
    % Check whether first option is numeric (-> dataset no) or char (dim)
    if ~isnan(str2double(opt{1})) && str2double(opt{1}) <= length(ad.data)
        numDataset = str2double(opt{1});
        % Remove first option
        opt(1) = [];
    end
    switch lower(opt{1})
        case {'poc','pretrigger'}
            guiProcessingPOC(numDataset);
            update_visibleSpectra();
        case {'bgc','background'}
            guiProcessingBGC(numDataset);
            update_visibleSpectra();
        case {'blc','baseline'}
            trEPRgui_BLCwindow();
        case {'acc','accumulate'}
            trEPRgui_ACCwindow();
        otherwise
            trEPRgui_cmd_helpwindow(opt{1})
    end
else
    trEPRgui_cmd_helpwindow('introduction');
end

end

