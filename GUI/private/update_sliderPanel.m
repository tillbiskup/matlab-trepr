function status = update_sliderPanel()
% UPDATE_SLIDERPANEL Helper function that updates the slider panel
%   of the trEPR GUI, namely trEPR_gui_mainwindow.
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

% Get handles from main window
gh = guidata(mainWindow);

% Get appdata from main GUI
ad = getappdata(mainWindow);

if (isempty(ad.control.data.visible))
    return;
end

% Make lines shorter and life easier
active = ad.control.data.active;

data = getData(ad.data{active});

% Get dimensions and axes of current dataset
[y,x] = size(data);
x = linspace(1,x,x);
y = linspace(1,y,y);
if (isfield(ad.data{active},'axes') ...
        && isfield(ad.data{active}.axes,'x') ...
        && isfield(ad.data{active}.axes.data(1),'values') ...
        && not (isempty(ad.data{active}.axes.data(1).values)))
    x = ad.data{active}.axes.data(1).values;
end
if (isfield(ad.data{active},'axes') ...
        && isfield(ad.data{active}.axes,'y') ...
        && isfield(ad.data{active}.axes.data(2),'values') ...
        && not (isempty(ad.data{active}.axes.data(2).values)))
    y = ad.data{active}.axes.data(2).values;
end
% In case that we loaded 1D data...
if isscalar(x)
    x = [x x+1];
end
if isscalar(y)
    y = [y y+1];
end

% Update scaling panel
set(...
    gh.slider_panel_scaling_x_index_edit,...
    'String',...
    num2str(ad.data{active}.display.scaling.data(1))...
    );
set(...
    gh.slider_panel_scaling_x_unit_edit,...
    'String',...
    num2str(...
    (((x(end)-x(1))*ad.data{active}.display.scaling.data(1)))-...
    (x(end)-x(1)))...
    );
set(...
    gh.slider_panel_scaling_y_index_edit,...
    'String',...
    num2str(ad.data{active}.display.scaling.data(2))...
    );
set(...
    gh.slider_panel_scaling_y_unit_edit,...
    'String',...
    num2str(...
    (((y(end)-y(1))*ad.data{active}.display.scaling.data(2)))-...
    (y(end)-y(1)))...
    );
set(...
    gh.slider_panel_scaling_z_index_edit,...
    'String',...
    num2str(ad.data{active}.display.scaling.data(3))...
    );

if ad.control.axis.normalisation.enable
    if strcmpi(ad.control.axis.normalisation.dimension,'1D')
        switch lower(ad.control.axis.normalisation.type)
            case {'pk2pk','pk-pk'}
                z = [0 1];
            case 'area'
                z(1) = min(min(data/...
                    sum(sum(data))));
                z(2) = max(max(data/...
                    sum(sum(data))));
            case 'max'
                z(1) = min(min(data/...
                    max(max(data))));
                z(2) = max(max(data/...
                    max(max(data))));
            case 'min'
                z(1) = min(min(data/...
                    min(min(data))));
                z(2) = max(max(data/...
                    min(min(data))));
        end
    else
        switch lower(ad.control.axis.normalisation.type)
            case {'pk2pk','pk-pk'}
                z = [0 1];
            case 'area'
                z(1) = min(min(data/...
                    sum(sum(data))));
                z(2) = max(max(data/...
                    sum(sum(data))));
            case 'max'
                z(1) = min(min(data/...
                    max(max(data))));
                z(2) = max(max(data/...
                    max(max(data))));
            case 'min'
                z(1) = min(min(data/...
                    min(min(data))));
                z(2) = max(max(data/...
                    min(min(data))));
        end
    end
else
    z(1) = min(min(data));
    z(2) = max(max(data));
end

set(...
    gh.slider_panel_scaling_z_unit_edit,...
    'String',...
    num2str(...
    (((z(2)-z(1))*...
    ad.data{active}.display.scaling.data(3)))-...
    (z(2)-z(1)))...
    );

% Update displacement panel
set(...
    gh.slider_panel_displacement_x_index_edit,...
    'String',...
    num2str(ad.data{active}.display.displacement.data(1)));
set(...
    gh.slider_panel_displacement_x_unit_edit,...
    'String',...
    num2str(...
    (x(2)-x(1)) * ...
    ad.data{active}.display.displacement.data(1))...
    );
