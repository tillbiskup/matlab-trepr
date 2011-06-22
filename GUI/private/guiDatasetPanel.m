function handle = guiDatasetPanel(parentHandle,position)
% GUIDATASETPANEL Add a panel for dataset control to a gui
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

handle = uipanel('Tag','data_panel',...
    'parent',parentHandle,...
    'Title','Dataset display',...
    'FontWeight','bold',...
    'BackgroundColor',defaultBackground,...
    'Visible','off',...
    'Units','pixels','Position',position);

% Create the "Dataset display" panel
panel_size = get(handle,'Position');
uicontrol('Tag','data_panel_description',...
    'Style','text',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'FontAngle','oblique',...
    'Position',[10 panel_size(4)-60 panel_size(3)-20 30],...
    'String',{'Choose the datasets to be displayed in the main axes (on the left)'}...
    );

handle_p1 = uipanel('Tag','data_panel_invisible_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 panel_size(4)-170 panel_size(3)-20 100],...
    'Title','Invisible datasets'...
    );
uicontrol('Tag','data_panel_invisible_listbox',...
    'Style','listbox',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 10 panel_size(3)-40 70],...
    'String','',...
    'Callback',{@invisible_listbox_Callback}...
    );

handle_p2 = uipanel('Tag','data_panel_visible_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 panel_size(4)-360 panel_size(3)-20 140],...
    'Title','Visible datasets'...
    );
uicontrol('Tag','data_panel_visible_listbox',...
    'Style','listbox',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 50 panel_size(3)-40 70],...
    'String','',...
    'Callback',{@visible_listbox_Callback}...
    );
uicontrol('Tag','data_panel_accumulate_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 10 100 30],...
    'String','Accumulate...'...
    );
uicontrol('Tag','data_panel_previous_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[panel_size(3)-110 10 40 30],...
    'FontWeight','bold',...
    'String','<<',...
    'TooltipString','Show previous spectrum',...
    'Callback',{@previous_pushbutton_Callback}...
    );
uicontrol('Tag','data_panel_next_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[panel_size(3)-70 10 40 30],...
    'FontWeight','bold',...
    'String','>>',...
    'TooltipString','Show next spectrum',...
    'Callback',{@next_pushbutton_Callback}...
    );

uicontrol('Tag','data_panel_show_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 panel_size(4)-210 60 30],...
    'String','Show',...
    'TooltipString','Show currently highlighted spectrum',...
    'Enable','off',...
    'Callback', {@show_pushbutton_Callback}...
    );
uicontrol('Tag','data_panel_hide_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[panel_size(3)-70 panel_size(4)-210 60 30],...
    'String','Hide',...
    'TooltipString','Hide currently highlighted spectrum',...
    'Enable','off',...
    'Callback', {@hide_pushbutton_Callback}...
    );
uicontrol('Tag','show_hide_button_explanation',...
    'Style','text',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'HorizontalAlignment','Center',...
    'FontAngle','oblique',...
    'Position',[75 panel_size(4)-220 panel_size(3)-150 30],...
    'String',{'selected dataset'}...
    );

handle_p3 = uipanel('Tag','data_panel_currentlyactive_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 panel_size(4)-460 panel_size(3)-20 90],...
    'Title','Currently active dataset'...
    );
uicontrol('Tag','data_panel_save_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 40 floor((panel_size(3)-40)/3) 30],...
    'String','Save',...
    'TooltipString','Save currently active spectrum',...
    'Callback', {@save_pushbutton_Callback}...
    );
uicontrol('Tag','data_panel_saveas_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[floor((panel_size(3)-40)/3)+10 40 floor((panel_size(3)-40)/3) 30],...
    'String','Save as',...
    'TooltipString','Save currently active spectrum under different filename',...
    'Callback', {@saveas_pushbutton_Callback}...
    );
uicontrol('Tag','data_panel_remove_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[(floor((panel_size(3)-40)/3)*2)+10 40 floor((panel_size(3)-40)/3) 30],...
    'String','Remove',...
    'TooltipString','Remove currently active spectrum from GUI (does not delete the file)',...
    'Callback', {@remove_pushbutton_Callback}...
    );
uicontrol('Tag','data_panel_linestyle_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 10 floor((panel_size(3)-40)/3) 30],...
    'String','Line style'...
    );
