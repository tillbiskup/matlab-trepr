function status = update_datasetPanel()
% UPDATE_DATASETPANEL Helper function that updates the display panel
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
%gh = ad.guiHandles;

% Update display type popupmenu
% displayTypes = cellstr(get(gh.data_panel_displaytype_popupmenu,'String'));
% for k=1:length(displayTypes)
%     if strcmp(displayTypes(k),ad.control.axis.displayType)
%         set(gh.data_panel_displaytype_popupmenu,'Value',k)
%     end
% end

update_visibleSpectra();
update_invisibleSpectra();

status = 0;

end
