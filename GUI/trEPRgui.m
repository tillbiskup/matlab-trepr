function varargout = trEPRgui(varargin)
% TREPRGUI A GUI to display and process transient EPR data in Matlab.
%
% Main GUI window of the trEPR toolbox.
%
% Usage:
%
%   trEPRgui
%   handle = trEPRgui
%
% Note that you can only open one trEPRgui window at a time ("singleton"
% concept). Calling the function multiple times will only bring the current
% trEPRgui figure window in the foreground and make it active.

% Copyright (c) 2011-15, Till Biskup
% 2015-05-30

% Make GUI effectively a singleton
singleton = trEPRguiGetWindowHandle();
if ishghandle(singleton)
    figure(singleton);
    varargout{1} = singleton;
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Display "Splash"
hSplash = trEPRguiSplashWindow();

% Set some defaults in case configuration cannot be loaded
defaultBackground = [.9 .9 .9];
dx = 20;
dy = 40;

% Load configuration
conf = trEPRguiConfigLoad(mfilename);
% Assign config values from "general" to variables in function workspace
assignConfigValues(conf);

% Define main GUI window (figure)
hMainFigure = figure('Tag',mfilename,...
    'Visible','off',...
    'Name','trEPR GUI : Main Window',...
    'Units','Pixels',...
    'Position',[dx,dy,950,700],...
    'Resize','off',...
    'NumberTitle','off', ...
    'Menu','none','Toolbar','none',...
    'Color',defaultBackground,...
    'KeyPressFcn',@guiKeyBindings,...
    'CloseRequestFcn',@(~,~)guiClose);

% Create appdata structure
ad = trEPRguiDataStructure('guiappdatastructure');

appdataFields = fieldnames(ad);
for k=1:length(appdataFields)
    setappdata(hMainFigure,appdataFields{k},ad.(appdataFields{k}));
end

guiSize = get(hMainFigure,'Position');
guiSize = guiSize([3,4]);

% Set some default layout parameters
mainPanelWidth = 260;
mainToggleButtonWidth = floor(mainPanelWidth/3);

% Create the axes
% The mainAxes_panel contains all the axis-related ui elements
hPanelAxis = uipanel('Tag','mainAxes_panel',...
    'Parent',hMainFigure,...
    'Units','pixels',...
    'Position',[0,75,650,630],...
    'Title','',...
    'BorderType','none',...
    'BackgroundColor',defaultBackground,...
    'Visible','on'...
);

% Trick: Create axes in reverse order, as the last one "wins" in terms of
% "current axis handle"

axes(...         % axes for horizontal projection
    'Visible','off',...
    'Tag','horizontalAxis',...
	'Parent', hPanelAxis, ...
    'FontUnit','Pixel','Fontsize',14,...
    'Units', 'Pixels', ...
    'Box','on',...
    'Position',[120 95 450 50]);

axes(...         % axes for vertical projection
    'Visible','off',...
    'Tag','verticalAxis',...
	'Parent', hPanelAxis, ...
    'FontUnit','Pixel','Fontsize',14,...
    'Units', 'Pixels', ...
    'Box','on',...
    'Position',[70 145 50 450]);

axes(...         % the axes for plotting residuals
    'Visible','off',...
    'Tag','residualsAxis',...
	'Parent', hPanelAxis, ...
    'FontUnit','Pixel','Fontsize',14,...
    'Units', 'Pixels', ...
    'Box','on',...
    'Position',[70 95 500 50]);

hPlotAxes = axes(...         % the axes for plotting selected plot
    'Tag','mainAxis',...
	'Parent', hPanelAxis, ...
    'FontUnit','Pixel','Fontsize',14,...
    'Units', 'Pixels', ...
    'Position',[70 95 500 500]);
%    'HandleVisibility','callback', ...

% Create the sliders
slider_scroll_bgcolor = [1.0 0.7 0.7];
slider_scale_bgcolor = [1.0 1.0 0.8];
slider_displace_bgcolor = [0.8 1.0 1.0];

uicontrol('Tag','vert1_slider',...
    'Style', 'slider',...
	'Parent', hPanelAxis, ...
    'Min',1,'Max',100,'Value',50,...
    'Position', [595 95 15 500],...
    'BackgroundColor',slider_scroll_bgcolor,...
    'TooltipString','Scroll through dataset along second axes',...
    'Enable','off',...
    'Callback', {@slider_Callback,'scroll'}...
    );

uicontrol('Tag','vert2_slider',...
    'Style', 'slider',...
	'Parent', hPanelAxis, ...
    'Min',-1,'Max',1,'Value',0,...
    'Position', [615 95 15 500],...
    'BackgroundColor',slider_scale_bgcolor,...
    'TooltipString','Scale',...
    'Enable','off',...
    'Callback', {@slider_Callback,'scalev'}...
    );

