function handle = guiLoadPanel(parentHandle,position)
% GUILOADPANEL Add a panel for loading files to a gui
%       Should only be called from within a GUI defining function.
%
%       Arguments: parent Handle and position vector.
%
%       Returns the handle of the added panel.

% (c) 2011-13, Till Biskup
% 2013-02-18

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

defaultBackground = get(parentHandle,'Color');

handle = uipanel('Tag','load_panel',...
    'parent',parentHandle,...
    'Title','Load data',...
    'FontWeight','bold',...
    'BackgroundColor',defaultBackground,...
    'Visible','off',...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','pixels','Position',position);

% Create the "Load data" panel
handle_size = get(handle,'Position');
uicontrol('Tag','load_panel_description',...
    'Style','text',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'FontUnit','Pixel','Fontsize',12,...
    'FontAngle','oblique',...
    'Position',[10 handle_size(4)-60 handle_size(3)-20 30],...
    'String',{'Load data from file(s)' 'Import data from diverse sources'}...
    );

p1 = uipanel('Tag','load_panel_files_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-140 handle_size(3)-20 70],...
    'FontUnit','Pixel','Fontsize',12,...
    'Title','Files to load'...
    );
uicontrol('Tag','load_panel_files_combine_checkbox',...
    'Style','checkbox',...
    'Parent',p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 30 handle_size(3)-40 20],...
    'String',' Combine multiple files',...
    'TooltipString',sprintf('%s\n%s\n%s',...
    'If a dataset consists of several files',...
    '(e.g., time traces), combine them.','Use carefully.')...
    );
uicontrol('Tag','load_panel_files_directory_checkbox',...
    'Style','checkbox',...
    'Parent',p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 handle_size(3)-40 20],...
    'String',' Load whole directory',...
    'TooltipString',sprintf('%s\n%s','Load all readable files of a directory.',...
    'Use carefully.')...
    );

p2 = uipanel('Tag','load_panel_infofile_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-200 handle_size(3)-20 50],...
    'Title','Info file'...
    );
uicontrol('Tag','load_panel_infofile_checkbox',...
    'Style','checkbox',...
    'Parent',p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 handle_size(3)-40 20],...
    'TooltipString','Try to find, load and apply info file',...
    'String',' Load info file'...
    );

p3 = uipanel('Tag','load_panel_preprocessing_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-280 handle_size(3)-20 70],...
    'Title','Preprocessing on load'...
    );
uicontrol('Tag','load_panel_preprocessing_offset_checkbox',...
    'Style','checkbox',...
    'Parent',p3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 30 handle_size(3)-40 20],...
    'String',' Offset compensation',...
    'TooltipString',sprintf('%s\n%s','Perform offset compensation',...
    '(average of pretrigger offset for each time trace set to zero)')...
    );
uicontrol('Tag','load_panel_preprocessing_background_checkbox',...
    'Style','checkbox',...
    'Parent',p3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 handle_size(3)-40 20],...
    'String',' Background subtraction',...
    'TooltipString',sprintf('%s\n%s','Perform background subtraction',...
    '(subtract average of the first n time traces from each time trace)')...
    );

p4 = uipanel('Tag','load_panel_axislabels_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-340 handle_size(3)-20 50],...
    'Title','Axis labels'...
    );
uicontrol('Tag','load_panel_axislabels_checkbox',...
    'Style','checkbox',...
    'Parent',p4,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 handle_size(3)-40 20],...
    'TooltipString','Try to determine axis labels from (last loaded) file',...
    'String',' Determine labels from file'...
    );

p5 = uipanel('Tag','load_panel_filetype_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-400 handle_size(3)-20 50],...
    'Title','File type'...
    );
uicontrol('Tag','load_panel_filetype_popupmenu',...
    'Style','popupmenu',...
    'Parent',p5,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 handle_size(3)-40 20],...
    'String','Automatic'...
    );

uicontrol('Tag','load_panel_load_pushbutton_text',...
    'Style','text',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Right',...
    'FontAngle','oblique',...
    'Position',[10 handle_size(4)-445 handle_size(3)-90 30],...
    'String',{'Pressing the button opens the file selection dialogue '}...
    );
