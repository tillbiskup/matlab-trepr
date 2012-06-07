function varargout = trEPRgui_combinewindow(varargin)
% TREPRGUI_COMBINEWINDOW Combine multiple datasets to a single dataset,
% give user maximum control over that process and prevent too stupid things
% from happening.
%
% Normally, this window is called from within the trEPRgui window.
%
% See also TREPRGUI

% (c) 2011-12, Till Biskup
% 2012-06-07

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Make GUI effectively a singleton
singleton = trEPRguiGetWindowHandle('trEPRgui_combinewindow');
if (singleton)
    figure(singleton);
    varargout{1} = singleton;
    return;
end

% Get list of file formats that are combinable from trEPRload.ini
% In this INI file, all formats that allow to combine datasets have the
% field 'combineMultiple' set to 'true'
combinableFormats = cell(0);
fileFormats = trEPRiniFileRead(fullfile(trEPRinfo('dir'),'IO','trEPRload.ini'));
formatNames = fieldnames(fileFormats);
for k=1:length(formatNames)
    if isfield(fileFormats.(formatNames{k}),'combineMultiple') && ...
            strcmpi(fileFormats.(formatNames{k}).combineMultiple,'true')
        combinableFormats{end+1} = formatNames{k};
    end
end

% Try to get main GUI position
mainGUIHandle = trEPRguiGetWindowHandle();
if ishandle(mainGUIHandle)
    mainGUIPosition = get(mainGUIHandle,'Position');
    guiPosition = [mainGUIPosition(1)+10,mainGUIPosition(2)+150,650,510];
else
    guiPosition = [30,200,650,510];
end

%  Construct the components
hMainFigure = figure('Tag','trEPRgui_combinewindow',...
    'Visible','off',...
    'Name','trEPR GUI : Combine Window',...
    'Units','Pixels',...
    'Position',guiPosition,...
    'Resize','off',...
    'NumberTitle','off', ...
    'KeyPressFcn',@keypress_Callback,...
    'Menu','none','Toolbar','none');

defaultBackground = get(hMainFigure,'Color');
mainPanelWidth = 260;
mainPanelHeight = 540;
panel_size = 240;
guiSize = get(hMainFigure,'Position');
guiSize = guiSize([3,4]);


pp1 = uipanel('Tag','combinable_formats_panel',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[20 guiSize(2)-160 guiSize(1)-40 140],...
    'Title','Combinable file formats and file basenames'...
    );

pp2 = uipanel('Tag','combinable_datasets_panel',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[20 85 guiSize(1)-40 guiSize(2)-255],...
    'Title','Combinable datasets'...
    );

pp3 = uipanel('Tag','label_panel',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[20 20 2*mainPanelWidth-130 55],...
    'Title','Label for combined dataset'...
    );

pp1_p1 = uipanel('Tag','filetypes_panel',...
    'Parent',pp1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 mainPanelWidth-20 110],...
    'Title','Detected file formats'...
    );
uicontrol('Tag','filetypes_listbox',...
    'Style','listbox',...
    'Parent',pp1_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 mainPanelWidth-40 80],...
    'TooltipString','List of combinable file formats',...
    'String','',...
    'Callback',{@listbox_Callback,'filetypes'}...
    );

pp1_p2 = uipanel('Tag','filebasename_panel',...
    'Parent',pp1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[mainPanelWidth 10 mainPanelWidth-20 110],...
    'Title','File basenames'...
    );
uicontrol('Tag','filebasename_listbox',...
    'Style','listbox',...
    'Parent',pp1_p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 mainPanelWidth-40 80],...
    'TooltipString',sprintf('%s\n%s',...
    'List of file basenames of combinable datasets',...
    'for the file format selected in the left listbox'),...
    'String','',...
    'Callback',{@listbox_Callback,'filebasename'}...
    );