uicontrol('Tag','vert3_slider',...
    'Style', 'slider',...
	'Parent', hPanelAxis, ...
    'Min',-1,'Max',1,'Value',0,...
    'Position', [635 95 15 500],...
    'BackgroundColor',slider_displace_bgcolor,...
    'TooltipString','Displace',...
    'Enable','off',...
    'Callback', {@slider_Callback,'displacev'}...
    );

uicontrol('Tag','horz1_slider',...
    'Style', 'slider',...
	'Parent', hPanelAxis, ...
    'Min',-1,'Max',1,'Value',0,...
    'Position', [70 20 500 15],...
    'BackgroundColor',slider_scale_bgcolor,...
    'TooltipString','Scale',...
    'Enable','off',...
    'Callback', {@slider_Callback,'scaleh'}...
    );

uicontrol('Tag','horz2_slider',...
    'Style', 'slider',...
	'Parent', hPanelAxis, ...
    'Min',-1,'Max',1,'Value',0,...
    'Position', [70 0 500 15],...
    'BackgroundColor',slider_displace_bgcolor,...
    'TooltipString','Displace',...
    'Enable','off',...
    'Callback', {@slider_Callback,'displaceh'}...
    );

uicontrol('Tag','scrollsliderdesc',...
    'Style','text',...
    'Parent',hPanelAxis,...
    'BackgroundColor',slider_scroll_bgcolor,...
    'Units','Pixels','Position',[595 80 15 15],...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Center',...
    'String',{'S'},...
    'ToolTipString',['<html>Scroll through currently active dataset<br>'...
    '(only active in 1D modes)<br>Key: <tt>s</tt>'],...
    'Enable','Inactive' ...
    );
uicontrol('Tag','vscalesliderdesc',...
    'Style','text',...
    'Parent',hPanelAxis,...
    'BackgroundColor',slider_scale_bgcolor,...
    'Units','Pixels','Position',[615 80 15 15],...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Center',...
    'String',{'C'},...
    'ToolTipString',['<html>Scale vertically through currently active'...
    'dataset<br>(only active in 1D modes)<br>Key: <tt>c</tt>'],...
    'Enable','Inactive' ...
    );
uicontrol('Tag','vdisplacesliderdesc',...
    'Style','text',...
    'Parent',hPanelAxis,...
    'BackgroundColor',slider_displace_bgcolor,...
    'Units','Pixels','Position',[635 80 15 15],...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Center',...
    'String',{'D'},...
    'ToolTipString',['<html>Displace currently active dataset vertically'...
    '<br>(only active in 1D modes)<br>Key: <tt>d</tt>'],...
    'Enable','Inactive' ...
    );
uicontrol('Tag','hscalesliderdesc',...
    'Style','text',...
    'Parent',hPanelAxis,...
    'BackgroundColor',slider_scale_bgcolor,...
    'Units','Pixels','Position',[570 20 15 15],...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Center',...
    'String',{'C'},...
    'ToolTipString',['<html>Scale horizontally through currently active'...
    'dataset<br>(only active in 1D modes)<br>Key: <tt>c</tt>'],...
    'Enable','Inactive' ...
    );
uicontrol('Tag','hdisplacesliderdesc',...
    'Style','text',...
    'Parent',hPanelAxis,...
    'BackgroundColor',slider_displace_bgcolor,...
    'Units','Pixels','Position',[570 0 15 15],...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Center',...
    'String',{'D'},...
    'ToolTipString',['<html>Displace currently active dataset horizontally'...
    '<br>(only active in 1D modes)<br>Key: <tt>d</tt>'],...
    'Enable','Inactive' ...
    );

% Create buttons closeby the main axes
uicontrol('Tag','export_button',...
    'Style','pushbutton',...
	'Parent', hPanelAxis, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Detach',...
    'TooltipString',['<html>Replot current display in independent '...
    'Matlab figure.<br>Useful for, e.g., enlarging the display.'],...
    'pos',[590 0 60 25],...
    'Enable','off',...
    'Callback',{@pushbutton_Callback,'detach'}...
    );
uicontrol('Tag','reset_button',...
    'Style','pushbutton',...
	'Parent', hPanelAxis, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Reset',...
    'TooltipString','Reset all slider settings to their default values',...
    'pos',[590 25 60 25],...
    'Enable','off',...
    'Callback',{@pushbutton_Callback,'reset'}...
    );
