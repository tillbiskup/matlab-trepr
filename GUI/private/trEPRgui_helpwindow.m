function varargout = trEPRgui_helpwindow(varargin)
% TREPRGUI_HELPWINDOW Brief description of GUI.
%          Comments displayed at the command line in response 
%          to the help command. 

% (c) 2011, Till Biskup
% 2011-09-02

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Make GUI effectively a singleton
singleton = findobj('Tag','trEPRgui_helpwindow');
if (singleton)
    figure(singleton);
    return;
end

%  Construct the components
hMainFigure = figure('Tag','trEPRgui_helpwindow',...
    'Visible','off',...
    'Name','trEPR GUI : ACC : Help Window',...
    'Units','Pixels',...
    'Position',[110,200,450,450],...
    'Resize','off',...
    'KeyPressFcn',@keypress_Callback,...
    'NumberTitle','off', ...
    'Menu','none','Toolbar','none');

defaultBackground = get(hMainFigure,'Color');
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
    'Position',[10 guiSize(2)-35 guiSize(1)-20 20],...
    'String','How to Use the trEPR GUI?'...
    );
uicontrol('Tag','helptopic_text',...
    'Style','text',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Left',...
    'Units','Pixels',...
    'Position',[10 guiSize(2)-70 100 20],...
    'String','Choose topic'...
    );
hpm = uicontrol('Tag','helptopic_popupmenu',...
    'Style','popupmenu',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'pos',[120 guiSize(2)-70 guiSize(1)-130 20],...
    'String',sprintf('%s%s',...
    'Welcome|New features|Key bindings|',...
    'Load panel|Datasets panel|Slider panel|',...
    'Measure panel|Display panel|Processing panel|',...
    'Analysis panel|Help panel'),...
    'KeyPressFcn',@keypress_Callback,...
    'Callback',@helptext_popupmenu_Callback...
    );

% Create the message window
textdisplay = uicontrol('Tag','status_text',...
    'Style','edit',...
    'Parent',hMainFigure,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'Position',[10 50 guiSize(1)-20 guiSize(2)-135],...
    'Enable','inactive',...
    'Max',2,'Min',0,...
    'String','');

uicontrol('Tag','close_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Close',...
    'TooltipString','Close ACC GUI Help window',...
    'pos',[guiSize(1)-70 10 60 30],...
    'Enable','on',...
    'Callback',{@delete,hMainFigure}...
    );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try
    % Store handles in guidata
    guidata(hMainFigure,guihandles);
    
    % Make the GUI visible.
    set(hMainFigure,'Visible','on');
    
    guidata(hMainFigure,guihandles);
    if (nargout == 1)
        varargout{1} = hMainFigure;
    end
    
    % Try to show the help topic related to the currently active panel
    % Get gui handles of main figure
    % Get guihandles of main GUI window
    mainWindow = guiGetWindowHandle;
    mgh = guihandles(mainWindow);
    if get(get(mgh.mainButtonGroup,'SelectedObject'),'Tag')
        helpTopicOffset = 3;
        switch get(get(mgh.mainButtonGroup,'SelectedObject'),'Tag')
            case 'tbLoad'
                helpText = 'Load panel';
                set(hpm,'Value',helpTopicOffset+1);
            case 'tbDatasets'
                helpText = 'Datasets panel';
                set(hpm,'Value',helpTopicOffset+2);
            case 'tbSlider'
                helpText = 'Slider panel';
                set(hpm,'Value',helpTopicOffset+3);
            case 'tbMeasure'
                helpText = 'Measure panel';
                set(hpm,'Value',helpTopicOffset+4);
            case 'tbDisplay'
                helpText = 'Display panel';
                set(hpm,'Value',helpTopicOffset+5);
            case 'tbProcessing'
                helpText = 'Processing panel';
                set(hpm,'Value',helpTopicOffset+6);
            case 'tbAnalysis'
                helpText = 'Analysis panel';
                set(hpm,'Value',helpTopicOffset+7);
            case 'tbHelp'
                helpText = 'Help panel';
                set(hpm,'Value',helpTopicOffset+8);
            otherwise
                % That shall never happen
                add2status('trEPRgui_helpwindow(): Unknown panel');
        end
    else
        helpText = 'Welcome';
    end
    helptext_selector(helpText);