uicontrol('Tag','addbasename_pushbutton',...
    'Style','pushbutton',...
	'Parent', pp1, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Add',...
    'TooltipString',sprintf('%s\n%s',...
    'Add all datasets with this file basename',...
    'to the list of datasets to combine'),...
    'pos',[(mainPanelWidth*2)-10 45 guiSize(1)-(mainPanelWidth*2)-40 30],...
    'Enable','on',...
    'Callback',{@pushbutton_Callback,'Add basename'}...
    );
uicontrol('Tag','removebasename_pushbutton',...
    'Style','pushbutton',...
	'Parent', pp1, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Remove',...
    'TooltipString',sprintf('%s\n%s',...
    'Remove all datasets with this file basename',...
    'from the list of datasets to combine'),...
    'pos',[(mainPanelWidth*2)-10 10 guiSize(1)-(mainPanelWidth*2)-40 30],...
    'Enable','on',...
    'Callback',{@pushbutton_Callback,'Remove basename'}...
    );

pp2_p1 = uipanel('Tag','notcombine_panel',...
    'Parent',pp2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 mainPanelWidth-20 225],...
    'Title','Datasets not to combine'...
    );
uicontrol('Tag','notcombine_listbox',...
    'Style','listbox',...
    'Parent',pp2_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 mainPanelWidth-40 195],...
    'TooltipString','List of datasets that will not be combined',...
    'String','',...
    'Min',0,'Max',2,...
    'Callback',{@listbox_Callback,'notcombine'}...
    );

uicontrol('Tag','add_pushbutton',...
    'Style','pushbutton',...
	'Parent', pp2, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Add',...
    'TooltipString','Add selected datasets to list of datasets to combine',...
    'pos',[mainPanelWidth 200 guiSize(1)-(mainPanelWidth*2)-40 30],...
    'Enable','on',...
    'Callback',{@pushbutton_Callback,'Add'}...
    );
uicontrol('Tag','remove_pushbutton',...
    'Style','pushbutton',...
	'Parent', pp2, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Remove',...
    'TooltipString','Remove selected datasets from list of datasets to combine',...
    'pos',[mainPanelWidth 165 guiSize(1)-(mainPanelWidth*2)-40 30],...
    'Enable','on',...
    'Callback',{@pushbutton_Callback,'Remove'}...
    );
uicontrol('Tag','addall_pushbutton',...
    'Style','pushbutton',...
	'Parent', pp2, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Add all',...
    'TooltipString','Add all datasets to list of datasets to combine',...
    'pos',[mainPanelWidth 105 guiSize(1)-(mainPanelWidth*2)-40 30],...
    'Enable','on',...
    'Callback',{@pushbutton_Callback,'Add all'}...
    );
uicontrol('Tag','removeall_pushbutton',...
    'Style','pushbutton',...
	'Parent', pp2, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Remove all',...
    'TooltipString','Remove all datasets from list of datasets to combine',...
    'pos',[mainPanelWidth 70 guiSize(1)-(mainPanelWidth*2)-40 30],...
    'Enable','on',...
    'Callback',{@pushbutton_Callback,'Remove all'}...
    );
uicontrol('Tag','sort_pushbutton',...
    'Style','pushbutton',...
	'Parent', pp2, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Sort',...
    'TooltipString',sprintf('%s\n%s',...
    'Sort both lists of datasets according to',...
    'the index of the datasets displayed'),...
    'pos',[mainPanelWidth 10 guiSize(1)-(mainPanelWidth*2)-40 30],...
    'Enable','on',...
    'Callback',{@pushbutton_Callback,'Sort'}...
    );

pp2_p2 = uipanel('Tag','combine_panel',...
    'Parent',pp2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[guiSize(1)-mainPanelWidth-30 10 mainPanelWidth-20 225],...
    'Title','Datasets to combine'...
    );
uicontrol('Tag','combine_listbox',...
    'Style','listbox',...
    'Parent',pp2_p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 mainPanelWidth-40 195],...
    'TooltipString','List of datasets that will be combined',...
    'String','',...
    'Min',0,'Max',2,...
    'Callback',{@listbox_Callback,'combine'}...
    );

