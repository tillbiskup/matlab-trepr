function [status,warnings] = cmdLoadfiletype(handle,opt,varargin)
% CMDLOADFILETYPE Command line command of the trEPR GUI.
%
% Usage:
%   cmdLoadfiletype(handle,opt)
%   [status,warnings] = cmdShow(handle,opt)
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

% Copyright (c) 2015, Till Biskup
% 2015-10-18

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

% % Get command name from mfilename
% cmd = mfilename;
% cmd = cmd(4:end);

% Is there the GUI requested?
if (isempty(handle))
    warnings{end+1} = 'No GUI window could be found.';
    status = -1;
    return;
end

if isempty(opt)
    return;
end

% Get appdata from handle
ad = getappdata(handle);

fileTypes = {ad.control.panels.load.fileTypes.name};
fileType = find(cellfun(@(x)any(strfind(x,opt{1})),lower(fileTypes)));

if isempty(fileType)
    warnings{end+1} = sprintf('"%s" is not a valid filetype.',opt{1});
    status = -3;
    return;
end

ad.control.panels.load.fileType = fileType;
setappdata(handle,'control',ad.control);
update_loadPanel();

end