set(...
    gh.slider_panel_displacement_y_index_edit,...
    'String',...
    num2str(ad.data{active}.display.displacement.data(2)));
set(...
    gh.slider_panel_displacement_y_unit_edit,...
    'String',...
    num2str(...
    (y(2)-y(1)) * ...
    ad.data{active}.display.displacement.data(2))...
    );
set(...
    gh.slider_panel_displacement_z_index_edit,...
    'String',...
    num2str(ad.data{active}.display.displacement.data(3))...
    );
set(...
    gh.slider_panel_displacement_z_unit_edit,...
    'String',...
    num2str(...
    ad.data{active}.display.displacement.data(3)/...
    (max(max(data))-min(min(data)))*(z(2)-z(1))...
    )...
    );

% Update position panel
set(...
    gh.slider_panel_position_x_index_edit,...
    'String',...
    ad.data{active}.display.position.data(1)...
    );
set(...
    gh.slider_panel_position_x_unit_edit,...
    'String',...
    x(ad.data{active}.display.position.data(1))...
    );
set(...
    gh.slider_panel_position_y_index_edit,...
    'String',...
    ad.data{active}.display.position.data(2)...
    );
set(...
    gh.slider_panel_position_y_unit_edit,...
    'String',...
    y(ad.data{active}.display.position.data(2))...
    );

% Do tasks that depend on displayType
switch ad.control.axis.displayType
    case '2D plot'
    case '1D along x' % time profile
        % Update position slider
        set(gh.vert1_slider,...
            'Value',...
            ad.data{active}.display.position.data(2)...
            )
        % Update scaling slider
        if (ad.data{active}.display.scaling.data(3) > 1)
            set(gh.vert2_slider,...
                'Value',...
                ad.data{active}.display.scaling.data(3)-...
                get(gh.vert2_slider,'Max')...
                );
        else
            set(gh.vert2_slider,...
                'Value',...
                -(1/ad.data{active}.display.scaling.data(3)-...
                get(gh.vert2_slider,'Max'))...
                );
        end
        if (ad.data{active}.display.scaling.data(1) > 1)
            set(gh.horz1_slider,...
                'Value',...
                ad.data{active}.display.scaling.data(1)-...
                get(gh.horz1_slider,'Max')...
                );
        else
            set(gh.horz1_slider,...
                'Value',...
                -(1/ad.data{active}.display.scaling.data(1)-...
                get(gh.horz1_slider,'Max'))...
                );
        end
        % Update displacement slider
        set(gh.vert3_slider,...
            'Value',...
            ad.data{active}.display.displacement.data(3)...
            );
        set(gh.horz2_slider,...
            'Value',...
            ad.data{active}.display.displacement.data(1)...
            );
    case '1D along y' % B0 spectrum
        % Update position slider
        set(gh.vert1_slider,...
            'Value',...
            ad.data{active}.display.position.data(1)...
            )
        % Update scaling slider
        if (ad.data{active}.display.scaling.data(3) > 1)
            set(gh.vert2_slider,...
                'Value',...
                ad.data{active}.display.scaling.data(3)-...
                get(gh.vert2_slider,'Max')...
                );
        else
            set(gh.vert2_slider,...
                'Value',...
                -(1/ad.data{active}.display.scaling.data(3)-...
                get(gh.vert2_slider,'Max'))...
                );
        end
        if (ad.data{active}.display.scaling.data(2) > 1)
            set(gh.horz1_slider,...
                'Value',...
                ad.data{active}.display.scaling.data(2)-...
                get(gh.horz1_slider,'Max')...
                );
        else
            set(gh.horz1_slider,...
                'Value',...
                -(1/ad.data{active}.display.scaling.data(2)-...
                get(gh.horz1_slider,'Max'))...
                );
        end
        % Update displacement slider
        set(gh.vert3_slider,...
            'Value',...
            ad.data{active}.display.displacement.data(3)...
            );
        set(gh.horz2_slider,...
            'Value',...
            ad.data{active}.display.displacement.data(2)...
            );
    otherwise
        trEPRoptionUnknown(ad.control.axis.displayType,...
            'display type');
        return;
end

clear data;

status = 0;

end
