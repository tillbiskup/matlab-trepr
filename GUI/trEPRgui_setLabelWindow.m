function varargout = trEPRgui_setLabelWindow(varargin)
% TREPRGUI Brief description of GUI.
%          Comments displayed at the command line in response 
%          to the help command. 

% (Leave a blank line following the help.)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

title = 'Set label of dataset';
description = {...
    'Set the label of the selected dataset.' ...
    ' ' ...
    'TIP: Use short, precise and easily recognizable labels.' ...
    };
position = [200,300,300,160];

if (nargin > 0)
    oldLabel = varargin{1};
else
    oldLabel = '';
end

%  Construct the components
hMainFigure = figure('Tag','setLabelWindow',...
    'Visible','off',...
    'Name',title,...
    'Units','Pixels',...
    'Position',position,...
    'Resize','off',...
    'NumberTitle','off', ...
    'WindowStyle','modal',...
    'Menu','none','Toolbar','none',...
    'CloseRequestFcn',{@setLabel_Callback,'cancel'});

defaultBackground = get(hMainFigure,'Color');
guiSize = get(hMainFigure,'Position');
guiSize = guiSize([3,4]);

uicontrol('Tag','description',...
    'Style','text',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'Position',[10 85 guiSize(1)-20 65],...
    'String',description...
    );

edit = uicontrol('Tag','label_edit',...
    'Style','edit',...
    'Parent',hMainFigure,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 50 guiSize(1)-20 25],...
    'HorizontalAlignment','Left',...
    'String',oldLabel,...
    'Callback',{@setLabel_Callback,'apply'}...
    );

uicontrol('Tag','info_pushbutton',...
    'Style','pushbutton',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 60 30],...
    'String','Get Info',...
    'TooltipString','Display more informations about selected dataset',...
    'Callback',{@info_pushbutton_Callback}...
    );

uicontrol('Tag','cancel_pushbutton',...
    'Style','pushbutton',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[guiSize(1)-130 10 60 30],...
    'String','Cancel',...
    'TooltipString','Cancel and don''t change label text',...
    'Callback',{@setLabel_Callback,'cancel'}...
    );

uicontrol('Tag','apply_pushbutton',...
    'Style','pushbutton',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[guiSize(1)-70 10 60 30],...
    'String','Apply',...
    'TooltipString','Return to GUI and use label text as shown',...
    'Callback',{@setLabel_Callback,'apply'}...
    );



% Create the message window

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Store handles in guidata
guidata(hMainFigure,guihandles);

% Make the GUI visible.
set(hMainFigure,'Visible','on');

% Give edit control the focus
uicontrol(edit);

uiwait;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function setLabel_Callback(~,~,action)
    newLabel = get(edit,'String');
    switch action
        case 'apply'
            delete(hMainFigure);
            varargout{1} = newLabel;
        case 'cancel'
            delete(hMainFigure);
            varargout{1} = oldLabel;
        otherwise
            disp('Whatever you did, but that shall never happen...');
    end
end

function info_pushbutton_Callback(~,~)
    trEPRgui_infowindow();
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Utility functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