uicontrol('Tag','data_panel_getinfo_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[floor((panel_size(3)-40)/3)+10 10 floor((panel_size(3)-40)/3) 30],...
    'String','Get info'...
    );
uicontrol('Tag','data_panel_duplicate_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[(floor((panel_size(3)-40)/3)*2)+10 10 floor((panel_size(3)-40)/3) 30],...
    'TooltipString','Duplicate currently active dataset',...
    'String','Duplicate',...
    'Callback', {@duplicate_pushbutton_Callback}...
    );

handle_p4 = uipanel('Tag','data_panel_displaytype_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 panel_size(4)-520 panel_size(3)-20 50],...
    'Title','Display type'...
    );
uicontrol('Tag','data_panel_displaytype_popupmenu',...
    'Style','popupmenu',...
    'Parent',handle_p4,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 10 panel_size(3)-40 20],...
    'String','2D plot|1D along x|1D along y',...
    'Callback', {@displaytype_popupmenu_Callback}...
    );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function show_pushbutton_Callback(~,~)
    % Get appdata of main window
    mainWindow = findobj('Tag','trepr_gui_mainwindow');
    ad = getappdata(mainWindow);

    % Get handles of main window
    gh = guihandles(mainWindow);
    
    % Get selected item of listbox
    selected = get(gh.data_panel_invisible_listbox,'Value');

    % Be on the save side if user is faster than Matlab
    if selected == 0
        return;
    end
    
    % Move to visible
    ad.control.spectra.visible = [...
        ad.control.spectra.visible ...
        ad.control.spectra.invisible(selected) ...
        ];
    
    % Make moved entry active one
    ad.control.spectra.active = ad.control.spectra.invisible(selected);
    
    % Delete in invisible
    ad.control.spectra.invisible(selected) = [];
    
    % Update appdata of main window
    setappdata(mainWindow,'control',ad.control);
    
    % Update both list boxes
    update_invisibleSpectra();
    update_visibleSpectra();    
    
    %Update main axis
    update_mainAxis();
end


function hide_pushbutton_Callback(~,~)
    % Get appdata of main window
    mainWindow = findobj('Tag','trepr_gui_mainwindow');
    ad = getappdata(mainWindow);

    % Get handles of main window
    gh = guihandles(mainWindow);
    
    % Get selected item of listbox
    selected = get(gh.data_panel_visible_listbox,'Value');

    % Be on the save side if user is faster than Matlab
    if selected == 0
        return;
    end

    % Move to invisible
    ad.control.spectra.invisible = [...
        ad.control.spectra.invisible ...
        ad.control.spectra.visible(selected) ...
        ];
    
    % Delete in visible
    ad.control.spectra.visible(selected) = [];
    
    % Toggle active entry
    if (selected > length(ad.control.spectra.visible))
        if (selected == 1)
            ad.control.spectra.active = 0;
        else
            ad.control.spectra.active = ad.control.spectra.visible(end);
        end
    else
        ad.control.spectra.active = ad.control.spectra.visible(selected);
    end
    
    % Update appdata of main window
    setappdata(mainWindow,'control',ad.control);
    
    % Update both list boxes
    update_invisibleSpectra();
    update_visibleSpectra();
    
    %Update main axis
    update_mainAxis();
end

function save_pushbutton_Callback(~,~)
    % Get appdata of main window
    mainWindow = findobj('Tag','trepr_gui_mainwindow');
    ad = getappdata(mainWindow);

    % Get handles of main window
    gh = guihandles(mainWindow);
    
    % Get selected item of listbox
    selected = get(gh.data_panel_visible_listbox,'Value');

    % Get id of selected spectrum
    selectedId = ad.control.spectra.visible(selected);

    datasetSave(selectedId);
    
    % Update both list boxes
    update_invisibleSpectra();
    update_visibleSpectra();
    
    %Update main axis
    update_mainAxis();
end

function saveas_pushbutton_Callback(~,~)
    % Get appdata of main window
    mainWindow = findobj('Tag','trepr_gui_mainwindow');
    ad = getappdata(mainWindow);

    % Get handles of main window
    gh = guihandles(mainWindow);
    
    % Get selected item of listbox
    selected = get(gh.data_panel_visible_listbox,'Value');

    % Get id of selected spectrum
    selectedId = ad.control.spectra.visible(selected);

    datasetSaveAs(selectedId);
    
    % Update both list boxes
    update_invisibleSpectra();
    update_visibleSpectra();
    
    %Update main axis
    update_mainAxis();
