function handle = guiLoadPanel(parentHandle,position)
% GUILOADPANEL Add a panel for loading files to a gui
%       Should only be called from within a GUI defining function.
%
%       Arguments: parent Handle and position vector.
%       TODO: Add guidata and appdata to list of arguments
%
%       Returns the handle of the added panel.

% (Leave a blank line following the help.)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

defaultBackground = get(parentHandle,'Color');
handles = guidata(parentHandle);

handle = uipanel('Tag','load_panel',...
    'parent',parentHandle,...
    'Title','Load data',...
    'FontWeight','bold',...
    'BackgroundColor',defaultBackground,...
    'Visible','off',...
    'Units','pixels','Position',position);

% Create the "Load data" panel
panel_size = get(handle,'Position');
uicontrol('Tag','load_panel_description',...
    'Style','text',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'FontAngle','oblique',...
    'Position',[10 panel_size(4)-60 panel_size(3)-20 30],...
    'String',{'Load data from file(s)' 'Import data from diverse sources'}...
    );

handle_p1 = uipanel('Tag','load_panel_files_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 panel_size(4)-140 panel_size(3)-20 70],...
    'Title','Files to load'...
    );
handle_comb_cb = uicontrol('Tag','load_panel_files_combine_checkbox',...
    'Style','checkbox',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 30 panel_size(3)-40 20],...
    'String',' combine multiple files'...
    );
handle_dir_cb = uicontrol('Tag','load_panel_files_directory_checkbox',...
    'Style','checkbox',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 10 panel_size(3)-40 20],...
    'String',' load whole directory'...
    );

handle_p2 = uipanel('Tag','load_panel_preprocessing_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 panel_size(4)-220 panel_size(3)-20 70],...
    'Title','Preprocessing on load'...
    );
handle_poc_cb = uicontrol('Tag','load_panel_preprocessing_offset_checkbox',...
    'Style','checkbox',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 30 panel_size(3)-40 20],...
    'String',' offset compensation'...
    );
handle_bgc_cb = uicontrol('Tag','load_panel_preprocessing_background_checkbox',...
    'Style','checkbox',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 10 panel_size(3)-40 20],...
    'String',' background subtraction'...
    );

handle_p3 = uipanel('Tag','load_panel_axislabels_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 panel_size(4)-280 panel_size(3)-20 50],...
    'Title','Axis labels'...
    );
handle_axislabels_cb = uicontrol('Tag','load_panel_axislabels_checkbox',...
    'Style','checkbox',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 10 panel_size(3)-40 20],...
    'TooltipString','Try to determine axis labels from (last loaded) file',...
    'String',' determine labels from file (if available)'...
    );

handle_p4 = uipanel('Tag','load_panel_filetype_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 panel_size(4)-340 panel_size(3)-20 50],...
    'Title','File type'...
    );
uicontrol('Tag','load_panel_filetype_popupmenu',...
    'Style','popupmenu',...
    'Parent',handle_p4,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 10 panel_size(3)-40 20],...
    'String','automatic'...
    );

uicontrol('Tag','load_panel_load_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 panel_size(4)-390 60 40],...
    'String','Load',...
    'Callback', {@load_pushbutton_Callback}...
    );
uicontrol('Tag','load_panel_load_pushbutton_text',...
    'Style','text',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'FontAngle','oblique',...
    'Position',[80 panel_size(4)-385 panel_size(3)-90 30],...
    'String',{'Pressing the button opens the file selection dialogue'}...
    );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function load_pushbutton_Callback(source,eventdata)
    state = struct();
    FilterSpec = '*.*';
    
    % Get the appdata of the main window
    mainWindow = findobj('Tag','trepr_gui_mainwindow');
    ad = getappdata(mainWindow);
    
    % Set directory where to load files from
    if isfield(ad,'control') && isfield(ad.control,'lastLoadDir')
        startDir = ad.control.lastLoadDir;
    else
        startDir = pwd;
    end
        
    if (get(handle_dir_cb,'Value') == 1)
        state.dir = true;
    else
        state.dir = false;
    end
    if (get(handle_comb_cb,'Value') == 1)
        state.comb = true;
    else
        state.comb = false;
    end
        
    if (state.dir)
        FileName = uigetdir(...
            startDir,...
            'Select directory to load'...
            );
    else
        [FileName,PathName,FilterIndex] = uigetfile(...
            FilterSpec,...
            'Select file(s) to load',...
            'MultiSelect','on',...
            startDir...
            );
    end
    
    % If the user cancels file selection, print status message and return
    if isequal(FileName,0)
        msg = 'Loading dataset(s) cancelled by user.';
        % Update status
