function handle = guiGetWindowHandle(varargin)
% GUIGETWINDOWHANDLE Private function to get window handles of GUI windows.
%
% The idea behind having this function is to have only one place where you
% have to define the tag of the respective GUI windows (except, of course,
% in the respective m-files defining the GUI windows itself). That should
% be very much helpful for using the same GUI components for other
% toolboxes as well. Therefore, this function has to reside in the
% "private" directory of the GUI directory.
%
% Usage:
%    handle = guiGetWindowHandle();
%    handle = guiGetWindowHandle(identifier);
%
% Where, in the latter case, "identifier" is a string that defines which
% GUI window to look for. Normally, for convenience, this should be the
% name of the respective m-file the particular GUI window gets defined in.
%
% If no identifier is given, the handle of the main GUI window is returned.

try
    % Check whether we are called with input argument
    if nargin && ischar(varargin{1})
        identifier = varargin{1};
    else
        identifier = '';
    end
    
    windowTags = struct();
    windowTags.trEPRgui = 'trepr_gui_mainwindow';
    % Add here list of other window tags
    
    % Define default tag
    defaultTag = windowTags.trEPRgui;
    
    if identifier
        if isfield(windowTags,identifier)
            handle = findobj('Tag',getfield(windowTags,identifier));
        else
            handle = cell(0,1);
        end
    else
        % Get the appdata of the main window
        handle = findobj('Tag',defaultTag);
    end
catch exception
    try
        trEPRgui_bugreportwindow(exception);
    catch exception2
        % If even displaying the bug report window fails...
        exception = addCause(exception2, exception);
        throw(exception);
    end
end

end