function status = update_mainAxis()
% UPDATE_MAINAXIS Helper function that updates the main axis
%   of the trEPR GUI, namely trEPR_gui_mainwindow.
%
%   STATUS: return value for the exit status
%           -1: no tEPR_gui_mainwindow found
%            0: successfully updated main axis

% Is there currently a trEPRgui object?
mainWindow = findobj('Tag','trepr_gui_mainwindow');
if (isempty(mainWindow))
    status = -1;
    return;
end

% Get handles from main window
gh = guidata(mainWindow);

% Get appdata from main GUI
ad = getappdata(mainWindow);

% Set min and max for plots - internal function
if (ad.control.axis.limits.auto)
    setMinMax();
end

% Change enable status of pushbuttons and other elements
mainAxisChildren = findobj(...
    'Parent',gh.mainAxes_panel,...
    '-not','Type','uipanel',...
    '-not','Type','axes');
if isempty(ad.control.spectra.visible)
    set(mainAxisChildren,'Enable','off');
    splash = imread('TAtoolboxSplash.png','png');
    image(splash);
    axis off          % Remove axis ticks and numbers
    return;
else
    set(mainAxisChildren,'Enable','on');
end

% Plot depending on display type settings
% Be as robust as possible: if there is no axes, default is indices
[y,x] = size(ad.data{ad.control.spectra.active}.data);
x = linspace(1,x,x);
y = linspace(1,y,y);
if (isfield(ad.data{ad.control.spectra.active},'axes') ...
        && isfield(ad.data{ad.control.spectra.active}.axes,'x') ...
        && isfield(ad.data{ad.control.spectra.active}.axes.x,'values') ...
        && not (isempty(ad.data{ad.control.spectra.active}.axes.x.values)))
    x = ad.data{ad.control.spectra.active}.axes.x.values;
end
if (isfield(ad.data{ad.control.spectra.active},'axes') ...
        && isfield(ad.data{ad.control.spectra.active}.axes,'y') ...
        && isfield(ad.data{ad.control.spectra.active}.axes.y,'values') ...
        && not (isempty(ad.data{ad.control.spectra.active}.axes.y.values)))
    y = ad.data{ad.control.spectra.active}.axes.y.values;
