function hFigure = msgWindow(message,varargin)
% MSGWINDOW Display message window similar to Matlab(r) msgbox, but with
% nicer icons and HTML formatting for message.
%
% Default keyboard shortcuts (only for non-modal windows):
%
%   Ctrl/Cmd + w  - close window
%   Esc           - close window
%
% Please note: The function makes use of the underlying Java functionality
%              in Matlab(r) and therefore allows for extended formatting
%              using HTML.
%
% Usage:
%   msgWindow(message)
%   handle = msgWindow(message)
%   msgWindow(message,<parameter>,<value>)
%
%   message - text
%             message to be displayed
%
%   handle  - handle
%             handle of the figure window
%
% Optional parameters that can be set:
%
%   title           - string
%                     title of the window
%                     If not specified, "message" will be used
%
%   icon            - string
%                     icon to be displayed on the left side of the window
%                     One of "info", "help", "warning", "error"
%                     Default: no icon
%
%   WindowStyle     - string
%                     Window style used for message window.
%                     One of "modal", "normal"
%                     Default: "normal"
%
%                     Modal windows prevent the user from interacting with
%                     other windows before responding.For more information,
%                     see "WindowStyle" in the MATLAB Figure Properties.
%
%                     Please note that the keyboard shortcuts work only
%                     with non-modal windows.
%
%   Position        - vector (2x1 or 4x1)
%                     2x1: position of the window relative to the screen.
%                     4x1: position and size (be careful!)
%                     If only two values are given, size will be determined
%                     automatically dependent on message length.
%                     If no position is given, default is centering the
%                     window at the screen.
%
%   backgroundColor - vector (3x1)
%                     background color for the text
%                     If not provided, a default background color is used.
%
% See also: msgbox, uiText, uiImage

% Copyright (c) 2014, Till Biskup
% 2014-07-27

hFigure = [];

% Parse input arguments using the inputParser functionality
try
    p = inputParser;            % Create inputParser instance
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('message',@(x)ischar(x));
    p.addParameter('title','Message',@(x)ischar(x));
    p.addParameter('Position',[],...
        @(x)isvector(x) && (length(x) == 2 || length(x) == 4));
    p.addParameter('backgroundColor',[0.9 0.9 0.9],...
        @(x)isvector(x) && length(x) == 3);
    p.addParameter('icon','',...
        @(x)ischar(x) && any(strcmpi(x,{'info','help','warning','error'})));
    p.addParameter('WindowStyle','normal',...
        @(x)ischar(x) && any(strcmpi(x,{'normal','modal'})));
    p.parse(message,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

hFigure = dialogueWindow(...
    'Message',p.Results.message,...
    'title',p.Results.title,...
    'Position',p.Results.Position,...
    'backgroundColor',p.Results.backgroundColor,...
    'icon',p.Results.icon,...
    'WindowStyle',p.Results.WindowStyle, ...
    'visible','off' ...
    );

windowSize = get(hFigure,'Position');
buttonXOffset = 48+20;

hButton = uicontrol('Tag','close_pushbutton',...
    'Style','pushbutton',...
    'Parent',hFigure,...
    'BackgroundColor',p.Results.backgroundColor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[round((windowSize(3)-buttonXOffset/2)/2) 12 60 25],...
    'String','OK',...
    'TooltipString','Close window',...
    'Callback',{@closeWindow}...
    );

% Keyboard shortcuts only in non-modal mode
if strcmpi(p.Results.WindowStyle,'normal')
    set([hFigure,hButton],'KeyPressFcn',{@keypress_Callback});
end

% Block of callback functions that need to be inside the main function to
% get easy access to the main figure handle
    function keypress_Callback(~,evt)
        
        if isempty(evt.Character) && isempty(evt.Key)
            return;
        end
        
        try
            if ~isempty(evt.Modifier)
                if (strcmpi(evt.Modifier{1},'command')) || ...
                        (strcmpi(evt.Modifier{1},'control'))
                    switch evt.Key
                        case 'w'
                            closeWindow();
                    end
                end
            end
            switch evt.Key
                case 'escape'
                    closeWindow();
                    return;
                otherwise
                    return;
            end
        catch exception
            trEPRexceptionHandling(exception);
        end
        
    end

    function closeWindow(~,~)
        delete(hFigure);
    end
% end of callback functions blocks

set(hFigure,'Visible','on');

end
