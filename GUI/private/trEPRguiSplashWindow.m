function figureHandle = trEPRguiSplashWindow(varargin)
% TREPRGUISPLASHWINDOW Display splash window for trEPR toolbox GUI while
% loading the main GUI.
%
% Usage
%   trEPRguiSplashWindow
%   figureHandle = trEPRguiSplashWindow
%
%   figureHandle - handle
%                  handle of the figure (useful for closing)

% Copyright (c) 2014, Till Biskup
% 2014-10-14

figureHandle = [];

if nargin && ischar(varargin{1})
    messageString = varargin{1};
else
    messageString = 'Initialising GUI...';
end

% Load image
try
    [mfilepath,~,~] = fileparts(mfilename('fullpath'));
    img = imread(fullfile(...
        mfilepath,'splashes','trEPRtoolboxSplash-300x300.png'),'png');
catch  %#ok<CTCH>
    return;
end

% Get sizes
imgSize = size(img);
screenSize = get(0,'ScreenSize');
textHeight = 25;

centerPosition = screenSize(3:4)/2;

% Try to get position and size of main Matlab window
try %#ok<TRYNC>
    desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
    sizeX = desktop.getMainFrame.getSize.getWidth;
    sizeY = desktop.getMainFrame.getSize.getHeight;
    posX = desktop.getMainFrame.getLocationOnScreen.getX;
    posY = desktop.getMainFrame.getLocationOnScreen.getY;
    centerPosition = round([posX+sizeX/2 screenSize(4)-posY-sizeY/2]);
end

% Define figure and message text area
% NOTE: Figure is set invisible for now...
figureHandle = figure(...
    'WindowStyle','modal',...
    'unit','pixels',...
    'position',[centerPosition(1)-imgSize(2)/2 ...
    centerPosition(2)-imgSize(1)/2 ...
    imgSize(2)-3 imgSize(1)-1+textHeight+5],...
    'Color',[0 0 0],...
    'MenuBar','none',...
    'NumberTitle','off',...
    'Name','trEPR toolbox GUI',...
    'Visible','off'...
    );
uicontrol('Tag','message',...
    'Style','text',...
    'parent',figureHandle,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Center',...
    'BackgroundColor',[0 0 0],...
    'ForegroundColor',[1 1 1],...
    'Visible','on',...
    'Units','pixels',...
    'String',messageString,...
    'Position',[0 0 imgSize(2) textHeight]...
    );

% Plot image
image(img); 
axis off; 
axis image; 
set(gca,'unit','pixels','position',[0 1+textHeight+5 imgSize(2)-1 imgSize(1)-1]);

% Make figure visible
set(figureHandle,'Visible','on');

end