uicontrol('Tag','load_panel_load_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[handle_size(3)-70 handle_size(4)-450 60 40],...
    'String','Load',...
    'Callback', {@load_pushbutton_Callback}...
    );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function load_pushbutton_Callback(~,~)
    try
        state = struct();
        FilterSpec = '*.*';
        
        % Get the appdata of the main window
        mainWindow = trEPRguiGetWindowHandle;
        ad = getappdata(mainWindow);
        gh = guihandles(mainWindow);
        
        % Set directory where to load files from
        if isfield(ad,'control') && isfield(ad.control,'dirs') && ...
                isfield(ad.control.dirs,'lastLoad')  && ...
                ~isempty(ad.control.dirs.lastLoad)
            startDir = ad.control.dirs.lastLoad;
        else
            startDir = pwd;
        end
        
        if get(gh.load_panel_files_directory_checkbox,'Value')
            state.dir = true;
        else
            state.dir = false;
        end
        if get(gh.load_panel_files_combine_checkbox,'Value')
            state.comb = true;
        else
            state.comb = false;
        end
        
        if get(gh.load_panel_infofile_checkbox,'Value')
            loadInfoFile = true;
        else
            loadInfoFile = false;
        end
        
        if (state.dir)
            FileName = uigetdir(...
                startDir,...
                'Select directory to load'...
                );
            PathName = '';
        else
            [FileName,PathName,~] = uigetfile(...
                FilterSpec,...
                'Select file(s) to load',...
                'MultiSelect','on',...
                startDir...
                );
        end
        
        % If the user cancels file selection, print status message and return
        if isequal(FileName,0)
            trEPRmsg('Loading dataset(s) cancelled by user.','info');
            return;
        end
        
        % In case of files, not a directory, add path to filename
        if exist('PathName','var') && exist(PathName,'file')
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
        if exist(PathName,'dir')
            ad.control.dirs.lastLoad = PathName;
        else
            if iscell(FileName)
                ad.control.dirs.lastLoad = FileName{1};
            else
                ad.control.dirs.lastLoad = FileName;
            end
        end
        setappdata(mainWindow,'control',ad.control);
        
        % Adding status line
        trEPRmsg([{'Calling trEPRload and trying to load:'} FileName],'info');
        
        trEPRbusyWindow('start','Trying to load spectra...<br />please wait.');
       
        [data,warnings] = trEPRload(FileName,'combine',state.comb,...
            'loadInfoFile',loadInfoFile);

        % Get appdata, to make sure not to skip any messages that might be
        % written by trEPRload
        ad = getappdata(mainWindow);
        
        if isequal(data,0) || isempty(data)
            trEPRmsg('Data could not be loaded.','error');
            trEPRbusyWindow('stop','Trying to load spectra...<br /><b>failed</b>.');
            return;
        end
        
        if ~isempty(warnings)
            % Add warnings to status messages
            msgStr = cell(0);
            msgStr{end+1} = 'Some warnings occurred when trying to load ';
            msgStr{end+1} = FileName;
            for k=1:length(warnings)
                if length(warnings{k})>1
                    for m=1:length(warnings{k})
                        msgStr{end+1} = warnings{k}{m}.identifier; %#ok<AGROW>
                        msgStr{end+1} = warnings{k}{m}.message; %#ok<AGROW>
                    end
                else
                    msgStr{end+1} = warnings{k}.identifier; %#ok<AGROW>
                    msgStr{end+1} = warnings{k}.message; %#ok<AGROW>
                end
            end
            trEPRmsg(msgStr,'warning');
            clear msgStr;
        end

        % Check whether data{n}.data is numeric (very basic test for format)
        fnNoData = cell(0);
        nNoData = [];
        if iscell(data)
            for k=1:length(data)
                if (isfield(data{k},'data') && ~isnumeric(data{k}.data))
                    fnNoData{k} = data{k}.file.name;
                    nNoData = [ nNoData k ]; %#ok<AGROW>
                elseif ~isfield(data{k},'data')
                    nNoData = [ nNoData k ]; %#ok<AGROW>
                end
            end
            % Remove datasets from data cell array
            data(nNoData) = [];
        else
            if not(isnumeric(data.data))
                fnNoData = data.file.name;
                data = [];
            end
        end
        
        % Add status line
        if not (isempty(fnNoData))
            msgStr = cell(0);
            msgStr{length(msgStr)+1} = ...
                'The following files contained no numerical data (and were DISCARDED):';
            msg = [msgStr fnNoData];
            trEPRmsg(msg,'warning');
            clear msgStr msg;
        end
        
        if isempty(data)
            trEPRbusyWindow('stop','Trying to load spectra...<br /><b>failed</b>.');
            return;
        end
        
        % Get names of successfully loaded files
        % In parallel, add additional fields to each dataset
        % Define default display structure to add to datasets
        guiDataStruct = trEPRguiDataStructure('datastructure');
        % Important: Delete "history" field not to overwrite history
        guiDataStruct = rmfield(guiDataStruct,'history');
        guiDataStructFields = fieldnames(guiDataStruct);
        if iscell(data)
            fileNames = cell(0);
            for k = 1 : length(data)
                [p,fn,ext] = fileparts(data{k}.file.name);
                fileNames{k} = fullfile(p,[fn ext]);
                if ~isfield(data{k},'label') || isempty(data{k}.label)
                    data{k}.label = [fn ext];
                end
                for l=1:length(guiDataStructFields)
                    data{k}.(guiDataStructFields{l}) = ...
                        guiDataStruct.(guiDataStructFields{l});
                end
                if ~isfield(data{k},'history')
                    data{k}.history = cell(0);
                end
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
            fileNames = data.file.name;
            [~,fn,ext] = fileparts(data.file.name);
            if ~isfield(data,'label') || isempty(data.label)
                data.label = [fn ext];
            end
            for l=1:length(guiDataStructFields)
                data.(guiDataStructFields{l}) = ...
                    guiDataStruct.(guiDataStructFields{l});
            end
            if ~isfield(data,'history')
                data.history = cell(0);
            end
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
        % Necessary in case of further corrections applied to datasets
        % after loading
        newDataIdx = length(ad.data)+1 : 1 : length(ad.data)+length(data);
        
        % Add data to main GUI (appdata)
        [rows,cols] = size(data);
        if rows == 1
            ad.data = [ ad.data data ];
            ad.origdata = [ ad.origdata data ];
        elseif cols == 1
            ad.data = [ ad.data data' ];
            ad.origdata = [ ad.origdata data' ];
        end
        
        setappdata(mainWindow,'data',ad.data);
        setappdata(mainWindow,'origdata',ad.origdata);
        
        % Adding status line
        msgStr = sprintf('%i data set(s) successfully loaded:',length(data));
        trEPRmsg([msgStr fileNames],'info');
        clear msgStr;

        trEPRbusyWindow('stop','Trying to load spectra...<br /><b>done</b>.');
        
        % Get appdata again after making changes to it before
        ad = getappdata(mainWindow);
        
        % Add new loaded spectra to "invisible"
        ad.control.spectra.invisible = [...
            ad.control.spectra.invisible ...
            newDataIdx...
            ];
        setappdata(mainWindow,'control',ad.control);
        
        update_invisibleSpectra;
        
        % Handle dataset corrections when checked
        % pretrigger offset compensation
        if get(gh.load_panel_preprocessing_offset_checkbox,'Value')
            for k=1:length(newDataIdx)
                guiProcessingPOC(newDataIdx(k));
            end
        end
        
        % background subtraction
        if get(gh.load_panel_preprocessing_background_checkbox,'Value')
            for k=1:length(newDataIdx)
                guiProcessingBGC(newDataIdx(k));
            end
        end
        
        % Try to load axis labels from file
        if get(gh.load_panel_axislabels_checkbox,'Value')
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
    catch exception
        try
            msgStr = ['An exception occurred in ' ...
                exception.stack(1).name  '.'];
            trEPRmsg(msgStr,'error');
        catch exception2
            exception = addCause(exception2, exception);
            disp(msgStr);
        end
        try
            trEPRgui_bugreportwindow(exception);
        catch exception3
            % If even displaying the bug report window fails...
            exception = addCause(exception3, exception);
            throw(exception);
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Utility functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end