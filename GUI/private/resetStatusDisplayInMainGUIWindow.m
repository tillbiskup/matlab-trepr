function resetStatusDisplayInMainGUIWindow(mainGuiWindow)
% RESETSTATUSDISPLAYINMAINGUIWINDOW Resets the status display int he main GUI
% window to "OK".
%
% Copyright (c) 2015, Till Biskup
% 2015-10-18

ad = getappdata(mainGuiWindow);
ad.control.status.code = 'OK';
setappdata(mainGuiWindow,'control',ad.control);
trEPRguiUpdate('mainWindow');

end
