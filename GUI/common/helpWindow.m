function varargout = helpWindow(varargin)
% HELPWINDOW Help window for the trEPR GUI.
%
% This window provides the user with "online" help included within the GUI.
% Besides that, it gives access to all the other sources of additional
% help, such as the Matlab Help Browser and the toolbox website.
%
% Usage:
%   helpWindow
%   helpWindow(<parameter>,<value>,...)
%
%
% Optional parameters that can be set:
%
%   basedir   - string
%               Directory containing the help files
%               Must be an existing directory
%               Default: "pwd"
%
%   tag       - string
%               Tag of the help window used as figure tag
%               Defaults to the mfilename of this function
%               Important for identifying the different help windows.
%               Normally, it should be set to the mfilename of the function
%               calling this function
%
%   title     - string
%               title of the help window
%               Default: "trEPR GUI"
%
%   page      - string
%               Page that should be displayed in the help window.
%               To discern pages with identical name in different
%               subdirectories, a slash ("/") can be used to separate
%               directory and file.
%
%               If the respective page cannot be found, a default page is
%               displayed.
%
%   position  - vector (2x1)
%            	position of the window relative to the screen.
%
%   visible   - boolean
%               Whether to make the help window visible at the end.
%               In case additional controls should be added, it is wise to
%               make it visible manually afterwards.

