function fHandle = msgWindow(message,varargin)
% MSGWINDOW Display message window similar to Matlab(r) msgbox, but with
% nicer icons and HTML formatting for message.
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

fHandle = [];

% Parse input arguments using the inputParser functionality
try
    p = inputParser;            % Create inputParse instance
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('message',@(x)ischar(x));
    p.addParamValue('title','Message',@(x)ischar(x));
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

if isempty(message)
    message = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';
end

msgDim = getMessageDimensions(message);

iconDim = getIconDimensions(p.Results.icon);

position = getWindowPosition(p.Results.Position,msgDim,iconDim);

fHandle = figure(...
    'Name',p.Results.title,...
    'NumberTitle','off', ...
    'Menu','none','Toolbar','none',...
    'Color',p.Results.backgroundColor,...
    'Position',position,...
    'KeyPressFcn',{@keypress_Callback},...
    'Visible','off'...
    );

msgPos = getMessagePosition(msgDim,iconDim);

uiText(message,'parent',fHandle,'Position',msgPos);

plotIcon(p.Results.icon,iconDim,msgDim);

uicontrol('Tag','close_pushbutton',...
    'Style','pushbutton',...
    'Parent',fHandle,...
    'BackgroundColor',p.Results.backgroundColor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[position(3)/2+msgPos(1)-90 12 60 25],...
    'String','Close',...
    'TooltipString','Close window',...
    'KeyPressFcn',{@keypress_Callback},...
    'Callback',{@closeWindow}...
    );

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
        delete(fHandle);
    end
% end of callback functions blocks

set(fHandle,'Visible','on');

end

function msgDim = getMessageDimensions(message)

if length(message) < 70
    msgDim = [ceil(500/70)*length(message) 15];
else
    msgDim = [500 15*ceil(length(message)/70)];
end

end

function position = getWindowPosition(position,msgDim,iconDim)

if length(position) == 4
    return;
end

if isempty(position)
    screenSize = get(0,'ScreenSize');
    position = [screenSize(3)/2-msgDim(1)/2-iconDim(1)/2+20 ...
        screenSize(4)/2-msgDim(2)/2+20 msgDim+20];
elseif length(position) == 2
    position = [position msgDim+20];
end

position(3) = position(3)+iconDim(1);
position(4) = position(4)+30;

if position(4) < iconDim(2)+20+30
    position(4) = iconDim(2)+20+30;
end

end

function iconDim = getIconDimensions(icon)

if isempty(icon)
    iconDim = [0 0];
else
    iconDim = [48+10 48];
end

end

function msgPos = getMessagePosition(msgDim,iconDim)

msgPos = [10+iconDim(1) 40 msgDim];

if msgDim(2) < iconDim(2)
    msgPos(2) = msgPos(2)+(iconDim(2)-msgDim(2))/2;
end

end

function plotIcon(icon,iconDim,msgDim)

if isempty(icon)
    return;
end

iconFile = struct(...
    'info','note.png',...
    'help','tip.png',...
    'warning','warning.png',...
    'error','error.png' ...
    );

iconPos = [10 40];
if msgDim(2) > iconDim(2)
    iconPos(2) = iconPos(2)+(msgDim(2)-iconDim(2))/2;
end

[filePath,~,~] = fileparts(mfilename('fullpath'));
uiImage(fullfile(filePath,iconFile.(icon)),'Position',iconPos);

end
