function [status,warnings] = cmdReset(handle,opt,varargin)
% CMDRESET Command line command of the trEPR GUI.
%
% Usage:
%   cmdReset(handle,opt)
%   [status,warnings] = cmdReset(handle,opt)
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
% 2014-07-23

status = 0;
warnings = cell(0);

% Parse input arguments using the inputParser functionality
p = inputParser;            % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Include function name in error messages
p.KeepUnmatched = true;     % Enable errors on unmatched arguments
p.StructExpand = true;      % Enable passing arguments in a structure

p.addRequired('handle', @(x)ishandle(x));
p.addRequired('opt', @(x)iscell(x));
p.parse(handle,opt,varargin{:});
handle = p.Results.handle;
% opt = p.Results.opt;

% Get command name from mfilename
% cmd = mfilename;
% cmd = lower(cmd(4:end));

% Is there the GUI requested?
if (isempty(handle))
    warnings{end+1} = 'No GUI window could be found.';
    status = -1;
    return;
end

% Get appdata of main window
mainWindow = trEPRguiGetWindowHandle();
ad = getappdata(mainWindow);

if isempty(ad.control.spectra.visible)
    warnings{end+1} = 'No visible datasets.';
    status = -3;
    return;
end

active = ad.control.spectra.active;

% Reset displacement and scaling for current spectrum
ad.data{active}.display.displacement.data.x = 0;
ad.data{active}.display.displacement.data.y = 0;
ad.data{active}.display.displacement.data.z = 0;

ad.data{active}.display.scaling.data.x = 1;
ad.data{active}.display.scaling.data.y = 1;
ad.data{active}.display.scaling.data.z = 1;

% Update appdata of main window
setappdata(mainWindow,'data',ad.data);

% Update slider panel
update_sliderPanel();

%Update main axis
update_mainAxis();

end

