function status = trEPRguiUpdateStatusWindow(statusmessages)
% TREPRGUIUPDATESTATUSWINDOW Helper function that updates the status window
%   of the trEPR GUI, namely trEPRgui_statuswindow.
%
%   STATUSMESSAGES: cell array containing the complete status messages
%
%   STATUS: return value for the exit status
%           -1: no tEPRgui_statuswindow found
%            0: successfully updated status window
%
%   Using the findjobj function from Y. Altman, it ensures that always
%   the last (i.e., most current) line of the status window is visible.

% Copyright (c) 2011-15, Till Biskup
% 2015-10-18

% Is there currently a trEPRgui_statuswindow object?
statuswindow = trEPRguiGetWindowHandle('trEPRgui_statuswindow');
if (isempty(statuswindow))
    status = -1;
    return;
end

% Get handle for textdisplay
handles = getappdata(statuswindow,'guiHandles');
textdisplay = handles.status_text;

% Update status display
set(textdisplay,'String',statusmessages);

try
    % Display always the last (i.e., most current) line
    % uses findjobj from Yair Altman
    % Get the underlying Java control peer (a scroll-pane object)
    jhEdit = findjobj(textdisplay);
    % Get the scroll-pane's internal edit control
    jEdit = jhEdit.getComponent(0).getComponent(0);
    % Now move the caret position to the end of the text
    jEdit.setCaretPosition(jEdit.getDocument.getLength);
    % jEdit.setContentType('text/html');
catch exception
    trEPRmsg(getReport(exception, 'extended', 'hyperlinks', 'off'),...
        'warning');
end

status = 0;

end
