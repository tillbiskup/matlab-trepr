function guiZoom(action)
% GUIZOOM Private function to handle displacing of datasets
%
% Arguments:
%     action    - string
%                 Action to be performed: on|off|reset

% Copyright (c) 2013-15, Till Biskup
% 2015-10-18

try
    % Get appdata of main window
    mainWindow = trEPRguiGetWindowHandle();
    ad = getappdata(mainWindow);
    % Get guihandles of main window
    gh = ad.guiHandles;
 
    % Set position for dataset
    switch lower(action)
        case 'on'
            set(gh.zoom_togglebutton,'Value',1);
            zh = zoom(mainWindow);
            % set(zh,'UIContextMenu',handles.axisToolsContextMenu);
            set(zh,'Enable','on');
            set(zh,'Motion','both');
            set(zh,'Direction','in');
            ad.control.axis.zoom.enable = true;
        case 'off'
            set(gh.zoom_togglebutton,'Value',0);
            zh = zoom(mainWindow);
            set(zh,'Enable','off');
            refresh;
            % Get current x and y limits of main axis
            currentXLim = get(gh.mainAxis,'XLim');
            currentYLim = get(gh.mainAxis,'YLim');
            switch lower(ad.control.axis.displayType)
                case '2d plot'
                    setXLim = [ ad.control.axis.limits.x.min ...
                        ad.control.axis.limits.x.max];
                    setYLim = [ ad.control.axis.limits.y.min ...
                        ad.control.axis.limits.y.max];
                    ad.control.axis.zoom.x = get(gh.mainAxis,'XLim');
                    ad.control.axis.zoom.y = get(gh.mainAxis,'YLim');
                case '1d along x'
                    setXLim = [ ad.control.axis.limits.x.min ...
                        ad.control.axis.limits.x.max];
                    setYLim = [ ad.control.axis.limits.z.min ...
                        ad.control.axis.limits.z.max];
                    ad.control.axis.zoom.x = get(gh.mainAxis,'XLim');
                    ad.control.axis.zoom.z = get(gh.mainAxis,'YLim');
                case '1d along y'
                    setXLim = [ ad.control.axis.limits.y.min ...
                        ad.control.axis.limits.y.max];
                    setYLim = [ ad.control.axis.limits.z.min ...
                        ad.control.axis.limits.z.max];
                    ad.control.axis.zoom.y = get(gh.mainAxis,'XLim');
                    ad.control.axis.zoom.z = get(gh.mainAxis,'YLim');
            end
            if all(currentXLim == setXLim) && all(currentYLim == setYLim)
                ad.control.axis.zoom.enable = false;
                ad.control.axis.zoom.x = [0 0];
                ad.control.axis.zoom.y = [0 0];
                ad.control.axis.zoom.z = [0 0];
            elseif ad.control.data.active
                ad.control.axis.zoom.enable = true;
            else
                ad.control.axis.zoom.enable = false;
            end
        case 'reset'
            set(gh.zoom_togglebutton,'Value',0);
            zh = zoom(mainWindow);
            set(zh,'Enable','off');
            
            ad.control.axis.zoom.enable = false;
            ad.control.axis.zoom.x = [0 0];
            ad.control.axis.zoom.y = [0 0];
            ad.control.axis.zoom.z = [0 0];
            setappdata(mainWindow,'control',ad.control);
            
            %Update main axis
            update_mainAxis();
    end
    setappdata(mainWindow,'control',ad.control);
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
end

end
