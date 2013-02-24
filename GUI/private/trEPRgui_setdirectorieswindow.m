function varargout = trEPRgui_setdirectorieswindow(varargin)
% TREPRGUI_SETDIRECTORIESWINDOW Window displaying the directories used
% inside the GUI with possibility to change them.
%
% Normally, this window is called from within the trEPRgui window. 
%
% See also TREPRGUI

% (c) 2013, Till Biskup
% 2013-02-24

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Make GUI effectively a singleton
singleton = findobj('Tag',mfilename);
if (singleton)
    figure(singleton);
    if nargout
        varargout{1} = singleton;
    end
    return;
end

guiPosition = [160,240,650,430];
% Try to get NetPolarisationwindow GUI position
mainGUIHandle = trEPRguiGetWindowHandle();
if ishandle(mainGUIHandle)
    mainGUIPosition = get(mainGUIHandle,'Position');
    guiPosition = [mainGUIPosition(1)+40,mainGUIPosition(2)+150,...
        guiPosition(3), guiPosition(4)];
else
    disp('No trEPR GUI main window found. Bye...');
    return;
end

%  Construct the components
hMainFigure = figure('Tag',mfilename,...
    'Visible','off',...
    'Name','trEPR GUI : Show/Set Directories Window',...
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
    'Position',[10 guiSize(2)-35 guiSize(1)-220 20],...
    'String','Show/Set directories used internally in the trEPR GUI'...
    );

p1 = uipanel('Tag','loaddir_panel',...
    'parent',hMainFigure,...
    'Title','Load directory',...
    'FontUnit','Pixel','Fontsize',12,...
    'BackgroundColor',defaultBackground,...
    'Visible','on',...
    'Units','pixels',...
    'Position',[10 330 guiSize(1)-20 60] ...
    );
uicontrol('Tag','loaddir_panel_edit',...
    'Style','edit',...
    'Parent',p1,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Left',...
    'FontName','Monospaced',...
    'Units','Pixels',...
    'Position',[10 10 guiSize(1)-80 25],...
    'String','',...
    'Callback',{@edit_Callback,'loaddir'}...
    );
uicontrol('Tag','loaddir_pushbutton',...
    'Style','pushbutton',...
	'Parent', p1, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','...',...
    'TooltipString','Open directory browser for setting directory',...
    'pos',[guiSize(1)-60 10 30 25],...
    'Enable','on',...
    'Callback',{@pushbutton_Callback,'loaddir'}...
    );

p2 = uipanel('Tag','savedir_panel',...
    'parent',hMainFigure,...
    'Title','Save directory',...
    'FontUnit','Pixel','Fontsize',12,...
    'BackgroundColor',defaultBackground,...
    'Visible','on',...
    'Units','pixels',...
    'Position',[10 260 guiSize(1)-20 60] ...
    );
uicontrol('Tag','savedir_panel_edit',...
    'Style','edit',...
    'Parent',p2,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Left',...
    'FontName','Monospaced',...
    'Units','Pixels',...
    'Position',[10 10 guiSize(1)-80 25],...
    'String','',...
    'Callback',{@edit_Callback,'savedir'}...
    );
uicontrol('Tag','savedir_pushbutton',...
    'Style','pushbutton',...
	'Parent', p2, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','...',...
    'TooltipString','Open directory browser for setting directory',...
    'pos',[guiSize(1)-60 10 30 25],...
    'Enable','on',...
    'Callback',{@pushbutton_Callback,'savedir'}...
    );

p3 = uipanel('Tag','savefigdir_panel',...
    'parent',hMainFigure,...
    'Title','Save figure directory',...
    'FontUnit','Pixel','Fontsize',12,...
    'BackgroundColor',defaultBackground,...
    'Visible','on',...
    'Units','pixels',...
    'Position',[10 190 guiSize(1)-20 60] ...
    );
