function status = guiConfigApply(guiname)
% GUICONFIGAPPLY Apply configuration parameters to a given GUI window.
%
% Used normally when initialising a GUI. The GUI needs to have a field
% "configuration" in its appdata structure. To actually read configuration
% settings from a file, use guiConfigLoad.
%
% Usage
%   guiConfigApply(guiname)
%
%   guiname - string
%             valid mfilename of a GUI
%             An instance of that GUI must run.
%
% See also GUICONFIGLOAD, INIFILEREAD

% Copyright (c) 2011-14, Till Biskup
% 2014-10-08

status = 0;

% If called without a GUI name, return
if isempty(guiname)
    status = sprintf('GUI "%s" could not be found',guiname);
    return;
end

try
    % Get handle for GUI
    % NOTE: That means that an instance of the GUI must exist.
    handle = trEPRguiGetWindowHandle(guiname);
    if isempty(handle) || ~ishandle(handle)
        status = -2;
        return;
    end
    
    ad = getappdata(handle);
    gh = guihandles(handle);

    ad.configuration = trEPRguiConfigLoad(guiname);
    setappdata(handle,'configuration',ad.configuration);

    % Switch depending on GUI name - use GUI mfilename therefore
    switch lower(guiname)
        case 'treprgui'
            % NOTE: Be very defensive in general, as we cannot rely on the
            % GUI having loaded a valid config file.
            % This is true in particular due to the fact that only the
            % .ini.dist files get distributed, but not the actual config
            % files.
            
            % Set position of the main GUI window
            if isfield(ad.configuration,'general')
                guiPosition = get(handle,'Position');
                if isfield(ad.configuration.general,'dx')
                    guiPosition(1) = ad.configuration.general.dx;
                    set(handle,'Position',guiPosition);
                end
                if isfield(ad.configuration.general,'dy')
                    guiPosition(2) = ad.configuration.general.dy;
                    set(handle,'Position',guiPosition);
                end
            end
            
            % Set load panel's settings
            fieldNames = {'combine','loaddir','infofile',...
                'unitconversion','POC','BGC','labels','visible'};
            % 2014-10-08: (Temporary) trick to compensate for inconsistent
            %             field names in different config files...
            % TODO: Rename configuration settings in trEPRgui.conf
            fieldNames2 = {'combine','loadDir','loadInfoFile',...
                'convertUnits','POC','BGC','determineAxisLabels',...
                'visibleUponLoad'};
            for fieldName = 1:length(fieldNames)
                if isfield(ad.configuration.load,fieldNames{fieldName})
                    set(gh.(['load_' fieldNames2{fieldName} '_checkbox']),...
                        'Value',...
                        ad.configuration.load.(fieldNames{fieldName}));
                end
            end                
            if isfield(ad.configuration.load,'format')
                % Get value from load_filetype_popupmenu
                fileTypes = ...
                    cellstr(get(gh.load_filetype_popupmenu,'String'));
                for k=1:length(fileTypes)
                    if strcmpi(fileTypes{k},ad.configuration.load.format)
                        set(gh.load_filetype_popupmenu,'Value',k);
                    end
                end
            end
            % Set display panel's settings
            if isfield(ad.configuration.display,'figsave')
                set(gh.display_panel_axesexport_includecaption_checkbox,...
                    'Value',ad.configuration.display.figsave.caption);
            end
            % Set colormap settings
            ad.control.axis.colormap = structcopy(...
                ad.control.axis.colormap,ad.configuration.colormap);
            % Generically set a number of configuration settings where we
            % have a direct match
            matchConfig = {...
                'dirs','dirs'; ...
                'messages','messages'; ...
                'cmd','cmd'; ...
                };
            for k=1:length(matchConfig(:,1))
                if isfield(ad.configuration,matchConfig{k,1})
                    ad.control.(matchConfig{k,2}) = ...
                        structcopy(ad.control.(matchConfig{k,2}), ...
                        ad.configuration.(matchConfig{k,1}));
                end
            end
            setappdata(handle,'control',ad.control);
        otherwise
            return;
    end
catch exception
    % If this happens, something probably more serious went wrong...
    throw(exception);
end

end
