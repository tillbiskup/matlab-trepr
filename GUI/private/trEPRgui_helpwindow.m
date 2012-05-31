function varargout = trEPRgui_helpwindow(varargin)
% TREPRGUI_HELPWINDOW Help window for the trEPR GUI.
%
% This window provides the user with "online" help included into the GUI.
% Besides that, it gives access to all the other sources of additional
% help, such as the Matlab Help Browser and the toolbox website.

% (c) 2011-12, Till Biskup
% 2012-05-31

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Make GUI effectively a singleton
singleton = trEPRguiGetWindowHandle(mfilename);
if (singleton)
    figure(singleton);
    return;
end

% Get position of main window to position help window relative to it
hMainGUI = trEPRguiGetWindowHandle();
if ishandle(hMainGUI)
    mainGUIPosition = get(hMainGUI,'Position');
    position = [mainGUIPosition(1)+95,mainGUIPosition(2)+175,450,430];
else
    position = [115,235,450,430];
end

% Construct the components
hMainFigure = figure('Tag',mfilename,...
    'Visible','off',...
    'Name','trEPR GUI : Help Window',...
    'Units','Pixels',...
    'Position',position,...
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
    'String',[...
    '--- General Topics ---|',...
    'Welcome|Why a GUI?|Key concepts|New features|'...
    'Key bindings|Known bugs|Report a bug|Other resources|Disclaimer|',...
    '--- Help for Panels ---|',...
    'Load panel|Datasets panel|Slider panel|',...
    'Measure panel|Display panel|Processing panel|',...
    'Analysis panel|Configure panel'],...
    'Value',2,...
    'KeyPressFcn',@keypress_Callback,...
    'Callback',@helptext_popupmenu_Callback...
    );

% Create the message window
% NEW: Use a Java Browser object to display HTML
jObject = com.mathworks.mlwidgets.html.HTMLBrowserPanel;
[browser,container] = javacomponent(jObject, [], hMainFigure);
set(container,...
    'Units','Pixels',...
    'Position',[10 50 guiSize(1)-20 guiSize(2)-135]...
    );

uicontrol('Tag','back_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','<html>&larr;</html>',...
    'TooltipString','Go to previous page in browser history',...
    'pos',[10 10 40 30],...
    'Enable','on',...
    'Callback',{@pushbutton_Callback,'browserback'} ...
    );
uicontrol('Tag','fwd_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','<html>&rarr;</html>',...
    'TooltipString','Go to next page in browser history',...
    'pos',[50 10 40 30],...
    'Enable','on',...
    'Callback',{@pushbutton_Callback,'browserforward'} ...
    );

uicontrol('Tag','help_panel_about_pushbutton',...
    'Style','pushbutton',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[130 10 70 30],...
    'TooltipString','Show general info about the trEPR toolbox and GUI',...
    'String','About',...
    'Callback',{@(~,~)trEPRgui_aboutwindow}...
    );
uicontrol('Tag','help_panel_launcher2_pushbutton',...
    'Style','pushbutton',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[200 10 70 30],...
    'TooltipString','Show trEPR toolbox manual (in MATLAB(TM) helpbrowser)',...
    'String','Manual',...
    'Callback',{@(~,~)web([trEPRinfo('dir') '/doc/index.html'],'-helpbrowser')}...
    );
uicontrol('Tag','help_panel_website_pushbutton',...
    'Style','pushbutton',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[270 10 70 30],...
    'TooltipString',sprintf('%s\n%s',...
    'Open website of the trEPR toolbox (in system webbrowser)',...
    '(Warning: Apparently that does not work with Windows.)'),...
    'String','Website',...
    'Callback',{@startBrowser,trEPRinfo('url')}...
    );

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
    mainWindow = trEPRguiGetWindowHandle;
    mgh = guihandles(mainWindow);
    if get(get(mgh.mainButtonGroup,'SelectedObject'),'Tag')
        helpTopicOffset = 11;
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
            case 'tbConfigure'
                helpText = 'Configure panel';
                set(hpm,'Value',helpTopicOffset+8);
            otherwise
                % That shall never happen
                trEPRadd2status('trEPRgui_helpwindow(): Unknown panel');
        end
    else
        helpText = 'Welcome';
    end
    helptext_selector(helpText);
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function helptext_popupmenu_Callback(source,~)
    try
        helpTexts = cellstr(get(source,'String'));
        helpText = helpTexts{get(source,'Value')};

        if ~strncmp(helpText,'---',3)
            helptext_selector(helpText);
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
        switch action
            case 'browserback'
                browser.executeScript('javascript:history.back()');
            case 'browserforward'
                browser.executeScript('javascript:history.forward()');
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
            TAgui_bugreportwindow(exception);
        catch exception3
            % If even displaying the bug report window fails...
            exception = addCause(exception3, exception);
            throw(exception);
        end
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
                        delete(hMainFigure);
                        return;
                end
            end
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

