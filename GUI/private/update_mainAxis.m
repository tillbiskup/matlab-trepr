function status = update_mainAxis(varargin)
% UPDATE_MAINAXIS Helper function that updates the main axis
%   of the trEPR GUI, namely trEPR_gui_mainwindow.
%
%   handle (optional) - figure handle to plot to
%
%   STATUS: return value for the exit status
%           -1: no tEPR_gui_mainwindow found
%            0: successfully updated main axis

% Copyright (c) 2011-15, Till Biskup
% 2015-05-30

% Is there currently a trEPRgui object?
mainWindow = trEPRguiGetWindowHandle();
if (isempty(mainWindow))
    status = -1;
    return;
end

% Get handles and appdata from main window
gh = guidata(mainWindow);
ad = getappdata(mainWindow);

% Set current axes to the main axes of main GUI
mainAxes = gh.mainAxis;
set(mainWindow,'CurrentAxes',gh.mainAxis);

% Set defaults
showTitle = ad.control.axis.title;
showYTicks = ad.control.axis.yticks;
showYAxis = ad.control.axis.yaxis;
showBox = ad.control.axis.box;

% Check for additional input parameters
if (nargin > 0)
    if ishandle(varargin{1})
        mainAxes = newplot(varargin{1});
        % Remove first optional input argument
        varargin(1) = [];
    end
    if ~isempty(varargin) && ischar(varargin{1})
        for k=1:2:length(varargin)
            switch lower(varargin{k})
                case 'title'
                    showTitle = varargin{k+1};
                case 'noyticks'
                    showYTicks = ~varargin{k+1};
                case 'noyaxis'
                    showYAxis = ~varargin{k+1};
                case 'nobox'
                    showBox = ~varargin{k+1};
                otherwise
                    trEPRoptionUnknown(varargin{k},'optional argument');
            end
        end
    end
end

% IMPORTANT: Set main axis to active axis
axes(mainAxes);

% Change enable status of pushbuttons and other elements
mainAxisChildren = findobj(...
    'Parent',gh.mainAxes_panel,...
    '-not','Type','uipanel',...
    '-not','Type','axes');
if isempty(ad.control.data.visible)
    set(mainAxisChildren,'Enable','off');
    [path,~,~] = fileparts(mfilename('fullpath'));
    splash = imread(fullfile(path,'splashes','trEPRtoolboxSplash.png'),'png');
    image(splash);
    axis off          % Remove axis ticks and numbers
    return;
else
    set(mainAxisChildren,'Enable','on');
end

% Set min and max for plots - internal function
setMinMax();

% Get appdata from main window
% IMPORTANT: Need to do that (again) after calling setMinMax()
ad = getappdata(mainWindow);

% Just to be on the save side, check whether we have a currently active
% spectrum
if ~(ad.control.data.active)
    if showTitle
        % Set title to empty string
        title('');
    end
    trEPRmsg([mfilename ' : No active spectrum'],'info');
    return;
end

% For shorter and easier to read code:
active = ad.control.data.active;

% Set units if only one visible dataset or only active visible
if length(ad.control.data.visible) == 1 || ad.control.axis.onlyActive
    ad.control.axis.labels.x.unit = ad.data{active}.axes.data(1).unit;
    ad.control.axis.labels.y.unit = ad.data{active}.axes.data(2).unit;
    ad.control.axis.labels.z.unit = ad.data{active}.axes.data(3).unit;
    setappdata(mainWindow,'control',ad.control);
end

% Plot depending on display type settings
x = ad.data{active}.axes.data(1).values;
y = ad.data{active}.axes.data(2).values;

% In case we have no axes values, should not happen, but might do...
% (simulation for example)
if isempty(x)
    x=1;
end
if isempty(y)
    y=1;
end

% Get displacement slider factors from configuration
% Assume that if the "slider" configuration struct exists, the necessary
% field exists as well
if isfield(ad.configuration,'slider') 
    displacement.x.factor = ad.configuration.slider.displacement.x.factor;
    displacement.y.factor = ad.configuration.slider.displacement.y.factor;
    displacement.z.factor = ad.configuration.slider.displacement.z.factor;
else
    displacement.x.factor = 1;
    displacement.y.factor = 1;
    displacement.z.factor = 1;
end

% Handle data/calculated
data = getData(ad.data{active});

