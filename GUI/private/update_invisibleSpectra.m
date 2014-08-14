function status = update_invisibleSpectra()
% UPDATE_INVISIBLESPECTRA Helper function that updates the panels 
%   of the trEPR GUI, namely trEPRgui_statuswindow, that list the
%   loaded but currently invisible spectra.
%
%   STATUS: return value for the exit status
%           -1: no tEPRgui_statuswindow found
%            0: successfully updated panels listing the spectra

% Copyright (c) 2011-14, Till Biskup
% 2014-06-06

% Is there currently a trEPRgui object?
mainWindow = trEPRguiGetWindowHandle();
if (isempty(mainWindow))
    status = -1;
    return;
end

% Get handle for invisible spectra listbox
gh = guihandles(mainWindow);
invLbox = gh.data_panel_invisible_listbox;

% Get appdata from main GUI
ad = getappdata(mainWindow);

% Get indices of invisible spectra
inv = ad.control.data.invisible;

% Get names for display in listbox
labels = cell(0);
for k=1:length(inv)
    if (find(inv(k)==ad.control.data.modified))
        labels{k} = sprintf('%02.0f: *%s',inv(k),ad.data{inv(k)}.label);
    else
        labels{k} = sprintf('%02.0f: %s',inv(k),ad.data{inv(k)}.label);
    end
end

% Update status display
set(invLbox,'String',labels);
if (get(invLbox,'Value')>length(inv))
    set(invLbox,'Value',length(inv));
end
if ((get(invLbox,'Value')==0) && (~isempty(inv)))
    set(invLbox,'Value',1);
end

% Change enable status of pushbuttons and other elements
invPanelChildren = findobj('Parent',gh.data_panel_invisible_panel);
if isempty(ad.control.data.invisible)
    set(gh.data_panel_show_pushbutton,'Enable','off');
    set(gh.data_panel_showall_pushbutton,'Enable','off');
    set(invPanelChildren,'Enable','off');
else
    set(gh.data_panel_show_pushbutton,'Enable','on');
    set(gh.data_panel_showall_pushbutton,'Enable','on');
    set(invPanelChildren,'Enable','on');
end

status = 0;

end
