function status = update_measurePanel()
% UPDATE_MEASUREPANEL Helper function that updates the measure panel
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

% Toggle state of the measure buttons
if (ad.control.spectra.active)
    set(...
        gh.measure_panel_1point_togglebutton,...
        'Enable','on'...
        );
    set(...
        gh.measure_panel_2points_togglebutton,...
        'Enable','on'...
        );
    set(...
        gh.measure_panel_clear_pushbutton,...
        'Enable','on'...
        );
else
    set(...
        gh.measure_panel_1point_togglebutton,...
        'Enable','off'...
        );
    set(...
        gh.measure_panel_2points_togglebutton,...
        'Enable','off'...
        );
    set(...
        gh.measure_panel_clear_pushbutton,...
        'Enable','off'...
        );
end

status = 0;

end