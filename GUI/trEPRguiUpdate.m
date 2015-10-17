function trEPRguiUpdate(varargin)
% TREPRGUIUPDATE Update GUI display to resemble change in underlying
% appdata stucture.
%
% Usage:
%   trEPRguiUpdate
%
% See also: update_*

% Copyright (c) 2014-15, Till Biskup
% 2015-10-17

if nargin && strcmpi(varargin{1},'mainwindow')
    updateMainWindow;
    return;
end

% Needs to be way more intelligent. For now, just call all the update
% functions

% Get update functions
[path,~,~] = fileparts(mfilename('fullpath'));
updateFuns = dir(fullfile(path,'private','update_*.m'));

for updateFun = 1:length(updateFuns)
    fun = str2func(updateFuns(updateFun).name(1:end-2));
    fun();
end
       
end

function updateMainWindow

% get GUI handles and appdata
mainGuiWindow = trEPRguiGetWindowHandle;
ad = getappdata(mainGuiWindow);
gh = ad.UsedByGUIData_m;
%gh = guihandles(mainGuiWindow);

switch ad.control.status.code
    case 'OK'
        set(gh.status_panel_status_text,'BackgroundColor',[.7 .9 .7]);
    case 'WW'
        set(gh.status_panel_status_text,'BackgroundColor',[.9 .9 .7]);
    case 'EE'
        set(gh.status_panel_status_text,'BackgroundColor',[.9 .7 .7]);
    otherwise
        trEPRoptionUnknown(ad.control.status.code);
end
set(gh.status_panel_status_text,'String',ad.control.status.code);

end