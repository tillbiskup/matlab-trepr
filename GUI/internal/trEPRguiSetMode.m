function [status,warnings] = trEPRguiSetMode(mode,varargin)
% TREPRSETMODE Helper function setting the mode of the trEPR GUI
%
% Usage:
%   trEPRsetMode(mode)
%   mode = trEPRsetMode(mode)
%
%   mode    - string (not case sensitive)
%             Mode to set the GUI into
%             Current options are:
%
%               None, Scroll, sCale, Displace, Zoom, Measure, Pick, cOmmand
%
%             Capital letters denote the single letter abbreviation for
%             each mode that may be used as well.
%
%   status  - scalar
%             Return value for the exit status:
%             -1: no trEPRgui window found
%             -2: trEPRgui window appdata don't contain necessary fields
%             -3: some other problems
%              0: successfully set mode
%
%  warnings - cell array
%             Contains warnings/error messages if any, otherwise empty

% (c) 2013, Till Biskup
% 2013-02-04

status = 0;
warnings = cell(0);

% If called with no input arguments, just display help and exit
if (nargin==0)
    help trEPRsetMode;
    return;
end

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('mode', @(x)ischar(x));
%p.addOptional('command','',@(x)ischar(x));
p.parse(mode,varargin{:});

% Is there currently a trEPRgui object?
mainWindow = trEPRguiGetWindowHandle();
if (isempty(mainWindow))
    warnings{end+1} = 'No trEPRgui window could be found.';
    status = -1;
    return;
end

% Get appdata from mainwindow
ad = getappdata(mainWindow);
% Get handles from main GUI
gh = guidata(mainWindow);

% Check for availability of necessary fields in appdata
if (isfield(ad,'control') == 0) || (isfield(ad.control,'status') == 0)
    warnings{end+1} = ['trEPRgui window appdata don''t contain '...
        'necessary fields'];
    status = -2;
    return;
end


% Handle modes
% Current modes are: None, Scroll, sCale, Displace, Zoom, Measure, Pick
switch lower(mode)
    case {'none','n'}
        GUImode = 'None';
        set(gh.command_panel_edit,'Enable','inactive');
    case {'scroll','s'}
        GUImode = 'Scroll';
    case {'scale','c'}
        GUImode = 'Scale';
    case {'displace','d'}
        GUImode = 'Displace';
    case {'zoom','z'}
        GUImode = 'Zoom';
    case {'measure','m'}
        GUImode = 'Measure';
    case {'pick','p'}
        GUImode = 'Pick';
    case {'command','o'}
        GUImode = 'Command';
        set(gh.command_panel_edit,'Enable','on');
        uicontrol(gh.command_panel_edit);
    otherwise
        warnings{end+1} = sprintf('Unknown mode "%s"\n',mode);
        status = -3;
end

% Set mode in main GUI window
ad.control.mode = GUImode;

% Push appdata back to main gui
setappdata(mainWindow,'control',ad.control);

% Set mode display accordingly
set(gh.status_panel_mode_text,'String',GUImode);

% Inform user about mode switching
trEPRmsg(['Mode switched to "' GUImode '"'],'debug');

end