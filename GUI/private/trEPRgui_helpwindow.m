function varargout = trEPRgui_helpwindow(varargin)
% TREPRGUI_HELPWINDOW Help window for the trEPR GUI.
%
% This window provides the user with "online" help included within the GUI.
% Besides that, it gives access to all the other sources of additional
% help, such as the Matlab Help Browser and the toolbox website.

% Copyright (c) 2011-14, Till Biskup
% 2014-07-26

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Make GUI effectively a singleton
singleton = trEPRguiGetWindowHandle(mfilename);
if (singleton)
    figure(singleton);
    return;
end

guiPosition = [160,240,850,450];
defaultBackground = [0.90 0.90 0.90];

% Get position of main window to position help window relative to it
mainGUIHandle = trEPRguiGetWindowHandle();
if ishandle(mainGUIHandle)
    mainGUIPosition = get(mainGUIHandle,'Position');
    guiPosition = [mainGUIPosition(1)+40,mainGUIPosition(2)+150,...
        guiPosition(3), guiPosition(4)];
end

% Construct the components
hMainFigure = figure('Tag',mfilename,...
    'Visible','off',...
    'Name','trEPR GUI : Help Window',...
    'Color',defaultBackground,...
    'Units','Pixels',...
    'Position',guiPosition,...
    'Resize','off',...
    'KeyPressFcn',@keypress_Callback,...
    'NumberTitle','off', ...
    'Menu','none','Toolbar','none');

guiSize = get(hMainFigure,'Position');
guiSize = guiSize([3,4]);

% Create button group.
hButtonGroup = uibuttongroup('Tag','buttonGroup',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'BorderType','none',...
    'Units','Pixels',...
    'Position', [10 guiSize(2)-35 200 25],...
    'Visible','on',...
    'SelectionChangeFcn',{@buttongroup_Callback,'topics'}...
    );
hGeneralButton = uicontrol('Tag','bg_general_pushbutton',...
    'Parent',hButtonGroup,...
    'Style','togglebutton',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','General',...
    'TooltipString',...
    'General help topics for using the trEPR GUI',...
    'Position',[0 0 95 25],...
    'HandleVisibility','off',...
    'Value',1 ...
    );
hPanelsButton = uicontrol('Tag','bg_panels_pushbutton',...
    'Parent',hButtonGroup,...
    'Style','togglebutton',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Panels',...
    'TooltipString',...
    'Specific help for the different panels of the trEPR GUI',...
    'Position',[95 0 95 25],...
    'HandleVisibility','off',...
    'Value',0 ...
    );

uicontrol('Tag','heading_text',...
    'Style','text',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',14,...
    'HorizontalAlignment','Left',...
    'FontWeight','bold',...
    'Units','Pixels',...
    'Position',[210 guiSize(2)-35 guiSize(1)-220 20],...
    'String','How to Use the trEPR GUI?'...
    );
p1 = uipanel('Tag','topic_panel',...
    'parent',hMainFigure,...
    'Title','',...
    'FontUnit','Pixel','Fontsize',12,...
    'BorderType','none',...
    'BackgroundColor',defaultBackground,...
    'Visible','on',...
    'Units','pixels',...
    'Position',[10 10 190 guiSize(2)-50] ...
    );
% Create listbox with help topics
hGeneralListbox = uicontrol('Tag','helptopic_listbox',...
    'Style','listbox',...
    'Parent',p1,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',14,...
    'Units','Pixels',...
    'Position',[0 0 190 guiSize(2)-50],...
    'String','',...
    'Callback',{@listbox_Callback,'general'}...
    );

p2 = uipanel('Tag','commandlist_panel',...
    'parent',hMainFigure,...
    'Title','',...
    'FontUnit','Pixel','Fontsize',12,...
    'BorderType','none',...
    'BackgroundColor',defaultBackground,...
    'Visible','off',...
    'Units','pixels',...
    'Position',[10 10 190 guiSize(2)-50] ...
    );
% Create listbox with help topics
hPanelsListbox = uicontrol('Tag','commands_listbox',...
    'Style','listbox',...
    'Parent',p2,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',14,...
    'Units','Pixels',...
    'Position',[0 0 190 guiSize(2)-50],...
    'String','',...
    'Callback',{@listbox_Callback,'panels'}...
    );

% Create the message window
% Use a Java Browser object to display HTML
jObject = com.mathworks.mlwidgets.html.HTMLBrowserPanel;
[browser,container] = javacomponent(jObject, [], hMainFigure);
set(container,...
    'Units','Pixels',...
    'Position',[210 50 guiSize(1)-220 guiSize(2)-91]...
    );

uicontrol('Tag','back_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','<html>&larr;</html>',...
    'TooltipString','Go to previous page in browser history',...
    'pos',[210 10 40 30],...
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
    'pos',[250 10 40 30],...
    'Enable','on',...
    'Callback',{@pushbutton_Callback,'browserforward'} ...
    );

uicontrol('Tag','help_panel_about_pushbutton',...
    'Style','pushbutton',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[330 10 70 30],...
    'TooltipString','Show general info about the trEPR toolbox and GUI',...
    'String','About',...
    'Callback',{@(~,~)trEPRgui_aboutwindow}...
    );
