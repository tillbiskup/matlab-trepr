function status = update_measurePanel()
% UPDATE_MEASUREPANEL Helper function that updates the measure panel
%   of the trEPR GUI, namely trEPR_gui_mainwindow.
%
%   STATUS: return value for the exit status
%           -1: no tEPR_gui_mainwindow found
%            0: successfully updated main axis

% Copyright (c) 2011-14, Till Biskup
% 2014-06-27

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

% Toggle state of the measure buttons
if ~ad.control.spectra.active
    set(gh.measure_panel_point_togglebutton,'Enable','off');
    set(gh.measure_panel_distance_togglebutton,'Enable','off');
    set(gh.measure_panel_clear_pushbutton,'Enable','off');
    set(gh.measure_panel_poi_pushbutton,'Enable','off');
    set(gh.measure_panel_doi_pushbutton,'Enable','off');
    return;
end

set(gh.measure_panel_point_togglebutton,'Enable','on');
set(gh.measure_panel_distance_togglebutton,'Enable','on');
set(gh.measure_panel_clear_pushbutton,'Enable','on');

% Set values accordingly - if they exist
active = ad.control.spectra.active;
if isfield(ad.data{active}.display,'measure') && ...
        ~isempty(ad.data{active}.display.measure.point(1).index)
    set(gh.measure_panel_point1_x_index_edit,'String',...
        num2str(ad.data{active}.display.measure.point(1).index(1)));
    set(gh.measure_panel_point1_y_index_edit,'String',...
        num2str(ad.data{active}.display.measure.point(1).index(2)));
    set(gh.measure_panel_point1_x_unit_edit,'String',...
        num2str(ad.data{active}.display.measure.point(1).unit(1)));
    set(gh.measure_panel_point1_y_unit_edit,'String',...
        num2str(ad.data{active}.display.measure.point(1).unit(2)));
    
    set(gh.measure_panel_poi_pushbutton,'Enable','on');
else
    set(gh.measure_panel_point1_x_index_edit,'String','0');
    set(gh.measure_panel_point1_y_index_edit,'String','0');
    set(gh.measure_panel_point1_x_unit_edit,'String','0');
    set(gh.measure_panel_point1_y_unit_edit,'String','0');
    
    set(gh.measure_panel_poi_pushbutton,'Enable','off');
end
if isfield(ad.data{active}.display,'measure') && ...
        length(ad.data{active}.display.measure.point) > 1 && ...
        ~isempty(ad.data{active}.display.measure.point(2).index)
    set(gh.measure_panel_point2_x_index_edit,'String',...
        num2str(ad.data{active}.display.measure.point(2).index(1)));
    set(gh.measure_panel_point2_y_index_edit,'String',...
        num2str(ad.data{active}.display.measure.point(2).index(2)));
    set(gh.measure_panel_point2_x_unit_edit,'String',...
        num2str(ad.data{active}.display.measure.point(2).unit(1)));
    set(gh.measure_panel_point2_y_unit_edit,'String',...
        num2str(ad.data{active}.display.measure.point(2).unit(2)));
    
    set(gh.measure_panel_distance_x_index_edit,'String',...
        num2str(ad.data{active}.display.measure.point(2).index(1)-...
        ad.data{active}.display.measure.point(1).index(1)));
    set(gh.measure_panel_distance_y_index_edit,'String',...
        num2str(ad.data{active}.display.measure.point(2).index(2)-...
        ad.data{active}.display.measure.point(1).index(2)));
    set(gh.measure_panel_distance_x_unit_edit,'String',...
        num2str(ad.data{active}.display.measure.point(2).unit(1)-...
        ad.data{active}.display.measure.point(1).unit(1)));
    set(gh.measure_panel_distance_y_unit_edit,'String',...
        num2str(ad.data{active}.display.measure.point(2).unit(2)-...
        ad.data{active}.display.measure.point(1).unit(2)));

    set(gh.measure_panel_doi_pushbutton,'Enable','on');
else
    set(gh.measure_panel_point2_x_index_edit,'String','0');
    set(gh.measure_panel_point2_y_index_edit,'String','0');
    set(gh.measure_panel_point2_x_unit_edit,'String','0');
    set(gh.measure_panel_point2_y_unit_edit,'String','0');
    
    set(gh.measure_panel_distance_x_index_edit,'String','0');
    set(gh.measure_panel_distance_y_index_edit,'String','0');
    set(gh.measure_panel_distance_x_unit_edit,'String','0');
    set(gh.measure_panel_distance_y_unit_edit,'String','0');

    set(gh.measure_panel_doi_pushbutton,'Enable','off');
end

status = 0;

end