switch ad.control.axis.displayType
    case '2D plot'
        % Disable slider
        sliderHandles = findobj(...
            'Parent',gh.mainAxes_panel,...
            'style','slider');
        set(sliderHandles,'Enable','off');
        set(gh.reset_button,'Enable','off');
        if ad.control.axis.colormap.individual
            if ad.control.axis.colormap.symmetric
                clims = [-max(abs([min(min(data)) max(max(data))])) ...
                    max(abs([min(min(data)) max(max(data))]))];
            else
                clims = [min(min(data)) max(max(data))];
            end
        else
            minmax = allMinMax;
            if ad.control.axis.colormap.symmetric
                clims = [-max(abs([min(minmax(:,1)) max(minmax(:,2))])) ...
                    max(abs([min(minmax(:,1)) max(minmax(:,2))]))];
            else
                clims = [min(minmax(:,1)) max(minmax(:,2))];
            end
        end
        % Apply filter if necessary
        if (ad.data{active}.display.smoothing.data(1).parameters.width > 0)
            filterfun = str2func(ad.data{active}.display.smoothing.data(1).filterfun);
            for yidx = 1:size(data,1)
                data(yidx,:) = filterfun(data(yidx,:),...
                    ad.data{active}.display.smoothing.data(1).parameters);
            end
        end
        if (ad.data{active}.display.smoothing.data(2).parameters.width > 0)
            filterfun = str2func(ad.data{active}.display.smoothing.data(2).filterfun);
            for xidx = 1:size(data,2)
                data(:,xidx) = filterfun(data(:,xidx),...
                    ad.data{active}.display.smoothing.data(2).parameters);
            end
        end
        % For very special cases where limits are identical
        % (example: user subtracted dataset from itself)
        if min(clims) == max(clims)
            clims(1) = clims(1)-0.000000001;
            clims(2) = clims(2)+0.000000001;
        end
        % Do the actual plotting
        imagesc(x,y,data,clims);
        set(gca,'YDir','normal');
        set(gca,'Tag','mainAxis');
        % Plot axis labels
        xlabel(gca,...
            sprintf('{\\it %s} / %s',...
            ad.control.axis.labels.x.measure,...
            ad.control.axis.labels.x.unit));
        if showYAxis
            ylabel(gca,...
                sprintf('{\\it %s} / %s',...
                ad.control.axis.labels.y.measure,...
                ad.control.axis.labels.y.unit));
        end
        % Set limits of axis
        if (ad.control.axis.limits.x.min==ad.control.axis.limits.x.max)
            xLimits = [ad.control.axis.limits.x.min-1 ...
                ad.control.axis.limits.x.max+1];
        else
            xLimits = [ad.control.axis.limits.x.min ...
                ad.control.axis.limits.x.max];
        end
        if (ad.control.axis.limits.y.min==ad.control.axis.limits.y.max)
            yLimits = [ad.control.axis.limits.y.min-1 ...
                ad.control.axis.limits.y.max+1];
        else
            yLimits = [ad.control.axis.limits.y.min ...
                ad.control.axis.limits.y.max];
        end
        if ad.control.axis.zoom.enable
            if any(ad.control.axis.zoom.x)
                xLimits = ad.control.axis.zoom.x;
            end
            if any(ad.control.axis.zoom.y)
                yLimits = ad.control.axis.zoom.y;
            end
        end
        set(mainAxes,...
            'XLim',xLimits,...
            'YLim',yLimits...
            );
        if ad.control.axis.characteristics
            trEPRdatasetShowCharacteristics(mainAxes,ad.data{active});
        end
        if ad.control.axis.BGpositions.enable
            trEPRdatasetShowBGpositions(mainAxes,ad.data{active},...
                'DisplayType','2D',...
                'Shift',ad.control.axis.BGpositions.shift);
        end
        % Set axes limits according to zoom
        if ad.control.axis.zoom.enable
            if min(ad.control.axis.zoom.x) ~= max(ad.control.axis.zoom.x)
                set(mainAxes,'XLim',ad.control.axis.zoom.x);
            end
            if min(ad.control.axis.zoom.y) ~= max(ad.control.axis.zoom.y)
                set(mainAxes,'YLim',ad.control.axis.zoom.y);
            end
        end
        if ad.control.axis.projectionAxes.enable
            plotProjection();
        end
    case '1D along x' % time profile
        % Enable sliders
        sliderHandles = findobj(...
            'Parent',gh.mainAxes_panel,...
            'style','slider');
        set(sliderHandles,'Enable','on');
        % Enable displacement slider
        set(gh.vert3_slider,...
            'Enable','on',...
            'Min',-(max(max(data))-min(min(data)))*displacement.z.factor,...
            'Max',(max(max(data))-min(min(data)))*displacement.z.factor,...
            'SliderStep',[0.001 0.01]...
            );
        set(gh.horz2_slider,...
            'Enable','on',...
            'Min',-length(x)*displacement.x.factor,...
            'Max',length(x)*displacement.x.factor,...
            'SliderStep',[1/(displacement.x.factor*2*length(x)) ...
            10/(displacement.x.factor*2*length(x))]...
            );
        set(gh.reset_button,'Enable','on');
        % Enable position slider only if second axis has more than one value
        if (length(y)>1)
            set(gh.vert1_slider,...
                'Enable','on',...
                'Min',1,'Max',length(y),...
                'SliderStep',[1/(length(y)) 10/(length(y))],...
                'Value',ad.data{active}.display.position.data(2)...
                );
        else
            set(gh.vert1_slider,...
                'Enable','off'...
                );
        end
        % Do the actual plotting
        cla(mainAxes,'reset');
        hold(mainAxes,'on');
        if ad.control.axis.onlyActive
            k = ad.control.data.active;
            data = getData(ad.data{k});
            x = ad.data{k}.axes.data(1).values;
            y = data(ad.data{k}.display.position.data(2),:);
            % In case that we loaded 1D data...
            if isscalar(x)
                x = [x x+1];
            end
            if isscalar(y)
                y = [y y+1];
            end
            % Normalise if necessary
            if ad.control.axis.normalisation.enable
                if strcmpi(ad.control.axis.normalisation.dimension,'1D')
                    switch lower(ad.control.axis.normalisation.type)
                        case {'pk-pk','pk2pk'}
                            y = y/(max(y)-min(y));
                        case 'area'
                            y = y/sum(abs(y));
                        case 'max'
                            y = y/max(y);
                        case 'min'
                            y = y/abs(min(y));
                    end
                else
                    switch lower(ad.control.axis.normalisation.type)
                        case {'pk-pk','pk2pk'}
                            y = y/(max(max(ad.data{k}.data))-...
                                min(min(ad.data{k}.data)));
                        case 'area'
                            y = y/sum(sum(abs(ad.data{k}.data)));
                        case 'max'
                            y = y/max(max(ad.data{k}.data));
                        case 'min'
                            y = y/abs(min(min(ad.data{k}.data)));
                    end
                end
            end
            % Apply displacement if necessary
            % IMPORTANT: Apply AFTER normalisation
            if (ad.data{k}.display.displacement.data(1) ~= 0)
                x = x + (x(2)-x(1)) * ad.data{k}.display.displacement.data(1);
            end
            if (ad.data{k}.display.displacement.data(3) ~= 0)
                y = y + ad.data{k}.display.displacement.data(3);
            end
            % Apply filter if necessary
            if (ad.data{k}.display.smoothing.data(1).parameters.width > 0)
                filterfun = str2func(ad.data{k}.display.smoothing.data(1).filterfun);
                y = filterfun(y,ad.data{k}.display.smoothing.data(1).parameters);
            end
            % Apply scaling if necessary
            if (ad.data{k}.display.scaling.data(1) ~= 0)
                x = linspace(...
                    (((x(end)-x(1))/2)+x(1))-((x(end)-x(1))*ad.data{k}.display.scaling.data(1)/2),...
                    (((x(end)-x(1))/2)+x(1))+((x(end)-x(1))*ad.data{k}.display.scaling.data(1)/2),...
                    length(x));
            end
            if (ad.data{k}.display.scaling.data(3) ~= 0)
                y = y * ad.data{k}.display.scaling.data(3);
            end
            if ad.control.axis.stdev && isfield(ad.data{k},'avg') ...
                    && strcmpi(ad.data{k}.avg.dimension,'y')
                errorbar(...
                    mainAxes,...
                    x,...
                    y,...
                    ad.data{k}.avg.stdev,...
                    'Color',ad.data{k}.display.lines.data.color,...
                    'LineStyle',ad.data{k}.display.lines.data.style,...
                    'Marker',ad.data{k}.display.lines.data.marker.type,...
                    'MarkerEdgeColor',ad.data{k}.display.lines.data.marker.edgeColor,...
                    'MarkerFaceColor',ad.data{k}.display.lines.data.marker.faceColor,...
                    'MarkerSize',ad.data{k}.display.lines.data.marker.size,...
                    'LineWidth',ad.data{k}.display.lines.data.width...
                    );
            else
                plot(...
                    mainAxes,...
                    x,...
                    y,...
                    'Color',ad.data{k}.display.lines.data.color,...
                    'LineStyle',ad.data{k}.display.lines.data.style,...
                    'Marker',ad.data{k}.display.lines.data.marker.type,...
                    'MarkerEdgeColor',ad.data{k}.display.lines.data.marker.edgeColor,...
                    'MarkerFaceColor',ad.data{k}.display.lines.data.marker.faceColor,...
                    'MarkerSize',ad.data{k}.display.lines.data.marker.size,...
                    'LineWidth',ad.data{k}.display.lines.data.width...
                    );
            end
        else
            for l = 1 : length(ad.control.data.visible)
                k = ad.control.data.visible(l);
                data = getData(ad.data{k});
                x = ad.data{k}.axes.data(1).values;
                y = data(ad.data{k}.display.position.data(2),:);
                % In case that we loaded 1D data...
                if isscalar(x)
                    x = [x x+1]; %#ok<AGROW>
                end
                if isscalar(y)
                    y = [y y+1]; %#ok<AGROW>
                end
                % Normalise if necessary
                if ad.control.axis.normalisation.enable
                    if strcmpi(ad.control.axis.normalisation.dimension,'1D')
                        switch lower(ad.control.axis.normalisation.type)
                            case {'pk-pk','pk2pk'}
                                y = y/(max(y)-min(y));
                            case 'area'
                                y = y/sum(abs(y));
                            case 'max'
                                y = y/max(y);
                            case 'min'
                                y = y/abs(min(y));
                        end
                    else
                        switch lower(ad.control.axis.normalisation.type)
                            case {'pk-pk','pk2pk'}
                                y = y/(max(max(ad.data{k}.data))-...
                                    min(min(ad.data{k}.data)));
                            case 'area'
                                y = y/sum(sum(abs(ad.data{k}.data)));
                            case 'max'
                                y = y/max(max(ad.data{k}.data));
                            case 'min'
                                y = y/abs(min(min(ad.data{k}.data)));
                        end
                    end
                end
                % Apply displacement if necessary
                % IMPORTANT: Apply AFTER normalisation
                if (ad.data{k}.display.displacement.data(1) ~= 0)
                    x = x + (x(2)-x(1)) * ad.data{k}.display.displacement.data(1);
                end
                if (ad.data{k}.display.displacement.data(3) ~= 0)
                    y = y + ad.data{k}.display.displacement.data(3);
                end
                % Apply filter if necessary
                if (ad.data{k}.display.smoothing.data(1).parameters.width > 0)
                    filterfun = str2func(ad.data{k}.display.smoothing.data(1).filterfun);
                    y = filterfun(y,ad.data{k}.display.smoothing.data(1).parameters);
                end
                % Apply scaling if necessary
                if (ad.data{k}.display.scaling.data(1) ~= 0)
                    x = linspace(...
                        (((x(end)-x(1))/2)+x(1))-((x(end)-x(1))*ad.data{k}.display.scaling.data(1)/2),...
                        (((x(end)-x(1))/2)+x(1))+((x(end)-x(1))*ad.data{k}.display.scaling.data(1)/2),...
                        length(x));
                end
                if (ad.data{k}.display.scaling.data(3) ~= 0)
                    y = y * ad.data{k}.display.scaling.data(3);
                end
                if ad.control.axis.stdev && isfield(ad.data{k},'avg') ...
                        && strcmpi(ad.data{k}.avg.dimension,'y')
                    errBar = errorbar(...
                        mainAxes,...
                        x,...
                        y,...
                        ad.data{k}.avg.stdev,...
                        'Color',ad.data{k}.display.lines.data.color,...
                        'LineStyle',ad.data{k}.display.lines.data.style,...
                        'Marker',ad.data{k}.display.lines.data.marker.type,...
                        'MarkerEdgeColor',ad.data{k}.display.lines.data.marker.edgeColor,...
                        'MarkerFaceColor',ad.data{k}.display.lines.data.marker.faceColor,...
                        'MarkerSize',ad.data{k}.display.lines.data.marker.size,...
                        'LineWidth',ad.data{k}.display.lines.data.width...
                        );
                    if (k == active) && ...
                            ~isempty(ad.control.axis.highlight.method)
                        set(errBar,...
                            ad.control.axis.highlight.method,...
                            ad.control.axis.highlight.value...
                            );
                    end
                else
                    currLine = plot(...
                        mainAxes,...
                        x,...
                        y,...
                        'Color',ad.data{k}.display.lines.data.color,...
                        'LineStyle',ad.data{k}.display.lines.data.style,...
                        'Marker',ad.data{k}.display.lines.data.marker.type,...
                        'MarkerEdgeColor',ad.data{k}.display.lines.data.marker.edgeColor,...
                        'MarkerFaceColor',ad.data{k}.display.lines.data.marker.faceColor,...
                        'MarkerSize',ad.data{k}.display.lines.data.marker.size,...
                        'LineWidth',ad.data{k}.display.lines.data.width...
                        );
                    if (k == active) && ...
                            ~isempty(ad.control.axis.highlight.method) && ...
                            length(ad.control.data.visible) > 1
                        set(currLine,...
                            ad.control.axis.highlight.method,...
                            ad.control.axis.highlight.value...
                            );
                    end
                end
                clear data;
            end
        end
        if ad.control.data.temporary.visible
            tmpData = trEPRalgebra(...
                ad.data(ad.control.data.temporary.datasets),...
                ad.control.data.temporary.parameters);
            plot(...
                mainAxes,...
                tmpData.axes.data(1).values,...
                tmpData.data(tmpData.display.position.data(2),:),...
                'Color',ad.control.axis.lines.temporary.color,...
                'LineStyle',ad.control.axis.lines.temporary.style,...
                'Marker',ad.control.axis.lines.temporary.marker.type,...
                'MarkerEdgeColor',ad.control.axis.lines.temporary.marker.edgeColor,...
                'MarkerFaceColor',ad.control.axis.lines.temporary.marker.faceColor,...
                'MarkerSize',ad.control.axis.lines.temporary.marker.size,...
                'LineWidth',ad.control.axis.lines.temporary.width...
                );
        end
        hold(mainAxes,'off');
        if (ad.control.axis.grid.zero.visible)
            line(...
                [ad.control.axis.limits.x.min ad.control.axis.limits.x.max],...
                [0 0],...
                'Color',ad.control.axis.grid.zero.color,...
                'LineWidth',ad.control.axis.grid.zero.width,...
                'LineStyle',ad.control.axis.grid.zero.style,...
                'Parent',mainAxes);
        end
        % Set limits of axis
        if (ad.control.axis.limits.x.min==ad.control.axis.limits.x.max)
            xLimits = [ad.control.axis.limits.x.min-1 ...
                ad.control.axis.limits.x.max+1];
        else
            xLimits = [ad.control.axis.limits.x.min ...
                ad.control.axis.limits.x.max];
        end
        if (ad.control.axis.limits.z.min==ad.control.axis.limits.z.max)
            yLimits = [ad.control.axis.limits.z.min-1 ...
                ad.control.axis.limits.z.max+1];
        else
            yLimits = [ad.control.axis.limits.z.min ...
                ad.control.axis.limits.z.max];
        end
        if ad.control.axis.zoom.enable
            if any(ad.control.axis.zoom.x)
                xLimits = ad.control.axis.zoom.x;
            end
            if any(ad.control.axis.zoom.z)
                yLimits = ad.control.axis.zoom.z;
            end
        end
        set(mainAxes,...
            'XLim',xLimits,...
            'YLim',yLimits...
            );
        % Plot axis labels
        if isempty(ad.control.axis.labels.x.unit)
            xlabel(mainAxes,...
                sprintf('{\\it %s}',...
                ad.control.axis.labels.x.measure));
        else
            xlabel(mainAxes,...
                sprintf('{\\it %s} / %s',...
                ad.control.axis.labels.x.measure,...
                ad.control.axis.labels.x.unit));
        end
        if showYAxis
            if isempty(ad.control.axis.labels.z.unit)
                ylabel(mainAxes,...
                    sprintf('{\\it %s}',...
                    ad.control.axis.labels.z.measure));
            else
                ylabel(mainAxes,...
                    sprintf('{\\it %s} / %s',...
                    ad.control.axis.labels.z.measure,...
                    ad.control.axis.labels.z.unit));
            end
        end
        % Display legend - internal function
        display_legend(mainAxes);
        % Set axes limits according to zoom
        if ad.control.axis.zoom.enable
            if min(ad.control.axis.zoom.x) ~= max(ad.control.axis.zoom.x)
                set(mainAxes,'XLim',ad.control.axis.zoom.x);
            end
            if min(ad.control.axis.zoom.z) ~= max(ad.control.axis.zoom.z)
                set(mainAxes,'YLim',ad.control.axis.zoom.z);
            end
        end
        if ad.control.axis.residualsAxes.enable
            plotResiduals();
        end
    case '1D along y' % B0 spectrum
        % Enable sliders
        sliderHandles = findobj(...
            'Parent',gh.mainAxes_panel,...
            'style','slider');
        set(sliderHandles,'Enable','on');
        % Enable displacement slider
        set(gh.vert3_slider,...
            'Enable','on',...
            'Min',-(max(max(data))-min(min(data)))*displacement.z.factor,...
            'Max',(max(max(data))-min(min(data)))*displacement.z.factor,...
            'SliderStep',[0.001 0.01]...
            );
        set(gh.horz2_slider,...
            'Enable','on',...
            'Min',-length(y)*displacement.y.factor,...
            'Max',length(y)*displacement.y.factor,...
            'SliderStep',[1/(displacement.y.factor*2*length(y))...
            10/(displacement.y.factor*2*length(y))]...
            );
        set(gh.reset_button,'Enable','on');
        % Enable position slider only if second axis has more than one value
        if (length(x)>1)
            set(gh.vert1_slider,...
                'Enable','on',...
                'Min',1,'Max',length(x),...
                'SliderStep',[1/(length(x)) 10/(length(x))],...
                'Value',ad.data{active}.display.position.data(1)...
                );
        else
            set(gh.vert1_slider,...
                'Enable','off'...
                );
        end
        % Do the actual plotting
        cla(mainAxes,'reset');
        hold(mainAxes,'on');
        if ad.control.axis.onlyActive
            k = ad.control.data.active;
            data = getData(ad.data{k});
            y = ad.data{k}.axes.data(2).values;
            x = data(:,ad.data{k}.display.position.data(1));
            % In case that we loaded 1D data...
            if isscalar(x)
                x = [x x+1];
            end
            if isscalar(y)
                y = [y y+1];
            end
            % Normalise if necessary
            if ad.control.axis.normalisation.enable
                if strcmpi(ad.control.axis.normalisation.dimension,'1D')
                    switch lower(ad.control.axis.normalisation.type)
                        case {'pk-pk','pk2pk'}
                            x = x/(max(x)-min(x));
                        case 'area'
                            x = x/sum(abs(x));
                        case 'max'
                            x = x/max(x);
                        case 'min'
                            x = x/abs(min(x));
                    end
                else
                    switch lower(ad.control.axis.normalisation.type)
                        case {'pk-pk','pk2pk'}
                            x = x/(max(max(data))-min(min(data)));
                        case 'area'
                            x = x/sum(sum(abs(data)));
                        case 'max'
                            x = x/max(max(data));
                        case 'min'
                            x = x/abs(min(min(data)));
                    end
                end
            end
            % Apply displacement if necessary
            % IMPORTANT: Apply AFTER normalisation
            if (ad.data{k}.display.displacement.data(2) ~= 0)
                y = y + (y(2)-y(1)) * ad.data{k}.display.displacement.data(2);
            end
            if (ad.data{k}.display.displacement.data(3) ~= 0)
                x = x + ad.data{k}.display.displacement.data(3);
            end
            % Apply filter if necessary
            if (ad.data{k}.display.smoothing.data(2).parameters.width > 0)
                filterfun = str2func(ad.data{k}.display.smoothing.data(2).filterfun);
                x = filterfun(x,ad.data{k}.display.smoothing.data(2).parameters.width);
            end
            % Apply scaling if necessary
            if (ad.data{k}.display.scaling.data(2) ~= 0)
                y = linspace(...
                    (((y(end)-y(1))/2)+y(1))-((y(end)-y(1))*ad.data{k}.display.scaling.data(2)/2),...
                    (((y(end)-y(1))/2)+y(1))+((y(end)-y(1))*ad.data{k}.display.scaling.data(2)/2),...
                    length(y));
            end
            if (ad.data{k}.display.scaling.data(3) ~= 0)
                x = x * ad.data{k}.display.scaling.data(3);
            end
            if ad.control.axis.stdev && isfield(ad.data{k},'avg') ...
                    && strcmpi(ad.data{k}.avg.dimension,'x')
                errorbar(...
                    mainAxes,...
                    y,...
                    x,...
                    ad.data{k}.avg.stdev,...
                    'Color',ad.data{k}.display.lines.data.color,...
                    'LineStyle',ad.data{k}.display.lines.data.style,...
                    'Marker',ad.data{k}.display.lines.data.marker.type,...
                    'MarkerEdgeColor',ad.data{k}.display.lines.data.marker.edgeColor,...
                    'MarkerFaceColor',ad.data{k}.display.lines.data.marker.faceColor,...
                    'MarkerSize',ad.data{k}.display.lines.data.marker.size,...
                    'LineWidth',ad.data{k}.display.lines.data.width...
                    );
            else
                plot(...
                    mainAxes,...
                    y,...
                    x,...
                    'Color',ad.data{k}.display.lines.data.color,...
                    'LineStyle',ad.data{k}.display.lines.data.style,...
                    'Marker',ad.data{k}.display.lines.data.marker.type,...
                    'MarkerEdgeColor',ad.data{k}.display.lines.data.marker.edgeColor,...
                    'MarkerFaceColor',ad.data{k}.display.lines.data.marker.faceColor,...
                    'MarkerSize',ad.data{k}.display.lines.data.marker.size,...
                    'LineWidth',ad.data{k}.display.lines.data.width...
                    );
            end
            % WARNING: Quick and dirty fix to display calculated data along
            %          with measured data. Needs to be rewritten soon!
            % TB 2013/11/28
            if ad.control.axis.sim && isfield(ad.data{k},'calculated') && ...
                    ~isempty(ad.data{k}.calculated)
                plot(...
                    mainAxes,...
                    y,...
                    ad.data{k}.calculated,...
                    'Color',ad.data{k}.display.lines.calculated.color,...
                    'LineStyle',ad.data{k}.display.lines.calculated.style,...
                    'Marker',ad.data{k}.display.lines.calculated.marker.type,...
                    'MarkerEdgeColor',ad.data{k}.display.lines.calculated.marker.edgeColor,...
                    'MarkerFaceColor',ad.data{k}.display.lines.calculated.marker.faceColor,...
                    'MarkerSize',ad.data{k}.display.lines.calculated.marker.size,...
                    'LineWidth',ad.data{k}.display.lines.calculated.width...
                    );
            end
        else % onlyActive
            for l = 1 : length(ad.control.data.visible)
                k = ad.control.data.visible(l);
                data = getData(ad.data{k});
                y = ad.data{k}.axes.data(2).values;
                x = data(:,ad.data{k}.display.position.data(1));
                % In case that we loaded 1D data...
                if isscalar(x)
                    x = [x x+1]; %#ok<AGROW>
                end
                if isscalar(y)
                    y = [y y+1]; %#ok<AGROW>
                end
                % Normalise if necessary
                if ad.control.axis.normalisation.enable
                    if strcmpi(ad.control.axis.normalisation.dimension,'1D')
                        switch lower(ad.control.axis.normalisation.type)
                            case {'pk-pk','pk2pk'}
                                x = x/(max(x)-min(x));
                            case 'area'
                                x = x/sum(abs(x));
                            case 'max'
                                x = x/max(x);
                            case 'min'
                                x = x/abs(min(x));
                        end
                    else
                        switch lower(ad.control.axis.normalisation.type)
                            case {'pk-pk','pk2pk'}
                                x = x/(max(max(ad.data{k}.data))-...
                                    min(min(ad.data{k}.data)));
                            case 'area'
                                x = x/sum(sum(abs(ad.data{k}.data)));
                            case 'max'
                                x = x/max(max(ad.data{k}.data));
                            case 'min'
                                x = x/abs(min(min(ad.data{k}.data)));
                        end
                    end
                end
                % Apply displacement if necessary
                % IMPORTANT: Apply AFTER normalisation
                if (ad.data{k}.display.displacement.data(2) ~= 0)
                    y = y + (y(2)-y(1)) * ad.data{k}.display.displacement.data(2);
                end
                if (ad.data{k}.display.displacement.data(3) ~= 0)
                    x = x + ad.data{k}.display.displacement.data(3);
                end
                % Apply filter if necessary
                if (ad.data{k}.display.smoothing.data(2).parameters.width > 0)
                    filterfun = str2func(ad.data{k}.display.smoothing.data(2).filterfun);
                    x = filterfun(x,ad.data{k}.display.smoothing.data(2).parameters.width);
                end
                % Apply scaling if necessary
                if (ad.data{k}.display.scaling.data(2) ~= 0)
                    y = linspace(...
                        (((y(end)-y(1))/2)+y(1))-((y(end)-y(1))*ad.data{k}.display.scaling.data(2)/2),...
                        (((y(end)-y(1))/2)+y(1))+((y(end)-y(1))*ad.data{k}.display.scaling.data(2)/2),...
                        length(y));
                end
                if (ad.data{k}.display.scaling.data(3) ~= 0)
                    x = x * ad.data{k}.display.scaling.data(3);
                end
                if ad.control.axis.stdev && isfield(ad.data{k},'avg') ...
                        && strcmpi(ad.data{k}.avg.dimension,'x')
                    errBar = errorbar(...
                        mainAxes,...
                        y,...
                        x,...
                        ad.data{k}.avg.stdev,...
                        'Color',ad.data{k}.display.lines.data.color,...
                        'LineStyle',ad.data{k}.display.lines.data.style,...
                        'Marker',ad.data{k}.display.lines.data.marker.type,...
                        'MarkerEdgeColor',ad.data{k}.display.lines.data.marker.edgeColor,...
                        'MarkerFaceColor',ad.data{k}.display.lines.data.marker.faceColor,...
                        'MarkerSize',ad.data{k}.display.lines.data.marker.size,...
                        'LineWidth',ad.data{k}.display.lines.data.width...
                        );
                    if (k == active) && ...
                            ~isempty(ad.control.axis.highlight.method)
                        set(errBar,...
                            ad.control.axis.highlight.method,...
                            ad.control.axis.highlight.value...
                            );
                    end
                else
                    currLine = plot(...
                        mainAxes,...
                        y,...
                        x,...
                        'Color',ad.data{k}.display.lines.data.color,...
                        'LineStyle',ad.data{k}.display.lines.data.style,...
                        'Marker',ad.data{k}.display.lines.data.marker.type,...
                        'MarkerEdgeColor',ad.data{k}.display.lines.data.marker.edgeColor,...
                        'MarkerFaceColor',ad.data{k}.display.lines.data.marker.faceColor,...
                        'MarkerSize',ad.data{k}.display.lines.data.marker.size,...
                        'LineWidth',ad.data{k}.display.lines.data.width...
                        );
                    if (k == active) && ...
                            ~isempty(ad.control.axis.highlight.method) && ...
                            length(ad.control.data.visible) > 1 
                        set(currLine,...
                            ad.control.axis.highlight.method,...
                            ad.control.axis.highlight.value...
                            );
                    end
                end
                % WARNING: Quick and dirty fix to display calculated data along
                %          with measured data. Needs to be rewritten soon!
                % TB 2013/11/28
                if ad.control.axis.sim && isfield(ad.data{k},'calculated') ...
                        && ~isempty(ad.data{k}.calculated)
                    plot(...
                        mainAxes,...
                        y,...
                        ad.data{k}.calculated,...
                        'Color',ad.data{k}.display.lines.calculated.color,...
                        'LineStyle',ad.data{k}.display.lines.calculated.style,...
                        'Marker',ad.data{k}.display.lines.calculated.marker.type,...
                        'MarkerEdgeColor',ad.data{k}.display.lines.calculated.marker.edgeColor,...
                        'MarkerFaceColor',ad.data{k}.display.lines.calculated.marker.faceColor,...
                        'MarkerSize',ad.data{k}.display.lines.calculated.marker.size,...
                        'LineWidth',ad.data{k}.display.lines.calculated.width...
                        );
                end
            end
        end
        if ad.control.data.temporary.visible
            tmpData = trEPRalgebra(...
                ad.data(ad.control.data.temporary.datasets),...
                ad.control.data.temporary.parameters);
            plot(...
                mainAxes,...
                tmpData.axes.data(2).values,...
                tmpData.data(:,tmpData.display.position.data(1)),...
                'Color',ad.control.axis.lines.temporary.color,...
                'LineStyle',ad.control.axis.lines.temporary.style,...
                'Marker',ad.control.axis.lines.temporary.marker.type,...
                'MarkerEdgeColor',ad.control.axis.lines.temporary.marker.edgeColor,...
                'MarkerFaceColor',ad.control.axis.lines.temporary.marker.faceColor,...
                'MarkerSize',ad.control.axis.lines.temporary.marker.size,...
                'LineWidth',ad.control.axis.lines.temporary.width...
                );
        end
        if (ad.control.axis.grid.zero.visible)
            line(...
                [ad.control.axis.limits.y.min ad.control.axis.limits.y.max],...
                [0 0],...
                'Color',ad.control.axis.grid.zero.color,...
                'LineWidth',ad.control.axis.grid.zero.width,...
                'LineStyle',ad.control.axis.grid.zero.style,...
                'Parent',mainAxes);
        end
        hold(mainAxes,'off');
        % Set limits of axis
        if (ad.control.axis.limits.y.min==ad.control.axis.limits.y.max)
            xLimits = [ad.control.axis.limits.y.min-1 ...
                ad.control.axis.limits.y.max+1];
        else
            xLimits = [ad.control.axis.limits.y.min ...
                ad.control.axis.limits.y.max];
        end
        if (ad.control.axis.limits.z.min==ad.control.axis.limits.z.max)
            yLimits = [ad.control.axis.limits.z.min-1 ...
                ad.control.axis.limits.z.max+1];
        else
            yLimits = [ad.control.axis.limits.z.min ...
                ad.control.axis.limits.z.max];
        end
        if ad.control.axis.zoom.enable
            if any(ad.control.axis.zoom.y)
                xLimits = ad.control.axis.zoom.y;
            end
            if any(ad.control.axis.zoom.z)
                yLimits = ad.control.axis.zoom.z;
            end
        end
        set(mainAxes,...
            'XLim',xLimits,...
            'YLim',yLimits...
            );
        % Plot axis labels
        if isempty(ad.control.axis.labels.y.unit)
            xlabel(mainAxes,...
                sprintf('{\\it %s}',...
                ad.control.axis.labels.y.measure));
        else
            xlabel(mainAxes,...
                sprintf('{\\it %s} / %s',...
                ad.control.axis.labels.y.measure,...
                ad.control.axis.labels.y.unit));
        end
        if showYAxis
            if isempty(ad.control.axis.labels.z.unit)
                ylabel(mainAxes,...
                    sprintf('{\\it %s}',...
                    ad.control.axis.labels.z.measure));
            else
                ylabel(mainAxes,...
                    sprintf('{\\it %s} / %s',...
                    ad.control.axis.labels.z.measure,...
                    ad.control.axis.labels.z.unit));
            end
        end
        % Display legend - internal function
        display_legend(mainAxes);
        if ad.control.axis.BGpositions.enable
            trEPRdatasetShowBGpositions(mainAxes,ad.data{active},...
                'DisplayType','1D',...
                'Shift',ad.control.axis.BGpositions.shift);
        end
        % Set axes limits according to zoom
        if ad.control.axis.zoom.enable
            if min(ad.control.axis.zoom.y) ~= max(ad.control.axis.zoom.y)
                set(mainAxes,'XLim',ad.control.axis.zoom.y);
            end
            if min(ad.control.axis.zoom.z) ~= max(ad.control.axis.zoom.z)
                set(mainAxes,'YLim',ad.control.axis.zoom.z);
            end
        end
        if ad.control.axis.residualsAxes.enable
            plotResiduals();
        end
    otherwise
        trEPRoptionUnknown(ad.control.axis.displayType,'display type');
        return;
