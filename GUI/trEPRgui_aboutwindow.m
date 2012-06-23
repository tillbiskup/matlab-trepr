function varargout = trEPRgui_aboutwindow()
% TREPRGUI_ABOUTWINDOW Display basic information about the trEPR toolbox,
% including links to the toolbox homepage and a list of contributors.

% (c) 2011-12, Till Biskup
% 2012-06-23

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Make GUI effectively a singleton
singleton = findobj('Tag',mfilename);
if (singleton)
    varargout{1} = figure(singleton);
    return;
end

% Try to get main GUI position
mainGUIHandle = trEPRguiGetWindowHandle();
if ishandle(mainGUIHandle)
    mainGUIPosition = get(mainGUIHandle,'Position');
    guiPosition = [mainGUIPosition(1)+50,mainGUIPosition(2)+250,528,300];
else
    guiPosition = [70,290,528,300];
end

info = trEPRinfo;

title = 'trEPR Toolbox: About';
toolboxNameString = 'trEPR Toolbox';
versionString = ...
    sprintf('v.%s (%s)',info.version.Version,info.version.Date);
copyrightInfo = {...
    sprintf('(c) 2005-12, %s, <%s>',info.maintainer.name,info.maintainer.email)...
%     ''...
%     sprintf('%s',info.url)...
    };

%  Construct the components
hMainFigure = figure('Tag',mfilename,...
    'Visible','off',...
    'Name',title,...
    'Units','Pixels',...
    'Position',guiPosition,...
    'Resize','off',...
    'NumberTitle','off', ...
    'Menu','none','Toolbar','none',...
    'KeyPressFcn',@keypress_Callback,...
    'CloseRequestFcn',{@closeWindow}...
    );

defaultBackground = get(hMainFigure,'Color');

% Set icon (jLabel)
[path,~,~] = fileparts(mfilename('fullpath'));
icon = javax.swing.ImageIcon(fullfile(path,'trEPR-logo-128x128.png'));
jLabel = javax.swing.JLabel('');
jLabel.setIcon(icon);
bgcolor = num2cell(get(hMainFigure, 'Color'));
jLabel.setBackground(java.awt.Color(bgcolor{:}));
javacomponent(jLabel,[20 guiPosition(4)-128-20 128 128],hMainFigure);

% Set length of scrolling panel depending on the platform
if any(strfind(platform,'Linux'))
    scrollPanelHeight = guiPosition(4)+2300;
elseif any(strfind(platform,'Windows'))
    scrollPanelHeight = guiPosition(4)+2080;
else % In case we are on a Mac
    scrollPanelHeight = guiPosition(4)+2500;
end

hPanel = uipanel('Parent',hMainFigure,...
    'Title','',...
    'FontUnit','Pixel','Fontsize',12,...
    'Visible','on',...
    'Units','Pixels',...
    'Position',[168 140-scrollPanelHeight 350 scrollPanelHeight],...
    'BackgroundColor',defaultBackground,...
    'BorderType','none'...
    );

% Read text for welcome message from file and display it
contributorsMessageFile = fullfile(...
    trEPRinfo('dir'),'GUI','private','helptexts','main','contributors.html');
contributorsMessageText = textFileRead(contributorsMessageFile);
% Convert text into one single string
contributorsText = cellfun(@(x) [char(x) ' '],contributorsMessageText,...
    'UniformOutput',false);
contributorsText = [ contributorsText{:} ];

jTextLabel = javaObjectEDT('javax.swing.JLabel',contributorsText);
jTextLabel.setBackground(java.awt.Color(bgcolor{:}));
jTextLabel.setVerticalAlignment(jTextLabel.TOP);
javacomponent(jTextLabel,[1 0 349 scrollPanelHeight],hPanel);

uicontrol('style','text',...
    'Units','Pixels',...
    'Position',[168 140 350 165],...
    'BackgroundColor',defaultBackground...
    );

uicontrol('style','text',...
    'Units','Pixels',...
    'Position',[168 240 350 40],...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',32,...
    'String',toolboxNameString...
    );