end
switch ad.control.axis.displayType
    case '2D plot'
        % Disable slider
        set(gh.vert1_slider,'Enable','off');
        % Do the actual plotting
        imagesc(...
            x,...
            y,...
            ad.data{ad.control.spectra.active}.data...
            );
        set(gca,'YDir','normal');
        % Plot axis labels
        xlabel(gca,...
            sprintf('{\\it %s} / %s',...
            ad.control.axis.labels.x.measure,...
            ad.control.axis.labels.x.unit));
        ylabel(gca,...
            sprintf('{\\it %s} / %s',...
            ad.control.axis.labels.y.measure,...
            ad.control.axis.labels.y.unit));
        % Set limits of axis
        if (ad.control.axis.limits.x.min==ad.control.axis.limits.x.max)
            xLimits = [ad.control.axis.limits.x.min-1 ad.control.axis.limits.x.max+1];
        else
            xLimits = [ad.control.axis.limits.x.min ad.control.axis.limits.x.max];
        end
        if (ad.control.axis.limits.y.min==ad.control.axis.limits.y.max)
            yLimits = [ad.control.axis.limits.y.min-1 ad.control.axis.limits.y.max+1];
        else
            yLimits = [ad.control.axis.limits.y.min ad.control.axis.limits.y.max];
        end
        set(gca,...
            'XLim',xLimits,...
            'YLim',yLimits...
            );
    case '1D along x' % time profile
        % Enable slider (only if second axis has more than one value)
        if (length(y)>1)
            set(gh.vert1_slider,...
                'Enable','on',...
                'Min',1,'Max',length(y),...
                'SliderStep',[1/(length(y)) 10/(length(y))],...
                'Value',ad.data{ad.control.spectra.active}.display.position.y...
                );
        else
            set(gh.vert1_slider,...
                'Enable','off'...
                );
        end
        % Do the actual plotting
        cla reset;
        hold on;
        for k = 1 : length(ad.control.spectra.visible)
            [y,x] = size(ad.data{k}.data);
            x = linspace(1,x,x);
            y = linspace(1,y,y);
            if (isfield(ad.data{k},'axes') ...
                    && isfield(ad.data{k}.axes,'x') ...
                    && isfield(ad.data{k}.axes.x,'values') ...
                    && not (isempty(ad.data{k}.axes.x.values)))
                x = ad.data{k}.axes.x.values;
            end
            if (isfield(ad.data{k},'axes') ...
                    && isfield(ad.data{k}.axes,'y') ...
                    && isfield(ad.data{k}.axes.y,'values') ...
                    && not (isempty(ad.data{k}.axes.y.values)))
                y = ad.data{k}.axes.y.values;
            end
            % Apply filter if necessary
            y = ad.data{k}.data(...
                ad.data{k}.display.position.y,...
                :);
            if (ad.data{k}.display.smoothing.x.value > 1)
                filterfun = str2func(ad.data{k}.display.smoothing.x.filterfun);
                y = filterfun(y,ad.data{k}.display.smoothing.x.value);
            end
            currLine = plot(...
                x,...
                y,...
                'Color',ad.data{k}.line.color,...
                'LineStyle',ad.data{k}.line.style,...
                'Marker',ad.data{k}.line.marker,...
                'LineWidth',ad.data{k}.line.width...
                );
            if (k == ad.control.spectra.active)
                set(currLine,...
                    ad.control.axis.highlight.method,...
                    ad.control.axis.highlight.value...
                    );
            end
        end     
        if (ad.control.axis.grid.zero)
            zeroline = plot(...
                [ad.control.axis.limits.x.min ad.control.axis.limits.x.max],...
                [0 0],...
                'Color',[0.5 0.5 0.5],'LineStyle','--');
            % Exclude line from legend
            set(get(get(zeroline,'Annotation'),'LegendInformation'),...
                'IconDisplayStyle','off'); 
        end
        hold off;
        % Set limits of axis
        if (ad.control.axis.limits.x.min==ad.control.axis.limits.x.max)
            xLimits = [ad.control.axis.limits.x.min-1 ad.control.axis.limits.x.max+1];
        else
            xLimits = [ad.control.axis.limits.x.min ad.control.axis.limits.x.max];
        end
        if (ad.control.axis.limits.z.min==ad.control.axis.limits.z.max)
            yLimits = [ad.control.axis.limits.z.min-1 ad.control.axis.limits.z.max+1];
        else
            yLimits = [ad.control.axis.limits.z.min ad.control.axis.limits.z.max];
        end
        set(gca,...
            'XLim',xLimits,...
            'YLim',yLimits...
            );
        % Plot axis labels
        xlabel(gca,...
            sprintf('{\\it %s} / %s',...
            ad.control.axis.labels.x.measure,...
            ad.control.axis.labels.x.unit));
        ylabel(gca,...
            sprintf('{\\it %s} / %s',...
            ad.control.axis.labels.z.measure,...
            ad.control.axis.labels.z.unit));
        % Display legend - internal function
        display_legend();
    case '1D along y' % B0 spectrum
        % Enable slider (only if second axis has more than one value)
        if (length(x)>1)
            set(gh.vert1_slider,...
                'Enable','on',...
                'Min',1,'Max',length(x),...
                'SliderStep',[1/(length(x)) 10/(length(x))],...
                'Value',ad.data{ad.control.spectra.active}.display.position.x...
                );
        else
            set(gh.vert1_slider,...
                'Enable','off'...
                );
        end
        % Do the actual plotting
        cla reset;
        hold on;
        for k = 1 : length(ad.control.spectra.visible)
            [y,x] = size(ad.data{k}.data);
            x = linspace(1,x,x);
            y = linspace(1,y,y);
            if (isfield(ad.data{k},'axes') ...
                    && isfield(ad.data{k}.axes,'x') ...
                    && isfield(ad.data{k}.axes.x,'values') ...
                    && not (isempty(ad.data{k}.axes.x.values)))
                x = ad.data{k}.axes.x.values;
            end
            if (isfield(ad.data{k},'axes') ...
                    && isfield(ad.data{k}.axes,'y') ...
                    && isfield(ad.data{k}.axes.y,'values') ...
                    && not (isempty(ad.data{k}.axes.y.values)))
                y = ad.data{k}.axes.y.values;
            end
            % Apply filter if necessary
            x = ad.data{k}.data(...
                :,...
                ad.data{k}.display.position.x...
                );
            if (ad.data{k}.display.smoothing.y.value > 1)
                filterfun = str2func(ad.data{k}.display.smoothing.y.filterfun);
                x = filterfun(x,ad.data{k}.display.smoothing.y.value);
            end
            currLine = plot(...
                y,...
                x,...
                'Color',ad.data{k}.line.color,...
                'LineStyle',ad.data{k}.line.style,...
                'Marker',ad.data{k}.line.marker,...
                'LineWidth',ad.data{k}.line.width...
                );
            if (k == ad.control.spectra.active)
                set(currLine,...
                    ad.configuration.display.highlight.method,...
                    ad.configuration.display.highlight.value...
                    );
            end
        end     
        if (ad.control.axis.grid.zero)
            zeroline = plot(...
                [ad.control.axis.limits.y.min ad.control.axis.limits.y.max],...
                [0 0],...
                'Color',[0.5 0.5 0.5],'LineStyle','--');
            % Exclude line from legend
            set(get(get(zeroline,'Annotation'),'LegendInformation'),...
                'IconDisplayStyle','off'); 
        end
        hold off;
        % Set limits of axis
        if (ad.control.axis.limits.y.min==ad.control.axis.limits.y.max)
            xLimits = [ad.control.axis.limits.y.min-1 ad.control.axis.limits.y.max+1];
        else
            xLimits = [ad.control.axis.limits.y.min ad.control.axis.limits.y.max];
        end
        if (ad.control.axis.limits.z.min==ad.control.axis.limits.z.max)
            yLimits = [ad.control.axis.limits.z.min-1 ad.control.axis.limits.z.max+1];
        else
            yLimits = [ad.control.axis.limits.z.min ad.control.axis.limits.z.max];
        end
        set(gca,...
            'XLim',xLimits,...
            'YLim',yLimits...
            );
        % Plot axis labels
        xlabel(gca,...
            sprintf('{\\it %s} / %s',...
            ad.control.axis.labels.y.measure,...
            ad.control.axis.labels.y.unit));
        ylabel(gca,...
            sprintf('{\\it %s} / %s',...
            ad.control.axis.labels.z.measure,...
            ad.control.axis.labels.z.unit));
        % Display legend - internal function
        display_legend();
    otherwise
        msg = sprintf('Display type %s currently unsupported',displayType);
        add2status(msg);    
