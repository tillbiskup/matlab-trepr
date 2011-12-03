function handle = guiHelpPanel(parentHandle,position)
% GUIHELPPANEL Add a panel displaying some help elements to a gui
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

toolboxWebURL = 'http://www.till-biskup.de/de/software/matlab/trepr/';

handle = uipanel('Tag','help_panel',...
    'parent',parentHandle,...
    'Title','Help',...
    'FontUnit','Pixel','Fontsize',12,...
    'FontWeight','bold',...
    'BackgroundColor',defaultBackground,...
    'Visible','off',...
    'Units','pixels','Position',position);

% Create the "Help" panel
handle_size = get(handle,'Position');
uicontrol('Tag','help_panel_description',...
    'Style','text',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'FontAngle','oblique',...
    'Position',[10 handle_size(4)-60 handle_size(3)-20 30],...
    'String',{'Some basic help for working with the trEPR GUI and access to further information'}...
    );

handle_p1 = uipanel('Tag','help_panel_launcher_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-130 handle_size(3)-20 60],...
    'Title','Additional windows'...
    );
uicontrol('Tag','help_panel_about_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 floor((handle_size(3)-40)/3) 30],...
    'TooltipString','Show general info about the trEPR toolbox and GUI',...
    'String','About',...
    'Callback',{@(~,~)trEPRgui_aboutwindow}...
    );
uicontrol('Tag','help_panel_launcher2_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[floor((handle_size(3)-40)/3)+10 10 floor((handle_size(3)-40)/3) 30],...
    'TooltipString','Show trEPR toolbox manual (in MATLAB(TM) helpbrowser)',...
    'String','Manual',...
    'Callback',{@(~,~)web([trEPRinfo('dir') '/doc/index.html'],'-helpbrowser')}...
    );
uicontrol('Tag','help_panel_website_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[(floor((handle_size(3)-40)/3)*2)+10 10 floor((handle_size(3)-40)/3) 30],...
    'TooltipString',sprintf('%s\n%s',...
    'Open website of the trEPR toolbox (in system webbrowser)',...
    '(Warning: Apparently that does not work with Windows.)'),...
    'String','Website',...
    'Callback',{@(~,~)web(toolboxWebURL,'-browser')}...
    );

handle_p2 = uipanel('Tag','help_panel_helptext_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-190 handle_size(3)-20 50],...
    'Title','Help texts'...
    );
uicontrol('Tag','load_panel_helptext_popupmenu',...
    'Style','popupmenu',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 handle_size(3)-40 20],...
    'String',{'Welcome','Why this GUI?','Key concepts','Key bindings','Known bugs','Report a bug','Other resources','Disclaimer'},...
    'TooltipString','Choose help topic',...
    'Callback', {@helptext_popupmenu_Callback}...    
    );

uicontrol('Tag','helptext_display_title',...
    'Style','text',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Left',...
    'FontWeight','bold',...
    'Position',[10 handle_size(4)-220 handle_size(3)-20 20],...
    'Enable','inactive',...
    'Max',2,'Min',0,...
    'String','Welcome');

hPanelText = uicontrol('Tag','helptext_display',...
    'Style','edit',...
    'Parent',handle,...
    'BackgroundColor',[1 1 1],...
    'Units','Pixels',...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Left',...
    'Position',[10 10 handle_size(3)-20 handle_size(4)-230],...
    'Enable','inactive',...
    'Max',2,'Min',0,...
    'String','');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try
    % Get appdata of main window
    mainWindow = guiGetWindowHandle;
    ad = getappdata(mainWindow);
    
    % Get guihandles of main window
    gh = guihandles(mainWindow);
    
    % Read text for welcome message from file and display it
    helpTextFile = fullfile(trEPRinfo('dir'),...
        'GUI','private','helptexts','main','welcome.txt');
    helpText = textFileRead(helpTextFile);
    % Workaround: Get rid of the second paragraph saying that one
    % sees this text only until pressing one of the panel switch
    % buttons.
    helpText(3:4) = [];
    set(hPanelText,'String',helpText);
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
        gh = guihandles(mainWindow);
        
        helpTexts = cellstr(get(source,'String'));
        helpText = helpTexts{get(source,'Value')};
        
        set(gh.helptext_display_title,'String',helpText);
        
        switch helpText
            case 'Welcome'
                % Read text for welcome message from file and display it
                helpTextFile = fullfile(trEPRinfo('dir'),...
                    'GUI','private','helptexts','main','welcome.txt');
                helpText = textFileRead(helpTextFile);
                % Workaround: Get rid of the second paragraph saying that one
                % sees this text only until pressing one of the panel switch
                % buttons.
                helpText(3:4) = [];
                set(hPanelText,'String',helpText);
            case 'Why this GUI?'
                % Read text for welcome message from file and display it
                helpTextFile = fullfile(trEPRinfo('dir'),...
                    'GUI','private','helptexts','main','whygui.txt');
                helpText = textFileRead(helpTextFile);
                set(hPanelText,'String',helpText);
            case 'Key concepts'
                % Read text for welcome message from file and display it
                helpTextFile = fullfile(trEPRinfo('dir'),...
                    'GUI','private','helptexts','main','keyconcepts.txt');
                helpText = textFileRead(helpTextFile);
                set(hPanelText,'String',helpText);
            case 'Key bindings'
                % Read text for welcome message from file and display it
                helpTextFile = fullfile(trEPRinfo('dir'),...
                    'GUI','private','helptexts','main','keybindings.txt');
                helpText = textFileRead(helpTextFile);
                set(hPanelText,'String',helpText);
            case 'Known bugs'
                % Read text for welcome message from file and display it
                helpTextFile = fullfile(trEPRinfo('dir'),...
                    'GUI','private','helptexts','main','knownbugs.txt');
                helpText = textFileRead(helpTextFile);
                set(hPanelText,'String',helpText);
            case 'Report a bug'
                % Read text for welcome message from file and display it
                helpTextFile = fullfile(trEPRinfo('dir'),...
                    'GUI','private','helptexts','main','bugreport.txt');
                helpText = textFileRead(helpTextFile);
                set(hPanelText,'String',helpText);
            case 'Disclaimer'
                % Read text for welcome message from file and display it
                helpTextFile = fullfile(trEPRinfo('dir'),...
                    'GUI','private','helptexts','main','disclaimer.txt');
                helpText = textFileRead(helpTextFile);
                set(hPanelText,'String',helpText);
            case 'Other resources'
                % Read text for welcome message from file and display it
                helpTextFile = fullfile(trEPRinfo('dir'),...
                    'GUI','private','helptexts','main','resources.txt');
                helpText = textFileRead(helpTextFile);
                set(hPanelText,'String',helpText);
            otherwise
                % That shall never happen
                add2status('guiHelpPanel(): Unknown helptext');
                set(hPanelText,'String','');
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

end