uicontrol('style','text',...
    'Units','Pixels',...
    'Position',[168 215 350 20],...
    'BackgroundColor',defaultBackground,...
    'FontWeight','bold',...
    'FontUnit','Pixel','Fontsize',14,...
    'String',versionString...
    );

uicontrol('style','text',...
    'Units','Pixels',...
    'Position',[168 170 350 35],...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',13,...
    'String',copyrightInfo...
    );

jHomepage = com.mathworks.widgets.HyperlinkTextLabel(...
    sprintf('<div align="center"><a href="%s">%s</a></div>',info.url,info.url));
jPanel = jHomepage.getHTMLPane;
bgcolor = num2cell(defaultBackground);
jHomepage.setBackgroundColor(java.awt.Color(bgcolor{:}));
javacomponent(jPanel,[168 150 350 20],hMainFigure);
hjHomepage = handle(jHomepage,'CallbackProperties');
set(hjHomepage,'MouseClickedCallback',{@startBrowser,info.url});

uicontrol('style','text',...
    'Units','Pixels',...
    'Position',[168 0 350 20],...
    'BackgroundColor',defaultBackground...
    );

uicontrol('Tag','modules_pushbutton',...
    'Style','pushbutton',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[(128+40-90)/2 100 90 30],...
    'TooltipString','Open window with information about installed modules',...
    'String','Modules',...
    'Callback','trEPRgui_moduleswindow'...
    );

uicontrol('Tag','website_pushbutton',...
    'Style','pushbutton',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[(128+40-90)/2 60 90 30],...
    'TooltipString','Open website of the trEPR toolbox (in system webbrowser)',...
    'String','Website',...
    'Callback',{@startBrowser,trEPRinfo('url')}...
    );

uicontrol('Tag','close_pushbutton',...
    'Style','pushbutton',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[(128+40-90)/2 20 90 30],...
    'String','Close',...
    'TooltipString','Close "about" window',...
    'Callback',{@closeWindow}...
    );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Make the GUI visible.
set(hMainFigure,'Visible','on');


% Add keypress function to every element that can have one...
handles = findall(...
    allchild(hMainFigure),'style','pushbutton',...
    '-or','style','togglebutton',...
    '-or','style','edit',...
    '-or','style','listbox',...
    '-or','style','slider',...
    '-or','style','popupmenu');
for k=1:length(handles)
    set(handles(k),'KeyPressFcn',@guiKeyBindings);
end

% Define timer for all the fun stuff
t1 = timer( ...
    'StartDelay', 8, ...
    'TasksToExecute', 1, ...
    'ExecutionMode', 'fixedRate');
t2 = timer( ...
    'StartDelay', 2, ...
    'Period', 0.05, ...
    'TasksToExecute', scrollPanelHeight-130, ...
    'ExecutionMode', 'fixedRate');

t1.TimerFcn = @(x,y)start(t2);
t1.StopFcn =  @(x,y)delete(t1);

t2.TimerFcn = @(x,y)scrollPanel;
t2.StopFcn =  @(x,y)delete(t2);

start(t1);

if nargout
    varargout{1} = hMainPanel;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function keypress_Callback(~,evt)
        try
            if isempty(evt.Character) && isempty(evt.Key)
                % In case "Character" is the empty string, i.e. only
                % modifier key was pressed...
                return;
            end
            if ~isempty(evt.Modifier)
                if (strcmpi(evt.Modifier{1},'command')) || ...
                        (strcmpi(evt.Modifier{1},'control'))
                    switch evt.Key
                        case 'w'
                            closeWindow();
                            return;
                    end
                end
            end
            switch evt.Key
                case 'escape'
                    closeWindow()
                    return;
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

    function closeWindow(~,~)
        if exist('t1','var') && isvalid(t1)
            stop(t1);
            delete(t1);
        end
        if exist('t2','var') && isvalid(t2)
            stop(t2);
            delete(t2);
        end
        try
            delete(hMainFigure);
        catch
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

    function scrollPanel(~,~)
        panelPos = get(hPanel,'Position');
        panelPos(2) = panelPos(2)+1;
        set(hPanel,'Position',panelPos);
    end

end