end

% Set grid
set(gca,'XGrid',ad.control.axis.grid.x);
set(gca,'YGrid',ad.control.axis.grid.y);
if (isequal(ad.control.axis.grid.x,'on'))
    set(gca,'XMinorGrid',ad.control.axis.grid.minor);
end
if (isequal(ad.control.axis.grid.y,'on'))
    set(gca,'YMinorGrid',ad.control.axis.grid.minor);
end


status = 0;

end


function display_legend()

mainWindow = findobj('Tag','trepr_gui_mainwindow');
% Get handles from main window
gh = guidata(mainWindow);

% Get appdata from main GUI
ad = getappdata(mainWindow);

% If there is no legend to be displayed
if (isequal(ad.control.axis.legend.location,'none'))
    legend('off');
    return;
end

legendLabels = cell(1,length(ad.control.spectra.visible));
for k = 1 : length(ad.control.spectra.visible)
    legendLabels{k} = strrep(ad.data{k}.label,'_','\_');
end

legend(legendLabels,'Location',ad.control.axis.legend.location);

end

function setMinMax()

% Get appdata from main GUI
mainWindow = findobj('Tag','trepr_gui_mainwindow');
ad = getappdata(mainWindow);

% Set min and max for spectra
if not (isempty(ad.control.spectra.visible))
    xmin = zeros(length(ad.control.spectra.visible),1);
    xmax = zeros(length(ad.control.spectra.visible),1);
    ymin = zeros(length(ad.control.spectra.visible),1);
    ymax = zeros(length(ad.control.spectra.visible),1);
    zmin = zeros(length(ad.control.spectra.visible),1);
    zmax = zeros(length(ad.control.spectra.visible),1);
    for k=1:length(ad.control.spectra.visible)
        % Be as robust as possible: if there is no axes, default is indices
        [y,x] = size(ad.data{k}.data);
        x = linspace(1,x,x);
        y = linspace(1,y,y);
        if (isfield(ad.data{k},'axes') ...
                && isfield(ad.data{k}.axes,'x') ...
                && isfield(ad.data{k}.axes.x,'values') ...
                && not (isempty(ad.data{k}.axes.x.values)))
            x = ad.data{k}.axes.x.values;
        end
        if (isfield(ad.data{k},'axes') ...
                && isfield(ad.data{k}.axes,'y') ...
                && isfield(ad.data{k}.axes.y,'values') ...
                && not (isempty(ad.data{k}.axes.y.values)))
            y = ad.data{k}.axes.y.values;
        end
        xmin(k) = x(1);
        xmax(k) = x(end);
        ymin(k) = y(1);
        ymax(k) = y(end);
        zmin(k) = min(min(ad.data{k}.data));
        zmax(k) = max(max(ad.data{k}.data));
    end
    ad.control.axis.limits.x.min = min(xmin);
    ad.control.axis.limits.x.max = max(xmax);
    ad.control.axis.limits.y.min = min(ymin);
    ad.control.axis.limits.y.max = max(ymax);
    ad.control.axis.limits.z.min = min(zmin);
    ad.control.axis.limits.z.max = max(zmax);
    
    % Update appdata of main window
    setappdata(mainWindow,'control',ad.control);    
end

end