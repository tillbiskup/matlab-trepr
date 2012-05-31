function status = update_sliderPanel()
% UPDATE_SLIDERPANEL Helper function that updates the slider panel
%   of the trEPR GUI, namely trEPR_gui_mainwindow.
%
%   STATUS: return value for the exit status
%           -1: no tEPR_gui_mainwindow found
%            0: successfully updated main axis

% (c) 2011-12, Till Biskup
% 2012-05-31

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

if (isempty(ad.control.spectra.visible))
    return;
end

% Get dimensions and axes of current dataset
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
    num2str(ad.data{ad.control.spectra.active}.display.scaling.x)...
    );
set(...
    gh.slider_panel_scaling_x_unit_edit,...
    'String',...
    num2str(...
    (((x(end)-x(1))*ad.data{ad.control.spectra.active}.display.scaling.x))-...
    (x(end)-x(1)))...
    );
set(...
    gh.slider_panel_scaling_y_index_edit,...
    'String',...
    num2str(ad.data{ad.control.spectra.active}.display.scaling.y)...
    );
set(...
    gh.slider_panel_scaling_y_unit_edit,...
    'String',...
    num2str(...
    (((y(end)-y(1))*ad.data{ad.control.spectra.active}.display.scaling.y))-...
    (y(end)-y(1)))...
    );
set(...
    gh.slider_panel_scaling_z_index_edit,...
    'String',...
    num2str(ad.data{ad.control.spectra.active}.display.scaling.z)...
    );

switch ad.control.axis.normalisation
    case 'pkpk'
        z = [0 1];
    case 'amplitude'
        z(1) = min(min(ad.data{ad.control.spectra.active}.data/...
            max(max(ad.data{ad.control.spectra.active}.data))));
        z(2) = max(max(ad.data{ad.control.spectra.active}.data/...
            max(max(ad.data{ad.control.spectra.active}.data))));
    otherwise
        z(1) = min(min(ad.data{ad.control.spectra.active}.data));
        z(2) = max(max(ad.data{ad.control.spectra.active}.data));
end

set(...
    gh.slider_panel_scaling_z_unit_edit,...
    'String',...
    num2str(...
    (((z(2)-z(1))*...
    ad.data{ad.control.spectra.active}.display.scaling.z))-...
    (z(2)-z(1)))...
    );

% Update displacement panel
set(...
    gh.slider_panel_displacement_x_index_edit,...
    'String',...
    num2str(ad.data{ad.control.spectra.active}.display.displacement.x));
set(...
    gh.slider_panel_displacement_x_unit_edit,...
    'String',...
    num2str(...
    (x(2)-x(1)) * ...
    ad.data{ad.control.spectra.active}.display.displacement.x)...
    );
set(...
    gh.slider_panel_displacement_y_index_edit,...
    'String',...
    num2str(ad.data{ad.control.spectra.active}.display.displacement.y));
set(...
    gh.slider_panel_displacement_y_unit_edit,...
    'String',...
    num2str(...
    (y(2)-y(1)) * ...
    ad.data{ad.control.spectra.active}.display.displacement.y)...
    );
set(...
    gh.slider_panel_displacement_z_index_edit,...
    'String',...
    num2str(ad.data{ad.control.spectra.active}.display.displacement.z)...
    );
set(...
    gh.slider_panel_displacement_z_unit_edit,...
    'String',...
    num2str(...
    ad.data{ad.control.spectra.active}.display.displacement.z/...
    (max(max(ad.data{ad.control.spectra.active}.data))-...
    min(min(ad.data{ad.control.spectra.active}.data)))*...
    (z(2)-z(1))...
    )...
    );

% Update position panel
set(...
    gh.slider_panel_position_x_index_edit,...
    'String',...
    ad.data{ad.control.spectra.active}.display.position.x...
    );
set(...
    gh.slider_panel_position_x_unit_edit,...
    'String',...
    x(ad.data{ad.control.spectra.active}.display.position.x)...
    );
set(...
    gh.slider_panel_position_y_index_edit,...
    'String',...
    ad.data{ad.control.spectra.active}.display.position.y...
    );
set(...
    gh.slider_panel_position_y_unit_edit,...
    'String',...
    y(ad.data{ad.control.spectra.active}.display.position.y)...
    );

% Do tasks that depend on displayType
switch ad.control.axis.displayType
    case '2D plot'
    case '1D along x' % time profile
        % Update position slider
        set(gh.vert1_slider,...
            'Value',...
            ad.data{ad.control.spectra.active}.display.position.y...
            )
        % Update scaling slider
        if (ad.data{ad.control.spectra.active}.display.scaling.z > 1)
            set(gh.vert2_slider,...
                'Value',...
                ad.data{ad.control.spectra.active}.display.scaling.z-...
                get(gh.vert2_slider,'Max')...
                );
        else
            set(gh.vert2_slider,...
                'Value',...
                -(1/ad.data{ad.control.spectra.active}.display.scaling.z-...
                get(gh.vert2_slider,'Max'))...
                );
        end
        if (ad.data{ad.control.spectra.active}.display.scaling.x > 1)
            set(gh.horz1_slider,...
                'Value',...
                ad.data{ad.control.spectra.active}.display.scaling.x-...
                get(gh.horz1_slider,'Max')...
                );
        else
            set(gh.horz1_slider,...
                'Value',...
                -(1/ad.data{ad.control.spectra.active}.display.scaling.x-...
                get(gh.horz1_slider,'Max'))...
                );
        end
        % Update displacement slider
        set(gh.vert3_slider,...
            'Value',...
            ad.data{ad.control.spectra.active}.display.displacement.z...
            );
        set(gh.horz2_slider,...
            'Value',...
            ad.data{ad.control.spectra.active}.display.displacement.x...
            );
    case '1D along y' % B0 spectrum
        % Update position slider
        set(gh.vert1_slider,...
            'Value',...
            ad.data{ad.control.spectra.active}.display.position.x...
            )
        % Update scaling slider
        if (ad.data{ad.control.spectra.active}.display.scaling.z > 1)
            set(gh.vert2_slider,...
                'Value',...
                ad.data{ad.control.spectra.active}.display.scaling.z-...
                get(gh.vert2_slider,'Max')...
                );
        else
            set(gh.vert2_slider,...
                'Value',...
                -(1/ad.data{ad.control.spectra.active}.display.scaling.z-...
                get(gh.vert2_slider,'Max'))...
                );
        end
        if (ad.data{ad.control.spectra.active}.display.scaling.y > 1)
            set(gh.horz1_slider,...
                'Value',...
                ad.data{ad.control.spectra.active}.display.scaling.y-...
                get(gh.horz1_slider,'Max')...
                );
        else
            set(gh.horz1_slider,...
                'Value',...
                -(1/ad.data{ad.control.spectra.active}.display.scaling.y-...
                get(gh.horz1_slider,'Max'))...
                );
        end
        % Update displacement slider
        set(gh.vert3_slider,...
            'Value',...
            ad.data{ad.control.spectra.active}.display.displacement.z...
            );
        set(gh.horz2_slider,...
            'Value',...
            ad.data{ad.control.spectra.active}.display.displacement.y...
            );
    otherwise
        msg = sprintf('Display type %s currently unsupported',ad.control.axis.displayType);
        trEPRadd2status(msg);
end

status = 0;

end