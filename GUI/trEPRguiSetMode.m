function [status,warnings] = trEPRguiSetMode(mode,varargin)
% TREPRSETMODE Helper function setting the mode of the trEPR GUI
%
% Usage:
%   trEPRguiSetMode(mode)
%   [status,warnings] = trEPRguiSetMode(mode)
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
% 2013-08-24

status = 0;
warnings = cell(0);

% If called with no input arguments, just display help and exit
if (nargin==0)
    help trEPRguiSetMode;
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
if ~isfield(ad,'control') || ~isfield(ad.control,'status')
    warnings{end+1} = ['trEPRgui window appdata don''t contain '...
        'necessary fields'];
    status = -2;
    return;
end

% Check whether mode has changed, and if not, return
if strcmpi(ad.control.mode,mode)
    if strcmpi(mode,'command')
        uicontrol(gh.command_panel_edit);
    end
    return;
end

% Handle modes
% Current modes are: None, Scroll, sCale, Displace, Zoom, Measure, Pick
guiZoom('off');
guiMeasure('off',0);

switch lower(mode)
    case {'none','n'}
        GUImode = 'None';
        set(gh.command_panel_edit,'Enable','inactive');
        set(gh.command_panel_edit,...
            'String','Enter command - Ctrl-l / Cmd-l for access');
    case {'scroll','s'}
        GUImode = 'Scroll';
    case {'scale','c'}
        GUImode = 'Scale';
    case {'displace','d'}
        GUImode = 'Displace';
    case {'zoom','z'}
        guiZoom('on');
        GUImode = 'Zoom';
    case {'measure','m'}
        guiMeasure('on',2);
        GUImode = 'Measure';
    case {'pick','p'}
        guiMeasure('on',1);
        GUImode = 'Pick';
    case {'command','o'}
        GUImode = 'Command';
        set(gh.command_panel_edit,'Enable','on');
        set(gh.command_panel_edit,'String','');
        uicontrol(gh.command_panel_edit);
    otherwise
        warnings{end+1} = sprintf('Unknown mode "%s"\n',mode);
        status = -3;
end

% Get appdata again
ad = getappdata(mainWindow);

% Set mode in main GUI window
ad.control.mode = GUImode;

% Push appdata back to main gui
setappdata(mainWindow,'control',ad.control);

% Set mode display accordingly
set(gh.status_panel_mode_text,'String',GUImode);

% Inform user about mode switching
trEPRmsg(['Mode switched to "' GUImode '"'],'debug');

end