function startBrowser(~,~,url)
    if any(strfind(platform,'Windows'))
        dos(['start ' url]);
    else
        web(url,'-browser');
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
                helpTextFile = fullfile(trEPRinfo('dir'),'GUI',...
                    'private','helptexts','main','welcome.html');
                browser.setCurrentLocation(helpTextFile);
            case 'Key concepts'
                % Read text from file and display it
                helpTextFile = fullfile(trEPRinfo('dir'),'GUI',...
                    'private','helptexts','main','keyconcepts.html');
                browser.setCurrentLocation(helpTextFile);
            case 'Why a GUI?'
                % Read text from file and display it
                helpTextFile = fullfile(trEPRinfo('dir'),'GUI',...
                    'private','helptexts','main','whygui.html');
                browser.setCurrentLocation(helpTextFile);
            case 'New features'
                % Read text from file and display it
                helpTextFile = fullfile(trEPRinfo('dir'),'GUI',...
                    'private','helptexts','main','newfeatures.html');
                browser.setCurrentLocation(helpTextFile);
            case 'Key bindings'
                % Read text from file and display it
                helpTextFile = fullfile(trEPRinfo('dir'),'GUI',...
                    'private','helptexts','main','keybindings.html');
                browser.setCurrentLocation(helpTextFile);
            case 'Known bugs'
                % Read text from file and display it
                helpTextFile = fullfile(trEPRinfo('dir'),'GUI',...
                    'private','helptexts','main','knownbugs.html');
                browser.setCurrentLocation(helpTextFile);
            case 'Disclaimer'
                % Read text from file and display it
                helpTextFile = fullfile(trEPRinfo('dir'),'GUI',...
                    'private','helptexts','main','disclaimer.html');
                browser.setCurrentLocation(helpTextFile);
            case 'Report a bug'
                % Read text from file and display it
                helpTextFile = fullfile(trEPRinfo('dir'),'GUI',...
                    'private','helptexts','main','bugreport.html');
                browser.setCurrentLocation(helpTextFile);
            case 'Other resources'
                % Read text from file and display it
                helpTextFile = fullfile(trEPRinfo('dir'),'GUI',...
                    'private','helptexts','main','resources.html');
                browser.setCurrentLocation(helpTextFile);
            case 'Load panel'
                % Read text from file and display it
                helpTextFile = fullfile(trEPRinfo('dir'),'GUI',...
                    'private','helptexts','main','load_panel.html');
                browser.setCurrentLocation(helpTextFile);
            case 'Datasets panel'
                % Read text from file and display it
                helpTextFile = fullfile(trEPRinfo('dir'),'GUI',...
                    'private','helptexts','main','datasets_panel.html');
                browser.setCurrentLocation(helpTextFile);
            case 'Slider panel'
                % Read text from file and display it
                helpTextFile = fullfile(trEPRinfo('dir'),'GUI',...
                    'private','helptexts','main','slider_panel.html');
                browser.setCurrentLocation(helpTextFile);
            case 'Measure panel'
                % Read text from file and display it
                helpTextFile = fullfile(trEPRinfo('dir'),'GUI',...
                    'private','helptexts','main','measure_panel.html');
                browser.setCurrentLocation(helpTextFile);
            case 'Display panel'
                % Read text from file and display it
                helpTextFile = fullfile(trEPRinfo('dir'),'GUI',...
                    'private','helptexts','main','display_panel.html');
                browser.setCurrentLocation(helpTextFile);
            case 'Processing panel'
                % Read text from file and display it
                helpTextFile = fullfile(trEPRinfo('dir'),'GUI',...
                    'private','helptexts','main','processing_panel.html');
                browser.setCurrentLocation(helpTextFile);
            case 'Analysis panel'
                % Read text from file and display it
                helpTextFile = fullfile(trEPRinfo('dir'),'GUI',...
                    'private','helptexts','main','analysis_panel.html');
                browser.setCurrentLocation(helpTextFile);
            case 'Configure panel'
                % Read text from file and display it
                helpTextFile = fullfile(trEPRinfo('dir'),'GUI',...
                    'private','helptexts','main','configure_panel.html');
                browser.setCurrentLocation(helpTextFile);
            otherwise
                % That shall never happen
                trEPRadd2status('trEPRgui_helpwindow(): Unknown helptext');
                browser.setCurrentLocation('');
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

