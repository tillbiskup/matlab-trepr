function [status,warnings] = cmdSet(handle,opt,varargin)
% CMDSET Command line command of the trEPR GUI.
%
% Usage:
%   cmdSet(handle,opt)
%   [status,warnings] = cmdSet(handle,opt)
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

% Copyright (c) 2014-15, Till Biskup
% 2015-05-31

status = 0;
warnings = cell(0);

% Parse input arguments using the inputParser functionality
try
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('handle', @(x)ishandle(x));
    p.addRequired('opt', @(x)iscell(x));
    p.parse(handle,opt,varargin{:});
    handle = p.Results.handle;
    opt = p.Results.opt;
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

% Get command name from mfilename
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
% Get handles from handle
% gh = guidata(handle);

if length(opt) < 2
    return;
end

ad = getappdata(handle);
try
    ad = commonSetCascadedField(ad,opt{1},opt{2});
catch exception
    trEPRmsg(sprintf('%s\n%s',...
        'Problems setting field:',exception.message),'warning');
    return;
end

adFieldNames = fieldnames(ad);
for field = 1:length(adFieldNames)
    setappdata(handle,adFieldNames{field},ad.(adFieldNames{field}));
end

msgStr{1} = ['Set field: ' opt{1}];
msgStr{2} = ['to value:  ' opt{2}];
trEPRmsg(msgStr,'info');

% Update GUI
trEPRguiUpdate;

end