catch exception
    try
        msgStr = ['An exception occurred. '...
            'The bug reporter should have been opened'];
        add2status(msgStr);
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function helptext_popupmenu_Callback(source,~)
    try
        % Get handles of main window
        gh = guihandles(hMainFigure);
        
        helpTexts = cellstr(get(source,'String'));
        helpText = helpTexts{get(source,'Value')};
        
        helptext_selector(helpText);
    catch exception
        try
            msgStr = ['An exception occurred. '...
                'The bug reporter should have been opened'];
            add2status(msgStr);
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
        if ~isempty(evt.Modifier)
            if (strcmpi(evt.Modifier{1},'command')) || ...
                    (strcmpi(evt.Modifier{1},'control'))
                switch evt.Key
                    case 'w'
                        delete(hMainFigure);
                        return;
                end
            end
        end
    catch exception
        try
            msgStr = ['An exception occurred. '...
                'The bug reporter should have been opened'];
            add2status(msgStr);
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

function helptext_selector(helpText)
    try
        switch helpText
            case 'Welcome'
                % Read text from file and display it
                helpTextFile = fullfile(...
                    trEPRtoolboxdir,'GUI','private','helptexts','main','welcome.txt');
                helpText = textFileRead(helpTextFile);
                % Workaround: Get rid of the second paragraph saying that one
                % sees this text only until pressing one of the panel switch
                % buttons.
                helpText(3:4) = [];
                set(textdisplay,'String',helpText);
            case 'New features'
                % Read text from file and display it
                helpTextFile = fullfile(...
                    trEPRtoolboxdir,'GUI','private','helptexts','main','newfeatures.txt');
                helpText = textFileRead(helpTextFile);
                set(textdisplay,'String',helpText);
            case 'Key bindings'
                % Read text from file and display it
                helpTextFile = fullfile(...
                    trEPRtoolboxdir,'GUI','private','helptexts','main','keybindings.txt');
                helpText = textFileRead(helpTextFile);
                set(textdisplay,'String',helpText);
            case 'Load panel'
                % Read text from file and display it
                helpTextFile = fullfile(...
                    trEPRtoolboxdir,'GUI','private','helptexts','main','load_panel.txt');
                helpText = textFileRead(helpTextFile);
                set(textdisplay,'String',helpText);
            case 'Datasets panel'
                % Read text from file and display it
                helpTextFile = fullfile(...
                    trEPRtoolboxdir,'GUI','private','helptexts','main','datasets_panel.txt');
                helpText = textFileRead(helpTextFile);
                set(textdisplay,'String',helpText);
            case 'Slider panel'
                % Read text from file and display it
                helpTextFile = fullfile(...
                    trEPRtoolboxdir,'GUI','private','helptexts','main','slider_panel.txt');
                helpText = textFileRead(helpTextFile);
                set(textdisplay,'String',helpText);
            case 'Measure panel'
                % Read text from file and display it
                helpTextFile = fullfile(...
                    trEPRtoolboxdir,'GUI','private','helptexts','main','measure_panel.txt');
                helpText = textFileRead(helpTextFile);
                set(textdisplay,'String',helpText);
            case 'Display panel'
                % Read text from file and display it
                helpTextFile = fullfile(...
                    trEPRtoolboxdir,'GUI','private','helptexts','main','display_panel.txt');
                helpText = textFileRead(helpTextFile);
                set(textdisplay,'String',helpText);
            case 'Processing panel'
                % Read text from file and display it
                helpTextFile = fullfile(...
                    trEPRtoolboxdir,'GUI','private','helptexts','main','processing_panel.txt');
                helpText = textFileRead(helpTextFile);
                set(textdisplay,'String',helpText);
            case 'Analysis panel'
                % Read text from file and display it
                helpTextFile = fullfile(...
                    trEPRtoolboxdir,'GUI','private','helptexts','main','analysis_panel.txt');
                helpText = textFileRead(helpTextFile);
                set(textdisplay,'String',helpText);
            case 'Help panel'
                % Read text from file and display it
                helpTextFile = fullfile(...
                    trEPRtoolboxdir,'GUI','private','helptexts','main','help_panel.txt');
                helpText = textFileRead(helpTextFile);
                set(textdisplay,'String',helpText);
            otherwise
                % That shall never happen
                add2status('trEPRgui_helpwindow(): Unknown helptext');
                set(textdisplay,'String','');
        end
    catch exception
        try
            msgStr = ['An exception occurred. '...
                'The bug reporter should have been opened'];
            add2status(msgStr);
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

end