end

function remove_pushbutton_Callback(~,~)
    % Get appdata of main window
    mainWindow = findobj('Tag','trepr_gui_mainwindow');
    ad = getappdata(mainWindow);

    % Get handles of main window
    gh = guihandles(mainWindow);
    
    % Get selected item of listbox
    selected = get(gh.data_panel_visible_listbox,'Value');
    
    % Get id of selected spectrum
    selectedId = ad.control.spectra.visible(selected);
    
    % Check whether currently selected spectrum is modified, and if so, ask
    % the user whether to remove it anyway
    if find(ad.control.spectra.modified==selectedId)
        answer = questdlg(...
            {'Dataset was modified. Remove anyway?'...
            ' '...
            'Note that "Remove" means that you loose the changes you made,'...
            'but the (original) file will not be deleted from the file system.'...
            ' '...
            'Other options include "Save & Remove" or "Cancel".'},...
            'Warning: Dataset Modified...',...
            'Save & Remove','Remove','Cancel',...
            'Save & Remove');
        switch answer
            case 'Save & Remove'
                datasetSave(selectedId);
            case 'Remove'
            case 'Cancel'
                return;
            otherwise
                return;
        end
    end
    
    removedDatasetLabel = ...
        ad.data{selectedId}.label;

    % Remove from data and origdata
    ad.data(selectedId) = [];
    ad.origdata(selectedId) = [];
    
    % Remove from modified if it's there
    ad.control.spectra.modified(...
        find(ad.control.spectra.modified == selectedId)) = [];
    % Remove from missing if it's there
    ad.control.spectra.missing(...
        find(ad.control.spectra.missing == selectedId)) = [];
        
    
    % Delete in visible
    ad.control.spectra.visible(selected) = [];
    
    % Shift numbering in spectra.visible and spectra.invisible
    if (~isempty(ad.control.spectra.visible))
        indices = find(ad.control.spectra.visible>selected);
        ad.control.spectra.visible(indices) = ...
            ad.control.spectra.visible(indices)-1;
    end
    if (~isempty(ad.control.spectra.invisible))
        indices = find(ad.control.spectra.invisible>selected);
        ad.control.spectra.invisible(indices) = ...
            ad.control.spectra.invisible(indices)-1;
    end
    
    % Shift numbering in spectra.modified
    if (~isempty(ad.control.spectra.modified))
        indices = find(ad.control.spectra.modified>selected);
        ad.control.spectra.modified(indices) = ...
            ad.control.spectra.modified(indices)-1;
    end
    
    % Toggle active entry
    if (selected > length(ad.control.spectra.visible))
        if (selected == 1)
            ad.control.spectra.active = [];
        else
            ad.control.spectra.active = ad.control.spectra.visible(end);
        end
    else
        ad.control.spectra.active = ad.control.spectra.visible(selected);
    end
    
    % Update appdata of main window
    setappdata(mainWindow,'control',ad.control);
    setappdata(mainWindow,'data',ad.data);
    setappdata(mainWindow,'origdata',ad.origdata);

    % Adding status line
    msgStr = cell(0);
    msgStr{length(msgStr)+1} = ...
        sprintf('Data set "%s" removed from GUI',removedDatasetLabel);
    status = add2status(msgStr);
    clear msgStr;    
    
    % Update both list boxes
    update_invisibleSpectra();
    update_visibleSpectra();
    
    %Update main axis
    update_mainAxis();
end

