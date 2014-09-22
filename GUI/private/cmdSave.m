function [status,warnings] = cmdSave(handle,opt,varargin)
% CMDSAVE Command line command of the trEPR GUI.
%
% Usage:
%   cmdSave(handle,opt)
%   [status,warnings] = cmdSave(handle,opt)
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
% 2014-09-22

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
% Get handles from handle
gh = guidata(handle);

% For convenience and shorter lines
active = ad.control.data.active;

if isempty(ad.data)
    warnings{end+1} = ['Command "' lower(cmd) '" needs datasets.'];
    return;
end

if isempty(opt)
    trEPRsaveDatasetInMainGUI(active);
    return;
end

if ~isnan(str2double(opt{1}))
    if any(ad.control.data.invisible==str2double(opt{1}))
        selected = str2double(opt{1});
    else
        status = -3;
        warnings{end+1} = ['Dataset ' opt{1} ' seems not to exist.'];
        return;
    end
    opt(1) = [];
else
    selected = active;
end    

if isempty(opt)
    trEPRsaveDatasetInMainGUI(selected);
else
    % Check for path in filename and if none exists, add default path
    [path,name,ext] = fileparts(opt{1});
    if isempty(path)
        filename = fullfile(ad.control.dirs.lastSave,[name ext]);
    else
        filename = opt{1};
    end
    
    trEPRsaveAsDatasetInMainGUI(selected,filename);
end

end
