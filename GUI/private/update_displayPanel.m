function status = update_displayPanel()
% UPDATE_DISPLAYPANEL Helper function that updates the display panel
%   of the trEPR GUI, namely trEPR_gui_mainwindow.
%
%   STATUS: return value for the exit status
%           -1: no tEPR_gui_mainwindow found
%            0: successfully updated main axis

% Copyright (c) 2011-15, Till Biskup
% 2015-10-18

% Is there currently a trEPRgui object?
mainWindow = trEPRguiGetWindowHandle();
if (isempty(mainWindow))
    status = -1;
    return;
end

% Get handles and appdata from main window
ad = getappdata(mainWindow);
gh = ad.guiHandles;

% Toggle legend box display
set(gh.display_panel_legendbox_checkbox,'Value',ad.control.axis.legend.box);

% Toggle "Highlight active"
if isempty(ad.control.axis.highlight.method)
    set(gh.display_panel_highlight_checkbox,'Value',0);
    set(gh.display_panel_highlight2_checkbox,'Value',0);
else
    set(gh.display_panel_highlight_checkbox,'Value',1);
    set(gh.display_panel_highlight2_checkbox,'Value',1);
end

% Set axis labels fields
set(gh.display_panel_axislabels_x_measure_edit,'String',...
    ad.control.axis.labels.x.measure);
set(gh.display_panel_axislabels_x_unit_edit,'String',...
    ad.control.axis.labels.x.unit);
set(gh.display_panel_axislabels_y_measure_edit,'String',...
    ad.control.axis.labels.y.measure);
set(gh.display_panel_axislabels_y_unit_edit,'String',...
    ad.control.axis.labels.y.unit);
set(gh.display_panel_axislabels_z_measure_edit,'String',...
    ad.control.axis.labels.z.measure);
set(gh.display_panel_axislabels_z_unit_edit,'String',...
    ad.control.axis.labels.z.unit);

% Toggle state of "get axislabels from current dataset"
if (ad.control.data.active)
    set(...
        gh.display_panel_axislabels_getfromactivedataset_pushbutton,...
        'Enable','on'...
        );
else
    set(...
        gh.display_panel_axislabels_getfromactivedataset_pushbutton,...
        'Enable','off'...
        );
end

% Set axis limits fields
set(gh.display_panel_axislimits_x_min_edit,'String',...
    num2str(ad.control.axis.limits.x.min));
set(gh.display_panel_axislimits_x_max_edit,'String',...
    num2str(ad.control.axis.limits.x.max));
set(gh.display_panel_axislimits_y_min_edit,'String',...
    num2str(ad.control.axis.limits.y.min));
set(gh.display_panel_axislimits_y_max_edit,'String',...
    num2str(ad.control.axis.limits.y.max));
set(gh.display_panel_axislimits_z_min_edit,'String',...
    num2str(ad.control.axis.limits.z.min));
set(gh.display_panel_axislimits_z_max_edit,'String',...
    num2str(ad.control.axis.limits.z.max));

% Toggle state of axislimits auto checkbox
set(gh.display_panel_axislimits_auto_checkbox,'Value',...
    ad.control.axis.limits.auto);

% Toggle some other checkboxes
set(gh.display_panel_stdev_checkbox,'Value',...
    ad.control.axis.stdev);
set(gh.display_panel_sim_checkbox,'Value',...
    ad.control.axis.sim);
set(gh.display_panel_characteristics_checkbox,'Value',...
    ad.control.axis.characteristics);
set(gh.display_panel_colormap_individual_checkbox,'Value',...
    ad.control.axis.colormap.individual);
set(gh.display_panel_colormap_symmetric_checkbox,'Value',...
    ad.control.axis.colormap.symmetric);
set(gh.display_panel_axesexport_colorbar_checkbox,'Value',...
    ad.control.axis.colormap.colorbar);

% Toggle state of axislimits edit fields according to "automatic"
editHandles = findobj(...
    'Parent',gh.display_panel_axislimits_panel,'Style','edit');
if (get(gh.display_panel_axislimits_auto_checkbox,'Value'))
    set(editHandles,'Enable','Off');
else
    set(editHandles,'Enable','On');
end


% Set zero line settings
% Set colour sample
set(gh.display_panel_zerolinecoloursample_text,'BackgroundColor',...
    ad.control.axis.grid.zero.color);
set(gh.display_panel_zerolinecoloursample_text,'TooltipString',...
    num2str(ad.control.axis.grid.zero.color));