end

% Set title (label of currently active dataset)
if showTitle
    title(['Active dataset: ' strrep(ad.data{active}.label,'_','\_')]);
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

% Set yaxis and yticks according to settings
if ~showYAxis
    % No ticks, therefore no tick marks
    set(gca,'YTick',[]);
    % Set yaxis color to white to fake nonexisting axis
    set(gca,'YColor',[1 1 1]);
    % Remove box
    set(gca,'Box','off');
end

if ~showYTicks
    % No ticks, therefore no tick marks
    set(gca,'YTick',[]);
end

if ~showBox
    % Remove box
    set(gca,'Box','off');
else
    set(gca,'Box','on');
end

status = 0;

end


function display_legend(mainAxes)

mainWindow = trEPRguiGetWindowHandle;

% Get appdata from main GUI
ad = getappdata(mainWindow);

%mainAxes = findobj(allchild(gh.mainAxes_panel),'Type','axes');

% If there is no legend to be displayed
if (isequal(ad.control.axis.legend.location,'none'))
    legend('off');
    return;
end

if ad.control.axis.onlyActive
    legendLabels = strrep(...
            ad.data{ad.control.data.active}.label,'_','\_');
else
    legendLabels = cell(1,length(ad.control.data.visible));
    for k = 1 : length(ad.control.data.visible)
        legendLabels{k} = strrep(...
            ad.data{ad.control.data.visible(k)}.label,'_','\_');
    end
