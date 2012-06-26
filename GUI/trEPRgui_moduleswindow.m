function varargout = trEPRgui_moduleswindow()
% TREPRGUI_MODULESWINDOW Display basic information about the modules
% installed for the trEPR toolbox, including links to the toolbox modules'
% homepage.

% (c) 2012, Till Biskup
% 2012-06-26

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
    guiPosition = [mainGUIPosition(1)+210,mainGUIPosition(2)+260,660,280];
else
    guiPosition = [230,300,660,280];
end

moduleInfo = trEPRinfo('modules');

title = 'trEPR Toolbox: Modules';

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

p1 = uipanel('Tag','modules_panel',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[20 60 120 200],...
    'Title','Modules'...
    );
uicontrol('Tag','modules_listbox',...
    'Style','listbox',...
    'Parent',p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 100 170],...
    'String',fieldnames(moduleInfo),...
    'Callback',{@listbox_Callback}...
    );

p2 = uipanel('Tag','info_panel',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[160 20 480 240],...
    'Title','Information about selected module'...
    );
uicontrol('Tag','modulename_text',...
    'Style','text',...
    'Parent',p2,...
    'Units','Pixels',...
    'Position',[10 190 460 20],...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',16,...
    'HorizontalAlignment','Left',...
    'String','Please select a module in the list'...
    );
uicontrol('Tag','moduledescription_text',...
    'Style','text',...
    'Parent',p2,...
    'Units','Pixels',...
    'Position',[10 140 460 50],...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',14,...
    'HorizontalAlignment','Left',...
    'FontAngle','Italic',...
    'String',''...
    );
uicontrol('Tag','modulerelease_label_text',...
    'Style','text',...
    'Parent',p2,...
    'Units','Pixels',...
    'Position',[10 120 70 20],...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Left',...
    'String','Release:'...
    );
uicontrol('Tag','modulerelease_text',...
    'Style','text',...
    'Parent',p2,...
    'Units','Pixels',...
    'Position',[90 120 380 20],...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Left',...
    'String',''...
    );
uicontrol('Tag','modulehomepage_label_text',...
    'Style','text',...
    'Parent',p2,...
    'Units','Pixels',...
    'Position',[10 90 70 20],...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Left',...
    'String','Homepage:'...
    );

jHomepage = com.mathworks.widgets.HyperlinkTextLabel('');
jPanel = jHomepage.getHTMLPane;
bgcolor = num2cell(defaultBackground);
jHomepage.setBackgroundColor(java.awt.Color(bgcolor{:}));
javacomponent(jPanel,[90 94 380 20],p2);

uicontrol('Tag','modulemaintainer_label_text',...
    'Style','text',...
    'Parent',p2,...
    'Units','Pixels',...
    'Position',[10 60 70 20],...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Left',...
    'String','Maintainer:'...
    );
uicontrol('Tag','modulemaintainer_text',...
    'Style','text',...
    'Parent',p2,...
    'Units','Pixels',...
    'Position',[90 40 380 40],...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Left',...
    'String',''...
    );
uicontrol('Tag','modulebugtracker_label_text',...
    'Style','text',...
    'Parent',p2,...
    'Units','Pixels',...
    'Position',[10 10 70 20],...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Left',...
    'String','Bug tracker:'...
    );

jBugtracker = com.mathworks.widgets.HyperlinkTextLabel('');
jPanel = jBugtracker.getHTMLPane;
bgcolor = num2cell(defaultBackground);
jBugtracker.setBackgroundColor(java.awt.Color(bgcolor{:}));
javacomponent(jPanel,[90 14 380 20],p2);

uicontrol('Tag','close_pushbutton',...
    'Style','pushbutton',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[35 20 90 30],...
    'String','Close',...
    'TooltipString','Close "about" window',...
    'Callback',{@closeWindow}...
    );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set guihandles
gh = guihandles;
guidata(hMainFigure,gh);

% Make the GUI visible.
set(hMainFigure,'Visible','on');
trEPRmsg('Modules window opened.','info');

% % Add keypress function to every element that can have one...
% handles = findall(...
%     allchild(hMainFigure),'style','pushbutton',...
%     '-or','style','togglebutton',...
%     '-or','style','edit',...
%     '-or','style','listbox',...
%     '-or','style','slider',...
%     '-or','style','popupmenu');
% for k=1:length(handles)
%     set(handles(k),'KeyPressFcn',@guiKeyBindings);
% end

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

    function listbox_Callback(source,~)
        try
            % Get gui handles
            gh = guihandles(hMainFigure);
            
            % Get name of currently selected list entry
            moduleNames = cellstr(get(source,'String'));
            if isempty(moduleNames)
                return;
            end
            module = char(moduleNames(get(source,'Value')));

            % Set display according to selection
            set(gh.modulename_text,'String',...
                moduleInfo.(module).name);
            set(gh.moduledescription_text,'String',...
                moduleInfo.(module).description);
            set(gh.modulerelease_text,'String',sprintf('%s (%s)',...
                moduleInfo.(module).version.Version,...
                moduleInfo.(module).version.Date));
            jHomepage.setText(sprintf('<a href="%s">%s</a>',...
                moduleInfo.(module).url,moduleInfo.(module).url));
            hjHomepage = handle(jHomepage,'CallbackProperties');
            set(hjHomepage,'MouseClickedCallback',...
                {@startBrowser,moduleInfo.(module).url});
            set(gh.modulemaintainer_text,'String',sprintf('%s\n<%s>',...
                moduleInfo.(module).maintainer.name,...
                moduleInfo.(module).maintainer.email));
            jBugtracker.setText(sprintf('<a href="%s">%s</a>',...
                moduleInfo.(module).bugtracker.url,...
                moduleInfo.(module).bugtracker.url));
            hjBugtracker = handle(jBugtracker,'CallbackProperties');
            set(hjBugtracker,'MouseClickedCallback',...
                {@startBrowser,moduleInfo.(module).bugtracker.url});
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

    function closeWindow(~,~)
        try
            delete(hMainFigure);
            trEPRmsg('Modules window closed.','info');
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


end