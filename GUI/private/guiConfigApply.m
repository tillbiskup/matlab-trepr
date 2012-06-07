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

% (c) 2011-12, Till Biskup
% 2012-05-31

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
    if isempty(handle) or ~ishandle(handle)
        status = -2;
        return;
    end
    
    % Define config file
    confFile = fullfile(...
        trEPRinfo('dir'),'GUI','private','conf',[guiname '.ini']);
    % If that file does not exist, try to create it from the
    % distributed config file sample
    if ~exist(confFile,'file')
        fprintf('Config file\n  %s\nseems not to exist. %s\n',...
            confFile,'Trying to create it from distributed file.');
        trEPRconf('create','overwrite',true,'file',confFile);
    end
    ad = getappdata(handle);
    gh = guihandles(handle);
    
    % Try to load and append configuration
    conf = trEPRiniFileRead(confFile,'typeConversion',true);
    if isempty(conf)
        status = -1;
        return;
    end
    
    ad.configuration = conf;
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
        otherwise
            return;
    end
catch exception
    % If this happens, something probably more serious went wrong...
    throw(exception);
end

end
