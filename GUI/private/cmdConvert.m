function [status,warnings] = cmdConvert(handle,opt,varargin)
% CMDCONVERT Command line command of the trEPR GUI.
%
% Usage:
%   cmdConvert(handle,opt)
%   [status,warnings] = cmdConvert(handle,opt)
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

% (c) 2013-14, Till Biskup
% 2014-07-12

status = 0;
warnings = cell(0);

% Parse input arguments using the inputParser functionality
p = inputParser;            % Create an inputParser instance
p.FunctionName = mfilename; % Include function name in error messages
p.KeepUnmatched = true;     % Enable errors on unmatched arguments
p.StructExpand = true;      % Enable passing arguments in a structure

p.addRequired('handle', @(x)ishandle(x));
p.addRequired('opt', @(x)iscell(x));
%p.addOptional('opt',cell(0),@(x)iscell(x));
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

% Get appdata from handle
ad = getappdata(handle);

% For convenience and shorter lines
active = ad.control.spectra.active;

% If there is no active dataset, return
if ~active
    warnings{end+1} = sprintf('Command "%s": No active dataset.',cmd);
    status = -3;
    return;
end

if isempty(opt)
    warnings{end+1} = sprintf(...
        'Command "%s": Not enough options. Use "help %s" to get some help.',cmd,cmd);
    status = -2;
    return;
end

% Check whether first option is numeric (-> dataset no) or char
% (conversion option)
if ~isnan(str2double(opt{1}))
    dataset = str2double(opt{1});
    % Remove first option
    opt(1) = [];
else
    dataset = active;
end

% Check first option for special selection of datasets
switch lower(opt{1})
    case 'all'
        dataset = 1:length(ad.data);
        opt(1) = [];
    case {'visible','vis'}
        dataset = ad.control.spectra.visible;
        opt(1) = [];
    case {'invisible','invis','inv'}
        dataset = ad.control.spectra.invisible;
        opt(1) = [];
end

% Check again for options
if isempty(opt)
    warnings{end+1} = sprintf(...
        'Command "%s": Not enough options. Use "help %s" to get some help.',cmd,cmd);
    status = -2;
    return;
end

% Perform actual conversion
for idx = 1:length(dataset)
    ad.data{dataset(idx)} = trEPRconvertUnits(ad.data{dataset(idx)},opt{1});
end
setappdata(handle,'data',ad.data);
update_mainAxis();

end