uicontrol('Tag','zoom_togglebutton',...
    'Style','togglebutton',...
	'Parent', hPanelAxis, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','+',...
    'TooltipString','Zoom into current axis display',...
    'pos',[600 50 25 25],...
    'Enable','off',...
    'Callback',{@togglebutton_Callback,'zoom'}...
    );
uicontrol('Tag','fullscale_pushbutton',...
    'Style','pushbutton',...
	'Parent', hPanelAxis, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','FS',...
    'TooltipString','Fullscale (reset zoom on main axes)',...
    'pos',[625 50 25 25],...
    'Enable','off',...
    'Callback',{@pushbutton_Callback,'fullscale'}...
    );

% Create (reserve) button list below horizontal sliders
% Create button group.
hbg_fb = uibuttongroup('Tag','functionButtonGroup',...
    'BackgroundColor',defaultBackground,...
    'BorderType','none',...
    'Units','Pixels',...
    'Position', [20 40 guiSize(1)-mainPanelWidth-90 25],...
    'Visible','off');
mainFbPanelWidth = get(hbg_fb,'Position');
mainFbPanelWidth = mainFbPanelWidth(3);
mainFbWidth = floor(mainFbPanelWidth/10);

uicontrol('Tag','functionButtonGroup_function1_pushbutton',...
    'Parent',hbg_fb,...
    'Style','pushbutton',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Help',...
    'TooltipString',['<html>Display help for how to operate the GUI<br>',...
    'Key: <tt>F1</tt>'],...
    'pos',[0*mainFbWidth 0 mainFbWidth 25],...
    'Enable','on',...
    'Callback',{@(~,~)trEPRgui_helpwindow} ...
    );
uicontrol('Tag','functionButtonGroup_function2_pushbutton',...
    'Parent',hbg_fb,...
    'Style','pushbutton',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','About',...
    'TooltipString',['<html>Open "Help:About" window with basic information',...
    '<br>about the GUI and toolbox<br>Key: <tt>F2</tt>'],...
    'pos',[1*mainFbWidth 0 mainFbWidth 25],...
    'Enable','on',...
    'Callback','trEPRgui_aboutwindow'...
    );
uicontrol('Tag','functionButtonGroup_function3_pushbutton',...
    'Parent',hbg_fb,...
    'Style','pushbutton',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Info',...
    'TooltipString',['<html>Show information about currently active dataset',...
    '<br>Key: <tt>F3</tt>'],...
    'pos',[2*mainFbWidth 0 mainFbWidth 25],...
    'Enable','on',...
    'Callback','trEPRgui_infowindow'...
    );
uicontrol('Tag','functionButtonGroup_function4_pushbutton',...
    'Parent',hbg_fb,...
    'Style','pushbutton',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','ACC',...
    'TooltipString',['<html>Accumulate (currently visible) datasets<br />',...
    'Key: <tt>F4</tt>'],...
    'pos',[3*mainFbWidth 0 mainFbWidth 25],...
    'Enable','on',...
    'Callback',{@trEPRgui_ACCwindow}...
    );
uicontrol('Tag','functionButtonGroup_function5_pushbutton',...
    'Parent',hbg_fb,...
    'Style','pushbutton',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','AVG',...
    'TooltipString',['<html>Average currently active dataset over time window',...
    '<br>Key: F5</tt>'],...
    'pos',[4*mainFbWidth 0 mainFbWidth 25],...
    'Enable','on',...
    'Callback',{@trEPRgui_AVGwindow}...
    );
uicontrol('Tag','functionButtonGroup_function6_pushbutton',...
    'Parent',hbg_fb,...
    'Style','pushbutton',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','BLC',...
    'TooltipString',['<html>Perform baseline correction (BLC)<br>',...
    'on currently active dataset<br>Key: <tt>F6</tt>'],...
    'pos',[5*mainFbWidth 0 mainFbWidth 25],...
    'Enable','on',...
    'Callback',{@trEPRgui_BLCwindow}...
    );
uicontrol('Tag','functionButtonGroup_function7_pushbutton',...
    'Parent',hbg_fb,...
    'Style','pushbutton',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Fit',...
    'TooltipString',['<html>Show basic fitting options for currently ',...
    'active dataset<br>Key: <tt>F7</tt>'],...
    'pos',[6*mainFbWidth 0 mainFbWidth 25],...
    'Enable','off'...
    );
uicontrol('Tag','functionButtonGroup_function8_pushbutton',...
    'Parent',hbg_fb,...
    'Style','pushbutton',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Sim',...
    'TooltipString',['<html>Simulate TREPR spectra<br>Key: <tt>F8</tt>'...
    '<br>(<em>Please note:</em> Needs additional module)'],...
    'pos',[7*mainFbWidth 0 mainFbWidth 25],...
    'Enable','off'...
    );
