function varargout = trEPRgui_AVG_helpwindow(varargin)
% TREPRGUI_AVG_HELPWINDOW Brief description of GUI.
%          Comments displayed at the command line in response 
%          to the help command. 

% (c) 2011-12, Till Biskup
% 2012-06-07

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Make GUI effectively a singleton
singleton = findobj('Tag','trEPRgui_AVG_helpwindow');
if (singleton)
    figure(singleton);
    return;
end

% Try to get main GUI position
infoGUIHandle = trEPRguiGetWindowHandle('trEPRgui_AVGwindow');
if ishandle(infoGUIHandle)
    infoGUIPosition = get(infoGUIHandle,'Position');
    guiPosition = [infoGUIPosition(1)+20,infoGUIPosition(2)+200,450,450];
else
    guiPosition = [50,250,450,450];
end

%  Construct the components
hMainFigure = figure('Tag','trEPRgui_AVG_helpwindow',...
    'Visible','off',...
    'Name','trEPR GUI : AVG : Help Window',...
    'Units','Pixels',...
    'Position',guiPosition,...
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
    'String','How to Use the Average (AVG) GUI?'...
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
uicontrol('Tag','helptopic_popupmenu',...
    'Style','popupmenu',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'pos',[120 guiSize(2)-70 guiSize(1)-130 20],...
    'String','Introduction|Display|Average|Settings|Key bindings',...
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
    'TooltipString','Close AVG GUI Help window',...
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
    % Read text for welcome message from file and display it
    helpTextFile = fullfile(trEPRinfo('dir'),'GUI','private','helptexts','AVG','intro.txt');
    helpText = textFileRead(helpTextFile);
    set(textdisplay,'String',helpText);
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
        
        switch helpText
            case 'Introduction'
                % Read text from file and display it
                helpTextFile = fullfile(...
                    trEPRinfo('dir'),'GUI','private','helptexts','AVG','intro.txt');
                helpText = textFileRead(helpTextFile);
                set(textdisplay,'String',helpText);
            case 'Display'
                % Read text from file and display it
                helpTextFile = fullfile(...
                    trEPRinfo('dir'),'GUI','private','helptexts','AVG','display.txt');
                helpText = textFileRead(helpTextFile);
                set(textdisplay,'String',helpText);
            case 'Average'
                % Read text from file and display it
                helpTextFile = fullfile(...
                    trEPRinfo('dir'),'GUI','private','helptexts','AVG','average.txt');
                helpText = textFileRead(helpTextFile);
                set(textdisplay,'String',helpText);
            case 'Settings'
                % Read text from file and display it
                helpTextFile = fullfile(...
                    trEPRinfo('dir'),'GUI','private','helptexts','AVG','settings.txt');
                helpText = textFileRead(helpTextFile);
                set(textdisplay,'String',helpText);
            case 'Key bindings'
                % Read text from file and display it
                helpTextFile = fullfile(...
                    trEPRinfo('dir'),'GUI','private','helptexts','AVG','keybindings.txt');
                helpText = textFileRead(helpTextFile);
                set(textdisplay,'String',helpText);
            otherwise
                % That shall never happen
                trEPRadd2status('guiHelpPanel(): Unknown helptext');
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Utility functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