uicontrol('Tag','label_edit',...
    'Style','edit',...
    'Parent',pp3,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','left',...
    'Units','Pixels',...
    'Position',[10 10 2*mainPanelWidth-150 25],...
    'String','label',...
    'TooltipString','Label for dataset created by combining the selected datasets',...
    'Enable','on',...
    'Callback',{@edit_Callback,'label'}...
    );


uicontrol('Tag','help_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'ForegroundColor',[0 0 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'FontWeight','bold',...
    'String','?',...
    'TooltipString','Display help for how to operate the Combine GUI',...
    'pos',[2*mainPanelWidth-100 32 25 25],...
    'Enable','on',...
    'Callback',@trEPRgui_combine_helpwindow...
    );

uicontrol('Tag','combine_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Combine',...
    'TooltipString','Combine selected datasets to new dataset',...
    'pos',[guiSize(1)-((mainPanelWidth)/3*2)-25 20 guiSize(1)-(mainPanelWidth*2)-40 50],...
    'Enable','on',...
    'Callback',{@pushbutton_Callback,'Combine'}...
    );
uicontrol('Tag','close_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Close',...
    'TooltipString','Close Combine GUI',...
    'pos',[guiSize(1)-((mainPanelWidth)/3)-20 20 (mainPanelWidth)/3+5 50],...
    'Enable','on',...
    'Callback',{@pushbutton_Callback,'Close'}...
    );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Store handles in guidata
guidata(hMainFigure,guihandles);

% Create appdata structure
ad = trEPRguiDataStructure('guiappdatastructure');

% Combine - struct
ad.combine = struct();
ad.combine.spectra.notcombine = [];
ad.combine.spectra.combine = [];
ad.combine.label = '';

setappdata(hMainFigure,'data',ad.data);
setappdata(hMainFigure,'origdata',ad.origdata);
setappdata(hMainFigure,'configuration',ad.configuration);
setappdata(hMainFigure,'control',ad.control);
setappdata(hMainFigure,'combine',ad.combine);

% Load data from Main GUI
mainGuiWindow = trEPRguiGetWindowHandle();
if (mainGuiWindow)
    admain = getappdata(mainGuiWindow);
    % Check for availability of necessary fields in appdata
    if (isfield(admain,'data') ~= 0)
        ad.data = admain.data;
        setappdata(hMainFigure,'data',ad.data);
        ad.origdata = admain.data;
        setappdata(hMainFigure,'origdata',ad.origdata);
    end
    ad = getappdata(hMainFigure);
end

% If there are no combinable datasets, close GUI and return
if ~checkForCombinableDatasets
    msgStr = 'combine GUI window not opened: missing combinable datasets';
    trEPRadd2status(msgStr);
    delete(hMainFigure);
    return;
end

% Make the GUI visible.
set(hMainFigure,'Visible','on');
msgStr = 'combine GUI window opened';
trEPRadd2status(msgStr);

if (nargout == 1)
    varargout{1} = hMainFigure;
end

updateFileformats()
updateBasenames();
updateSpectra();
updateLabel();

% Add keypress function to every element that can have one...
handles = findall(...
    allchild(hMainFigure),'style','pushbutton',...
    '-or','style','togglebutton',...
    '-or','style','edit',...
    '-or','style','listbox',...
    '-or','style','popupmenu');
for m=1:length(handles)
    set(handles(m),'KeyPressFcn',@keypress_Callback);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function listbox_Callback(source,~,field)
    try
        mainWindow = trEPRguiGetWindowHandle(mfilename);
        % Get appdata from combine GUI
        ad = getappdata(mainWindow);

        switch field
            case 'filetypes'
                updateFileformats();
                updateBasenames();
                updateSpectra();
            case 'filebasename'
            case 'notcombine'
            case 'combine'
            otherwise
                disp('trEPRgui_combinewindow: listbox_Callback(): Unknown field');
                disp(field);
                return;
        end
        updateSpectra();
    catch exception
        try
            msgStr = ['An exception occurred. '...
                'The bug reporter should have been opened'];
            trEPRadd2status(msgStr);
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

