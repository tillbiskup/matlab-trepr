function [status,warnings] = cmdUndo(handle,opt,varargin)
% CMDUNDO Command line command of the trEPR GUI.
%
% Usage:
%   cmdUndo(handle,opt)
%   [status,warnings] = cmdUndo(handle,opt)
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
% 2015-05-31

status = 0;
warnings = cell(0);

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

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
% Get handles from handle
gh = guidata(handle);

% For convenience and shorter lines
active = ad.control.data.active;

if isempty(ad.data)
    warnings{end+1} = ['Command "' lower(cmd) '" needs datasets.'];
    return;
end

if isempty(opt)
    active = ad.control.data.active;
    ad.data{active} = trEPRundo(ad.data{active});

    % Add to modified if necessary
    if isempty(ad.control.data.modified == active)
        ad.control.data.modified(end+1) = active;
    end
    
    % Update appdata of main window
    setappdata(handle,'control',ad.control);
    setappdata(handle,'data',ad.data);
    setappdata(handle,'origdata',ad.origdata);
    
    % Add status message (mainly for debug reasons)
    % IMPORTANT: Has to go AFTER setappdata
    trEPRmsg(sprintf('Applied UNDO to dataset #%i',active),'debug');
    
    % Update both list boxes
    update_invisibleSpectra();
    update_visibleSpectra();
    
    %Update main axis
    update_mainAxis();
end
end
