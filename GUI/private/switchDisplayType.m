function status = switchDisplayType(displayType)
% SWITCHDISPLAYTYPE Private function to switch between panels of the main GUI
%
% displayType - string with the name of the display type
%
% status      - return value of the function. Either 0 (OK) or -1 (failed)

% Copyright (c) 2011-15, Till Biskup
% 2015-10-18

try
    % Get appdata and handles of main window
    mainWindow = trEPRguiGetWindowHandle;
    ad = getappdata(mainWindow);
    gh = ad.guiHandles;
    
    if strcmpi(get(gh.displaytype_popupmenu,'Enable'),'Off')
        % The display type menu is disabled, meaning that there is no data
        % displayed currently and therefore no need to switch something.
        return;
    end
    
    displayTypes = cellstr(get(gh.displaytype_popupmenu,'String'));
    switch lower(displayType)
        case '2d plot'
            [~,idx] = max(strcmpi('2D',displayTypes));
            set(gh.displaytype_popupmenu,'Value',idx);
        case '1d along x'
            [~,idx] = max(strcmpi('x (time)',displayTypes));
            set(gh.displaytype_popupmenu,'Value',idx);
        case '1d along y'
            [~,idx] = max(strcmpi('y (field)',displayTypes));
            set(gh.displaytype_popupmenu,'Value',idx);
    end
    ad.control.axis.displayType = displayType;
    
    % Switch mode to none in case that we have switched to '2D plot' and
    % mode was "scale" or "displace"
    if strcmpi(displayType,'2D plot') && ...
            any(strcmpi(ad.control.mode,{'scale','displace'}))
        trEPRguiSetMode('none');
    end
    
    % Update appdata of main window
    setappdata(mainWindow,'control',ad.control);
    
    update_mainAxis();
    axesResize();
    
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