% Set line width
set(gh.display_panel_zerolinewidth_edit,'String',...
    num2str(ad.control.axis.grid.zero.width));

% Set line style
zeroLineStyles = {'-','--',':','-.','none'};
zeroLineStyle = ad.control.axis.grid.zero.style;
for k=1:length(zeroLineStyles)
    if strcmp(zeroLineStyles{k},zeroLineStyle)
        zeroLineStyleIndex = k;
    end
end
set(gh.display_panel_zerolinestyle_popupmenu,'Value',zeroLineStyleIndex);


% Set line settings
if ad.control.data.active
    active = ad.control.data.active;
    
    % Make settings depending on the line selected
    lineTypes = cellstr(get(gh.display_panel_line_popupmenu,'String'));
    lineType = lineTypes{get(gh.display_panel_line_popupmenu,'Value')};

    % NOTE: For now, not having both line settings at the same level in the
    %       data structure, we need to duplicate large parts of the code.
    %       Later on, we could just define the field name within the switch
    %       statement and run the rest without problem only once - see
    %       commented parts of the code.

    switch lineType
        case 'measured'
            % Set colour sample
            set(gh.display_panel_linecoloursample_text,'BackgroundColor',...
                ad.data{active}.display.lines.data.color);
            set(gh.display_panel_linecoloursample_text,'TooltipString',...
                num2str(ad.data{active}.display.lines.data.color));
            
            % Set line width
            set(gh.display_panel_linewidth_popupmenu,'Value',...
                ad.data{active}.display.lines.data.width);
            
            % Set line style
            lineStyles = {'-','--',':','-.','none'};
            lineStyle = ad.data{active}.display.lines.data.style;
            for k=1:length(lineStyles)
                if strcmp(lineStyles{k},lineStyle)
                    lineStyleIndex = k;
                end
            end
            set(gh.display_panel_linestyle_popupmenu,'Value',lineStyleIndex);
            
            % Set line marker type
            lineMarkers = {'none','+','o','*','.','x','s','d','^','v','>','<','p','h'};
            lineMarker = ad.data{active}.display.lines.data.marker.type;
            for k=1:length(lineMarkers)
                if strcmp(lineMarkers{k},lineMarker)
                    lineMarkerIndex = k;
                end
            end
            set(gh.display_panel_linemarker_popupmenu,'Value',lineMarkerIndex);
            % Set line marker edge colour
            lineMarkerEdgeColor = ad.data{active}.display.lines.data.marker.edgeColor;
            lineMarkerEdgeColorPopupmenuValues = ...
                cellstr(get(gh.display_panel_markeredgecolour_popupmenu,'String'));
            if ischar(lineMarkerEdgeColor) && length(lineMarkerEdgeColor)>1
                set(gh.display_panel_markeredgecolour_popupmenu,'Value',...
                    find(strcmpi(lineMarkerEdgeColor,...
                    lineMarkerEdgeColorPopupmenuValues)));
                switch lineMarkerEdgeColor
                    case 'none'
                        set(gh.display_panel_markeredgecoloursample_text,...
                            'BackgroundColor',get(mainWindow,'Color'));
                        set(gh.display_panel_markeredgecoloursample_text,...
                            'TooltipString','none');
                    case 'auto'
                        set(gh.display_panel_markeredgecoloursample_text,...
                            'BackgroundColor',ad.data{active}.display.lines.data.color);
                        set(gh.display_panel_markeredgecoloursample_text,...
                            'TooltipString',num2str(ad.data{active}.display.lines.data.color));
                end
            else
                set(gh.display_panel_markeredgecolour_popupmenu,'Value',...
                    find(strcmpi('colour',lineMarkerEdgeColorPopupmenuValues)));
                set(gh.display_panel_markeredgecoloursample_text,...
                    'BackgroundColor',ad.data{active}.display.lines.data.marker.edgeColor);
                set(gh.display_panel_markeredgecoloursample_text,...
                    'TooltipString',num2str(ad.data{active}.display.lines.data.marker.edgeColor));
            end
            % Set line marker face colour
            lineMarkerFaceColor = ad.data{active}.display.lines.data.marker.faceColor;
            lineMarkerFaceColorPopupmenuValues = ...
                cellstr(get(gh.display_panel_markerfacecolour_popupmenu,'String'));
            if ischar(lineMarkerFaceColor) && length(lineMarkerFaceColor)>1
                set(gh.display_panel_markerfacecolour_popupmenu,'Value',...
                    find(strcmpi(lineMarkerFaceColor,...
                    lineMarkerFaceColorPopupmenuValues)));
                switch lineMarkerFaceColor
                    case 'none'
                        set(gh.display_panel_markerfacecoloursample_text,...
                            'BackgroundColor',get(mainWindow,'Color'));
                        set(gh.display_panel_markerfacecoloursample_text,...
                            'TooltipString','none');
                    case 'auto'
                        set(gh.display_panel_markerfacecoloursample_text,...
                            'BackgroundColor',get(gca,'Color'));
                        set(gh.display_panel_markerfacecoloursample_text,...
                            'TooltipString',num2str(get(gca,'Color')));
                end
            else
                set(gh.display_panel_markerfacecolour_popupmenu,'Value',...
                    find(strcmpi('colour',lineMarkerFaceColorPopupmenuValues)));
                set(gh.display_panel_markerfacecoloursample_text,...
                    'BackgroundColor',ad.data{active}.display.lines.data.marker.faceColor);
                set(gh.display_panel_markerfacecoloursample_text,...
                    'TooltipString',num2str(ad.data{active}.display.lines.data.marker.faceColor));
            end
            % Set line marker size
            set(gh.display_panel_markersize_edit,'String',...
                num2str(ad.data{active}.display.lines.data.marker.size));
        case 'calculated'
            % Set colour sample
            set(gh.display_panel_linecoloursample_text,'BackgroundColor',...
                ad.data{active}.display.lines.calculated.color);
            set(gh.display_panel_linecoloursample_text,'TooltipString',...
                num2str(ad.data{active}.display.lines.calculated.color));
            
            % Set line width
            set(gh.display_panel_linewidth_popupmenu,'Value',...
                ad.data{active}.display.lines.calculated.width);
            
            % Set line style
            lineStyles = {'-','--',':','-.','none'};
            lineStyle = ad.data{active}.display.lines.calculated.style;
            for k=1:length(lineStyles)
                if strcmp(lineStyles{k},lineStyle)
                    lineStyleIndex = k;
                end
            end
            set(gh.display_panel_linestyle_popupmenu,'Value',lineStyleIndex);
            
            % Set line marker type
            lineMarkers = {'none','+','o','*','.','x','s','d','^','v','>','<','p','h'};
            lineMarker = ad.data{active}.display.lines.calculated.marker.type;
            for k=1:length(lineMarkers)
                if strcmp(lineMarkers{k},lineMarker)
                    lineMarkerIndex = k;
                end
            end
            set(gh.display_panel_linemarker_popupmenu,'Value',lineMarkerIndex);
            % Set line marker edge colour
            lineMarkerEdgeColor = ad.data{active}.display.lines.calculated.marker.edgeColor;
            lineMarkerEdgeColorPopupmenuValues = ...
                cellstr(get(gh.display_panel_markeredgecolour_popupmenu,'String'));
            if ischar(lineMarkerEdgeColor) && length(lineMarkerEdgeColor)>1
                set(gh.display_panel_markeredgecolour_popupmenu,'Value',...
                    find(strcmpi(lineMarkerEdgeColor,...
                    lineMarkerEdgeColorPopupmenuValues)));
                switch lineMarkerEdgeColor
                    case 'none'
                        set(gh.display_panel_markeredgecoloursample_text,...
                            'BackgroundColor',get(mainWindow,'Color'));
                        set(gh.display_panel_markeredgecoloursample_text,...
                            'TooltipString','none');
                    case 'auto'
                        set(gh.display_panel_markeredgecoloursample_text,...
                            'BackgroundColor',ad.data{active}.display.lines.calculated.color);
                        set(gh.display_panel_markeredgecoloursample_text,...
                            'TooltipString',num2str(ad.data{active}.display.lines.calculated.color));
                end
            else
                set(gh.display_panel_markeredgecolour_popupmenu,'Value',...
                    find(strcmpi('colour',lineMarkerEdgeColorPopupmenuValues)));
                set(gh.display_panel_markeredgecoloursample_text,...
                    'BackgroundColor',ad.data{active}.display.lines.calculated.marker.edgeColor);
                set(gh.display_panel_markeredgecoloursample_text,...
                    'TooltipString',num2str(ad.data{active}.display.lines.calculated.marker.edgeColor));
            end
            % Set line marker face colour
            lineMarkerFaceColor = ad.data{active}.display.lines.calculated.marker.faceColor;
            lineMarkerFaceColorPopupmenuValues = ...
                cellstr(get(gh.display_panel_markerfacecolour_popupmenu,'String'));
            if ischar(lineMarkerFaceColor) && length(lineMarkerFaceColor)>1
                set(gh.display_panel_markerfacecolour_popupmenu,'Value',...
                    find(strcmpi(lineMarkerFaceColor,...
                    lineMarkerFaceColorPopupmenuValues)));
                switch lineMarkerFaceColor
                    case 'none'
                        set(gh.display_panel_markerfacecoloursample_text,...
                            'BackgroundColor',get(mainWindow,'Color'));
                        set(gh.display_panel_markerfacecoloursample_text,...
                            'TooltipString','none');
                    case 'auto'
                        set(gh.display_panel_markerfacecoloursample_text,...
                            'BackgroundColor',get(gca,'Color'));
                        set(gh.display_panel_markerfacecoloursample_text,...
                            'TooltipString',num2str(get(gca,'Color')));
                end
            else
                set(gh.display_panel_markerfacecolour_popupmenu,'Value',...
                    find(strcmpi('colour',lineMarkerFaceColorPopupmenuValues)));
                set(gh.display_panel_markerfacecoloursample_text,...
                    'BackgroundColor',ad.data{active}.display.lines.calculated.marker.faceColor);
                set(gh.display_panel_markerfacecoloursample_text,...
                    'TooltipString',num2str(ad.data{active}.display.lines.calculated.marker.faceColor));
            end
            % Set line marker size
            set(gh.display_panel_markersize_edit,'String',...
                num2str(ad.data{active}.display.lines.calculated.marker.size));
        otherwise
            trEPRoptionUnknown(lineType,'line type');
            return;
    end
    
