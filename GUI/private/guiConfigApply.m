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
% 2014-07-29

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
            if isfield(ad.configuration.load,'combine')
                set(gh.load_panel_files_combine_checkbox,...
                    'Value',ad.configuration.load.combine);
            end
            if isfield(ad.configuration.load,'loaddir')
                set(gh.load_panel_files_directory_checkbox,...
                    'Value',ad.configuration.load.loaddir);
            end
            if isfield(ad.configuration.load,'infofile')
                set(gh.load_panel_infofile_checkbox,...
                    'Value',ad.configuration.load.infofile);
            end
            if isfield(ad.configuration.load,'unitconversion')
                set(gh.load_panel_unitconversion_checkbox,...
                    'Value',ad.configuration.load.unitconversion);
            end
            if isfield(ad.configuration.load,'POC')
                set(gh.load_panel_preprocessing_offset_checkbox,...
                    'Value',ad.configuration.load.POC);
            end
            if isfield(ad.configuration.load,'BGC')
                set(gh.load_panel_preprocessing_background_checkbox,...
                    'Value',ad.configuration.load.BGC);
            end
            if isfield(ad.configuration.load,'labels')
                set(gh.load_panel_axislabels_checkbox,...
                    'Value',ad.configuration.load.labels);
            end
            if isfield(ad.configuration.load,'visible')
                set(gh.load_panel_visible_checkbox,...
                    'Value',ad.configuration.load.visible);
            end
            if isfield(ad.configuration.load,'unitconversion')
                set(gh.load_panel_unitconversion_checkbox,...
                    'Value',ad.configuration.load.unitconversion);
            end
            if isfield(ad.configuration.load,'format')
                % Get value from load_panel_filetype_popupmenu
                fileTypes = ...
                    cellstr(get(gh.load_panel_filetype_popupmenu,'String'));
                for k=1:length(fileTypes)
                    if strcmpi(fileTypes{k},ad.configuration.load.format)
                        set(gh.load_panel_filetype_popupmenu,'Value',k);
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
