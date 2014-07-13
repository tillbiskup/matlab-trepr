function [status,warnings] = cmdPick(handle,opt,varargin)
% CMDPICK Command line command of the trEPR GUI.
%
% Usage:
%   cmdPick(handle,opt)
%   [status,warnings] = cmdPick(handle,opt)
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

% Copyright (c) 2013-14, Till Biskup
% 2014-07-12

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

if isempty(opt)
    warnings{end+1} = ['Command "' lower(cmd) '" needs options.'];
    status = -2;
    return;
end

% Get appdata from handle
ad = getappdata(handle);
% Get handles from handle
% gh = guidata(handle);

% For convenience and shorter lines
active = ad.control.spectra.active;

data = getData(ad.data{active});

if ~active
    warnings{end+1} = ['Command "' lower(cmd) '" needs an active dataset.'];
    return;
end
switch lower(opt{1}(1:3))
    case 'min'
        [~,ximin] = min(min(data));
        [~,yimin] = min(data(:,ximin));
        ad.data{active}.display.position.x = ximin;
        ad.data{active}.display.position.y = yimin;
        
        % Display info about values in status window
        message = sprintf('Values of minimum: x = %e, y = %8.2f, z = %f',...
            ad.data{active}.axes.x.values(ximin),...
            ad.data{active}.axes.y.values(yimin),...
            ad.data{active}.data(yimin,ximin) ...
            );
        trEPRmsg(message,'info')
        
        % Set appdata from main GUI
        setappdata(handle,'data',ad.data);
        
        % Update slider panel
        update_sliderPanel();
        
        %Update main axis
        update_mainAxis();
        return;
    case 'max'
        [~,ximax] = max(max(data));
        [~,yimax] = max(data(:,ximax));
        ad.data{active}.display.position.x = ximax;
        ad.data{active}.display.position.y = yimax;
        
        % Display info about values in status window
        message = sprintf('Values of maximum: x = %e, y = %8.2f, z = %f',...
            ad.data{active}.axes.x.values(ximax),...
            ad.data{active}.axes.y.values(yimax),...
            ad.data{active}.data(yimax,ximax) ...
            );
        trEPRmsg(message,'info')
        
        % Set appdata from main GUI
        setappdata(handle,'data',ad.data);
        
        % Update slider panel
        update_sliderPanel();
        
        %Update main axis
        update_mainAxis();
        return;
end
end