function edit_Callback(source,~,field)
    try
        if isempty(field)
            return;
        end
        
        % Get appdata of main window
        mainWindow = trEPRguiGetWindowHandle(mfilename);
        ad = getappdata(mainWindow);
        
        value = get(source,'String');
        
        switch field
            case 'label'
                ad.combine.label = value;
                setappdata(mainWindow,'combine',ad.combine);
                updateLabel();
            otherwise
                return;
        end
    catch exception
        try
            msgStr = ['An exception occurred. '...
                'The bug reporter should have been opened'];
            trEPRadd2status(msgStr);
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

function pushbutton_Callback(~,~,action)
    try
        if isempty(action)
            return;
        end
        
        % Get appdata of main window
        mainWindow = trEPRguiGetWindowHandle(mfilename);
        ad = getappdata(mainWindow);
        
        % Get handles of main window
        gh = guihandles(mainWindow);

        switch action
            case 'Add basename'
                baseNames = get(gh.filebasename_listbox,'String');
                baseName = baseNames{get(gh.filebasename_listbox,'Value')};
                [~,fileBaseNames,~] = cellfun(@(x) fileparts(x.file.name),...
                    ad.data,'UniformOutput',false);
                toadd = find(strcmp(baseName,fileBaseNames));
                for k=1:length(toadd)
                    if any(ad.combine.spectra.notcombine==toadd(k))
                        ad.combine.spectra.notcombine(...
                            ad.combine.spectra.notcombine==toadd(k)) = [];
                    end
                    if ~any(ad.combine.spectra.combine==toadd(k))
                        ad.combine.spectra.combine(end+1) = toadd(k);
                    end
                end
                setappdata(mainWindow,'combine',ad.combine);
                updateSpectra();
                updateLabel();
            case 'Remove basename'
                baseNames = get(gh.filebasename_listbox,'String');
                baseName = baseNames{get(gh.filebasename_listbox,'Value')};
                [~,fileBaseNames,~] = cellfun(@(x) fileparts(x.file.name),...
                    ad.data,'UniformOutput',false);
                toremove = find(strcmp(baseName,fileBaseNames));
                for k=1:length(toremove)
                    if any(ad.combine.spectra.combine==toremove(k))
                        ad.combine.spectra.combine(...
                            ad.combine.spectra.combine==toremove(k)) = [];
                    end
                    if ~any(ad.combine.spectra.notcombine==toremove(k))
                        ad.combine.spectra.notcombine(end+1) = toremove(k);
                    end
                end
                setappdata(mainWindow,'combine',ad.combine);
                updateSpectra();
                updateLabel();
            case 'Add'
                toadd = ad.combine.spectra.notcombine(...
                    get(gh.notcombine_listbox,'Value'));
                for k=1:length(toadd)
                    if any(ad.combine.spectra.notcombine==toadd(k))
                        ad.combine.spectra.notcombine(...
                            ad.combine.spectra.notcombine==toadd(k)) = [];
                    end
                    if ~any(ad.combine.spectra.combine==toadd(k))
                        ad.combine.spectra.combine(end+1) = toadd(k);
                    end
                end
                setappdata(mainWindow,'combine',ad.combine);
                updateSpectra();
                updateLabel();
            case 'Remove'
                toremove = ad.combine.spectra.combine(...
                    get(gh.combine_listbox,'Value'));
                for k=1:length(toremove)
                    if any(ad.combine.spectra.combine==toremove(k))
                        ad.combine.spectra.combine(...
                            ad.combine.spectra.combine==toremove(k)) = [];
                    end
                    if ~any(ad.combine.spectra.notcombine==toremove(k))
                        ad.combine.spectra.notcombine(end+1) = toremove(k);
                    end
                end
                setappdata(mainWindow,'combine',ad.combine);
                updateSpectra();
                updateLabel();
            case 'Add all'
                ad.combine.spectra.combine = [...
                    ad.combine.spectra.combine ...
                    ad.combine.spectra.notcombine];
                ad.combine.spectra.notcombine = [];
                setappdata(mainWindow,'combine',ad.combine);
                updateSpectra();
                updateLabel();
            case 'Remove all'
                ad.combine.spectra.notcombine = [...
                    ad.combine.spectra.notcombine ...
                    ad.combine.spectra.combine];
                ad.combine.spectra.combine = [];
                setappdata(mainWindow,'combine',ad.combine);
                updateSpectra();
                updateLabel();
            case 'Sort'
                ad.combine.spectra.notcombine = ...
                    sort(ad.combine.spectra.notcombine);
                ad.combine.spectra.combine = ...
                    sort(ad.combine.spectra.combine);
                setappdata(mainWindow,'combine',ad.combine);
                updateSpectra();
            case 'Combine'
                if isempty(ad.combine.spectra.combine)
                    return;
                end
                % And here has to go the real stuff
                [combinedDataset,status] = trEPRcombine(...
                    ad.data(ad.combine.spectra.combine),...
                    'Label',ad.combine.label);
                if isempty(combinedDataset)
                    msgbox(status,'An error occurred','Error','modal');
                    return;
                end
                status = trEPRappendDatasetToMainGUI(...
                    combinedDataset,'modified',true);
                if status
                    disp('Hmm... some problems with appending combined dataset to main GUI.');
                end
                status = trEPRremoveDatasetFromMainGUI(...
                    ad.combine.spectra.combine,'Force',true);
                if status
                    disp('Hmm... some problems with removing dataset(s) from main GUI.');
                end
                % After successful update of main GUI, refresh GUI data
                mainGuiWindow = trEPRguiGetWindowHandle();
                adMain = getappdata(mainGuiWindow);
                ad.data = adMain.data;
                setappdata(hMainFigure,'data',ad.data);
                ad.origdata = adMain.data;
                setappdata(hMainFigure,'origdata',ad.origdata);
                updateFileformats()
                updateBasenames();
                updateSpectra();
                updateLabel();
                % Bring combine GUI to fromt
                trEPRgui_combinewindow();
            case 'Close'
                msgStr = 'combine GUI window closed.';
                trEPRadd2status(msgStr);

                % Look for combine GUI Help window and if its there, close as
                % well
                hHelpWindow = trEPRguiGetWindowHandle('trEPRgui_combine_helpwindow');
                if ishandle(hHelpWindow)
                    delete(hHelpWindow);
                end
                delete(trEPRguiGetWindowHandle(mfilename));
            otherwise
                disp('trEPRgui_combinewindow: pushbutton_Callback(): Unknown action');
                disp(action);
                return;
        end
    catch exception
        try
            msgStr = ['An exception occurred. '...
                'The bug reporter should have been opened'];
            trEPRadd2status(msgStr);
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