% Copyright (c) 2014, Till Biskup
% 2014-08-10

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Parse input arguments using the inputParser functionality
try
    p = inputParser;            % Create inputParser instance
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addParamValue('basedir',pwd,@(x)ischar(x) && exist(x,'dir'));
    p.addParamValue('tag',mfilename,@(x)ischar(x));
    p.addParamValue('title','trEPR GUI',@(x)ischar(x));
    p.addParamValue('page','',@(x)ischar(x));
    p.addParamValue('position',[100 200],@(x)isvector(x) && length(x)==2);
    p.addParamValue('visible',true,@(x)islogical(x));
    p.parse(varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

% Make GUI effectively a singleton
singleton = findobj('Type','figure','Tag',p.Results.tag);
if (singleton)
    figure(singleton);
    return;
end

guiSize = [920 500];
defaultBackground = [0.95 0.95 0.90];

% Construct the components
hMainFigure = figure('Tag',p.Results.tag,...
    'Visible','off',...
    'Name',[p.Results.title ' : Help Window'],...
    'Color',defaultBackground,...
    'Units','Pixels',...
    'Position',[p.Results.position guiSize],...
    'Resize','off',...
    'KeyPressFcn',@keypress_Callback,...
    'NumberTitle','off', ...
    'Menu','none','Toolbar','none');

% Create listbox with help topics
hTopicsListbox = uicontrol('Tag','helptopic_listbox',...
    'Style','listbox',...
    'Parent',hMainFigure,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',14,...
    'Units','Pixels',...
    'Position',[10 guiSize(2)-70 190 60],...
    'String','',...
    'Callback',{@listbox_Callback,'topics'}...
    );

% Create listbox with help topics
hPagesListbox = uicontrol('Tag','commands_listbox',...
    'Style','listbox',...
    'Parent',hMainFigure,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',14,...
    'Units','Pixels',...
    'Position',[10 10 190 guiSize(2)-85],...
    'String','',...
    'Callback',{@listbox_Callback,'pages'}...
    );

% Create the message window
% Use a Java Browser object to display HTML
jObject = com.mathworks.mlwidgets.html.HTMLBrowserPanel;
[browser,container] = javacomponent(jObject, [], hMainFigure);
set(container,...
    'Units','Pixels',...
    'Position',[210 50 guiSize(1)-220 guiSize(2)-60]...
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
    % Store handles in guidata
    guidata(hMainFigure,guihandles);
    
    % Fill topics listbox
    topics = getTopics(p.Results.basedir);
    set(hTopicsListbox,'String',...
        cellfun(@(x){strcat(upper(x(1)),x(2:end))},topics(:,1)));
    
    % Get pages tree and fill pages listbox accordingly
    pageTree = getPageTree(p.Results.basedir,topics);
    if size(topics,2) > 1
        if isempty(pageTree.(topics{1,2}))
            set(hPagesListbox,'String','');
        else
            set(hPagesListbox,'String',pageTree.(topics{1,2})(:,1));
        end
    else
        if isempty(pageTree.(topics{1}))
            set(hPagesListbox,'String','');
        else
            set(hPagesListbox,'String',pageTree.(topics{1})(:,1));
        end
    end
        
    if ~isempty(p.Results.page)
        % Check for slash as separator
        % Note that currently only one level of subdirectories is supported
        if any(strfind(p.Results.page,'/'))
            [topicName,pageName] = strtok(p.Results.page,'/');
            if length(pageName) > 1
                pageName = pageName(2:end);
                if size(topics,2) > 1
                    topicIdx = find(strcmpi(topics(:,2),topicName));
                else
                    topicIdx = find(strcmpi(topics,topicName));
                end
                if topicIdx
                    if size(topics,2) > 1
                        currTopic = topics{topicIdx,2};
                    else
                        currTopic = topics{topicIdx};
                    end
                    if size(pageTree.(currTopic),2) > 1
                        pageMatch = find(strcmpi(...
                            pageTree.(currTopic)(:,2),pageName));
                    else
                        pageMatch = find(strcmpi(...
                            pageTree.(currTopic),pageName));
                    end
                    if ~isempty(pageMatch)
                        set(hTopicsListbox,'Value',topicIdx);
                        listbox_Callback(hTopicsListbox,'','topics');
                        set(hPagesListbox,'Value',pageMatch);
                    end
                end
            end
        else
            for topicIdx=1:size(topics,1)
                if size(topics,2) > 1
                    currTopic = topics{topicIdx,2};
                else
                    currTopic = topics{topicIdx};
                end
                if size(pageTree.(currTopic),2) > 1
                    pageMatch = find(strcmpi(...
                        pageTree.(currTopic)(:,2),p.Results.page));
                else
                    pageMatch = find(strcmpi(...
                        pageTree.(currTopic),p.Results.page));
                end
                if ~isempty(pageMatch)
                    set(hTopicsListbox,'Value',topicIdx);
                    listbox_Callback(hTopicsListbox,'','topics');
                    set(hPagesListbox,'Value',pageMatch);
                    break;
                end
            end
        end
    end
    
    % Call listbox callback to get page displayed
    listbox_Callback(hPagesListbox,'','pages');
    
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
        
        switch action
            case 'topics'
                if size(topics,2) > 1
                    if isempty(pageTree.(topics{strcmpi(topics(:,1),...
                            value),2}))
                        return;
                    end
                    pageList = pageTree.(topics{strcmpi(topics(:,1),...
                        value),2})(:,1);
                else
                    if isempty(pageTree.(topics{strcmpi(topics(:,1),...
                            value)}))
                        return;
                    end
                    pageList = pageTree.(topics{strcmpi(topics(:,1),...
                        value)})(:,1);
                end
                set(hPagesListbox,'String',pageList);
                if length(pageList) < get(hPagesListbox,'Value')
                    set(hPagesListbox,'Value',length(pageList));
                end
                listbox_Callback(hPagesListbox,'','pages');
            case 'pages'
                % Get current topic
                if size(topics,2) > 1
                    topic = topics{get(hTopicsListbox,'Value'),2};
                else
                    topic = topics{get(hTopicsListbox,'Value')};
                end
                if isempty(pageTree.(topic))
                    htmlText = ['<html>' ...
                        '<h1>File not found.</h1>'...
                        '<p>Sorry, no help available (yet).</p>'...
                        '</html>'];
                    browser.setHtmlText(htmlText);
                    return;
                end
                if size(pageTree.(topic),2) > 1
                    pageList = pageTree.(topic)(:,1);
                    fileList = pageTree.(topic)(:,2);
                else
                    pageList = pageTree.(topic)(:,1);
                    fileList = pageList;
                end
                if isdir(fullfile(p.Results.basedir,topic))
                    helpTextFile = fullfile(p.Results.basedir,...
                        topic,[fileList{strcmpi(value,pageList)} '.html']);
                else
                    helpTextFile = fullfile(p.Results.basedir,...
                        [fileList{strcmpi(value,pageList)} '.html']);
                end
                if exist(helpTextFile,'file')
                    % Read text from file and display it
                    browser.setCurrentLocation(helpTextFile);
                else
                    % That shall never happen
                    trEPRmsg(['guiHelpPanel(): Unknown helptext "'...
                        helpTextFile '"'],'info');
                    htmlText = ['<html>' ...
                        '<h1>File not found.</h1>'...
                        '<p>Sorry, no help available (yet) for this topic.</p>'...
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

function topicList = getTopics(baseDir)

% Check whether file "topics.m" exists
if exist(fullfile(baseDir,'topics.m'),'file');
    PWD = pwd;
    cd(baseDir);
    %topicList = topics;
    topics;
    cd(PWD);
    return;
end

% Fallback: Get list of directories
topicList = getDirs(baseDir);

% If there are no (sub)directories, use default
if isempty(topicList)
    topicList = {'general'};
end

topicList = topicList';

end

function pagesTree = getPageTree(baseDir,topics)

% Check whether topics has more than one column
if size(topics,2) > 1
    topics = topics(:,2);
end

PWD = pwd;
cd(baseDir);

for topic = 1:length(topics)
    if isdir(topics{topic})
        pagesTree.(topics{topic}) = getPages(fullfile(pwd,topics{topic}));
    else
        pagesTree.(topics{topic}) = getPages(pwd);
    end
end

cd(PWD);

end

function pageList = getPages(directory)

PWD = pwd;
cd(directory);

% Check whether file "toc.m" exists
if exist('pages.m','file');
    pages;
    cd(PWD);
    return;
end

% Fallback: Get html files
pageList = dir('*.html');
if isempty(pageList)
    pageList = cell(0);
    return;
end
pageList = cellfun(@(x){x(1:end-5)},{pageList(:).name});
pageList = pageList';

cd(PWD);

end
