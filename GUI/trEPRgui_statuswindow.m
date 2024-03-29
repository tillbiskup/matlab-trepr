function varargout = trEPRgui_statuswindow(varargin)
% TREPRGUI_STATUSWINDOW A GUI window displaying status messages of the
% toolbox and GUI.
%
% Normally, this window is called from within the trEPRgui window.
%
% See also trEPRgui, trEPRmsg

% Copyright (c) 2011-14, Till Biskup
% 2014-10-09

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Reset colour of main GUI window status display
mainGuiWindow = trEPRguiGetWindowHandle();
if ishandle(mainGuiWindow)
    resetStatusDisplayInMainGUIWindow(mainGuiWindow);
end

% Make GUI effectively a singleton
singleton = trEPRguiGetWindowHandle(mfilename);
if ishandle(singleton)
    figure(singleton);
    varargout{1} = singleton;
    return;
end

% Try to get main GUI position
mainGUIHandle = trEPRguiGetWindowHandle();
if ishandle(mainGUIHandle)
    mainGUIPosition = get(mainGUIHandle,'Position');
    guiPosition = [mainGUIPosition(1)+10,mainGUIPosition(2)+10,950,250];
else
    guiPosition = [30,50,950,250];
end

%  Construct the components
hMainFigure = figure('Tag',mfilename,...
    'Visible','off',...
    'Name','trEPR GUI : Status Window',...
    'Units','Pixels',...
    'Position',guiPosition,...
    'Resize','off',...
    'NumberTitle','off', ...
    'Menu','none','Toolbar','none',...
    'KeyPressFcn',@keyBindings,...
    'WindowButtonDownFcn',@windowButtonDownFunction,...
    'CloseRequestFcn',@closeGUI);

guiSize = get(hMainFigure,'Position');
guiSize = guiSize([3,4]);

% Create the message window
textdisplay = uicontrol('Tag','status_text',...
    'Style','edit',...
    'Parent',hMainFigure,...
    'BackgroundColor',[1 1 1],...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'Position',[0 0 guiSize(1) guiSize(2)],...
    'Enable','inactive',...
    'Max',2,'Min',0,...
    'FontSize',12,...
    'FontName','Monospaced',...
    'String','');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Store handles in appdata
setappdata(hMainFigure,'guiHandles',guihandles);

% Apply configuration
guiConfigApply(mfilename);

% Set font size depending on OS (12 pt seems a bit huge with linux)
if isunix && ~ismac
    set(textdisplay,'FontSize',10);
end

% Apply configuration settings
ad = getappdata(hMainFigure);
if isfield(ad,'configuration') && isfield(ad.configuration,'general')
    switch lower(ad.configuration.general.positioning)
        case 'relative'
            % Try to get main GUI position
            mainGUIHandle = trEPRguiGetWindowHandle();
            if ishandle(mainGUIHandle)
                mainGUIPosition = get(mainGUIHandle,'Position');
                statusWindowPosition = get(hMainFigure,'Position');
                statusWindowPosition(1) = ...
                    mainGUIPosition(1)+ad.configuration.general.dx;
                statusWindowPosition(2) = ...
                    mainGUIPosition(2)+ad.configuration.general.dy;
            end
        case 'absolute'
            statusWindowPosition = get(hMainFigure,'Position');
            statusWindowPosition(1) = ad.configuration.general.dx;
            statusWindowPosition(2) = ad.configuration.general.dy;
    end
    set(hMainFigure,'Position',statusWindowPosition);
end

% Make the GUI visible.
set(hMainFigure,'Visible','on');
trEPRmsg('Status window opened.','debug');

if (nargout == 1)
    varargout{1} = hMainFigure;
end

% Set string
if ishandle(mainGuiWindow)
    ad = getappdata(mainGuiWindow);
    % Check for availability of necessary fields in appdata
    if (isfield(ad,'control') ~= 0) && (isfield(ad.control,'status') ~= 0)
        statusstring = ad.control.status.messages;
    end
else
    statusstring = {...
        '  1: There seems to be no trEPR GUI main window...',...
        };
end
trEPRguiUpdateStatusWindow(statusstring);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function closeGUI(~,~)
    try
        delete(hMainFigure);
        trEPRmsg('Status window closed.','debug');
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

function keyBindings(~,evt)
    try
        if ~isempty(evt.Modifier)
            if (strcmpi(evt.Modifier{1},'command')) || ...
                    (strcmpi(evt.Modifier{1},'control'))
                switch evt.Key
                    case 'w'
                        closeGUI();
                        return;
                    otherwise
                        return;
                end
            end
        end
        switch evt.Key
            case 'f1'
                return;
            case 'escape'
                closeGUI();
                return;
            otherwise
                %             disp(evt);
                %             fprintf('       Caller: %i\n\n',src);
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

    function windowButtonDownFunction(~,~)
        resetStatusDisplayInMainGUIWindow(mainGuiWindow);
    end

end

