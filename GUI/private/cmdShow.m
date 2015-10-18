function [status,warnings] = cmdShow(handle,opt,varargin)
% CMDSHOW Command line command of the trEPR GUI.
%
% Usage:
%   cmdShow(handle,opt)
%   [status,warnings] = cmdShow(handle,opt)
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

% For convenience and shorter lines
active = ad.control.data.active;

if isempty(ad.data)
    warnings{end+1} = ['Command "' lower(cmd) '" needs datasets.'];
    return;
end

if isempty(opt)
    if ~isempty(ad.control.data.invisible)
        % Get selected item of listbox
        selected = get(gh.data_panel_invisible_listbox,'Value');
        
        % Be on the save side if user is faster than Matlab
        if selected == 0
            return;
        end
        
        % Move to visible
        ad.control.data.visible = [...
            ad.control.data.visible ...
            ad.control.data.invisible(selected) ...
            ];
        
        % Make moved entry active one
        ad.control.data.active = ad.control.data.invisible(selected);
        
        % Delete in invisible
        ad.control.data.invisible(selected) = [];
        
        % Update appdata of main window
        setappdata(handle,'control',ad.control);
        
        % Add status message (mainly for debug reasons)
        % IMPORTANT: Has to go AFTER setappdata
        msgStr = cell(0,1);
        msgStr{end+1} = sprintf(...
            'Moved dataset %i to visible',...
            ad.control.data.active);
        msgStr{end+1} = ['Label: ' ...
            ad.data{ad.control.data.active}.label];
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
    else
        trEPRmsg('No invisible spectra to make visible.','debug');
        return;
    end
elseif ~isnan(str2double(opt{1}))
    if any(ad.control.data.invisible==str2double(opt{1}))
        selected = str2double(opt{1});
        % Move to visible
        ad.control.data.visible = [...
            ad.control.data.visible ...
            selected ...
            ];
        
        % Make moved entry active one
        ad.control.data.active = selected;
        
        % Delete in invisible
        ad.control.data.invisible(ad.control.data.invisible==selected) = [];
        
        % Update appdata of main window
        setappdata(handle,'control',ad.control);
        
        % Add status message (mainly for debug reasons)
        % IMPORTANT: Has to go AFTER setappdata
        msgStr = cell(0,1);
        msgStr{end+1} = sprintf(...
            'Moved dataset %i to visible',...
            ad.control.data.active);
        msgStr{end+1} = ['Label: ' ...
            ad.data{ad.control.data.active}.label];
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
    elseif any(ad.control.data.visible==str2double(opt{1}))
        % Make dataset active one
        ad.control.data.active = str2double(opt{1});

        % Update appdata of main window
        setappdata(handle,'control',ad.control);
        
        %Update GUI
        update_visibleSpectra();
        update_mainAxis();
    else
        status = -3;
        warnings{end+1} = ['Dataset ' opt{1} ' not in invisible datasets.'];
        return;
    end
else
    switch lower(opt{1})
        case 'all'
            if length(opt) > 1
                switch lower(opt{2})
                    case 'visible'
                        % Unset "onlyActive"
                        ad.control.axis.onlyActive = 0;
                        set(gh.data_panel_showonlyactive_checkbox,'Value',0);
                        % Update appdata of main window
                        setappdata(handle,'control',ad.control);
                        update_mainAxis();
                        return;
                    otherwise
                        status = -3;
                        warnings{end+1} = ['Option ' opt{2} ' not understood.'];
                        return;
                end
            end
            if ~isempty(ad.control.data.invisible)
                % Move to visible
                ad.control.data.visible = [...
                    ad.control.data.visible ...
                    ad.control.data.invisible ...
                    ];
                
                % Delete in invisible
                ad.control.data.invisible = [];
                
                % Set active if not done
                if isempty(active) || (active < 1)
                    ad.control.data.active = 1;
                end
                
                % Add status message (mainly for debug reasons)
                % IMPORTANT: Has to go AFTER setappdata
                msgStr = cell(0,1);
                msgStr{end+1} = 'Moved all datasets to visible';
                invStr = sprintf('%i ',ad.control.data.invisible);
                visStr = sprintf('%i ',ad.control.data.visible);
                msgStr{end+1} = sprintf(...
                    'Currently invisible: [ %s]; currently visible: [ %s]; total: %i',...
                    invStr,visStr,length(ad.data));
                trEPRmsg(msgStr,'debug');
                
                % Update both list boxes
                update_invisibleSpectra();
                update_visibleSpectra();
            end
            
            % Unset "onlyActive"
            ad.control.axis.onlyActive = 0;
            set(gh.data_panel_showonlyactive_checkbox,'Value',0);
            
            % Update appdata of main window
            setappdata(handle,'control',ad.control);
            
            % Update both list boxes
            update_invisibleSpectra();
            update_visibleSpectra();
            
            %Update main axis
            update_mainAxis();
            return;
        case 'only'
            if length(opt) < 2
                status = -3;
                warnings{end+1} = ['Option "' opt{1} '" needs another option.'];
                return;
            end                
            switch lower(opt{2})
                case 'active'
                    ad.control.axis.onlyActive = 1;
                    set(gh.data_panel_showonlyactive_checkbox,'Value',1);
                    setappdata(handle,'control',ad.control);
                    update_mainAxis();
                    return;
                otherwise
                    status = -3;
                    warnings{end+1} = ['Option ' opt{2} ' not understood.'];
                    return;
            end
        case {'next','n'}
            if ~ad.control.data.active || ...
                    length(ad.control.data.visible) == 1
                return;
            end
            idx = find(ad.control.data.visible==ad.control.data.active);
            if idx < length(ad.control.data.visible)
                ad.control.data.active = ad.control.data.visible(idx+1);
            else
                ad.control.data.active = ad.control.data.visible(1);
            end
            setappdata(handle,'control',ad.control);
            update_mainAxis();
            update_visibleSpectra();
            update_processingPanel();
            update_sliderPanel();
        case {'prev','previous','p'}
            if ~ad.control.data.active || ...
                    length(ad.control.data.visible) == 1
                return;
            end
            idx = find(ad.control.data.visible==ad.control.data.active);
            if idx == 1
                ad.control.data.active = ad.control.data.visible(end);
            else
                ad.control.data.active = ad.control.data.visible(idx-1);
            end
            setappdata(handle,'control',ad.control);
            update_mainAxis();
            update_visibleSpectra();
            update_processingPanel();
            update_sliderPanel();
        case {char([100 105 108 98 101 114 116]),char([120 107 99 100]),...
                char([112 104 100 99 111 109 105 99]),...
                char([110 105 99 104 116 108 117 115 116 105 103])}
            guiProcRast(opt{1});
        otherwise
            status = -3;
            warnings{end+1} = ['Option ' opt{1} ' not understood.'];
            return;
    end

end
