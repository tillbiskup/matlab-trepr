function [status,warnings] = cmdHide(handle,opt,varargin)
% CMDHIDE Command line command of the trEPR GUI.
%
% Usage:
%   cmdHide(handle,opt)
%   [status,warnings] = cmdHide(handle,opt)
%
%   handle  - handle
%             Handle of the window the command should be performed for
%
%   opt     - cell array
%             Options of the command
%
%   status  - scalar
%             Return value for the exit status:
%              0: command successfully performed
%             -1: GUI window found
%             -2: missing options
%             -3: some other problems
%
%  warnings - cell array
%             Contains warnings/error messages if any, otherwise empty

% Copyright (c) 2013-15, Till Biskup
% 2015-10-18

status = 0;
warnings = cell(0);

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('handle', @(x)ishandle(x));
p.addRequired('opt', @(x)iscell(x));
%p.addOptional('opt',cell(0),@(x)iscell(x));
p.parse(handle,opt,varargin{:});
handle = p.Results.handle;
opt = p.Results.opt;

% Get command name from mfilename
cmd = mfilename;
cmd = cmd(4:end);

% Is there the GUI requested?
if (isempty(handle))
    warnings{end+1} = 'No GUI window could be found.';
    status = -1;
    return;
end

% Get appdata from handle
ad = getappdata(handle);
% Get handles from handle
gh = ad.guiHandles;

if isempty(ad.data)
    warnings{end+1} = ['Command "' lower(cmd) '" needs datasets.'];
    return;
end

if isempty(opt)
    if ~isempty(ad.control.data.visible)
        % Get selected item of listbox
        selected = get(gh.data_panel_visible_listbox,'Value');
        
        % Be on the save side if user is faster than Matlab
        if selected == 0
            return;
        end
        
        % Move to invisible
        ad.control.data.invisible = [...
            ad.control.data.invisible ...
            ad.control.data.visible(selected) ...
            ];
        
        % Delete in visible
        ad.control.data.visible(selected) = [];
        
        % Toggle active entry
        if (selected > length(ad.control.data.visible))
            if (selected == 1)
                ad.control.data.active = 0;
            else
                ad.control.data.active = ad.control.data.visible(end);
            end
        else
            ad.control.data.active = ad.control.data.visible(selected);
        end
    end
elseif strcmpi(opt{1},'all')
    % If there are no visible datasets, return immediately
    if isempty(ad.control.data.visible)
        return;
    end
    % Move to invisible
    ad.control.data.invisible = [...
        ad.control.data.invisible ...
        ad.control.data.visible ...
        ];
    
    % Delete in visible
    ad.control.data.visible = [];
    
    % Reset active entry
    ad.control.data.active = 0;
elseif ~isnan(str2double(opt{1}))
    if any(ad.control.data.visible==str2double(opt{1}))
        % Move to invisible
        selected = str2double(opt{1});
        ad.control.data.invisible = [...
            ad.control.data.invisible ...
            selected ...
            ];
        
        % Delete in visible
        ad.control.data.visible(ad.control.data.visible==selected) = [];
        
        % Toggle active entry
        if (selected > length(ad.control.data.visible))
            if (selected == 1)
                ad.control.data.active = 0;
            else
                ad.control.data.active = ad.control.data.visible(end);
            end
        else
            ad.control.data.active = ad.control.data.visible(...
                get(gh.data_panel_visible_listbox,'Value'));
        end
    else
        status = -3;
        warnings{end+1} = ['Dataset ' opt{1} ' not in visible datasets.'];
        return;
    end
else
    status = -3;
    warnings{end+1} = ['Option ' opt{1} ' not understood.'];
    return;
end
        
% Update appdata of main window
setappdata(handle,'control',ad.control);

% Add status message (mainly for debug reasons)
% IMPORTANT: Has to go AFTER setappdata
msgStr = cell(0,1);
msgStr{end+1} = 'Moved all datasets to invisible';
invStr = sprintf('%i ',ad.control.data.invisible);
visStr = sprintf('%i ',ad.control.data.visible);
msgStr{end+1} = sprintf(...
    'Currently invisible: [ %s]; currently visible: [ %s]; total: %i',...
    invStr,visStr,length(ad.data));
trEPRmsg(msgStr,'debug');

% Update both list boxes
update_invisibleSpectra();
update_visibleSpectra();

%Update main axis
update_mainAxis();
return;

end