function duplicate_pushbutton_Callback(~,~)
    % Get appdata of main window
    mainWindow = findobj('Tag','trepr_gui_mainwindow');
    ad = getappdata(mainWindow);
    
    % Get handles of main window
    gh = guihandles(mainWindow);
    
    % Get selected item of listbox
    selected = get(gh.data_panel_visible_listbox,'Value');
    
    % Create label for duplicate
    % That is, add number in brackets at the end: (n)
    % But check whether there is already such a number in brackets in any
    % of the visible spectra with the same label.
    expression = sprintf('\\((\\d+)\\)$',ad.data{selected}.label);
    l = 0;
    token = [];
    for k=1:length(ad.control.spectra.visible)
        tokens = regexp(ad.data{ad.control.spectra.visible(k)}.label,expression,'tokens');
        if ~isempty(tokens)
            l=l+1;
            token(l) = str2double(char(tokens{1}));
        end
    end
    if ~isempty(token)
        ad.data{selected}.label
        if (regexp(ad.data{selected}.label,' \((\d+)\)$'))
            duplicateLabel = regexprep(...
                ad.data{selected}.label,...
                ' \((\d+)\)$',sprintf(' (%i)',max(token)+1));
        else
            duplicateLabel = sprintf('%s (%i)',ad.data{selected}.label,max(token)+1);
        end
    else
        duplicateLabel = sprintf('%s (1)',ad.data{selected}.label);
    end
    
    % Actually duplicate the dataset
    duplicate = ad.data{selected};
    % Set label of duplicate
    duplicate.label = duplicateLabel;
    % IMPORTANT: Set the filename of the duplicate to empty string
    duplicate.filename = '';
    
    nSpectra = length(ad.data);
    
    ad.data{end+1} = duplicate;
    ad.origdata{end+1} = duplicate;
    
    ad.control.spectra.visible(end+1) = nSpectra+1;
    ad.control.spectra.modified(end+1) = nSpectra+1;
    
    % Update appdata of main window
    setappdata(mainWindow,'control',ad.control);
    setappdata(mainWindow,'data',ad.data);
    setappdata(mainWindow,'origdata',ad.origdata);

    % Adding status line
    msgstr = cell(0);
    msgstr{length(msgstr)+1} = ...
        sprintf(...
        'Data set "%s" duplicated as %s',...
        ad.data{selected}.label,...
        duplicateLabel);
    status = add2status(msgstr);
    clear msgstr;
    
    % Update both list boxes
    update_invisibleSpectra();
    update_visibleSpectra();
    
    %Update main axis
    update_mainAxis();
end


function displaytype_popupmenu_Callback(source,~)
    % Get appdata of main window
    mainWindow = findobj('Tag','trepr_gui_mainwindow');
    ad = getappdata(mainWindow);

    displayTypes = cellstr(get(source,'String'));
    displayType = displayTypes{get(source,'Value')};
    ad.control.axis.displayType = displayType;
    
    % Update appdata of main window
    setappdata(mainWindow,'control',ad.control);
    
    update_mainAxis();
end

function visible_listbox_Callback(~,~)
    % Get appdata of main window
    mainWindow = findobj('Tag','trepr_gui_mainwindow');
    ad = getappdata(mainWindow);

    % Get handles of main window
    gh = guihandles(mainWindow);

    ad.control.spectra.active = ad.control.spectra.visible(...
        get(gh.data_panel_visible_listbox,'Value')...
        );
    
    % Update appdata of main window
    setappdata(mainWindow,'control',ad.control);
    
    % If user double clicked on list entry
    if strcmp(get(gcf,'SelectionType'),'open')
        datasetChangeLabel(ad.control.spectra.active);
    end
    
    % Update processing panel
    update_processingPanel();
    
    % Update slider panel
    update_sliderPanel();
    
    % Update visible spectra listboxes (in diverse panels!)
    update_visibleSpectra();

    %Update main axis
    update_mainAxis();
end

function invisible_listbox_Callback(source,~);
    % Get appdata of main window
    mainWindow = findobj('Tag','trepr_gui_mainwindow');
    ad = getappdata(mainWindow);
    
    % If user double clicked on list entry
    if strcmp(get(gcf,'SelectionType'),'open')
        datasetChangeLabel(...
            ad.control.spectra.invisible(...
            get(source,'Value')...
            ));
    end
    update_invisibleSpectra();
end

function previous_pushbutton_Callback(~,~)
    % Get appdata of main window
    mainWindow = findobj('Tag','trepr_gui_mainwindow');
    ad = getappdata(mainWindow);

    % This shall never happen, as the element should not be active in this
    % case
    if (length(ad.control.spectra.visible) < 2)
        return;
    end
    
    if (ad.control.spectra.active == ad.control.spectra.visible(1))
        ad.control.spectra.active = ad.control.spectra.visible(end);
    else
        ad.control.spectra.active = ad.control.spectra.visible(...
            find(ad.control.spectra.visible==ad.control.spectra.active)-1);
    end
    
    % Update appdata of main window
    setappdata(mainWindow,'control',ad.control);
    
    % Update processing panel
    update_processingPanel();
    
    % Update slider panel
    update_sliderPanel();
    
    % Update visible spectra listboxes (in diverse panels!)
    update_visibleSpectra();

    %Update main axis
    update_mainAxis();
