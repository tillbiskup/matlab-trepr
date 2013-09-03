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

% (c) 2013, Till Biskup
% 2013-09-03

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

if ~isempty(opt)
    % Check whether first option is numeric (-> dataset no) or char
    % (conversion option)
    if ~isnan(str2double(opt{1}))
        dataset = str2double(opt{1});
        % Remove first option
        opt(1) = [];
    else
        dataset = active;
    end
    
    % Perform actual conversion
    ad.data{dataset} = trEPRconvertUnits(ad.data{dataset},opt{1});
    setappdata(handle,'data',ad.data);
    update_mainAxis();
else
    warnings{end+1} = sprintf(...
        'Command "%s": Not enough options. Use "help %s" to get some help.',cmd,cmd);
    status = -2;
    return;
end

end