end

ad.control.axis.legend.handle = legend(mainAxes,legendLabels);

set(ad.control.axis.legend.handle,...
    'Location',ad.control.axis.legend.location,...
    'FontName',ad.control.axis.legend.FontName,...
    'FontWeight',ad.control.axis.legend.FontWeight,...
    'FontAngle',ad.control.axis.legend.FontAngle,...
    'FontSize',ad.control.axis.legend.FontSize...
    );

if ad.control.axis.legend.box
    set(ad.control.axis.legend.handle,'edgecolor',[0 0 0]);
else
    set(ad.control.axis.legend.handle,'edgecolor',get(gca,'color'));
end

setappdata(mainWindow,'control',ad.control);

end

function setMinMax()

% Get appdata from main GUI
mainWindow = trEPRguiGetWindowHandle();
ad = getappdata(mainWindow);

if (isempty(ad.control.data.visible))
    return;
end

% set min and max for spectra
if (ad.control.axis.limits.auto)
    xmin = zeros(length(ad.control.data.visible),1);
    xmax = zeros(length(ad.control.data.visible),1);
    ymin = zeros(length(ad.control.data.visible),1);
    ymax = zeros(length(ad.control.data.visible),1);
    zmin = zeros(length(ad.control.data.visible),1);
    zmax = zeros(length(ad.control.data.visible),1);
    for k=1:length(ad.control.data.visible)
        data = getData(ad.data{ad.control.data.visible(k)});
        x = ad.data{ad.control.data.visible(k)}.axes.data(1).values;
        y = ad.data{ad.control.data.visible(k)}.axes.data(2).values;
        xmin(k) = x(1);
        xmax(k) = x(end);
        ymin(k) = y(1);
        ymax(k) = y(end);
        if ad.control.axis.normalisation.enable
            if strcmpi(ad.control.axis.normalisation.dimension,'1d')
                switch lower(ad.control.axis.displayType)
                    case '1d along x'
                        data = data(ad.data{...
                            ad.control.data.visible(k)}.display.position.data(2),:);
                    case '1d along y'
                        data = data(:,ad.data{...
                            ad.control.data.visible(k)}.display.position.data(1));
                end
                switch ad.control.axis.normalisation.type
                    case {'pk-pk','pk2pk'}
                        zmin(k) = min(min(data/...
                            (max(max(data))-...
                            min(min(data)))));
                        zmax(k) = max(max(data/...
                            (max(max(data))-...
                            min(min(data)))));
                    case 'area'
                        zmin(k) = min(min(data/...
                            sum(sum(abs(data)))));
                        zmax(k) = max(max(data/...
                            sum(sum(abs(data)))));
                    case 'max'
                        zmin(k) = min(min(data/...
                            max(max(data))));
                        zmax(k) = max(max(data/...
                            max(max(data))));
                    case 'min'
                        zmin(k) = min(min(data/...
                            abs(min(min(data)))));
                        zmax(k) = max(max(data/...
                            abs(min(min(data)))));
                end
            else % This is the 2D case
                switch ad.control.axis.normalisation.type
                    case {'pk-pk','pk2pk'}
                        zmin(k) = min(min(data/...
                            (max(max(data))-...
                            min(min(data)))));
                        zmax(k) = max(max(data/...
                            (max(max(data))-...
                            min(min(data)))));
                    case 'area'
                        zmin(k) = min(min(data/...
                            sum(sum(abs(data)))));
                        zmax(k) = max(max(data/...
                            sum(sum(abs(data)))));
                    case 'max'
                        zmin(k) = min(min(data/...
                            max(max(data))));
                        zmax(k) = max(max(data/...
                            max(max(data))));
                    case 'min'
                        zmin(k) = min(min(data/...
                            min(min(data))));
                        zmax(k) = max(max(data/...
                            min(min(data))));
                end
            end
        else
            zmin(k) = ...
                min(min(data));
            zmax(k) = ...
                max(max(data));
            % WARNING: Quick and dirty fix for making displaying of
            %          calculated spectra together with measured data
            %          possible. Needs to be properly rewritten asap.
            % TB 2013/11/28
            if ad.control.axis.sim && isfield(ad.data{k},'calculated')
                if zmin(k) > min(ad.data{k}.calculated)
                    zmin(k) = min(ad.data{k}.calculated);
                end
                if zmax(k) < max(ad.data{k}.calculated)
                    zmax(k) = max(ad.data{k}.calculated);
                end
            end
        end
    end
    ad.control.axis.limits.x.min = min(xmin);
    ad.control.axis.limits.x.max = max(xmax);
    ad.control.axis.limits.y.min = min(ymin);
    ad.control.axis.limits.y.max = max(ymax);
    % Adjust z limits so that the axis limits are a bit wider than the
    % actual z limits
    zAmplitude = max(zmax)-min(zmin);
    ad.control.axis.limits.z.min = min(zmin)-0.025*zAmplitude;
    ad.control.axis.limits.z.max = max(zmax)+0.025*zAmplitude;
    clear data;