uicontrol('Tag','functionButtonGroup_function9_pushbutton',...
    'Parent',hbg_fb,...
    'Style','pushbutton',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','FFT',...
    'TooltipString',['<html>Perform FFT on currently active dataset',...
    '<br>Key: <tt>F9</tt>'],...
    'pos',[8*mainFbWidth 0 mainFbWidth 25],...
    'Enable','off'...
    );
uicontrol('Tag','functionButtonGroup_function10_pushbutton',...
    'Parent',hbg_fb,...
    'Style','pushbutton',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Status',...
    'TooltipString',['<html>Show status window',...
    'Key: <tt>F10</tt>'],...
    'pos',[9*mainFbWidth 0 mainFbWidth 25],...
    'Enable','on',...
    'Callback',@trEPRgui_statuswindow...
    );

% Create help button
uicontrol('Tag','help_pushbutton',...
    'Style','pushbutton',...
    'BackgroundColor',defaultBackground,...
    'ForegroundColor',[0 0 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'FontWeight','bold',...
    'String','?',...
    'TooltipString','Display help for how to operate the GUI',...
    'pos',[guiSize(1)-mainPanelWidth-65 40 25 25],...
    'Enable','on', ...
    'Callback',{@contextHelp} ...
    );


% Create button group, toggle buttons and main panels
% Create the button group.
hbg = uibuttongroup('Tag','mainButtonGroup',...
    'BackgroundColor',defaultBackground,...
    'BorderType','none',...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position', [guiSize(1)-mainPanelWidth-20 guiSize(2)-110 mainPanelWidth 90],...
    'Visible','off');
% Create toggle buttons in the button group.
uicontrol('Tag','tbLoad',...
    'Style','Toggle',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Load',...
    'TooltipString','Load files',...
    'pos',[0 60 mainToggleButtonWidth 30],...
    'parent',hbg,...
    'HandleVisibility','off');
uicontrol('Tag','tbDatasets',...
    'Style','Toggle',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Datasets',...
    'TooltipString','Display loaded data/toggle visible data',...
    'pos',[mainToggleButtonWidth 60 mainToggleButtonWidth 30],...
    'parent',hbg,...
    'HandleVisibility','off');
uicontrol('Tag','tbSlider',...
    'Style','Toggle',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Slider',...
    'TooltipString','Display the slider values',...
    'pos',[mainToggleButtonWidth*2 60 mainToggleButtonWidth 30],...
    'parent',hbg,...
    'HandleVisibility','off');
uicontrol('Tag','tbMeasure',...
    'Style','Toggle',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Measure',...
    'TooltipString','Measure distances and positions in data',...
    'pos',[0 30 mainToggleButtonWidth 30],...
    'parent',hbg,...
    'HandleVisibility','off');
uicontrol('Tag','tbDisplay',...
    'Style','Toggle',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Display',...
    'TooltipString','Display settings, export current display, ...',...
    'pos',[mainToggleButtonWidth 30 mainToggleButtonWidth 30],...
    'parent',hbg,...
    'HandleVisibility','off');
uicontrol('Tag','tbProcessing',...
    'Style','Toggle',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Processing',...
    'TooltipString','(Pre)processing of datasets (POC, BGC, BLC, ACC), smoothing',...
    'pos',[mainToggleButtonWidth*2 30 mainToggleButtonWidth 30],...
    'parent',hbg,...
    'HandleVisibility','off');
uicontrol('Tag','tbAnalysis',...
    'Style','Toggle',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Analysis',...
    'TooltipString','Data analysis tools',...
    'pos',[0 0 mainToggleButtonWidth 30],...
    'parent',hbg,...
    'HandleVisibility','off');
uicontrol('Tag','tbInternal',...
    'Style','Toggle',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Internal',...
    'TooltipString','GUI internals',...
    'pos',[mainToggleButtonWidth 0 mainToggleButtonWidth 30],...
    'parent',hbg,...
    'HandleVisibility','off');
uicontrol('Tag','tbConfigure',...
    'Style','Toggle',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Configure',...
    'TooltipString','Configure GUI',...
    'pos',[mainToggleButtonWidth*2 0 mainToggleButtonWidth 30],...
    'parent',hbg,...
    'HandleVisibility','off');

% Create the main control panels

try
    panelLoad(...
        hMainFigure,...
        [guiSize(1)-mainPanelWidth-20 100 mainPanelWidth guiSize(2)-220]);
    
    panelDatasets(...
        hMainFigure,...
        [guiSize(1)-mainPanelWidth-20 100 mainPanelWidth guiSize(2)-220]);
    
    panelSlider(...
        hMainFigure,...
        [guiSize(1)-mainPanelWidth-20 100 mainPanelWidth guiSize(2)-220]);
    
    panelMeasure(...
        hMainFigure,...
        [guiSize(1)-mainPanelWidth-20 100 mainPanelWidth guiSize(2)-220]);
    
    panelDisplay(...
        hMainFigure,...
        [guiSize(1)-mainPanelWidth-20 100 mainPanelWidth guiSize(2)-220]);
    
    panelProcessing(...
        hMainFigure,...
        [guiSize(1)-mainPanelWidth-20 100 mainPanelWidth guiSize(2)-220]);
    
    panelAnalysis(...
        hMainFigure,...
        [guiSize(1)-mainPanelWidth-20 100 mainPanelWidth guiSize(2)-220]);
    
    panelInternal(...
        hMainFigure,...
        [guiSize(1)-mainPanelWidth-20 100 mainPanelWidth guiSize(2)-220]);
    
    panelConfigure(...
        hMainFigure,...
        [guiSize(1)-mainPanelWidth-20 100 mainPanelWidth guiSize(2)-220]);
catch exception
    % Hm... something serious must have gone wrong...
    rethrow(exception);
end

% Create display style control parts below main panels
hp_displaytype = uipanel('Tag','displaytype_panel',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[guiSize(1)-mainPanelWidth-20 40 mainPanelWidth-100 50],...
    'Title','Display type'...
    );
uicontrol('Tag','displaytype_popupmenu',...
    'Style','popupmenu',...
    'Parent',hp_displaytype,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 mainPanelWidth-120 20],...
    'String','2D|x (time)|y (field)',...
    'Callback', {@popupmenu_Callback,'displaytype'}...
    );
