function varargout = trEPRgui_snapshot_showwindow(varargin)
% TREPRGUI_SNAPSHOT_SHOWWINDOW Window displaying snapshots from a given
% directory together with a bit of information.
%
% Normally, this window is called from within the trEPRgui window. 
%
% See also TREPRGUI

% Copyright (c) 2013-15, Till Biskup
% 2015-10-18

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Make GUI effectively a singleton
singleton = findobj('Tag',mfilename);
if ishghandle(singleton)
    figure(singleton);
    if nargout
        varargout{1} = singleton;
    end
    return;
end

defaultBackground = [.9 .9 .9];

guiPosition = [160,240,650,430];
% Try to get main GUI position
mainGUIHandle = trEPRguiGetWindowHandle();
if ishandle(mainGUIHandle)
    mainGUIPosition = get(mainGUIHandle,'Position');
    guiPosition = [mainGUIPosition(1)+40,mainGUIPosition(2)+150,...
        guiPosition(3), guiPosition(4)];
else
    disp('No trEPR GUI main window found. Bye...');
    return;
end

%  Construct the components
hMainFigure = figure('Tag',mfilename,...
    'Visible','off',...
    'Name','trEPR GUI : Snapshots',...
    'Color',defaultBackground,...
    'Units','Pixels',...
    'Position',guiPosition,...
    'Resize','off',...
    'KeyPressFcn',@keypress_Callback,...
    'NumberTitle','off', ...
    'Menu','none','Toolbar','none');

guiSize = get(hMainFigure,'Position');
guiSize = guiSize([3,4]);

uicontrol('Tag','heading_text',...
    'Style','text',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',14,...
    'HorizontalAlignment','Left',...
    'FontWeight','bold',...
    'Units','Pixels',...
    'Position',[10 guiSize(2)-35 guiSize(1)-220 20],...
    'String','trEPR GUI: Snapshots'...
    );

p1 = uipanel('Tag','filelist_panel',...
    'parent',hMainFigure,...
    'Title','Snapshots',...
    'FontUnit','Pixel','Fontsize',12,...
    'BackgroundColor',defaultBackground,...
    'Visible','on',...
    'Units','pixels',...
    'Position',[10 50 240 guiSize(2)-100] ...
    );
uicontrol('Tag','filelist_panel_listbox',...
    'Style','listbox',...
    'Parent',p1,...
    'BackgroundColor',[0.95 0.95 0.95],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 220 guiSize(2)-130],...
    'Min',0,'Max',2,...
    'String','',...
    'Callback',{@listbox_Callback,'snapshots'}...
    );

p2 = uipanel('Tag','content_panel',...
    'parent',hMainFigure,...
    'Title','Content of selected snapshot',...
    'FontUnit','Pixel','Fontsize',12,...
    'BackgroundColor',defaultBackground,...
    'Visible','on',...
    'Units','pixels',...
    'Position',[260 50 guiSize(1)-270 guiSize(2)-100] ...
    );
uicontrol('Tag','content_panel_date_text',...
    'Style','text',...
    'Parent',p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Right',...
    'Position',[10 guiSize(2)-150 70 20],...
    'String','Date:'...
    );
uicontrol('Tag','content_panel_date_content_text',...
    'Style','text',...
    'Parent',p2,...
    'BackgroundColor',[.95 .95 .95],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'Position',[90 guiSize(2)-150 270 20],...
    'String',''...
    );
uicontrol('Tag','content_panel_format_text',...
    'Style','text',...
    'Parent',p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Right',...
    'Position',[10 guiSize(2)-175 70 20],...
    'String','Format:'...
    );
uicontrol('Tag','content_panel_format_content_text',...
    'Style','text',...
    'Parent',p2,...
    'BackgroundColor',[.95 .95 .95],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'Position',[90 guiSize(2)-175 270 20],...
    'String',''...
    );
uicontrol('Tag','content_panel_version_text',...
    'Style','text',...
    'Parent',p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Right',...
    'Position',[10 guiSize(2)-200 70 20],...
    'String','Version:'...
    );
uicontrol('Tag','content_panel_version_content_text',...
    'Style','text',...
    'Parent',p2,...
    'BackgroundColor',[.95 .95 .95],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'Position',[90 guiSize(2)-200 270 20],...
    'String',''...
    );
uicontrol('Tag','content_panel_version_text',...
    'Style','text',...
    'Parent',p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Right',...
    'Position',[10 guiSize(2)-235 70 20],...
    'String','Datasets:'...
    );
cmdHistory = uicontrol('Tag','content_panel_dataset_listbox',...
    'Style','listbox',...
    'Parent',p2,...
    'BackgroundColor',[0.95 0.95 0.95],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[90 guiSize(2)-275 270 60],...
    'Min',0,'Max',2,...
    'String','',...
    'Callback',{@listbox_Callback,'datasets'}...
    );

uicontrol('Tag','chdir_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Change dir',...
    'TooltipString','Change to other directory containing snapshots',...
    'pos',[10 10 90 30],...
    'Enable','on',...
    'Callback',{@pushbutton_Callback,'chdir'}...
    );
uicontrol('Tag','load_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Load',...
    'TooltipString','Load currently selected snapshot into GUI',...
    'pos',[guiSize(1)-190 10 90 30],...
    'Enable','on',...
    'Callback',{@pushbutton_Callback,'load'}...
    );
