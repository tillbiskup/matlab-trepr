function status = update_loadPanel()
% UPDATE_LOADPANEL Helper function that updates the load panel of the trEPR
% GUI, namely trEPR_gui_mainwindow. 
%
%   STATUS: return value for the exit status
%           -1: no tEPR_gui_mainwindow found
%            0: successfully updated main axis

% Copyright (c) 2014-15, Till Biskup
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

fileType = ad.control.panels.load.fileType;
if isfield(gh,'load_filetype_popupmenu')
    set(gh.load_filetype_popupmenu,'Value',fileType);
end
fields = fieldnames(ad.control.panels.load.fileTypes);
for field = 1:length(fields)
    tagname = ['load_' fields{field} '_checkbox'];
    if isfield(gh,tagname)
        set(gh.(tagname),'Value',...
            ad.control.panels.load.fileTypes(fileType).(fields{field}));
    end
end

status = 0;

end