uicontrol('Tag','previous_pushbutton',...
    'Style','pushbutton',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[guiSize(1)-110 40 45 45],...
    'FontWeight','normal',...
    'String','<<',...
    'TooltipString','<html>Show previous spectrum<br>Key: <tt>Page up</tt>',...
    'Callback',{@pushbutton_Callback,'previous'}...
    );
uicontrol('Tag','next_pushbutton',...
    'Style','pushbutton',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[guiSize(1)-65 40 45 45],...
    'FontWeight','normal',...
    'String','>>',...
    'TooltipString','<html>Show next spectrum<br>Key: <tt>Page down</tt>',...
    'Callback',{@pushbutton_Callback,'next'}...
    );

% Add command panel for script command functionality
hp_command = uipanel('Tag','command_panel',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'BorderType','none',...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[20 10 guiSize(1)-mainPanelWidth-60 25]...
    );
uicontrol('Tag','command_panel_edit',...
    'Style','edit',...
    'Parent',hp_command,...
    'BackgroundColor',[.95 .95 .95],...
    'ForegroundColor',[.25 .25 .25],...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Left',...
    'FontName','Monospaced',...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[0 0 guiSize(1)-mainPanelWidth-135 25],...
    'String','Enter command - Ctrl-l / Cmd-l for access',...
    'KeyPressFcn',@command_keypress_Callback,...
    'Callback',{@command_Callback}...
    );
uicontrol('Tag','command_panel_history_pushbutton',...
    'Style','pushbutton',...
    'Parent',hp_command,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[guiSize(1)-mainPanelWidth-134 0 25 25],...
    'FontWeight','normal',...
    'String','H',...
    'TooltipString','Show history of CMD',...
    'Callback',{@trEPRgui_cmd_historywindow}...
    );
uicontrol('Tag','command_panel_execute_pushbutton',...
    'Style','pushbutton',...
    'Parent',hp_command,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[guiSize(1)-mainPanelWidth-109 0 25 25],...
    'FontWeight','normal',...
    'String','E',...
    'TooltipString',sprintf('%s\n%s',...
    'Execute script on the CMD',...
    '(Opens GUI allowing to select the appropriate script)'),...
    'Callback',{@pushbutton_Callback,'cmdExecuteScript'}...
    );
