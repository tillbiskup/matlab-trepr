function status = update_displayPanel()
% UPDATE_DISPLAYPANEL Helper function that updates the display panel
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
if (ad.control.spectra.active)
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

% Toggle state of axislimits edit fields according to "automatic"
editHandles = findobj(...
    'Parent',gh.display_panel_axislimits_panel,'Style','edit');
if (get(gh.display_panel_axislimits_auto_checkbox,'Value'))
    set(editHandles,'Enable','Off');
else
    set(editHandles,'Enable','On');
end

% Update display type popupmenu
displayTypes = cellstr(get(gh.display_panel_displaytype_popupmenu,'String'));
for k=1:length(displayTypes)
    if strcmp(displayTypes(k),ad.control.axis.displayType)
        set(gh.display_panel_displaytype_popupmenu,'Value',k)
    end
end

status = 0;

end