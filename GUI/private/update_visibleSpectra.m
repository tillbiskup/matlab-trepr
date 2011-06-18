function status = update_visibleSpectra()
% UPDATE_VISIBLESPECTRA Helper function that updates the panels 
%   of the trEPR GUI, namely trEPR_gui_mainwindow, that list the
%   loaded and currently visible spectra.
%
%   At the same time, it updates the list of visible spectra in other
%   panels.
%
%   STATUS: return value for the exit status
%           -1: no tEPR_gui_mainwindow found
%            0: successfully updated panels listing the spectra

% Is there currently a trEPRgui object?
mainWindow = findobj('Tag','trepr_gui_mainwindow');
if (isempty(mainWindow))
    status = -1;
    return;
end

% Get handle for visible spectra listbox
gh = guidata(mainWindow);
visLbox = gh.data_panel_visible_listbox;

% Get appdata from main GUI
ad = getappdata(mainWindow);

% Get indices of invisible spectra
vis = ad.control.spectra.visible;

% Get names for display in listbox
labels = cell(0);
for k=1:length(vis)
    labels{k} = ad.data{vis(k)}.label;
end

% Update status display
set(visLbox,'String',labels);
if (get(visLbox,'Value')>length(vis))
    set(visLbox,'Value',length(vis));
end
if ((get(visLbox,'Value')==0) && (length(vis)>0))
    set(visLbox,'Value',1);
end

% Highlight currently active
if ad.control.spectra.active
    set(visLbox,'Value',find(vis==ad.control.spectra.active));
end

% Change enable status of pushbuttons and other elements
currActiveButtons = findobj('Parent',gh.data_panel_currentlyactive_panel);
visPanelChildren = findobj('Parent',gh.data_panel_visible_panel,'-not','Style','Listbox');
dTypePanelChildren = findobj('Parent',gh.data_panel_displaytype_panel);
if isempty(ad.control.spectra.visible)
    set(gh.data_panel_hide_pushbutton,'Enable','off');
    set(currActiveButtons,'Enable','off');
    set(visPanelChildren,'Enable','off');
    set(dTypePanelChildren,'Enable','off');
    set(gh.processing_panel_datasets_listbox,'Enable','off');
    set(gh.data_panel_visible_listbox,'Enable','off');
    set(gh.display_panel_displaytype_popupmenu,'Enable','off');
else
    set(gh.data_panel_hide_pushbutton,'Enable','on');
    set(currActiveButtons,'Enable','on');
    set(gh.data_panel_visible_listbox,'Enable','on');
    set(dTypePanelChildren,'Enable','on');
    set(gh.processing_panel_datasets_listbox,'Enable','on');
    set(gh.data_panel_visible_listbox,'Enable','on');
    set(gh.display_panel_displaytype_popupmenu,'Enable','on');

    % Show additional controls in visible_listbox only if there are more
    % than two datasets currently visible
    if (length(ad.control.spectra.visible) > 1)
        set(visPanelChildren,'Enable','on');
    else
        set(visPanelChildren,'Enable','off');
    end

    % Make "Save" button active only if currently active spectrum is
    % modified
    if (find(ad.control.spectra.modified==ad.control.spectra.active))
        set(gh.data_panel_save_pushbutton,'Enable','On');
    else
        set(gh.data_panel_save_pushbutton,'Enable','Off');
    end
    
    % Set displayType in ad.control.axis
    if isempty(ad.control.axis.displayType)
        displayTypes = cellstr(get(gh.data_panel_displaytype_popupmenu,'String'));
        displayType = displayTypes{get(gh.data_panel_displaytype_popupmenu,'Value')};
        ad.control.axis.displayType = displayType;
        % Update appdata of main window
        setappdata(mainWindow,'control',ad.control);
    end
end

% Update list of spectra of the processing panel
procPLbox = gh.processing_panel_datasets_listbox;
set(procPLbox,'String',labels);

% Highlight currently active
if ad.control.spectra.active
    set(procPLbox,'Value',find(vis==ad.control.spectra.active));
end


status = 0;

end