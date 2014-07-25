function status = update_processingPanel()
% UPDATE_PROCESSINGPANEL Helper function that updates the processing panel
%   of the trEPR GUI, namely trEPR_gui_mainwindow.
%
%   STATUS: return value for the exit status
%           -1: no tEPR_gui_mainwindow found
%            0: successfully updated main axis

% Copyright (c) 2011-14, Till Biskup
% 2014-07-25

% Is there currently a trEPRgui object?
mainWindow = trEPRguiGetWindowHandle();
if (isempty(mainWindow))
    status = -1;
    return;
end

% Get handles and appdata from main window
gh = guidata(mainWindow);
ad = getappdata(mainWindow);

if isempty(ad.control.spectra.visible)
    set(findobj(allchild(gh.processing_panel),'-not','type','uipanel'),...
        'Enable','Inactive');
    return;
end

active = ad.control.spectra.active;

set(findobj(allchild(gh.processing_panel),'-not','type','uipanel'),...
    'Enable','On');
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

% Set edit fields
set(gh.processing_panel_smoothing_width_points_edit,...
    'String',num2str(...
    ad.data{active}.display.smoothing.data.(direction(1)).parameters.width)...
    );
units = ad.data{active}.axes.(direction(1)).values;
if length(units)>1
    deltaUnits = (units(2)-units(1))*ad.data{active}.display.smoothing.data.(...
        direction(1)).parameters.width;
else
    deltaUnits = 0;
end
set(gh.processing_panel_smoothing_width_unit_edit,...
    'String',num2str(deltaUnits)...
    );
% Set filter type popupmenu
filterTypes = cellstr(...
    get(gh.processing_panel_smoothing_type_popupmenu,'String'));
filterType = ad.data{active}.display.smoothing.data.(direction(1)).filterfun;
if ~isempty(filterType)
    set(gh.processing_panel_smoothing_type_popupmenu,'Value',...
        find(strcmpi(filterTypes,filterType(length('trEPRfilter_')+1:end))));
end


status = 0;

end