uicontrol('Tag','savefigdir_panel_edit',...
    'Style','edit',...
    'Parent',p3,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Left',...
    'FontName','Monospaced',...
    'Units','Pixels',...
    'Position',[10 10 guiSize(1)-80 25],...
    'String','',...
    'Callback',{@edit_Callback,'savefigdir'}...
    );
uicontrol('Tag','savefigdir_pushbutton',...
    'Style','pushbutton',...
	'Parent', p3, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','...',...
    'TooltipString','Open directory browser for setting directory',...
    'pos',[guiSize(1)-60 10 30 25],...
    'Enable','on',...
    'Callback',{@pushbutton_Callback,'savefigdir'}...
    );

p4 = uipanel('Tag','exportdir_panel',...
    'parent',hMainFigure,...
    'Title','Export directory',...
    'FontUnit','Pixel','Fontsize',12,...
    'BackgroundColor',defaultBackground,...
    'Visible','on',...
    'Units','pixels',...
    'Position',[10 120 guiSize(1)-20 60] ...
    );
uicontrol('Tag','exportdir_panel_edit',...
    'Style','edit',...
    'Parent',p4,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Left',...
    'FontName','Monospaced',...
    'Units','Pixels',...
    'Position',[10 10 guiSize(1)-80 25],...
    'String','',...
    'Callback',{@edit_Callback,'exportdir'}...
    );
uicontrol('Tag','exportdir_pushbutton',...
    'Style','pushbutton',...
	'Parent', p4, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','...',...
    'TooltipString','Open directory browser for setting directory',...
    'pos',[guiSize(1)-60 10 30 25],...
    'Enable','on',...
    'Callback',{@pushbutton_Callback,'exportdir'}...
    );

p5 = uipanel('Tag','snapshotdir_panel',...
    'parent',hMainFigure,...
    'Title','Snapshot directory',...
    'FontUnit','Pixel','Fontsize',12,...
    'BackgroundColor',defaultBackground,...
    'Visible','on',...
    'Units','pixels',...
    'Position',[10 50 guiSize(1)-20 60] ...
    );
uicontrol('Tag','snapshotdir_panel_edit',...
    'Style','edit',...
    'Parent',p5,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Left',...
    'FontName','Monospaced',...
    'Units','Pixels',...
    'Position',[10 10 guiSize(1)-80 25],...
    'String','',...
    'Callback',{@edit_Callback,'snapshotdir'}...
    );
uicontrol('Tag','snapshotdir_pushbutton',...
    'Style','pushbutton',...
	'Parent', p5, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','...',...
    'TooltipString','Open directory browser for setting directory',...
    'pos',[guiSize(1)-60 10 30 25],...
    'Enable','on',...
    'Callback',{@pushbutton_Callback,'snapshotdir'}...
    );

