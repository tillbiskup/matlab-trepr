function guiDisplace(dimension,step)
% GUIDISPLACE Private function to handle displacing of datasets
%
% Arguments:
%     dimension - char (x,y,z)
%     step      - scalar|string
%                 if string, one of {'first','last','end'}

% Copyright (c) 2013-15, Till Biskup
% 2015-10-18

try
    % Get appdata of main window
    mainWindow = trEPRguiGetWindowHandle();
    ad = getappdata(mainWindow);
    % Get guihandles of main window
    gh = ad.guiHandles;
    
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
                        ad.data{active}.display.displacement.data(1) = -x;
                    elseif ischar(step) && any(strcmpi(step,{'last','end'}))
                        ad.data{active}.display.displacement.data(1) = x;
                    elseif isscalar(step)
                        ad.data{active}.display.displacement.data(1) = ...
                            ad.data{active}.display.displacement.data(1) + step;
                        % Check for boundaries
                        if (ad.data{active}.display.displacement.data(1) < -x)
                            ad.data{active}.display.displacement.data(1) = -x;
                        end
                        if (ad.data{active}.display.displacement.data(1) > x)
                            ad.data{active}.display.displacement.data(1) = x;
                        end
                    else
                        return;
                    end
                    set(gh.horz2_slider,'Value',...
                        ad.data{active}.display.displacement.data(1));
                case '1D along y'
                    if ischar(step) && strcmpi(step,'first')
                        ad.data{active}.display.displacement.data(2) = -y;
                    elseif ischar(step) && any(strcmpi(step,{'last','end'}))
                        ad.data{active}.display.displacement.data(2) = y;
                    elseif isscalar(step)
                        ad.data{active}.display.displacement.data(2) = ...
                            ad.data{active}.display.displacement.data(2) + step;
                        % Check for boundaries
                        if (ad.data{active}.display.displacement.data(2) < -y)
                            ad.data{active}.display.displacement.data(2) = y;
                        end
                        if (ad.data{active}.display.displacement.data(2) > y)
                            ad.data{active}.display.displacement.data(2) = y;
                        end
                    else
                        return;
                    end
                    set(gh.horz2_slider,'Value',...
                        ad.data{active}.display.displacement.data(2));
            end
        case 'y'
            if ischar(step) && strcmpi(step,'first')
                ad.data{active}.display.displacement.data(3) = zMax(1);
            elseif ischar(step) && strcmpi(step,'last')
                ad.data{active}.display.displacement.data(3) = zMax(2);
            elseif isscalar(step)
                ad.data{active}.display.displacement.z = ...
                    ad.data{active}.display.displacement.data(3) + (step*zStep);
                % Check for boundaries
                if (ad.data{active}.display.displacement.data(3) < zMax(1))
                    ad.data{active}.display.displacement.data(3) = zMax(1);
                end
                if (ad.data{active}.display.displacement.data(3) > zMax(2))
                    ad.data{active}.display.displacement.data(3) = zMax(2);
                end
            else
                return;
            end
            set(gh.vert3_slider,'Value',...
                ad.data{active}.display.displacement.data(3));
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
