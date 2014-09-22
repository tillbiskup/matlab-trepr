function [status,warnings] = cmdClear(handle,opt,varargin)
% CMDCLEAR Command line command of the trEPR GUI.
%
% Usage:
%   cmdClear(handle,opt)
%   [status,warnings] = cmdClear(handle,opt)
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

% % Get command name from mfilename
% cmd = mfilename;
% cmd = cmd(4:end);

% Is there the GUI requested?
if (isempty(handle))
    warnings{end+1} = 'No GUI window could be found.';
    status = -1;
    return;
end

% Get appdata from handle
ad = getappdata(handle);

if isempty(opt)
    return;
end

% If option "all" is given, remove all variables
if strcmpi(opt{1},'all')
    ad.control.cmd.variables = struct();
    setappdata(handle,'control',ad.control);
    return;
end

for optIdx = 1:length(opt)
    if isfield(ad.control.cmd.variables,opt{optIdx})
        ad.control.cmd.variables = ...
            rmfield(ad.control.cmd.variables,opt{optIdx});
    else
        warnings{end+1} = ['Variable "' opt{optIdx} '" doesn''t exist.']; %#ok<AGROW>
    end
end

setappdata(handle,'control',ad.control);

end