else
%     ad.control.axis.limits.x.min = ...
%         ad.data{ad.control.data.active}.axes.data(1).values(1);
%     ad.control.axis.limits.x.max = ...
%         ad.data{ad.control.data.active}.axes.data(1).values(end);
%     ad.control.axis.limits.y.min = ...
%         ad.data{ad.control.data.active}.axes.data(2).values(1);
%     ad.control.axis.limits.y.max = ...
%         ad.data{ad.control.data.active}.axes.data(2).values(end);
%     switch ad.control.axis.normalisation
%         case 'pk-pk'
%             ad.control.axis.limits.z.min = ...
%                 min(min(...
%                 ad.data{ad.control.data.active}.data/...
%                 (max(max(ad.data{ad.control.data.active}.data))-...
%                 min(min(ad.data{ad.control.data.active}.data)))));
%             ad.control.axis.limits.z.max = ...
%                 max(max(...
%                 ad.data{ad.control.data.active}.data/...
%                 (max(max(ad.data{ad.control.data.active}.data))-...
%                 min(min(ad.data{ad.control.data.active}.data)))));
%         case 'amplitude'
%             ad.control.axis.limits.z.min = ...
%                 min(min(ad.data{ad.control.data.active}.data/...
%                 max(max(ad.data{ad.control.data.active}.data))));
%             ad.control.axis.limits.z.max = ...
%                 max(max(ad.data{ad.control.data.active}.data/...
%                 max(max(ad.data{ad.control.data.active}.data))));
%         otherwise
%             ad.control.axis.limits.z.min = ...
%                 min(min(ad.data{ad.control.data.active}.data));
%             ad.control.axis.limits.z.max = ...
%                 max(max(ad.data{ad.control.data.active}.data));
%     end
end

