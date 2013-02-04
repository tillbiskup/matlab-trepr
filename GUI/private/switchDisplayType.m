function status = switchDisplayType(displayType)
% SWITCHDISPLAYTYPE Private function to switch between panels of the main GUI
%
% displayType - string with the name of the display type
%
% status      - return value of the function. Either 0 (OK) or -1 (failed)

% (c) 2011-13, Till Biskup
% 2013-02-04

try
    % Get appdata and handles of main window
    mainWindow = trEPRguiGetWindowHandle;
    ad = getappdata(mainWindow);
    gh = guihandles(mainWindow);
    
    if strcmpi(get(gh.displaytype_popupmenu,'Enable'),'Off')
        % The display type menu is disabled, meaning that there is no data
        % displayed currently and therefore no need to switch something.
        return;
    end
    
    displayTypes = cellstr(get(gh.displaytype_popupmenu,'String'));
    [~,idx] = max(strcmpi(displayType,displayTypes));
    set(gh.displaytype_popupmenu,'Value',idx);
    ad.control.axis.displayType = displayType;
    
    % Switch mode to none in case that we have switched to '2D plot' and
    % mode was "scale" or "displace"
    if strcmpi(displayType,'2D plot') && ...
            any(strcmpi(ad.control.mode,{'scale','displace'}))
        trEPRsetMode('none');
    end
    
    % Update appdata of main window
    setappdata(mainWindow,'control',ad.control);
    
    update_mainAxis();
    
    status = 0;
catch exception
    try
        msgStr = ['An exception occurred in ' ...
            exception.stack(1).name  '.'];
        trEPRmsg(msgStr,'error');
    catch exception2
        exception = addCause(exception2, exception);
        disp(msgStr);
    end
    try
        trEPRgui_bugreportwindow(exception);
    catch exception3
        % If even displaying the bug report window fails...
        exception = addCause(exception3, exception);
        throw(exception);
    end
    status = -1;
end

end