function keypress_Callback(src,evt)
    try
        if isempty(evt.Character) && isempty(evt.Key)
            % In case "Character" is the empty string, i.e. only modifier key
            % was pressed...
            return;
        end
        mainWindow = trEPRguiGetWindowHandle(mfilename);
        % Get appdata from combine GUI
        ad = getappdata(mainWindow);

        if ~isempty(evt.Modifier)
            if (strcmpi(evt.Modifier{1},'command')) || ...
                    (strcmpi(evt.Modifier{1},'control'))
                switch evt.Key
                    case 'w'
                        pushbutton_Callback(src,evt,'Close')
                        return;
                end
            end
        end
        switch evt.Key
            case 'f1'
                trEPRgui_combine_helpwindow();
                return;
            otherwise
%                 disp(evt);
%                 fprintf('       Caller: %i\n\n',src);
                return;
        end
    catch exception
        try
            msgStr = ['An exception occurred. '...
                'The bug reporter should have been opened'];
            trEPRadd2status(msgStr);
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

function status = checkForCombinableDatasets()
    try
        status = false;
        mainWindow = trEPRguiGetWindowHandle(mfilename);
        % Get appdata of combine GUI
        ad = getappdata(mainWindow);
        
        % Get file formats
        formats = cellfun(@(x) x.file.format,ad.data,'UniformOutput',false);
        % Get unique formats
        uniqueFormats = unique(formats);

        % If one of the formats is combinable, set output to true
        for k=1:length(uniqueFormats)
            if max(strcmpi(uniqueFormats{k},combinableFormats)) ...
                    && length(find(strcmpi(uniqueFormats{k},formats)))>1
                status = true;
            end
        end
    catch exception
        try
            msgstr = ['an exception occurred. '...
                'the bug reporter should have been opened'];
            trEPRadd2status(msgstr);
        catch exception2
            exception = addcause(exception2, exception);
            disp(msgstr);
        end
        try
            trEPRgui_bugreportwindow(exception);
        catch exception3
            % if even displaying the bug report window fails...
            exception = addcause(exception3, exception);
            throw(exception);
        end
    end