uicontrol('Tag','command_panel_help_pushbutton',...
    'Style','pushbutton',...
    'Parent',hp_command,...
    'BackgroundColor',defaultBackground,...
    'ForegroundColor',[0 0 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[guiSize(1)-mainPanelWidth-84 0 25 25],...
    'FontWeight','bold',...
    'String','?',...
    'TooltipString',['<html>Show help for CMD<br>'...
    'Alternative: commands <tt>help</tt> or <tt>?</tt> on the CMD'],...
    'Callback',{@pushbutton_Callback,'cmdHelpwindow'}...
    );

% Add status panel for displaying some status things
hp_status = uipanel('Tag','status_panel',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'BorderType','none',...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[guiSize(1)-mainPanelWidth-20 10 mainPanelWidth 25]...
    );
uicontrol('Tag','status_panel_mode_desctext',...
    'Style','text',...
    'Parent',hp_status,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Right',...
    'Position',[0 5 20 15],...
    'ToolTipString','Mode indicator of GUI',...
    'String',{'M: '}...
    );
uicontrol('Tag','status_panel_mode_text',...
    'Style','text',...
    'Parent',hp_status,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'Position',[20 5 140 15],...
    'ToolTipString','Mode indicator of GUI',...
    'String',{'None'}...
    );
uicontrol('Tag','status_panel_normalisation_desctext',...
    'Style','text',...
    'Parent',hp_status,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Right',...
    'Position',[160 5 20 15],...
    'String',{'N: '},...
    'ToolTipString','Normalisation currently in use (no, 1D, 2D)'...
    );
uicontrol('Tag','status_panel_normalisation_text',...
    'Style','text',...
    'Parent',hp_status,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Center',...
    'Position',[180 5 30 15],...
    'String',{'no'},...
    'ToolTipString','Normalisation currently in use (no, 1D, 2D)'...
    );
uicontrol('Tag','status_panel_status_desctext',...
    'Style','text',...
    'Parent',hp_status,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Right',...
    'Position',[210 5 20 15],...
    'String',{'S: '},...
    'ToolTipString',sprintf('%s\n%s',...
        'Status indicator of the GUI (OK, WW, EE)',...
        'Click on coloured area on the right to open status window.')...
    );
uicontrol('Tag','status_panel_status_text',...
    'Style','text',...
    'Parent',hp_status,...
    'BackgroundColor',[.7 .9 .7],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Center',...
    'Position',[230 5 30 15],...
    'String',{'OK'},...
    'Enable','Inactive',...
    'ButtonDownFcn',@trEPRgui_statuswindow ...
    );



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Apply configuration
guiConfigApply(mfilename);
% Get appdata for immediate use
ad = getappdata(hMainFigure);

% Initialize some button group properties. 
set(hbg,'SelectionChangeFcn',{@tbg_Callback});
set(hbg,'Visible','on');
    
set(hbg_fb,'Visible','on');

% Display splash image in main axes
try
    set(hMainFigure,'CurrentAxes',hPlotAxes);
    [path,~,~] = fileparts(mfilename('fullpath'));
    splash = imread(fullfile(path,...
        'private','splashes','trEPRtoolboxSplash.png'),'png');
    image(splash);
    axis off          % Remove axis ticks and numbers
catch exception
    % If this happens, something probably more serious went wrong...
    throw(exception);
end

gh = guihandles;
gh.mainAxis = hPlotAxes;
guidata(hMainFigure,gh);
if (nargout == 1)
    varargout{1} = hMainFigure;
end

set(gh.load_panel,'Visible','on');

% Add keypress function to every element that can have one...
handles = findall(...
    allchild(hMainFigure),'style','pushbutton',...
    '-or','style','togglebutton',...
    '-or','style','listbox',...
    '-or','style','checkbox',...
    '-or','style','slider',...
    '-or','style','popupmenu',...
    '-not','tag','command_panel_edit');
for k=1:length(handles)
    set(handles(k),'KeyPressFcn',@guiKeyBindings);
end

% As Matlab seems to ignore me four lines above, set the KeyPressFcn again
% for the command line edit control
set(gh.command_panel_edit,'KeyPressFcn',@command_keypress_Callback);

% Enable sim button if applicable
if exist('trEPRgui_SIMwindow','file')
    set(gh.functionButtonGroup_function8_pushbutton,'Enable','On',...
        'Callback','trEPRgui_SIMwindow');
end

% Set directories
dirs = fieldnames(ad.control.dirs);
% Parse directory strings using "trEPRparseDir"
for k=1:length(dirs)
    ad.control.dirs.(dirs{k}) = trEPRparseDir(ad.control.dirs.(dirs{k}));
end
setappdata(hMainFigure,'control',ad.control);

% Start garbage collector
guiGarbageCollector('start');

% Check for saved history
if exist(trEPRparseDir(ad.control.cmd.historyfile),'file')
    ad.control.cmd.history = ...
        textFileRead(trEPRparseDir(ad.control.cmd.historyfile));
end

% Check whether to save history -- and if so, write time stamp
if ad.control.cmd.historysave
    timeStamp = ['%-- ' datestr(now,'yyyy-mm-dd HH:MM') ' --%'];
    [histsavestat,histsavewarn] = trEPRgui_cmd_writeToFile(timeStamp);
    if histsavestat
        trEPRmsg(histsavewarn,'warn');
    end
end

% Make the GUI visible.
set(hMainFigure,'Visible','on');
if ishandle(hSplash)
    delete(hSplash);
end

% Be very careful, such as not to break old installations without updated
% config files
if isfield(ad.configuration,'start')
    if isfield(ad.configuration.start,'statuswindow') && ...
            ad.configuration.start.statuswindow
        trEPRgui_statuswindow();
    end
    if isfield(ad.configuration.start,'welcome') ...
            && ad.configuration.start.welcome
        trEPRgui_helpwindow('page','welcome');
    end
    if isfield(ad.configuration.start,'tip') && ...
            ad.configuration.start.tip
        showTips = showTip('File',fullfile(...
            trEPRinfo('dir'),'GUI','private','helptexts','tips.txt'),...
            'ShowTip',logical(ad.configuration.start.tip));
        if ~showTips
            conf = trEPRguiConfigLoad(mfilename);
            conf.start.tip = showTips;
            warnings = guiConfigWrite(mfilename,conf);
            if warnings
                trEPRmsg(warnings,'warning');
            end
        end
    end
end
    
setappdata(hMainFigure,'control',ad.control);

% Check for updates - use special function with timer to prevent slow or
% not-existing internet connections from slowing down GUI start
if ad.configuration.start.updatecheck
    trEPRguiUpdateCheck;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function slider_Callback(source,~,action)
    try
        % Get appdata of main window
        mainWindow = trEPRguiGetWindowHandle();
        ad = getappdata(mainWindow);

        guiZoom('off');
        
        active = ad.control.data.active;
        
        % Depending on display type settings
        switch lower(action)
            case 'scroll'
                switch lower(ad.control.axis.displayType)
                    case '2d plot'
                        return;
                    case '1d along x'
                        ad.data{active}.display.position.data(2) = ...
                            int16(get(source,'Value'));
                    case '1d along y'
                        ad.data{active}.display.position.data(1) = ...
                            int16(get(source,'Value'));
                end
            case 'displaceh'
                switch ad.control.axis.displayType
                    case {'2D plot','1D along x'}
                        ad.data{active}.display.displacement.data(1) = ...
                            get(source,'Value');
                    case '1D along y'
                        ad.data{active}.display.displacement.data(2) = ...
                            get(source,'Value');
                    otherwise
                        trEPRoptionUnknown(ad.control.axis.displayType,...
                            'display type');
                end
            case 'displacev'
                switch ad.control.axis.displayType
                    case '2D plot'
                        ad.data{active}.display.displacement.data(2) = ...
                            get(source,'Value');
                    case {'1D along x','1D along y'}
                        ad.data{active}.display.displacement.data(3) = ...
                            get(source,'Value');
                    otherwise
                        trEPRoptionUnknown(ad.control.axis.displayType,...
                            'display type');
                end
            case 'scaleh'
                % Convert slider value to scaling factor
                if (get(source,'Value') > 0)
                    scalingFactor = get(source,'Value')+1;
                else
                    scalingFactor = 1/(abs(get(source,'Value'))+1);
                end
                
                % Depending on display type settings
                switch ad.control.axis.displayType
                    case {'2D plot','1D along x'}
                        ad.data{active}.display.scaling.data(1) = scalingFactor;
                    case '1D along y'
                        ad.data{active}.display.scaling.data(2) = scalingFactor;
                    otherwise
                        trEPRoptionUnknown(ad.control.axis.displayType,...
                            'display type');
                end
            case 'scalev'
                % Convert slider value to scaling factor
                if (get(source,'Value') > 0)
                    scalingFactor = get(source,'Value')+1;
                else
                    scalingFactor = 1/(abs(get(source,'Value'))+1);
                end
                switch lower(ad.control.axis.displayType)
                    case '2d plot'
                        ad.data{active}.display.scaling.data(2) = scalingFactor;
                    case {'1d along x','1d along y'}
                        ad.data{active}.display.scaling.data(3) = scalingFactor;
                end
            otherwise
                trEPRoptionUnknown(action);
                return;
        end
        
        % Update appdata of main window
        setappdata(mainWindow,'data',ad.data);
        
        % Update slider panel
        update_sliderPanel();
        
        %Update main axis
        update_mainAxis();
    catch exception
        trEPRexceptionHandling(exception)
    end
end

function togglebutton_Callback(source,~,action)
    try
        % Get appdata of main window
        mainWindow = trEPRguiGetWindowHandle();
        ad = getappdata(mainWindow);
        gh = guihandles(mainWindow);
        
        switch lower(action)
            case 'zoom'
                if (get(source,'Value'))
                    guiZoom('on');
                    trEPRguiSetMode('zoom');
                else
                    guiZoom('off');
                    trEPRguiSetMode('none');
                end
            otherwise
                trEPRoptionUnknown(action)
                return;
        end
    catch exception
        trEPRexceptionHandling(exception)
    end
end

function pushbutton_Callback(source,~,action)
    try
        % Get appdata of main window
        mainWindow = trEPRguiGetWindowHandle();
        ad = getappdata(mainWindow);
        
        active = ad.control.data.active;

        switch lower(action)
            case 'fullscale'
                guiZoom('reset');
                trEPRguiSetMode('none');
                return;
            case 'reset'
                if (get(source,'Value') == 0) || ~active || isempty(active)
                    return;
                end
                cmdReset(mainWindow,{});
                return;
            case 'detach'
                % Open new figure window
                newFig = figure();
                
                % Plot into new figure window
                update_mainAxis(newFig);
                return;
            case 'next'
                cmdShow(mainWindow,{'next'});
                return;
            case 'previous'
                cmdShow(mainWindow,{'prev'});
                return;
            case 'cmdexecutescript'
                trEPRgui_cmd_scriptSelectWindow();
            case 'cmdhelpwindow'
                trEPRgui_cmd_helpwindow();
                return;
            otherwise
                trEPRoptionUnknown(action);
                return;
        end
    catch exception
        trEPRexceptionHandling(exception)
    end
end

function tbg_Callback(source,~)
    try 
        status = switchMainPanel(get(get(source,'SelectedObject'),'String'));
        
        if status
            st = dbstack;
            trEPRmsg(...
                [st.name ' :' ...
                'Something went wrong with switching the panels.'],...
                'warning');
        end
    catch exception
        trEPRexceptionHandling(exception)
    end
end

function popupmenu_Callback(source,~,action)
    try
        % Get appdata of main window
        mainWindow = trEPRguiGetWindowHandle;
        ad = getappdata(mainWindow);
        
        switch lower(action)
            case 'displaytype'
                displayTypes = cellstr(get(source,'String'));
                switch lower(displayTypes{get(source,'Value')})
                    case '2d'
                        ad.control.axis.displayType = '2D plot';
                    case 'x (time)'
                        ad.control.axis.displayType = '1D along x';
                    case 'y (field)'
                        ad.control.axis.displayType = '1D along y';
                end                
                % Update appdata of main window
                setappdata(mainWindow,'control',ad.control);
                
                update_mainAxis();
                axesResize();
            otherwise
                trEPRoptionUnknown(action);
                return;
        end
    catch exception
        trEPRexceptionHandling(exception)
    end
end

function command_Callback(source,~)
    try
        [status,warning] = trEPRguiCommand(get(source,'String'));
        % In case that the command ended the GUI, check for its existence
        if isempty(trEPRguiGetWindowHandle)
            return;
        end
        if status && ~isempty(warning)
            trEPRmsg(warning,'warning');
        end
        set(source,'String','');
    catch exception
        trEPRexceptionHandling(exception)
    end
end

function command_keypress_Callback(source,evt)
    try
        % Get appdata of main window
        mainWindow = trEPRguiGetWindowHandle;
        ad = getappdata(mainWindow);
        
        switch evt.Key
            case 'uparrow'
                if ad.control.cmd.historypos
                    set(source,'String',ad.control.cmd.history{...
                        ad.control.cmd.historypos});
                    ad.control.cmd.historypos = ad.control.cmd.historypos-1;
                end
            case 'downarrow'
                if ad.control.cmd.historypos < length(ad.control.cmd.history)
                    set(source,'String',ad.control.cmd.history{...
                        ad.control.cmd.historypos+1});
                    ad.control.cmd.historypos = ad.control.cmd.historypos+1;
                else
                    set(source,'String','');
                end
            otherwise
                guiKeyBindings(source,evt);
                return;
        end
        setappdata(mainWindow,'control',ad.control);
    catch exception
        trEPRexceptionHandling(exception)
    end
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Helper functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function contextHelp(~,~)

try
    % Get appdata of main window
    mainWindow = trEPRguiGetWindowHandle;
    ad = getappdata(mainWindow);
    
    trEPRgui_helpwindow('page',['panels/' ad.control.panels.active])
catch exception
    trEPRexceptionHandling(exception)
end

end

function assignConfigValues(conf)

if ~isempty(fieldnames(conf)) && isfield(conf,'general')
    generalFields = fieldnames(conf.general);
    for field = 1:length(generalFields)
        assignin('caller',generalFields{field},...
            conf.general.(generalFields{field}));
    end
end

end
