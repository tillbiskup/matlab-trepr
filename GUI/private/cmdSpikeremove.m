function [status,warnings] = cmdSpikeremove(handle,opt,varargin)
% CMDSPIKEREMOVE Command line command of the trEPR GUI.
%
% Usage:
%   cmdDoi(handle,opt)
%   [status,warnings] = cmdSpikeremove(handle,opt)
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
% 2014-07-12

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

if isempty(opt)
    warnings{end+1} = ['Command "' lower(cmd) '" needs options.'];
    status = -2;
    return;
end

ad = getappdata(handle);

if isempty(ad.control.spectra.visible)
    warnings{end+1} = 'No visible datasets.';
    status = -3;
    return;
end

active = ad.control.spectra.active;

% Handle options as positions
positions = str2num(strtrim(sprintf('%s ',opt{:}))); %#ok<ST2NM>

if any(isnan(positions)) || isempty(positions)
    warnings{end+1} = ['Problem coverting options "' opt{:} ...
        '" into positions'];
    return;
end

ad.data{active} = trEPRspikeRemoval(ad.data{active},positions);

% Set appdata
setappdata(handle,'data',ad.data);

% Update GUI
update_mainAxis();

end