%     switch lineType
%         case 'measured'
%             fieldName = 'data';
%         case 'calculated'
%             fieldName = 'calculated';
%         otherwise
%             trEPRoptionUnknown(lineType,'line type');
%             return;
%     end
%     
%     % Set colour sample
%     set(gh.display_panel_linecoloursample_text,'BackgroundColor',...
%         ad.data{active}.display.lines.(fieldName).color);
%     set(gh.display_panel_linecoloursample_text,'TooltipString',...
%         num2str(ad.data{active}.display.lines.(fieldName).color));
%     
%     % Set line width
%     set(gh.display_panel_linewidth_popupmenu,'Value',...
%         ad.data{active}.display.lines.(fieldName).width);
% 
%     % Set line style
%     lineStyles = {'-','--',':','-.','none'};
%     lineStyle = ad.data{active}.display.lines.(fieldName).style;
%     for k=1:length(lineStyles)
%         if strcmp(lineStyles{k},lineStyle)
%             lineStyleIndex = k;
%         end
%     end
%     set(gh.display_panel_linestyle_popupmenu,'Value',lineStyleIndex);
%     
%     % Set line marker type
%     lineMarkers = {'none','+','o','*','.','x','s','d','^','v','>','<','p','h'};
%     lineMarker = ad.data{active}.display.lines.(fieldName).marker.type;
%     for k=1:length(lineMarkers)
%         if strcmp(lineMarkers{k},lineMarker)
%             lineMarkerIndex = k;
%         end
%     end
%     set(gh.display_panel_linemarker_popupmenu,'Value',lineMarkerIndex);
%     % Set line marker edge colour
%     lineMarkerEdgeColor = ...
%         ad.data{active}.display.lines.(fieldName).marker.edgeColor;
%     lineMarkerEdgeColorPopupmenuValues = ...
%         cellstr(get(gh.display_panel_markeredgecolour_popupmenu,'String'));
%     if ischar(lineMarkerEdgeColor) && length(lineMarkerEdgeColor)>1
%         set(gh.display_panel_markeredgecolour_popupmenu,'Value',...
%             find(strcmpi(lineMarkerEdgeColor,...
%             lineMarkerEdgeColorPopupmenuValues)));
%         switch lineMarkerEdgeColor
%             case 'none'
%                 set(gh.display_panel_markeredgecoloursample_text,...
%                     'BackgroundColor',get(mainWindow,'Color'));
%                 set(gh.display_panel_markeredgecoloursample_text,...
%                     'TooltipString','none');
%             case 'auto'
%                 set(gh.display_panel_markeredgecoloursample_text,...
%                     'BackgroundColor',...
%                     ad.data{active}.display.lines.(fieldName).color);
%                 set(gh.display_panel_markeredgecoloursample_text,...
%                     'TooltipString',...
%                     num2str(ad.data{active}.display.lines.(fieldName).color));
%         end
%     else
%         set(gh.display_panel_markeredgecolour_popupmenu,'Value',...
%             find(strcmpi('colour',lineMarkerEdgeColorPopupmenuValues)));
%         set(gh.display_panel_markeredgecoloursample_text,...
%             'BackgroundColor',...
%             ad.data{active}.display.lines.(fieldName).marker.edgeColor);
%         set(gh.display_panel_markeredgecoloursample_text,...
%             'TooltipString',...
%             num2str(ad.data{active}.display.lines.(fieldName).marker.edgeColor));
%     end
%     % Set line marker face colour
%     lineMarkerFaceColor = ...
%         ad.data{active}.display.lines.(fieldName).marker.faceColor;
%     lineMarkerFaceColorPopupmenuValues = ...
%         cellstr(get(gh.display_panel_markerfacecolour_popupmenu,'String'));
%     if ischar(lineMarkerFaceColor) && length(lineMarkerFaceColor)>1
%         set(gh.display_panel_markerfacecolour_popupmenu,'Value',...
%             find(strcmpi(lineMarkerFaceColor,...
%             lineMarkerFaceColorPopupmenuValues)));
%         switch lineMarkerFaceColor
%             case 'none'
%                 set(gh.display_panel_markerfacecoloursample_text,...
%                     'BackgroundColor',get(mainWindow,'Color'));
%                 set(gh.display_panel_markerfacecoloursample_text,...
%                     'TooltipString','none');
%             case 'auto'
%                 set(gh.display_panel_markerfacecoloursample_text,...
%                     'BackgroundColor',get(gca,'Color'));
%                 set(gh.display_panel_markerfacecoloursample_text,...
%                     'TooltipString',num2str(get(gca,'Color')));
%         end
%     else
%         set(gh.display_panel_markerfacecolour_popupmenu,'Value',...
%             find(strcmpi('colour',lineMarkerFaceColorPopupmenuValues)));
%         set(gh.display_panel_markerfacecoloursample_text,...
%             'BackgroundColor',...
%             ad.data{active}.display.lines.(fieldName).marker.faceColor);
%         set(gh.display_panel_markerfacecoloursample_text,...
%             'TooltipString',...
%             num2str(ad.data{active}.display.lines.(fieldName).marker.faceColor));
%     end
%     % Set line marker size
%     set(gh.display_panel_markersize_edit,'String',...
%         num2str(ad.data{active}.display.lines.(fieldName).marker.size));
    
