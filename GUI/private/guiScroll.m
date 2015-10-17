function guiScroll(dimension,step)
% GUISCROLL Private function to handle scrolling through datasets
%
% Arguments:
%     dimension - char (x,y,z)
%     step      - scalar|string
%                 if string, one of {'first','last','end'}

% Copyright (c) 2013-15, Till Biskup
% 2015-10-17

try
    % Get appdata of main window
    mainWindow = trEPRguiGetWindowHandle();
    ad = getappdata(mainWindow);
    % Get guihandles of main window
    gh = ad.UsedByGUIData_m;
    %gh = guihandles(mainWindow);
    
    % For convenience and shorter lines
    active = ad.control.data.active;
    
    % Get dimension of active dataset
    [y,x] = size(ad.data{active}.data);
    
    % Set position for dataset
    switch lower(dimension)
        case 'x'
            if ischar(step) && strcmpi(step,'first')
                ad.data{active}.display.position.data(1) = 1;
            elseif ischar(step) && any(strcmpi(step,{'last','end'}))
                ad.data{active}.display.position.data(1) = x;
            elseif isscalar(step)
                ad.data{active}.display.position.data(1) = ...
                    ad.data{active}.display.position.data(1) + step;
                % Check for boundaries
                if (ad.data{active}.display.position.data(1) < 1)
                    ad.data{active}.display.position.data(1) = 1;
                end
                if (ad.data{active}.display.position.data(1) > x)
                    ad.data{active}.display.position.data(1) = x;
                end
            else
                return;
            end
        case 'y'
            if ischar(step) && strcmpi(step,'first')
                ad.data{active}.display.position.data(2) = 1;
            elseif ischar(step) && any(strcmpi(step,{'last','end'}))
                ad.data{active}.display.position.data(2) = y;
            elseif isscalar(step)
                ad.data{active}.display.position.data(2) = ...
                    ad.data{active}.display.position.data(2) + step;
                % Check for boundaries
                if (ad.data{active}.display.position.data(2) < 1)
                    ad.data{active}.display.position.data(2) = 1;
                end
                if (ad.data{active}.display.position.data(2) > y)
                    ad.data{active}.display.position.data(2) = y;
                end
            else
                return;
            end
        case 'z'
    end
    
    % Set slider values depending on display type settings
    switch ad.control.axis.displayType
        case '1D along x'
            set(gh.vert1_slider,'Value',ad.data{active}.display.position.data(2));
        case '1D along y'
            set(gh.vert1_slider,'Value',ad.data{active}.display.position.data(1));
        otherwise
            trEPRoptionUnknown(ad.control.axis.displayType,...
                'display type');
    end
    
    % Update appdata of main window
    setappdata(mainWindow,'data',ad.data);
    
    % Update slider panel
    update_sliderPanel();
    
    %Update main axis
    update_mainAxis();
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