%        PWD = pwd;
%        cd(fileparts(mfilename('fullpath')));
        add2status(msg);
%        cd(PWD);
        return;
    end
    
    % In case of files, not a directory, add path to filename
    if exist('PathName')
        % In case of multiple files
        if iscell(FileName)
            for k = 1 : length(FileName)
                FileName{k} = fullfile(PathName,FileName{k});
            end
        else
            FileName = fullfile(PathName,FileName);
        end
    end

    % Set lastLoadDir in appdata
    if exist('PathName')
        ad.control.lastLoadDir = PathName;
    else
        ad.control.lastLoadDir = FileName;
    end
    setappdata(mainWindow,'control',ad.control);
    
    % Adding status line
    msgStr = cell(0);
    msgStr{length(msgStr)+1} = 'Calling trEPRload and trying to load';
    msg = [ msgStr FileName];
    add2status(msg);
    clear msgStr msg;
    
    data = trEPRload(FileName);

    if isequal(data,0)
        msg = 'Data could not be loaded.';
        return;
    end
    
    % Check whether data{n}.data is numeric (very basic test for format)
    fnNoData = cell(0);
    nNoData = [];
    if iscell(data)
        for k=1:length(data)
            if not(isnumeric(data{k}.data))
                fnNoData{k} = data{k}.filename;
                nNoData = [ nNoData k ];
            end
        end
        % Remove datasets from data cell array
        data([nNoData]) = [];
    else
        if not(isnumeric(data.data))
            fnNoData = data.filename;
            data = [];
        end
    end
    
    % Add status line
    if not (isempty(fnNoData))
        msgStr = cell(0);
        msgStr{length(msgStr)+1} = ...
            'The following files contained no numerical data (and were DISCARDED):';
        msg = [msgStr fnNoData];
        add2status(msg);
        clear msgStr msg;
    end
    
    if isempty(data)
        return;
    end
    
    % Get names of successfully loaded files
    % In parallel, add additional fields to each dataset
    % Define default display structure to add to datasets
    display = struct();
    display.position.x = 1;
    display.position.y = 1;
    display.displacement.x = 0;
    display.displacement.y = 0;
    display.displacement.z = 0;
    display.scaling.x = 1;
    display.scaling.y = 1;
    display.scaling.z = 1;
    display.smoothing.x.value = 1;
    display.smoothing.y.value = 1;
    line = struct();
    line.color = 'k';
    line.style = '-';
    line.marker = 'none';
    line.width = 1;
    if iscell(data)
        fileNames = cell(0);
        for k = 1 : length(data)
            [p,fn,ext] = fileparts(data{k}.filename);
            fileNames{k} = fullfile(p,[fn ext]);
            data{k}.label = [fn ext];
            data{k}.display = display;
            data{k}.history = cell(0);
            data{k}.line = line;
            % For compatibility with old versions of trEPRread and for
            % consistency with the naming of all other structures
            if (isfield(data{k},'axes') && isfield(data{k}.axes,'xaxis'))
                data{k}.axes.x = data{k}.axes.xaxis;
                data{k}.axes = rmfield(data{k}.axes,'xaxis');
            end
            if (isfield(data{k},'axes') && isfield(data{k}.axes,'yaxis'))
                data{k}.axes.y = data{k}.axes.yaxis;
                data{k}.axes = rmfield(data{k}.axes,'yaxis');
            end            
        end
    else
        fileNames = data.filename;
        [~,fn,ext] = fileparts(data.filename);
        data.label = [fn ext];
        data.display = display;
        data.history = cell(0);
        data.line = line;
        % For compatibility with old versions of trEPRread and for
        % consistency with the naming of all other structures
        if (isfield(data,'axes') && isfield(data.axes,'xaxis'))
            data.axes.x = data.axes.xaxis;
            data.axes = rmfield(data.axes,'xaxis');
        end
        if (isfield(data,'axes') && isfield(data.axes,'yaxis'))
            data.axes.y = data.axes.yaxis;
            data.axes = rmfield(data.axes,'yaxis');
        end            
    end
    
    % Get indices of new datasets
    % Necessary in case of further corrections applied to datasets after
    % loading
    newDataIdx = [ ...
        length(ad.data)+1 : 1 : length(ad.data)+length(data) ];

    % Add data to main GUI (appdata)
    ad.data = [ ad.data data ];
    ad.origdata = [ ad.origdata data ];
    
    setappdata(mainWindow,'data',ad.data);
    setappdata(mainWindow,'origdata',ad.origdata);

    % Adding status line
    msgStr = cell(0);
    msgStr{length(msgStr)+1} = ...
        sprintf('%i data set(s) successfully loaded:',length(data));
    msg = [msgStr fileNames];
    status = add2status(msg);
    clear msgStr msg;
    
    % Get appdata again after making changes to it before
    ad = getappdata(mainWindow);
    
    % Add new loaded spectra to "invisible"
    ad.control.spectra.invisible = [...
        ad.control.spectra.invisible ...
        [length(ad.data)-length(data)+1:1:length(ad.data)]...
        ];
    setappdata(mainWindow,'control',ad.control);
    
    update_invisibleSpectra;
    
    % Handle dataset corrections when checked
    % pretrigger offset compensation
    if (get(handle_poc_cb,'Value') == 1)
        for k=1:length(newDataIdx)
            guiProcessingPOC(newDataIdx(k));
        end
    end
    
    % background subtraction
    if (get(handle_bgc_cb,'Value') == 1)
        for k=1:length(newDataIdx)
            guiProcessingBGC(newDataIdx(k));
        end
    end
    
    % Try to load axis labels from file
    if (get(handle_axislabels_cb,'Value') == 1)
        if (isfield(ad.data{newDataIdx(end)},'axes'))
            if (isfield(ad.data{newDataIdx(end)}.axes,'x') && ...
                    isfield(ad.data{newDataIdx(end)}.axes.x,'measure'))
                ad.control.axis.labels.x.measure = ...
                    ad.data{newDataIdx(end)}.axes.x.measure;
            end
            if (isfield(ad.data{newDataIdx(end)}.axes,'x') && ...
                    isfield(ad.data{newDataIdx(end)}.axes.x,'unit'))
                ad.control.axis.labels.x.unit = ...
                    ad.data{newDataIdx(end)}.axes.x.unit;
            end
            if (isfield(ad.data{newDataIdx(end)}.axes,'y') && ...
                    isfield(ad.data{newDataIdx(end)}.axes.y,'measure'))
                ad.control.axis.labels.y.measure = ...
                    ad.data{newDataIdx(end)}.axes.y.measure;
            end
            if (isfield(ad.data{newDataIdx(end)}.axes,'y') && ...
                    isfield(ad.data{newDataIdx(end)}.axes.y,'unit'))
                ad.control.axis.labels.y.unit = ...
                    ad.data{newDataIdx(end)}.axes.y.unit;
            end
            if (isfield(ad.data{newDataIdx(end)}.axes,'z') && ...
                    isfield(ad.data{newDataIdx(end)}.axes.z,'measure'))
                ad.control.axis.labels.z.measure = ...
                    ad.data{newDataIdx(end)}.axes.z.measure;
            end
            if (isfield(ad.data{newDataIdx(end)}.axes,'z') && ...
                    isfield(ad.data{newDataIdx(end)}.axes.z,'unit'))
                ad.control.axis.labels.z.unit = ...
                    ad.data{newDataIdx(end)}.axes.z.unit;
            end
        end
        setappdata(mainWindow,'control',ad.control);
    end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Utility functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end