end

function next_pushbutton_Callback(~,~)
    % Get appdata of main window
    mainWindow = findobj('Tag','trepr_gui_mainwindow');
    ad = getappdata(mainWindow);
    
    % This shall never happen, as the element should not be active in this
    % case
    if (length(ad.control.spectra.visible) < 2)
        return;
    end
    
	if(ad.control.spectra.active == ad.control.spectra.visible(end))
        ad.control.spectra.active = ad.control.spectra.visible(1);
    else
        ad.control.spectra.active = ad.control.spectra.visible(...
            find(ad.control.spectra.visible==ad.control.spectra.active)+1);
    end
    
    % Update appdata of main window
    setappdata(mainWindow,'control',ad.control);
    
    % Update processing panel
    update_processingPanel();
    
    % Update slider panel
    update_sliderPanel();
    
    % Update visible spectra listboxes (in diverse panels!)
    update_visibleSpectra();

    %Update main axis
    update_mainAxis();
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Utility functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function datasetChangeLabel(index)
    % Get appdata of main window
    mainWindow = findobj('Tag','trepr_gui_mainwindow');
    ad = getappdata(mainWindow);

    ad.data{index}.label = trEPRgui_setLabelWindow(ad.data{index}.label);
    % Update appdata of main window
    setappdata(mainWindow,'data',ad.data);

end

function datasetSave(id)
    % Get appdata of main window
    mainWindow = findobj('Tag','trepr_gui_mainwindow');
    ad = getappdata(mainWindow);
    
    % Check whether selected dataset has a (valid) filename
    if ~isfield(ad.data{id},'filename') || ...
            (strcmp(ad.data{id}.filename,''))
        datasetSaveAs(id);
    else
        [fpath,fname,fext] = fileparts(ad.data{id}.filename);
        if ~strcmp(fext,'.zip')
            ad.data{id}.filename = fullfile(fpath,[fname '.zip']);
            % Need to test for existing file and in case, ask user...
            if (exist(ad.data{id}.filename,'file'))
                answer = questdlg(...
                    {'WARNING: You''re about to save the current dataset to the file'...
                    ad.data{id}.filename ...
                    ' '...
                    'This file exists already! Are you sure you want to overwrite it?'...
                    ' '...
                    'Please hold on and think twice before you hit "Overwrite".'...
                    'Alternatively you can press "Save as" and choose a different name.'},...
                    'Warning: File exists already...',...
                    'Overwrite','Save as','Cancel',...
                    'Cancel');
                switch answer
                    case 'Overwrite'
                    case 'Save as'
                        datasetSaveAs(id);
                        return;
                    case 'Cancel'
                        return;
                    otherwise
                        return;
                end
            end
        end
    end
    
    for k = 1:length(ad.data)
        if (strcmp(ad.data{k}.filename,ad.data{id}.filename)) && (k ~= id)
            answer = questdlg(...
                {'WARNING: You''re about to save the current dataset to the file'...
                ad.data{id}.filename ...
                ' '...
                'A dataset loaded from a file with that name has been loaded to the GUI!'...
                ' '...
                'Please use "Save as" and choose a different name or press "Cancel".'},...
                'Warning: Dataset with same filename loaded to GUI...',...
                'Save as','Cancel',...
                'Cancel');
            switch answer
                case 'Save as'
                    datasetSaveAs(id);
                    return;
                case 'Cancel'
                    return;
                otherwise
                    return;
            end
        end
    end
    
    % Do the actual saving
    [ status, exception ] = ...
        trEPRsave(ad.data{id}.filename,ad.data{id});
    
    % In case something went wrong
    if status
        % Adding status line
        msgStr = cell(0);
        msgStr{length(msgStr)+1} = ...
            sprintf('Problems when trying to save "%s" to file',...
            ad.data{selected}.label);
        msgStr{length(msgStr)+1} = ad.data{id}.filename;
        status = add2status(msgStr);
        clear msgStr;
        return;
    else
        % Get second output parameter from trEPRsave, i.e. filename
        % (See help of trEPRsave for details)
        filename = exception;
    end
    
    % Remove from modified
    ad.control.spectra.modified(...
        find(ad.control.spectra.modified == id)) = [];
    
    % Update appdata of main window
    setappdata(mainWindow,'control',ad.control);
    setappdata(mainWindow,'data',ad.data);
    setappdata(mainWindow,'origdata',ad.origdata);
    
    % Adding status line
    msgStr = cell(0);
    msgStr{length(msgStr)+1} = ...
        sprintf('Data set "%s" saved to file',ad.data{id}.label);
    msgStr{length(msgStr)+1} = filename;
    status = add2status(msgStr);
    clear msgStr;