end

function updateFileformats()
    try
        mainWindow = trEPRguiGetWindowHandle(mfilename);
        % Get appdata of combine GUI
        ad = getappdata(mainWindow);
        
        % Get handles of combine GUI
        gh = guihandles(mainWindow);
        
        % Get file formats
        formats = cellfun(@(x) x.file.format,ad.data,'UniformOutput',false);
        % Get unique formats
        uniqueFormats = unique(formats);
        
        % Compile list of combinable file formats from datasets loaded in
        % the main GUI
        displayFormats = cell(0);
        for k=1:length(uniqueFormats)
            if max(strcmp(uniqueFormats{k},combinableFormats)) ...
                    && length(find(strcmpi(uniqueFormats{k},formats)))>1
                displayFormats{end+1} = uniqueFormats{k};
            end
        end
        % Display combinable file formats in listbox
        set(gh.filetypes_listbox,'String',displayFormats);
        
        ad.combine.spectra.notcombine = [];
        ad.combine.spectra.combine = [];
        setappdata(mainWindow,'combine',ad.combine);
    catch exception
        try
            msgstr = ['an exception occurred. '...
                'the bug reporter should have been opened'];
            trEPRadd2status(msgstr);
        catch exception2
            exception = addcause(exception2, exception);
            disp(msgstr);
        end
        try
            trEPRgui_bugreportwindow(exception);
        catch exception3
            % if even displaying the bug report window fails...
            exception = addcause(exception3, exception);
            throw(exception);
        end
    end
end

function updateBasenames()
    try
        mainWindow = trEPRguiGetWindowHandle(mfilename);
        % Get appdata of combine GUI
        ad = getappdata(mainWindow);
        
        % Get handles of combine GUI
        gh = guihandles(mainWindow);
        
        % Get selected format from filetypes listbox
        selectedFormats = get(gh.filetypes_listbox,'String');
        if isempty(selectedFormats)
            set(gh.filebasename_listbox,'String','');
            set(gh.filebasename_listbox,'Value',1);
            return;
        end
        selectedFormat = selectedFormats{get(gh.filetypes_listbox,'Value')};
        
        % Get file formats
        formats = cellfun(@(x) x.file.format,ad.data,'UniformOutput',false);
        % Get unique formats
        uniqueFormats = unique(formats);
        
        ad.combine.spectra.notcombine = find(strcmp(selectedFormat,formats));
        
        % Get datasets in selected format
        [~,filebasenames,fileexts] = cellfun(@(x) fileparts(x.file.name),...
            ad.data(ad.combine.spectra.notcombine),...
            'UniformOutput',false);
        uniqueFilebasenames = unique(filebasenames);

        % Display unique file basenames for selected file format
        set(gh.filebasename_listbox,'String',uniqueFilebasenames);
        if (get(gh.filebasename_listbox,'Value')>length(uniqueFilebasenames))
            if isempty(uniqueFilebasenames)
                set(gh.filebasename_listbox,'Value',1);
            else
                set(gh.filebasename_listbox,'Value',length(uniqueFilebasenames));
            end
        end

        setappdata(mainWindow,'combine',ad.combine);
    catch exception
        try
            msgstr = ['an exception occurred. '...
                'the bug reporter should have been opened'];
            trEPRadd2status(msgstr);
        catch exception2
            exception = addcause(exception2, exception);
            disp(msgstr);
        end
        try
            trEPRgui_bugreportwindow(exception);
        catch exception3
            % if even displaying the bug report window fails...
            exception = addcause(exception3, exception);
            throw(exception);
        end
    end