uicontrol('Tag','close_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Close',...
    'TooltipString','Close Net Polarisation GUI Help window',...
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
    
    % Add keypress function to every element that can have one...
    handles = findall(...
        allchild(hMainFigure),'style','pushbutton',...
        '-or','style','togglebutton',...
        '-or','style','edit',...
        '-or','style','listbox',...
        '-or','style','checkbox',...
        '-or','style','slider',...
        '-or','style','popupmenu',...
        '-not','tag','command_panel_edit');
    for k=1:length(handles)
        set(handles(k),'KeyPressFcn',@keypress_Callback);
    end

    % Preset edits with directories
    updateWindow();
    
    % Make the GUI visible.
    set(hMainFigure,'Visible','on');
    trEPRmsg('Show/Set directories window opened.','info');
    
    if (nargout == 1)
        varargout{1} = hMainFigure;
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pushbutton_Callback(~,~,action)
    try
        if isempty(action)
            return;
        end
        
        admain = getappdata(trEPRguiGetWindowHandle());
        
        switch lower(action)
            case 'loaddir'
                directory = uigetdir(...
                    admain.control.dirs.lastLoad,...
                    'Select directory for loading datasets'...
                    );
                if ischar(directory) && exist(directory,'dir')
                    cmdDir(trEPRguiGetWindowHandle(),...
                        {lower(action),directory});
                end
            case 'savedir'
                directory = uigetdir(...
                    admain.control.dirs.lastSave,...
                    'Select directory for saving datasets'...
                    );
                if ischar(directory) && exist(directory,'dir')
                    cmdDir(trEPRguiGetWindowHandle(),...
                        {lower(action),directory});
                end
            case 'savefigdir'
                directory = uigetdir(...
                    admain.control.dirs.lastFigSave,...
                    'Select directory for saving figures'...
                    );
                if ischar(directory) && exist(directory,'dir')
                    cmdDir(trEPRguiGetWindowHandle(),...
                        {lower(action),directory});
                end
            case 'exportdir'
                directory = uigetdir(...
                    admain.control.dirs.lastExport,...
                    'Select directory for exporting datasets'...
                    );
                if ischar(directory) && exist(directory,'dir')
                    cmdDir(trEPRguiGetWindowHandle(),...
                        {lower(action),directory});
                end
            case 'snapshotdir'
                directory = uigetdir(...
                    admain.control.dirs.lastSnapshot,...
                    'Select directory for loading/saving snapshots'...
                    );
                if ischar(directory) && exist(directory,'dir')
                    cmdDir(trEPRguiGetWindowHandle(),...
                        {lower(action),directory});
                end
            otherwise
                disp(['Action ' action ' not understood.'])
                return;
        end
        updateWindow()
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

function edit_Callback(source,~,action)
    try
        if isempty(action)
            return;
        end
        
        directory = get(source,'String');
        if strcmpi(directory,'pwd')
            directory = pwd;
        end
        if ~exist(directory,'dir')
            updateWindow();
            return;
        end
        
        switch lower(action)
            case {'loaddir','savedir','savefigdir','exportdir','snapshotdir'}
                cmdDir(trEPRguiGetWindowHandle(),{lower(action),directory});
            otherwise
                disp(['Action ' action ' not understood.'])
                return;
        end
        updateWindow()
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

function keypress_Callback(~,evt)
    try
        if isempty(evt.Character) && isempty(evt.Key)
            % In case "Character" is the empty string, i.e. only modifier
            % key was pressed...
            return;
        end
        
        % Get handles of GUI
        gh = guihandles(hMainFigure);
        
        if ~isempty(evt.Modifier)
            if (strcmpi(evt.Modifier{1},'command')) || ...
                    (strcmpi(evt.Modifier{1},'control'))
                switch evt.Key
                    case '1'
                        uicontrol(gh.loaddir_panel_edit);
                        return;
                    case '2'
                        uicontrol(gh.savedir_panel_edit);
                        return;
                    case '3'
                        uicontrol(gh.savefigdir_panel_edit);
                        return;
                    case '4'
                        uicontrol(gh.exportdir_panel_edit);
                        return;
                    case '5'
                        uicontrol(gh.snapshotdir_panel_edit);
                        return;
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Utility functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function closeGUI(~,~)
    try
        clear('jObject');
        delete(hMainFigure);
        trEPRmsg('Show/Set directories window closed.','info');
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

function updateWindow()
    try
        % Get appdata from main trEPR GUI handle
        admain = getappdata(mainGUIHandle);
        
        % Get gui handles
        gh = guihandles(hMainFigure);
        
        set(gh.loaddir_panel_edit,'String',admain.control.dirs.lastLoad);
        set(gh.savedir_panel_edit,'String',admain.control.dirs.lastSave);
        set(gh.savefigdir_panel_edit,'String',admain.control.dirs.lastFigSave);
        set(gh.exportdir_panel_edit,'String',admain.control.dirs.lastExport);
        set(gh.snapshotdir_panel_edit,'String',admain.control.dirs.lastSnapshot);
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

end
