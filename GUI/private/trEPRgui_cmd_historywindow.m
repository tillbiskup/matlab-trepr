function varargout = trEPRgui_cmd_historywindow(varargin)
% TREPRGUI_CMD_HISTORYWINDOW Window displaying the directories used
% inside the GUI with possibility to change them.
%
% Normally, this window is called from within the trEPRgui window. 
%
% See also TREPRGUI

% Copyright (c) 2013-14, Till Biskup
% 2014-10-10

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Make GUI effectively a singleton
singleton = findobj('Tag',mfilename);
if ishghandle(singleton)
    figure(singleton);
    if nargout
        varargout{1} = singleton;
    end
    return;
end

defaultBackground = [.9 .9 .9];
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
    'Name','trEPR GUI : Cmd History',...
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
    'Position',[10 guiSize(2)-35 guiSize(1)-220 20],...
    'String','trEPR GUI: Cmd History'...
    );

p1 = uipanel('Tag','history_panel',...
    'parent',hMainFigure,...
    'Title','Cmd history',...
    'FontUnit','Pixel','Fontsize',12,...
    'BackgroundColor',defaultBackground,...
    'Visible','on',...
    'Units','pixels',...
    'Position',[10 10 guiSize(1)-140 guiSize(2)-60] ...
    );
cmdHistory = uicontrol('Tag','history_panel_listbox',...
    'Style','listbox',...
    'Parent',p1,...
    'BackgroundColor',[0.95 0.95 0.95],...
    'FontUnit','Pixel','Fontsize',14,...
    'FontName','Monospaced',...
    'Units','Pixels',...
    'Position',[10 10 guiSize(1)-160 guiSize(2)-90],...
    'Min',0,'Max',2,...
    'String',''...
    );

uicontrol('Tag','evaluate_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Evaluate',...
    'TooltipString','Evaluate selection',...
    'pos',[guiSize(1)-120 guiSize(2)-85 110 30],...
    'Enable','on',...
    'Callback',{@pushbutton_Callback,'evaluate'}...
    );
uicontrol('Tag','create_script_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Create script',...
    'TooltipString','Create script from selection',...
    'pos',[guiSize(1)-120 guiSize(2)-120 110 30],...
    'Enable','inactive',...
    'Callback',{@pushbutton_Callback,'createScript'}...
    );
uicontrol('Tag','save_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Save',...
    'TooltipString','Save cmd history to file',...
    'pos',[guiSize(1)-120 guiSize(2)-185 110 30],...
    'Enable','inactive',...
    'Callback',{@pushbutton_Callback,'save'}...
    );
uicontrol('Tag','clear_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Clear',...
    'TooltipString','Clear cmd history',...
    'pos',[guiSize(1)-120 guiSize(2)-220 110 30],...
    'Enable','inactive',...
    'Callback',{@pushbutton_Callback,'clear'}...
    );
uicontrol('Tag','close_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Close',...
    'TooltipString','Close Net Polarisation GUI Help window',...
    'pos',[guiSize(1)-120 10 110 30],...
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
    trEPRmsg('Cmd history window opened.','debug');
    
    if (nargout == 1)
        varargout{1} = hMainFigure;
    end
    
    uicontrol(cmdHistory);
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
        
        % Get handles of GUI
        gh = guihandles(hMainFigure);
        
        switch lower(action)
            case 'evaluate'
                history = get(gh.history_panel_listbox,'String');
                values = get(gh.history_panel_listbox,'Value');
                for commands=1:length(values)
                    [status,warning] = trEPRguiCommand(char(history(...
                        values(commands))));
                    if status
                        trEPRmsg(warning,'warning');
                    end
                end
            otherwise
                disp(['Action ' action ' not understood.'])
                return;
        end
        updateWindow()
    catch exception
        trEPRexceptionHandling(exception);
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
        trEPRexceptionHandling(exception);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Utility functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function closeGUI(~,~)
    try
        delete(hMainFigure);
        trEPRmsg('Cmd history window closed.','debug');
    catch exception
        trEPRexceptionHandling(exception);
    end
end

function updateWindow()
    try
        % Get appdata from main trEPR GUI handle
        admain = getappdata(mainGUIHandle);
        
        % Get gui handles
        gh = guihandles(hMainFigure);
        
        set(gh.history_panel_listbox,'String',admain.control.cmd.history);
        % Make last entry active
        set(gh.history_panel_listbox,'Value',...
            length(admain.control.cmd.history));
    catch exception
        trEPRexceptionHandling(exception);
    end
end

end
