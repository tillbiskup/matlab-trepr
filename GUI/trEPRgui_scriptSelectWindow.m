function varargout = trEPRgui_scriptSelectWindow(varargin)
% TREPRGUI_SCRIPTSELECTWINDOW Help window for the trEPR GUI.
%
% This window provides the user with "online" help included within the GUI.
% Besides that, it gives access to all the other sources of additional
% help, such as the Matlab Help Browser and the toolbox website.
%
% Usage:
%   trEPRgui_scriptSelectWindow
%   trEPRgui_scriptSelectWindow(<parameter>,<value>,...)
%
%
% Optional parameters that can be set:
%
%   position  - vector (2x1)
%            	position of the window relative to the screen.

% Copyright (c) 2014, Till Biskup
% 2014-09-23

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Parse input arguments using the inputParser functionality
try
    p = inputParser;            % Create inputParser instance
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addParamValue('position',[100 200],@(x)isvector(x) && length(x)==2);
    p.parse(varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

% Check for main GUI, and if no trEPR GUI window exists, exit immediately.
mainGuiWindow = trEPRguiGetWindowHandle();
if isempty(mainGuiWindow)
    return;
end

% Make GUI effectively a singleton
singleton = findobj('Type','figure','Tag',mfilename);
if (singleton)
    figure(singleton);
    return;
end

guiSize = [920 500];
defaultBackground = [0.95 0.95 0.90];

% Construct the components
hMainFigure = figure('Tag',mfilename,...
    'Visible','off',...
    'Name','Scripts for the CMD',...
    'Color',defaultBackground,...
    'Units','Pixels',...
    'Position',[p.Results.position guiSize],...
    'Resize','off',...
    'KeyPressFcn',@keypress_Callback,...
    'NumberTitle','off', ...
    'Menu','none','Toolbar','none');

% Create popupmenu with directories
directoryPopupmenu = uicontrol('Tag','directories_popupmenu',...
    'Style','popupmenu',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 guiSize(2)-30 240 20],...
    'String','',...
    'Callback', {@popupmenu_Callback,'dir'}...
    );

% Create listbox with list of files
hFilesListbox = uicontrol('Tag','files_listbox',...
    'Style','listbox',...
    'Parent',hMainFigure,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',14,...
    'Units','Pixels',...
    'Position',[10 10 240 guiSize(2)-50],...
    'String','',...
    'Callback',{@listbox_Callback,'files'}...
    );

% Create the text window
textdisplay = uicontrol('Tag','text_edit',...
    'Style','edit',...
    'Parent',hMainFigure,...
    'BackgroundColor',[1 1 1],...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'Position',[260 50 guiSize(1)-270 guiSize(2)-60],...
    'Enable','inactive',...
    'Max',2,'Min',0,...
    'FontSize',13,...
    'FontName','Monospaced',...
    'String','');

uicontrol('Tag','execute_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Execute',...
    'TooltipString','Run selected script in CMD',...
    'pos',[guiSize(1)-130 10 60 30],...
    'Enable','on',...
    'Callback',{@pushbutton_Callback,'execute'} ...
    );

uicontrol('Tag','close_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Close',...
    'TooltipString','Close window',...
    'pos',[guiSize(1)-70 10 60 30],...
    'Enable','on',...
    'Callback',{@closeGUI}...
    );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try
    % Store handles in guidata
    guidata(hMainFigure,guihandles);
    
    adMain = getappdata(mainGuiWindow);
    scriptDir = adMain.control.dirs.lastScript;
    
    % Fill directory popupmenu
    set(directoryPopupmenu,'String',getDirectoryList(scriptDir));
    
    % Fill files listbox
    set(hFilesListbox,'String',getFiles(scriptDir));
    
    % Set font size depending on OS (13 pt seems a bit huge with linux)
    if isunix && ~ismac
        set(textdisplay,'FontSize',11);
    end
    
    % Add keypress function to every element that can have one...
    handles = findall(...
        allchild(hMainFigure),'style','pushbutton',...
        '-or','style','togglebutton',...
        '-or','style','edit',...
        '-or','style','listbox',...
        '-or','style','checkbox',...
        '-or','style','slider',...
        '-or','style','popupmenu');
    for k=1:length(handles)
        set(handles(k),'KeyPressFcn',@keypress_Callback);
    end
    
    % Make the GUI visible.
    set(hMainFigure,'Visible','on');
    trEPRmsg('Scripts for CMD window opened.','debug');

    if (nargout == 1)
        varargout{1} = hMainFigure;
    end
catch exception
    trEPRexceptionHandling(exception);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function popupmenu_Callback(source,~,action)
    try
        switch lower(action)
            case 'dir'
                directories = cellstr(get(source,'String'));
                directoryIndex = get(source,'Value');
                
                path = cellfun(@(x)sprintf('%s%s',filesep,x),...
                    flipud(directories(directoryIndex:end)),...
                    'UniformOutput',false);
                scriptDir = [path{:}];
                set(directoryPopupmenu,...
                    'String',getDirectoryList(scriptDir),...
                    'Value',1);
                set(hFilesListbox,'String',getFiles(scriptDir));
            otherwise
                trEPRoptionUnknown(action);
                return;
        end
    catch exception
        trEPRexceptionHandling(exception)
    end
end

function listbox_Callback(source,~,action)
    try
        if isempty(action)
            return;
        end

        values = cellstr(get(source,'String'));
        if isempty(get(source,'Value'))
            return;
        end
        value = values{get(source,'Value')};

        if strcmpi(value,'..')
            scriptDir = scriptDir(1:max(strfind(scriptDir,filesep)-1));
        elseif isdir(fullfile(scriptDir,value))
            scriptDir = fullfile(scriptDir,value);
        elseif strcmpi(value(end-2:end),'cmd')
            % Load text file
            scriptFileContent = textFileRead(fullfile(scriptDir,value));
            set(textdisplay,'String',scriptFileContent);
            return;
        end
        
        set(directoryPopupmenu,...
            'String',getDirectoryList(scriptDir),...
            'Value',1);
        set(hFilesListbox,...
            'String',getFiles(scriptDir),...
            'Value',1);
        set(textdisplay,'String','');
        
    catch exception
        trEPRexceptionHandling(exception);
    end
end

function pushbutton_Callback(~,~,action)
    try
        if isempty(action)
            return;
        end
        switch action
            case ''
        end
    catch exception
        trEPRexceptionHandling(exception);
    end
end

function keypress_Callback(~,evt)
    try
        if isempty(evt.Character) && isempty(evt.Key)
            % In case "Character" is the empty string, i.e. only modifier key
            % was pressed...
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
        end
        switch evt.Key
            case 'escape'
                closeGUI();
                return;
        end
    catch exception
        trEPRexceptionHandling(exception);
    end
end

function closeGUI(~,~)
    try
        delete(hMainFigure);
        trEPRmsg('Scripts for CMD window closed.','debug');
    catch exception
        trEPRexceptionHandling(exception);
    end
end

    function directories = getDirectoryList(directory)
        directories = fliplr(regexp(directory(2:end),filesep,'split'));
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Utility functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function filesList = getFiles(baseDir)

filesList = cell(0);

files = dir(fullfile(baseDir,'*'));
for file = 1:length(files)
    if (files(file).isdir && ~strcmp(files(file).name,'.')) || ...
            (length(files(file).name)>4 && ...
            strcmpi(files(file).name(end-2:end),'cmd'))
        filesList{end+1,1} = files(file).name; %#ok<AGROW>
    end
end

end