uicontrol('Tag','help_panel_website_pushbutton',...
    'Style','pushbutton',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[400 10 70 30],...
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
    'Callback',{@closeGUI}...
    );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try
    % Store handles in guidata
    guidata(hMainFigure,guihandles);

    % Set help topics
    generalTopics = {...
        'trEPR Toolbox','toolbox'; ...
        'Welcome','welcome'; ...
        'GUI in 2 minutes','shortintro'; ...
        'Why a GUI?','whygui'; ...
        'Key concepts','keyconcepts'; ...
        'Info file','infofile'; ...
        'New features','newfeatures'; ...
        'Wishlist','wishlist'; ...
        'Key bindings','keybindings'; ...
        'Known bugs','knownbugs'; ...
        'Report a bug','bugreport'; ...
        'Other resources','resources'; ...
        'Disclaimer','disclaimer'; ...
        'Privacy','privacy'; ...
        'License','license'; ...
        };
    set(hGeneralListbox,'String',generalTopics(:,1));
    
    panelTopics = {...
        'Load panel','load_panel'; ...
        'Datasets panel','datasets_panel'; ...
        'Slider panel','slider_panel'; ...
        'Measure panel','measure_panel'; ...
        'Display panel','display_panel'; ...
        'Processing panel','processing_panel'; ...
        'Analysis panel','analysis_panel'; ...
        'Internal panel','internal_panel'; ...
        'Configure panel','configure_panel'; ...
        };
    set(hPanelsListbox,'String',panelTopics(:,1));
    
    % Try to show the help topic related to the currently active panel
    % Get gui handles of main figure
    % Get guihandles of main GUI window
    mainWindow = trEPRguiGetWindowHandle;
    mgh = guihandles(mainWindow);
    if get(get(mgh.mainButtonGroup,'SelectedObject'),'Tag')
        set(hGeneralButton,'Value',0);
        set(hPanelsButton,'Value',1);
        set(hButtonGroup,'SelectedObject',hPanelsButton);
        buttongroup_Callback(hButtonGroup,'','topics');
        selectedPanel = get(get(mgh.mainButtonGroup,'SelectedObject'),'Tag');
        set(hPanelsListbox,'Value',...
            find(strcmp([selectedPanel(3:end) ' panel'],panelTopics(:,1))));
        listbox_Callback(hPanelsListbox,'','panels');
    else
        helpText = 'Welcome';
        helptext_selector(helpText);
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
    trEPRmsg('trEPR GUI help window opened.','debug');
    
    guidata(hMainFigure,guihandles);
    if (nargout == 1)
        varargout{1} = hMainFigure;
    end
catch exception
    trEPRexceptionHandling(exception);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function listbox_Callback(source,~,action)
    try
        if isempty(action)
            return;
        end
        
        values = cellstr(get(source,'String'));
        value = values{get(source,'Value')};
        
        switch action
            case 'general'
                helpTextFile = fullfile(trEPRinfo('dir'),...
                    'GUI','private','helptexts','main',...
                    [generalTopics{strcmp(value,generalTopics(:,1)),2} '.html']);
                if exist(helpTextFile,'file')
                    % Read text from file and display it
                    browser.setCurrentLocation(helpTextFile);
                else
                    % That shall never happen
                    trEPRmsg('guiHelpPanel(): Unknown helptext','info');
                    htmlText = ['<html>' ...
                        '<h1>' value '</h1>'...
                        '<p>Sorry, no help available (yet) for this topic.</p>'...
                        '</html>'];
                    browser.setHtmlText(htmlText);
                end
            case 'panels'
                helpTextFile = fullfile(trEPRinfo('dir'),...
                    'GUI','private','helptexts','main',...
                    [panelTopics{strcmp(value,panelTopics(:,1)),2} '.html']);
                if exist(helpTextFile,'file')
                    % Read text from file and display it
                    browser.setCurrentLocation(helpTextFile);
                else
                    % That shall never happen
                    trEPRmsg('guiHelpPanel(): Unknown helptext','info');
                    htmlText = ['<html>' ...
                        '<h1>' value '</h1>'...
                        '<p>Sorry, no help available (yet) for this command.</p>'...
                        '</html>'];
                    browser.setHtmlText(htmlText);
                end
            otherwise
                trEPRoptionUnknown(action);
        end
    catch exception
        trEPRexceptionHandling(exception);
    end
end

function buttongroup_Callback(source,~,action)
    try
        if isempty(action)
            return;
        end
        
        switch action
            case 'topics'
                panels = [p1, p2];
                val = get(get(source,'SelectedObject'),'String');
                switch lower(val)
                    case 'general'
                        set(panels,'Visible','off');
                        set(p1,'Visible','on');
                        listbox_Callback(hGeneralListbox,'','general');
                    case 'panels'
                        set(panels,'Visible','off');
                        set(p2,'Visible','on');
                        listbox_Callback(hPanelsListbox,'','panels');
                end
        end
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
            case 'browserback'
                browser.executeScript('javascript:history.back()');
            case 'browserforward'
                browser.executeScript('javascript:history.forward()');
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
        trEPRmsg('trEPR GUI help window closed.','debug');
    catch exception
        trEPRexceptionHandling(exception);
    end
end

function startBrowser(~,~,url)
    webbrowser(url);
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
            case 'Internal panel'
                % Read text from file and display it
                helpTextFile = fullfile(trEPRinfo('dir'),'GUI',...
                    'private','helptexts','main','internal_panel.html');
                browser.setCurrentLocation(helpTextFile);
            case 'Configure panel'
                % Read text from file and display it
                helpTextFile = fullfile(trEPRinfo('dir'),'GUI',...
                    'private','helptexts','main','configure_panel.html');
                browser.setCurrentLocation(helpTextFile);
            otherwise
                trEPRoptionUnknown(helpText,'helptext');
                htmlText = ['<html>' ...
                    '<h1>Sorry, help could not be found</h1>'...
                    '<p>The help text you requested could not be found.</p>'...
                    '</html>'];
                browser.setHtmlText(htmlText);
        end
    catch exception
        trEPRexceptionHandling(exception);
    end
end

end
