function answer = questionDialogue(message,varargin)
% QUESTIONDIALOGUE Display question dialogue window similar to Matlab(r)
% questdlg, but with nicer icons and HTML formatting for message.
%
% Please note: The function makes use of the underlying Java functionality
%              in Matlab(r) and therefore allows for extended formatting
%              using HTML.
%
% Usage:
%   questionDialogue(message)
%   answer = questionDialogue(message)
%   answer = questionDialogue(message,<parameter>,<value>)
%
%   message - text
%             message to be displayed
%
%   answer  - text
%             Label of the button pressed.
%             Empty if dialogue was closed without pressing a button.
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
% See also: msgWindow, dialogueWindow, uiText, uiImage

% Copyright (c) 2014, Till Biskup
% 2014-07-27

answer = '';

% Parse input arguments using the inputParser functionality
try
    p = inputParser;            % Create inputParse instance
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('message',@(x)ischar(x));
    p.addParamValue('title','Message',@(x)ischar(x));
    p.addParamValue('buttons',{'OK','Cancel'},@(x)ischar(x) || iscell(x));
    p.addParamValue('defaultButton','OK',@(x)ischar(x));
    p.addParamValue('Position',[],...
        @(x)isvector(x) && (length(x) == 2 || length(x) == 4));
    p.addParamValue('backgroundColor',[0.9 0.9 0.9],...
        @(x)isvector(x) && length(x) == 3);
    p.addParamValue('icon','',...
        @(x)ischar(x) && any(strcmpi(x,{'info','help','warning','error'})));
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
    'WindowStyle','modal', ...
    'visible','off' ...
    );

windowSize = get(hFigure,'Position');
buttonXOffset = 48+20;
buttonSize = [60 25];

for button = 1:length(p.Results.buttons)
    uicontrol(...
        'Style','pushbutton',...
        'Parent',hFigure,...
        'BackgroundColor',p.Results.backgroundColor,...
        'FontUnit','Pixel','Fontsize',12,...
        'Units','Pixels',...
        'Position',[...
        round(windowSize(3)+buttonXOffset-length(p.Results.buttons)*...
        buttonSize(1))/2+(button-1)*buttonSize(1) 12 buttonSize],...
        'String',p.Results.buttons{button},...
        'Callback',{@pushbutton_Callback}...
        );
end

% Keyboard shortcuts
set([hFigure,findobj('Style','pushbutton')'],...
    'KeyPressFcn',{@keypress_Callback});

% Select default button
defaultButton = findobj(...
    allchild(hFigure),...
    'Style','pushbutton','-and','String',p.Results.defaultButton);

if ~isempty(defaultButton)
    uicontrol(defaultButton);
end

% Block of callback functions that need to be inside the main function to
% get easy access to the main figure handle
    function pushbutton_Callback(source,~)
        try
            answer = get(source,'String');
            closeWindow();
        catch exception
            trEPRexceptionHandling(exception);
        end
    end
        
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

waitfor(hFigure);

end