end

% Set 3D export panel
if ad.control.data.active
    [dimy,dimx] = size(ad.data{ad.control.data.active}.data);
    if get(gh.display_panel_reducing_auto_checkbox,'Value')
        ad.control.axis.vis3d.reduction.x = floor(dimx/50);
        ad.control.axis.vis3d.reduction.y = floor(dimy/50);
    end
    set(gh.display_panel_3D_original_x_edit,'String',num2str(dimx));
    set(gh.display_panel_3D_original_y_edit,'String',num2str(dimy));
    set(gh.display_panel_3D_factor_x_edit,'String',...
        num2str(ad.control.axis.vis3d.reduction.x));
    set(gh.display_panel_3D_factor_y_edit,'String',...
        num2str(ad.control.axis.vis3d.reduction.y));
    set(gh.display_panel_3D_size_x_edit,'String',...
        num2str(floor(dimx/ad.control.axis.vis3d.reduction.x)));
    set(gh.display_panel_3D_size_y_edit,'String',...
        num2str(floor(dimy/ad.control.axis.vis3d.reduction.y)));
    setappdata(mainWindow,'control',ad.control);
end

% Set projection axes settings
set(gh.display_panel_projectionaxes_checkbox,'value',...
    ad.control.axis.projectionAxes.enable);
set(gh.display_panel_projectionaxes_hheight_edit,'String',num2str(...
    ad.control.axis.projectionAxes.horizontal.height));
set(gh.display_panel_projectionaxes_vheight_edit,'String',num2str(...
    ad.control.axis.projectionAxes.vertical.height));

% Set residuals axis settings
set(gh.display_panel_residualsaxis_checkbox,'value',...
    ad.control.axis.residualsAxes.enable);
set(gh.display_panel_residualsaxis_height_edit,'String',num2str(...
    ad.control.axis.residualsAxes.height));
set(gh.display_panel_residualsaxis_gap_edit,'String',num2str(...
    ad.control.axis.residualsAxes.gap));

status = 0;

end
