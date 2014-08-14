function guiDisplace(dimension,step)
% GUIDISPLACE Private function to handle displacing of datasets
%
% Arguments:
%     dimension - char (x,y,z)
%     step      - scalar|string
%                 if string, one of {'first','last','end'}

% Copyright (c) 2013-14, Till Biskup
% 2014-07-23

try
    % Get appdata of main window
    mainWindow = trEPRguiGetWindowHandle();
    ad = getappdata(mainWindow);
    % Get guihandles of main window
    gh = guihandles(mainWindow);
    
    % For convenience and shorter lines
    active = ad.control.data.active;
    
    % Get dimension of active dataset
    [y,x] = size(ad.data{active}.data);

    zMax = [-(max(max(ad.data{active}.data))-...
            min(min(ad.data{active}.data))),...
            (max(max(ad.data{active}.data))-...
            min(min(ad.data{active}.data)))];
    zStep = (zMax(2)-zMax(1)) * 0.001;
    
    % Set position for dataset
    switch lower(dimension)
        case 'x'
            switch ad.control.axis.displayType
                case '1D along x'
                    if ischar(step) && strcmpi(step,'first')
                        ad.data{active}.display.displacement.data.x = -x;
                    elseif ischar(step) && any(strcmpi(step,{'last','end'}))
                        ad.data{active}.display.displacement.data.x = x;
                    elseif isscalar(step)
                        ad.data{active}.display.displacement.data.x = ...
                            ad.data{active}.display.displacement.data.x + step;
                        % Check for boundaries
                        if (ad.data{active}.display.displacement.data.x < -x)
                            ad.data{active}.display.displacement.data.x = -x;
                        end
                        if (ad.data{active}.display.displacement.data.x > x)
                            ad.data{active}.display.displacement.data.x = x;
                        end
                    else
                        return;
                    end
                    set(gh.horz2_slider,'Value',...
                        ad.data{active}.display.displacement.data.x);
                case '1D along y'
                    if ischar(step) && strcmpi(step,'first')
                        ad.data{active}.display.displacement.data.y = -y;
                    elseif ischar(step) && any(strcmpi(step,{'last','end'}))
                        ad.data{active}.display.displacement.data.y = y;
                    elseif isscalar(step)
                        ad.data{active}.display.displacement.data.y = ...
                            ad.data{active}.display.displacement.data.y + step;
                        % Check for boundaries
                        if (ad.data{active}.display.displacement.data.y < -y)
                            ad.data{active}.display.displacement.data.y = y;
                        end
                        if (ad.data{active}.display.displacement.data.y > y)
                            ad.data{active}.display.displacement.data.y = y;
                        end
                    else
                        return;
                    end
                    set(gh.horz2_slider,'Value',...
                        ad.data{active}.display.displacement.data.y);
            end
        case 'y'
            if ischar(step) && strcmpi(step,'first')
                ad.data{active}.display.displacement.data.z = zMax(1);
            elseif ischar(step) && strcmpi(step,'last')
                ad.data{active}.display.displacement.data.z = zMax(2);
            elseif isscalar(step)
                ad.data{active}.display.displacement.z = ...
                    ad.data{active}.display.displacement.data.z + (step*zStep);
                % Check for boundaries
                if (ad.data{active}.display.displacement.data.z < zMax(1))
                    ad.data{active}.display.displacement.data.z = zMax(1);
                end
                if (ad.data{active}.display.displacement.data.z > zMax(2))
                    ad.data{active}.display.displacement.data.z = zMax(2);
                end
            else
                return;
            end
            set(gh.vert3_slider,'Value',...
                ad.data{active}.display.displacement.data.z);
        case 'z'
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