% update appdata of main window
setappdata(mainWindow,'control',ad.control);    

end

function minmax = allMinMax()
% Get appdata from main GUI
mainWindow = trEPRguiGetWindowHandle();
ad = getappdata(mainWindow);

if isempty(ad.control.data.visible)
    minmax = [];
    return;
end

minmax = zeros(length(ad.control.data.visible),2);
for idx = 1:length(ad.control.data.visible)
    minmax(idx,1) = min(min(ad.data{ad.control.data.visible(idx)}.data));
    minmax(idx,2) = max(max(ad.data{ad.control.data.visible(idx)}.data));
end

end


function plotProjection()
% Get appdata from main GUI
mainWindow = trEPRguiGetWindowHandle();
ad = getappdata(mainWindow);
gh = ad.UsedByGUIData_m;

active = ad.control.data.active;

cla(gh.horizontalAxis,'reset');
cla(gh.verticalAxis,'reset');

switch lower(ad.control.axis.projectionAxes.mode)
    case 'slice'
        plot(gh.horizontalAxis,...
            ad.data{active}.axes.data(1).values,...
            ad.data{active}.data(ad.data{active}.display.position.data(2),:),...
            'k-');
        plot(gh.verticalAxis,...
            -ad.data{active}.data(:,ad.data{active}.display.position.data(1)),...
            ad.data{active}.axes.data(2).values,...
            'k-');
    case 'sum'
        plot(gh.horizontalAxis,...
            ad.data{active}.axes.data(1).values,sum(ad.data{active}.data,1),...
            'k-');
        plot(gh.verticalAxis,...
            -sum(ad.data{active}.data,2),ad.data{active}.axes.data(2).values,...
            'k-');
    otherwise
        trEPRoptionUnknown(option,'projection axis mode');