end

function datasetSaveAs(id)
    % Get appdata of main window
    mainWindow = findobj('Tag','trepr_gui_mainwindow');
    ad = getappdata(mainWindow);
    
    % Create default filename
    [fpath,fname,fext] = fileparts(ad.data{id}.filename);
    if ~strcmp(fext,'.zip')
        ad.data{id}.filename = fullfile(fpath,[fname '.zip']);
    end
    % Need to test for existing file and in case, change default name
    if (exist(ad.data{id}.filename,'file'))
        % 1. Check whether name ends with -NNN (where NNN are numbers)
        % 2. existingFiles = dir(sprintf('%s*',filename));
        % 2a. If name ends with -NNN, remove "-NNN" from filename before
        % 3. regexp existingFiles for "-NNN" pattern
        % 4. Get highest "-NNN" pattern and increment "NNN"
        % 5. Use filename with incremented "NNN" as new default filename
        if (regexp(fname,'_\d+$'))
            filesInDir = ...
                dir(sprintf('%s*',fullfile(fpath,regexprep(fname,'_\d+$',''))));
        else
            filesInDir = dir(sprintf('%s*',fullfile(fpath,fname)));
        end
        l=0;
        numbers = [];
        for k=1:length(filesInDir)
            token = regexp(filesInDir(k).name,'_(\d+)\..*$','tokens');
            if ~isempty(token)
                l=l+1;
                numbers(l) = str2double(token{1});
            end
        end
        if (~isempty(numbers));
            number = max(numbers)+1;
        else
            number = 1;
        end
        ad.data{id}.filename = fullfile(...
            fpath,...
            sprintf('%s_%i.zip',fname,number));
    end
    
    % Show dialog for file selection
    [FileName,PathName,FilterIndex] = uiputfile(...
        '*.zip',...
        'Save dataset in a new file',...
        ad.data{id}.filename);
    
    if (FileName == 0)
        return;
    end
    
    % Set filename to save in
    ad.data{id}.filename = fullfile(PathName, FileName);
    
    for k = 1:length(ad.data)
        if (strcmp(ad.data{k}.filename,ad.data{id}.filename)) && (k ~= id)
            answer = questdlg(...
                {'WARNING: You''re about to save the current dataset to the file'...
                ad.data{id}.filename ...
                ' '...
                'A dataset loaded from a file with that name has been loaded to the GUI!'...
                ' '...
                'Please use "Save as" and choose a different name or press "Cancel".'},...
                'Warning: Dataset with same filename loaded to GUI...',...
                'Save as','Cancel',...
                'Cancel');
            switch answer
                case 'Save as'
                    datasetSaveAs(id);
                    return;
                case 'Cancel'
                    return;
                otherwise
                    return;
            end
        end
    end
    
    % Do the actual saving
    [ status, exception ] = ...
        trEPRsave(ad.data{id}.filename,ad.data{id});
    
    % In case something went wrong
    if status
        % Adding status line
        msgStr = cell(0);
        msgStr{length(msgStr)+1} = ...
            sprintf('Problems when trying to save "%s" to file',...
            ad.data{selected}.label);
        msgStr{length(msgStr)+1} = ad.data{id}.filename;
        status = add2status(msgStr);
        clear msgStr;
        return;
    else
        % Get second output parameter from trEPRsave, i.e. filename
        % (See help of trEPRsave for details)
        filename = exception;
    end
    
    % Remove from modified
    ad.control.spectra.modified(...
        find(ad.control.spectra.modified == id)) = [];
    
    % Update appdata of main window
    setappdata(mainWindow,'control',ad.control);
    setappdata(mainWindow,'data',ad.data);
    setappdata(mainWindow,'origdata',ad.origdata);
    
    % Adding status line
    msgStr = cell(0);
    msgStr{length(msgStr)+1} = ...
        sprintf('Data set "%s" saved to file',ad.data{id}.label);
    msgStr{length(msgStr)+1} = filename;
    status = add2status(msgStr);
    clear msgStr;
end
    

end