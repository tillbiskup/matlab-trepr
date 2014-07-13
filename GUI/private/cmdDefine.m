function [status,warnings] = cmdDefine(handle,opt,varargin)
% CMDDEFINE Command line command of the trEPR GUI.
%
% Usage:
%   cmdDefine(handle,opt)
%   [status,warnings] = cmdDefine(handle,opt)
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
% 2014-06-07

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

% Concatenate option
opt = cellfun(@(x)[x ' '],opt,'UniformOutput',false);
opt = strtrim([opt{:}]);

assignmentParts = strtrim(regexp(opt,'=','split'));
if length(assignmentParts) == 2
    try
        ad.control.cmd.variables.(assignmentParts{1}) = assignmentParts{2};
    catch %#ok<CTCH>
        trEPRmsg(['Command ' lower(cmd) ': problems with assigning ' ...
            assignmentParts{1} ' - probably not a valid struct field name'],...
            'warning');
        return;
    end
    setappdata(handle,'control',ad.control);
else
    % Issue some warning
    trEPRmsg(['Command ' lower(cmd) ': option "' opt ...
        '" not understood'],'warning');
    return;
end

end

