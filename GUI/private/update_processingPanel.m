function status = update_processingPanel()
% UPDATE_PROCESSINGPANEL Helper function that updates the processing panel
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

if isempty(ad.control.data.visible)
    set(findobj(allchild(gh.processing_panel),'-not','type','uipanel',...
        '-not','type','uibuttongroup'),...
        'Enable','Inactive');
    return;
end

active = ad.control.data.active;

set(findobj(allchild(gh.processing_panel),'-not','type','uipanel',...
        '-not','type','uibuttongroup'),...
    'Enable','On');

% Set default value for MW frequency correction
set(gh.processing_panel_fc_edit,'String',...
    num2str(ad.data{active}.parameters.bridge.MWfrequency.value));

% Disable Savitzky-Golay-specific fields if not needed
smoothingTypes = cellstr(...
    get(gh.processing_panel_smoothing_type_popupmenu,'String'));
smoothingType = smoothingTypes{...
    get(gh.processing_panel_smoothing_type_popupmenu,'Value')};
if ~strcmpi(smoothingType,'savitzkygolay')
    set(gh.processing_panel_smoothing_order_edit,'Enable','off');
    set(gh.processing_panel_smoothing_deriv_edit,'Enable','off');
end

% Update smoothing panel
% Get direction along which to smooth
direction = get(get(gh.processing_panel_smoothing_buttongroup,...
    'SelectedObject'),'String');
direction = find(strcmpi(direction(1),{'x','y'}));

% Set edit fields
set(gh.processing_panel_smoothing_width_points_edit,...
    'String',num2str(...
    ad.data{active}.display.smoothing.data(direction).parameters.width)...
    );
units = ad.data{active}.axes.data(direction).values;
if length(units)>1
    deltaUnits = (units(2)-units(1))*ad.data{active}.display.smoothing.data(...
        direction).parameters.width;
else
    deltaUnits = 0;
end
set(gh.processing_panel_smoothing_width_unit_edit,...
    'String',num2str(deltaUnits)...
    );
% Set filter type popupmenu
filterTypes = cellstr(...
    get(gh.processing_panel_smoothing_type_popupmenu,'String'));
filterType = ad.data{active}.display.smoothing.data(direction).filterfun;
if ~isempty(filterType)
    set(gh.processing_panel_smoothing_type_popupmenu,'Value',...
        find(strcmpi(filterTypes,filterType(length('trEPRfilter_')+1:end))));
end


status = 0;

end