end

function updateSpectra()
    try
        mainWindow = trEPRguiGetWindowHandle(mfilename);
        % Get appdata of combine GUI
        ad = getappdata(mainWindow);
        
        % Get handles of combine GUI
        gh = guihandles(mainWindow);
        
        % Get not to combine datasets and display in respective listbox
        [~,filebasenames,fileexts] = cellfun(@(x) fileparts(x.file.name),...
            ad.data(ad.combine.spectra.notcombine),...
            'UniformOutput',false);
        fileNames = cell(0);
        for k=1:length(filebasenames)
            fileNames{k} = [filebasenames{k} fileexts{k}];
        end
        set(gh.notcombine_listbox,'String',fileNames);
        if (get(gh.notcombine_listbox,'Value')>length(fileNames))
            if isempty(fileNames)
                set(gh.notcombine_listbox,'Value',1);
            else
                set(gh.notcombine_listbox,'Value',length(fileNames));
            end
        end
        if ~(get(gh.notcombine_listbox,'Value'))
            set(gh.notcombine_listbox,'Value',1);
        end
        
        % Get to combine datasets and display in respective listbox
        [~,filebasenames,fileexts] = cellfun(@(x) fileparts(x.file.name),...
            ad.data(ad.combine.spectra.combine),...
            'UniformOutput',false);
        fileNames = cell(0);
        for k=1:length(filebasenames)
            fileNames{k} = [filebasenames{k} fileexts{k}];
        end
        set(gh.combine_listbox,'String',fileNames);        
        if (get(gh.combine_listbox,'Value')>length(fileNames))
            if isempty(fileNames)
                set(gh.combine_listbox,'Value',1);
                updateLabel();
            else
                set(gh.combine_listbox,'Value',length(fileNames));
            end
        end
        if ~(get(gh.combine_listbox,'Value'))
            set(gh.combine_listbox,'Value',1);
        end
    catch exception
        try
            msgstr = ['an exception occurred. '...
                'the bug reporter should have been opened'];
            trEPRadd2status(msgstr);
        catch exception2
            exception = addcause(exception2, exception);
            disp(msgstr);
        end
        try
            trEPRgui_bugreportwindow(exception);
        catch exception3
            % if even displaying the bug report window fails...
            exception = addcause(exception3, exception);
            throw(exception);
        end
    end
end

function updateLabel()
    try
        mainWindow = trEPRguiGetWindowHandle(mfilename);
        % Get appdata of combine GUI
        ad = getappdata(mainWindow);
        
        % Get handles of combine GUI
        gh = guihandles(mainWindow);
        
        if isempty(get(gh.combine_listbox,'String'))
            ad.combine.label = '';
        elseif isempty(ad.combine.label)
            ad.combine.label = ad.data{ad.combine.spectra.combine(...
                get(gh.combine_listbox,'Value'))}.label;
        end

        set(gh.label_edit,'String',ad.combine.label);
        setappdata(mainWindow,'combine',ad.combine);

    catch exception
        try
            msgstr = ['an exception occurred. '...
                'the bug reporter should have been opened'];
            trEPRadd2status(msgstr);
        catch exception2
            exception = addcause(exception2, exception);
            disp(msgstr);
        end
        try
            trEPRgui_bugreportwindow(exception);
        catch exception3
            % if even displaying the bug report window fails...
            exception = addcause(exception3, exception);
            throw(exception);
        end
    end
end

end