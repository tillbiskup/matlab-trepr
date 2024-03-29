function varargout = trEPRgui_combine_helpwindow(varargin)
% TREPRGUI_COMBINE_HELPWINDOW Brief description of GUI.
%          Comments displayed at the command line in response 
%          to the help command. 

% Copyright (c) 2011-15, Till Biskup
% 2015-10-18

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Make GUI effectively a singleton
singleton = findobj('Tag',mfilename);
if ishghandle(singleton)
    figure(singleton);
    return;
end

defaultBackground = [.9 .9 .9];

% Try to get main GUI position
infoGUIHandle = trEPRguiGetWindowHandle('trEPRgui_combinewindow');
if ishandle(infoGUIHandle)
    infoGUIPosition = get(infoGUIHandle,'Position');
    guiPosition = [infoGUIPosition(1)+20,infoGUIPosition(2)+170,450,450];
else
    guiPosition = [50,220,450,450];
end

%  Construct the components
hMainFigure = figure('Tag',mfilename,...
    'Visible','off',...
    'Name','trEPR GUI : Combine : Help Window',...
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
    'Position',[10 guiSize(2)-35 guiSize(1)-20 20],...
    'String','How to Use the Combine GUI?'...
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
    'String','Introduction|Key bindings',...
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
uicontrol('Tag','back_pushbutton',...
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

uicontrol('Tag','close_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Close',...
    'TooltipString','Close Combine GUI Help window',...
    'pos',[guiSize(1)-70 10 60 30],...
    'Enable','on',...
    'Callback',{@closeGUI}...
    );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try
    % Store handles in appdata
    setappdata(hMainFigure,'guiHandles',guihandles);
    
    % Make the GUI visible.
    set(hMainFigure,'Visible','on');
    trEPRmsg('Combine GUI help window opened.','debug');

    if (nargout == 1)
        varargout{1} = hMainFigure;
    end
    % Read text for welcome message from file and display it
    helpTextFile = fullfile(trEPRinfo('dir'),...
        'GUI','private','helptexts','combine','intro.html');
    browser.setCurrentLocation(helpTextFile);
catch exception
    trEPRexceptionHandling(exception)
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
                helpTextFile = fullfile(trEPRinfo('dir'),...
                    'GUI','private','helptexts','combine','intro.html');
                browser.setCurrentLocation(helpTextFile);
            case 'Key bindings'
                % Read text from file and display it
                helpTextFile = fullfile(trEPRinfo('dir'),...
                    'GUI','private','helptexts','combine','keybindings.html');
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
        trEPRexceptionHandling(exception)
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
        trEPRexceptionHandling(exception)
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
        else
            switch evt.Key
                case 'escape'
                    closeGUI();
                    return;
            end                    
        end
    catch exception
        trEPRexceptionHandling(exception)
    end
end

function closeGUI(~,~)
    try
        delete(hMainFigure);
        trEPRmsg('Combine GUI help window closed.','debug');
    catch exception
        trEPRexceptionHandling(exception)
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Utility functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