end

set(gh.horizontalAxis,'XLim',get(gh.mainAxis,'XLim'));
set(gh.verticalAxis,'YLim',get(gh.mainAxis,'YLim'));
set(gh.mainAxis,'XTickLabel',{''});
set(gh.mainAxis,'YTickLabel',{''});
set(gh.verticalAxis,'XTickLabel',{''});
set(gh.horizontalAxis,'YTickLabel',{''});
set(gh.horizontalAxis,'Visible','on');
set(gh.verticalAxis,'Visible','on');
xlabel(gh.horizontalAxis,sprintf('{\\it %s} / %s',...
    ad.control.axis.labels.x.measure,...
    ad.control.axis.labels.x.unit));
ylabel(gh.verticalAxis,sprintf('{\\it %s} / %s',...
    ad.control.axis.labels.y.measure,...
    ad.control.axis.labels.y.unit));
xlabel(gh.mainAxis,'');
ylabel(gh.mainAxis,'');

if (ad.control.axis.grid.zero.visible)
    line(...
        [0 0],...
        [ad.control.axis.limits.y.min ad.control.axis.limits.y.max],...
        'Color',ad.control.axis.grid.zero.color,...
        'LineWidth',ad.control.axis.grid.zero.width,...
        'LineStyle',ad.control.axis.grid.zero.style,...
        'Parent',gh.verticalAxis);
    line(...
        [ad.control.axis.limits.x.min ad.control.axis.limits.x.max],...
        [0 0],...
        'Color',ad.control.axis.grid.zero.color,...
        'LineWidth',ad.control.axis.grid.zero.width,...
        'LineStyle',ad.control.axis.grid.zero.style,...
        'Parent',gh.horizontalAxis);