uicontrol('Tag','close_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Close',...
    'TooltipString','Close Snapshots window',...
    'pos',[guiSize(1)-100 10 90 30],...
    'Enable','on',...
    'Callback',{@closeGUI}...
    );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try
    % Store handles in guidata
    setappdata(hMainFigure,'guiHandles',guihandles);
    
    % Add keypress function to every element that can have one...
    handles = findall(...
        allchild(hMainFigure),'style','pushbutton',...
        '-or','style','togglebutton',...
        '-or','style','edit',...
        '-or','style','listbox',...
        '-or','style','checkbox',...
        '-or','style','slider',...
        '-or','style','popupmenu',...
        '-not','tag','command_panel_edit');
    for k=1:length(handles)
        set(handles(k),'KeyPressFcn',@keypress_Callback);
    end

    % Preset edits with directories
    updateWindow();
    
    % Make the GUI visible.
    set(hMainFigure,'Visible','on');
    trEPRmsg('Cmd history window opened.','debug');
    
    if (nargout == 1)
        varargout{1} = hMainFigure;
    end
    
    uicontrol(cmdHistory);
catch exception
    trEPRexceptionHandling(exception);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pushbutton_Callback(~,~,action)
    try
        if isempty(action)
            return;
        end
        
        gh = getappdata(hMainFigure,'guiHandles');
        admain = getappdata(mainGUIHandle);
        
        switch lower(action)
            case 'chdir'
                directory = uigetdir(...
                    admain.control.dirs.lastSnapshot,...
                    'Select directory for loading snapshots'...
                    );
                if ischar(directory) && exist(directory,'dir')
                    cmdDir(mainGUIHandle,{'snapshotdir',directory});
                end
            case 'load'
                fileNames = get(gh.filelist_panel_listbox,'String');
                [status,warnings] = cmdSnapshot(mainGUIHandle,...
                    {'load',fullfile(admain.control.dirs.lastSnapshot,...
                    char(fileNames(get(gh.filelist_panel_listbox,'Value'))))});
                if status
                    trEPRmsg(warnings,'warning');
                end
                figure(hMainFigure);
            otherwise
                trEPRoptionUnknown(action);
                return;
        end
        updateWindow();
    catch exception
        trEPRexceptionHandling(exception);
    end
end

function listbox_Callback(~,~,action)
    try
        if isempty(action)
            return;
        end
        
        switch lower(action)
            case 'snapshots'
            otherwise
                trEPRoptionUnknown(action);
                return;
        end
        updateWindow();
    catch exception
        trEPRexceptionHandling(exception);
    end
end

function keypress_Callback(~,evt)
    try
        if isempty(evt.Character) && isempty(evt.Key)
            % In case "Character" is the empty string, i.e. only modifier
            % key was pressed...
            return;
        end
        if ~isempty(evt.Modifier)
            if (strcmpi(evt.Modifier{1},'command')) || ...
                    (strcmpi(evt.Modifier{1},'control'))
                switch evt.Key
                    case 'w'
                        closeGUI();
                        return;
                end
            end
        else
            switch evt.Key
                case 'escape'
                    closeGUI();
                    return;
            end                    
        end
    catch exception
        trEPRexceptionHandling(exception);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Utility functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function closeGUI(~,~)
    try
        delete(trEPRguiGetWindowHandle(mfilename));
        trEPRmsg('Snapshot window closed.','debug');
    catch exception
        trEPRexceptionHandling(exception);
    end
end

function updateWindow()
    try
        % Get appdata from main trEPR GUI handle
        admain = getappdata(trEPRguiGetWindowHandle());
        
        % Get gui handles
        gh = getappdata(trEPRguiGetWindowHandle(mfilename),'guiHandles');

        files = dir(admain.control.dirs.lastSnapshot);
        fileNames = cell(0);
        for fn=1:length(files)
            if ~files(fn).isdir && ~strncmp('.',files(fn).name,1)
                fileNames{end+1} = files(fn).name; %#ok<AGROW>
            end
        end

        set(gh.filelist_panel_listbox,'String',fileNames);
        
        if ~isempty(fileNames)
            try
                fullfile(admain.control.dirs.lastSnapshot,...
                    char(fileNames(get(gh.filelist_panel_listbox,'Value'))))
                AD = load(fullfile(admain.control.dirs.lastSnapshot,...
                    char(fileNames(get(gh.filelist_panel_listbox,'Value')))),...
                    '-mat');
                set(gh.content_panel_date_content_text,'String',...
                    datestr(datenum(AD.datetime,'yyyymmddTHHMMSS'),31));
                set(gh.content_panel_format_content_text,'String',...
                    AD.ad.format.name);
                set(gh.content_panel_version_content_text,'String',...
                    AD.ad.format.version);
                if ~isempty(AD.ad.data)
                    labels = cellfun(@(x)x.label,AD.ad.data,...
                        'UniformOutput',false);
                    set(gh.content_panel_dataset_listbox,'String',...
                        labels);
                else
                    set(gh.content_panel_dataset_listbox,'String','');
                end
            catch 
                set(gh.content_panel_format_content_text,'String',...
                    'File has unrecognised format');
            end
        end            
    catch exception
        trEPRexceptionHandling(exception);
    end
end
