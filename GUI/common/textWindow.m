function varargout = textWindow(filename,varargin)
% TEXTWINDOW Display (HTML) text in window
%
% This window provides the user with an easy way to display somehow formatted
% text by using the Java browser widget included in Matlab(R).
%
% Please be aware of the limitations of the Java browser widget with respect to
% interpreting HTML in general and CSS in particular.
%
% Usage:
%   textWindow(filename)
%
%   filename - string
%              Name of an (HTML) file to display.
%              If you don't provide a file extension, ".html" will be assumed.

% Copyright (c) 2015, Till Biskup
% 2015-10-18

% Parse input arguments using the inputParser functionality
try
    p = inputParser;            % Create inputParser instance
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('filename', @ischar);
    p.addParameter('basedir',pwd,@(x)ischar(x) && exist(x,'dir'));
    p.addParameter('tag',mfilename,@(x)ischar(x));
    p.addParameter('title','trEPR GUI : Text window',@(x)ischar(x));
    p.addParameter('page','',@(x)ischar(x));
    p.addParameter('position',[100 200],@(x)isvector(x) && length(x)==2);
    p.addParameter('visible',true,@(x)islogical(x));
    p.addParameter('fbbuttons',false,@islogical);
    p.parse(filename,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Make GUI effectively a singleton
singleton = findobj('Type','figure','Tag',p.Results.tag);
if ishghandle(singleton)
    figure(singleton);
    return;
end

guiSize = [700 500];
defaultBackground = [0.95 0.95 0.90];

% Construct the components
hMainFigure = figure('Tag',p.Results.tag,...
    'Visible','off',...
    'Name',p.Results.title,...
    'Color',defaultBackground,...
    'Units','Pixels',...
    'Position',[p.Results.position guiSize],...
    'Resize','off',...
    'KeyPressFcn',@keypress_Callback,...
    'NumberTitle','off', ...
    'Menu','none','Toolbar','none');

% Create the message window
% Use a Java Browser object to display HTML
jObject = com.mathworks.mlwidgets.html.HTMLBrowserPanel;
[browser,container] = javacomponent(jObject, [], hMainFigure);
set(container,...
    'Units','Pixels',...
    'Position',[10 50 guiSize(1)-20 guiSize(2)-60]...
    );

backbutton = uicontrol('Tag','back_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','<html>&larr;</html>',...
    'TooltipString','Go to previous page in browser history',...
    'pos',[10 10 40 30],...
    'Enable','on',...
    'Visible','off',...
    'Callback',{@pushbutton_Callback,'browserback'} ...
    );
fwdbutton = uicontrol('Tag','fwd_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','<html>&rarr;</html>',...
    'TooltipString','Go to next page in browser history',...
    'pos',[50 10 40 30],...
    'Enable','on',...
    'Visible','off',...
    'Callback',{@pushbutton_Callback,'browserforward'} ...
    );

uicontrol('Tag','close_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Close',...
    'TooltipString','Close Help window',...
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

    if ~exist(filename,'file')
        filename = [filename '.html'];
    end
    
    if exist(filename,'file')
%         content = textFileRead(filename);
%         browser.setHtmlText([content{:}]);
        browser.setCurrentLocation(filename);
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
    
    % Make forward and back buttons visible
    if p.Results.fbbuttons
        set([fwdbutton backbutton],'Visible','on');
    end
    
    % Make the GUI visible.
    if p.Results.visible
        set(hMainFigure,'Visible','on');
    end
    trEPRmsg([p.Results.title ' help window opened.'],'debug');

    if (nargout == 1)
        varargout{1} = hMainFigure;
    end
catch exception
    trEPRexceptionHandling(exception);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
        trEPRmsg([p.Results.title ' help window closed.'],'debug');
    catch exception
        trEPRexceptionHandling(exception);
    end
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Utility functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