end

set([gh.horizontalAxis,gh.verticalAxis],'XGrid',ad.control.axis.grid.x);
set([gh.horizontalAxis,gh.verticalAxis],'YGrid',ad.control.axis.grid.y);
if (isequal(ad.control.axis.grid.x,'on'))
    set([gh.horizontalAxis,gh.verticalAxis],...
        'XMinorGrid',ad.control.axis.grid.minor);
end
if (isequal(ad.control.axis.grid.y,'on'))
    set([gh.horizontalAxis,gh.verticalAxis],...
        'YMinorGrid',ad.control.axis.grid.minor);
end

if ad.control.axis.box
    set([gh.horizontalAxis,gh.verticalAxis],'Box','on');
else
    set([gh.horizontalAxis,gh.verticalAxis],'Box','off');
end

end


function plotResiduals()
% Get appdata from main GUI
mainWindow = trEPRguiGetWindowHandle();
ad = getappdata(mainWindow);
gh = ad.UsedByGUIData_m;

active = ad.control.data.active;

cla(gh.residualsAxis,'reset');

if ~isempty(ad.data{active}.calculated) && ad.control.axis.sim
    residuals = ad.data{active}.data(:,ad.data{active}.calculation.position)-...
        ad.data{active}.calculated;
    plot(gh.residualsAxis,ad.data{active}.axes.data(2).values,residuals,'k-');
end

set(gh.residualsAxis,'XLim',get(gh.mainAxis,'XLim'));
set(gh.mainAxis,'XTickLabel',{''});
if strfind(ad.control.axis.displayType,'x')
    xlabel(gh.residualsAxis,sprintf('%s / %s',...
        ad.control.axis.labels.x.measure,...
        ad.control.axis.labels.x.unit));
else
    xlabel(gh.residualsAxis,sprintf('%s / %s',...
        ad.control.axis.labels.y.measure,...
        ad.control.axis.labels.y.unit));
end
xlabel(gh.mainAxis,'');

if (ad.control.axis.grid.zero.visible)
    line(...
        get(gh.residualsAxis,'XLim'),...
        [0 0],...
        'Color',ad.control.axis.grid.zero.color,...
        'LineWidth',ad.control.axis.grid.zero.width,...
        'LineStyle',ad.control.axis.grid.zero.style,...
        'Parent',gh.residualsAxis);
end

set(gh.residualsAxis,'XGrid',ad.control.axis.grid.x);
set(gh.residualsAxis,'YGrid',ad.control.axis.grid.y);
if (isequal(ad.control.axis.grid.x,'on'))
    set(gh.residualsAxis,'XMinorGrid',ad.control.axis.grid.minor);
else
    set(gh.residualsAxis,'XMinorGrid','off');
end
if (isequal(ad.control.axis.grid.y,'on'))
    set(gh.residualsAxis,'YMinorGrid',ad.control.axis.grid.minor);
else
    set(gh.residualsAxis,'YMinorGrid','off');
end

% Set ylimits
if exist('residuals','var')
    additionalSpace = abs(max(residuals)-min(residuals))*0.1;
    set(gh.residualsAxis,'YLim',...
        [min(residuals)-additionalSpace max(residuals)+additionalSpace]);
else
    set(gh.residualsAxis,'YLim',[-1 1]);
end

if ad.control.axis.box
    set(gh.residualsAxis,'Box','on');
else
    set(gh.residualsAxis,'Box','off');
end

end

