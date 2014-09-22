function [status,warnings] = cmdInput(handle,opt,varargin)
% CMDINPUT Command line command of the trEPR GUI.
%
% Usage:
%   cmdInput(handle,opt)
%   [status,warnings] = cmdInput(handle,opt)
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
p.addOptional('opt',cell(0),@(x)iscell(x));
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

if isempty(opt)
    return;
end

% Check for variable type and preset
varPreset = '';
if length(opt) > 1
    for optidx = 2:length(opt)
        if length(opt{optidx})>4 && strncmpi(opt{optidx},'type=',5)
            varType = opt{optidx}(6:end);
            opt(optidx) = [];
        end
        if length(opt{optidx})>6 && strncmpi(opt{optidx},'preset=',7)
            varPreset = opt{optidx}(8:end);
            opt(optidx) = [];
        end
    end
end

% Check for prompt
if length(opt) > 1
    varPrompt = cellfun(@(x)[x ' '],opt(2:end),'UniformOutput',false);
    value = inputWindow([strtrim([varPrompt{:}]) ':'],'preset',varPreset);
else
    value = inputWindow([opt{1} ':'],'preset',varPreset);
end


if exist('varType','var')
    try
        value = cast(value,varType);
    catch %#ok<CTCH>
        trEPRmsg(['Command ' lower(cmd) ': problems with casting ' ...
            varType ' - probably not a valid variable type'],...
            'warning');
        return;
    end
end

try
    ad.control.cmd.variables.(opt{1}) = value;
catch %#ok<CTCH>
    trEPRmsg(['Command ' lower(cmd) ': problems with assigning ' ...
        opt{1} ' - probably not a valid struct field name'],...
        'warning');
    return;
end
setappdata(handle,'control',ad.control);

end