function helptext_selector2(helpText)
    try
        switch helpText
            case 'Welcome'
                % Read text from file and display it
                helpTextFile = fullfile(...
                    trEPRinfo('dir'),'GUI','private','helptexts','main','welcome.txt');
                helpText = textFileRead(helpTextFile);
                % Workaround: Get rid of the second paragraph saying that one
                % sees this text only until pressing one of the panel switch
                % buttons.
                helpText(3:4) = [];
                set(textdisplay,'String',helpText);
            case 'New features'
                % Read text from file and display it
                helpTextFile = fullfile(...
                    trEPRinfo('dir'),'GUI','private','helptexts','main','newfeatures.txt');
                helpText = textFileRead(helpTextFile);
                set(textdisplay,'String',helpText);
            case 'Key bindings'
                % Read text from file and display it
                helpTextFile = fullfile(...
                    trEPRinfo('dir'),'GUI','private','helptexts','main','keybindings.txt');
                helpText = textFileRead(helpTextFile);
                set(textdisplay,'String',helpText);
            case 'Why this GUI?'
                % Read text from file and display it
                helpTextFile = fullfile(...
                    trEPRinfo('dir'),'GUI','private','helptexts','main','whygui.txt');
                helpText = textFileRead(helpTextFile);
                set(textdisplay,'String',helpText);
            case 'Key concepts'
                % Read text from file and display it
                helpTextFile = fullfile(...
                    trEPRinfo('dir'),'GUI','private','helptexts','main','keyconcepts.txt');
                helpText = textFileRead(helpTextFile);
                set(textdisplay,'String',helpText);
            case 'Known bugs'
                % Read text from file and display it
                helpTextFile = fullfile(...
                    trEPRinfo('dir'),'GUI','private','helptexts','main','knownbugs.txt');
                helpText = textFileRead(helpTextFile);
                set(textdisplay,'String',helpText);
            case 'Report a bug' 
                % Read text from file and display it
                helpTextFile = fullfile(...
                    trEPRinfo('dir'),'GUI','private','helptexts','main','bugreport.txt');
                helpText = textFileRead(helpTextFile);
                set(textdisplay,'String',helpText);
            case 'Other resources'
                % Read text from file and display it
                helpTextFile = fullfile(...
                    trEPRinfo('dir'),'GUI','private','helptexts','main','resources.txt');
                helpText = textFileRead(helpTextFile);
                set(textdisplay,'String',helpText);
            case 'Disclaimer'
                % Read text from file and display it
                helpTextFile = fullfile(...
                    trEPRinfo('dir'),'GUI','private','helptexts','main','disclaimer.txt');
                helpText = textFileRead(helpTextFile);
                set(textdisplay,'String',helpText);
            case 'Load panel'
                % Read text from file and display it
                helpTextFile = fullfile(...
                    trEPRinfo('dir'),'GUI','private','helptexts','main','load_panel.txt');
                helpText = textFileRead(helpTextFile);
                set(textdisplay,'String',helpText);
            case 'Datasets panel'
                % Read text from file and display it
                helpTextFile = fullfile(...
                    trEPRinfo('dir'),'GUI','private','helptexts','main','datasets_panel.txt');
                helpText = textFileRead(helpTextFile);
                set(textdisplay,'String',helpText);
            case 'Slider panel'
                % Read text from file and display it
                helpTextFile = fullfile(...
                    trEPRinfo('dir'),'GUI','private','helptexts','main','slider_panel.txt');
                helpText = textFileRead(helpTextFile);
                set(textdisplay,'String',helpText);
            case 'Measure panel'
                % Read text from file and display it
                helpTextFile = fullfile(...
                    trEPRinfo('dir'),'GUI','private','helptexts','main','measure_panel.txt');
                helpText = textFileRead(helpTextFile);
                set(textdisplay,'String',helpText);
            case 'Display panel'
                % Read text from file and display it
                helpTextFile = fullfile(...
                    trEPRinfo('dir'),'GUI','private','helptexts','main','display_panel.txt');
                helpText = textFileRead(helpTextFile);
                set(textdisplay,'String',helpText);
            case 'Processing panel'
                % Read text from file and display it
                helpTextFile = fullfile(...
                    trEPRinfo('dir'),'GUI','private','helptexts','main','processing_panel.txt');
                helpText = textFileRead(helpTextFile);
                set(textdisplay,'String',helpText);
            case 'Analysis panel'
                % Read text from file and display it
                helpTextFile = fullfile(...
                    trEPRinfo('dir'),'GUI','private','helptexts','main','analysis_panel.txt');
                helpText = textFileRead(helpTextFile);
                set(textdisplay,'String',helpText);
            case 'Configure panel'
                % Read text from file and display it
                helpTextFile = fullfile(...
                    trEPRinfo('dir'),'GUI','private','helptexts','main','configure_panel.txt');
                helpText = textFileRead(helpTextFile);
                set(textdisplay,'String',helpText);
            otherwise
                % That shall never happen
                trEPRadd2status('trEPRgui_helpwindow(): Unknown helptext');
                set(textdisplay,'String','');
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

end
