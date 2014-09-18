function value = inputWindow(prompt,varargin)
% INPUTWINDOW Display input dialogue window similar to Matlab(r) inputdlg,
% but with more options and HTML formatting for prompt.
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
%   value = inputWindow(prompt)
%   value = inputWindow(prompt,<parameter>,<value>)
%
%   prompt  - string
%             prompt to be displayed
%
%   value   - string
%             value the user has typed
%
% Optional parameters that can be set:
%
%   title           - string
%                     title of the window
%                     If not specified, "prompt" will be used
%
%   preset          - string
%                     value shown as preset in the edit field
%                     If not specified, an empty string will be used
%
%   Position        - vector (2x1 or 4x1)
%                     2x1: position of the window relative to the screen.
%                     4x1: position and size (be careful!)
%                     If only two values are given, size will be determined
%                     automatically dependent on prompt length.
%                     If no position is given, default is centering the
%                     window at the screen.
%
%   backgroundColor - vector (3x1)
%                     background color for the text
%                     If not provided, a default background color is used.
%
% See also: msgbox, uiText, uiImage

% Copyright (c) 2014, Till Biskup
% 2014-09-18

hFigure = [];

% Parse input arguments using the inputParser functionality
try
    p = inputParser;            % Create inputParser instance
    p.FunctionName = mfilename; % Include function name in error prompts
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('prompt',@(x)ischar(x));
    p.addParamValue('preset','',@(x)ischar(x));
    p.addParamValue('title','Enter value',@(x)ischar(x));
    p.addParamValue('Position',[],...
        @(x)isvector(x) && (length(x) == 2 || length(x) == 4));
    p.addParamValue('backgroundColor',[0.9 0.9 0.9],...
        @(x)isvector(x) && length(x) == 3);
    p.addParamValue('html',false,@(x)islogical(x));
    p.parse(prompt,varargin{:});
catch exception
    disp(['(EE) ' exception.prompt]);
    return;
end

position = getWindowPosition(p.Results.Position);

hFigure = figure(...
    'Name',p.Results.title,...
    'NumberTitle','off', ...
    'Menu','none','Toolbar','none',...
    'Color',p.Results.backgroundColor,...
    'Position',position,...
    'WindowStyle','modal',...
    'Visible','off',...
    'CloseRequestFcn',@setValue...
    );

edit = uicontrol('Tag','input_edit',...
    'Style','edit',...
    'Parent',hFigure,...
    'FontUnit','Pixel','Fontsize',14,...
    'Units','Pixels',...
    'Position',[10 10 position(3)-20 30],...
    'HorizontalAlignment','Left',...
    'String',p.Results.preset,...
    'Callback',@setValue...
    );

promptPos = [10 40 200 30];

if p.Results.html
    uiText(p.Results.prompt,'parent',hFigure,'Position',promptPos);
else
    uicontrol('Tag','input_edit',...
        'Style','text',...
        'Parent',hFigure,...
        'FontUnit','Pixel','Fontsize',14,...
        'Units','Pixels',...
        'Position',promptPos,...
        'BackgroundColor',p.Results.backgroundColor,...
        'HorizontalAlignment','Left',...
        'String',p.Results.prompt...
        );
end

% Block of callback functions that need to be inside the main function to
% get easy access to the main figure handle
    function setValue(~,~)
        value = get(edit,'String');
        delete(hFigure);
    end

% end of callback functions blocks

set(hFigure,'Visible','on');

% Give edit control the focus
uicontrol(edit);

uiwait;

end


function position = getWindowPosition(position)

if length(position) == 4
    return;
end

innerDim = [350 60];

if isempty(position)
    screenSize = get(0,'ScreenSize');
    position = [screenSize(3)/2-innerDim(1)/2+20 ...
        screenSize(4)/2-innerDim(2)/2+20 innerDim+20];
elseif length(position) == 2
    position = [position innerDim+20];
end

end