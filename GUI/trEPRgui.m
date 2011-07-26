function varargout = trEPRgui(varargin)
% TREPRGUI Brief description of GUI.
%          Comments displayed at the command line in response 
%          to the help command. 

% (Leave a blank line following the help.)

% Make GUI effectively a singleton
singleton = findobj('Tag','trepr_gui_mainwindow');
if (singleton)
    figure(singleton);
    varargout{1} = singleton;
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hMainFigure = figure('Tag','trepr_gui_mainwindow',...
    'Visible','off',...
    'Name','trEPR GUI : Main Window',...
    'Units','Pixels',...
    'Position',[20,40,950,680],...
    'Resize','off',...
    'NumberTitle','off', ...
    'Menu','none','Toolbar','none',...
    'KeyPressFcn',@keyBindings,...
    'CloseRequestFcn',@closeGUI);

% Create appdata structure
ad = struct();
% data - empty cell array
ad.data = cell(0);
% origdata - empty cell array
ad.origdata = cell(0);
% configuration - struct
ad.configuration = struct();
ad.configuration.display = struct();
ad.configuration.display.highlight = struct();
ad.configuration.display.highlight.method = 'color';
ad.configuration.display.highlight.value = 'b';
ad.configuration.display.labels = struct();
ad.configuration.display.labels.x.measure = 'index';
ad.configuration.display.labels.x.unit = 'points';
ad.configuration.display.labels.y.measure = 'index';
ad.configuration.display.labels.y.unit = 'points';
ad.configuration.display.labels.z.measure = 'index';
ad.configuration.display.labels.z.unit = 'points';
ad.configuration.measure.setslider = 1;
% control - struct
ad.control = struct();
% control.status - empty struct
ad.control.status = cell(0);
% control.measure - struct
ad.control.measure = struct();
ad.control.measure.point = 0;
ad.control.measure.nPoints = 0;
ad.control.measure.setslider = 1;
% control.spectra - struct
ad.control.spectra = struct();
ad.control.spectra.active = 0;
ad.control.spectra.invisible = [];
ad.control.spectra.visible = [];
ad.control.spectra.modified = [];
ad.control.spectra.missing = [];
% control.axis - struct
ad.control.axis = struct();
ad.control.axis.displayType = '';
ad.control.axis.grid = struct();
ad.control.axis.grid.x = 'off';
ad.control.axis.grid.y = 'off';
ad.control.axis.grid.minor = 'off';
ad.control.axis.grid.zero = true;
ad.control.axis.highlight = struct();
ad.control.axis.highlight.method = ...
    ad.configuration.display.highlight.method;
ad.control.axis.highlight.value = ...
    ad.configuration.display.highlight.value;
ad.control.axis.legend = struct();
ad.control.axis.legend.location = 'none';
ad.control.axis.labels = struct();
ad.control.axis.labels.x = struct();
ad.control.axis.labels.x.measure = ...
    ad.configuration.display.labels.x.measure;
ad.control.axis.labels.x.unit = ...
    ad.configuration.display.labels.x.unit;
ad.control.axis.labels.y = struct();
ad.control.axis.labels.y.measure = ...
    ad.configuration.display.labels.y.measure;
ad.control.axis.labels.y.unit = ...
    ad.configuration.display.labels.y.unit;
ad.control.axis.labels.z = struct();
ad.control.axis.labels.z.measure = ...
    ad.configuration.display.labels.z.measure;
ad.control.axis.labels.z.unit = ...
    ad.configuration.display.labels.z.unit;
ad.control.axis.limits = struct();
ad.control.axis.limits.auto = true;
ad.control.axis.limits.x = struct();
ad.control.axis.limits.x.min = 0;
ad.control.axis.limits.x.max = 1;
ad.control.axis.limits.y = struct();
ad.control.axis.limits.y.min = 0;
ad.control.axis.limits.y.max = 1;
ad.control.axis.limits.z = struct();
ad.control.axis.limits.z.min = 0;
ad.control.axis.limits.z.max = 1;
ad.control.axis.normalisation = 'none';
% control.system - struct
ad.control.system = struct();
% Get username of current user
% In worst case, username is an empty string. So nothing should really rely
% on it.
% Windows style
ad.control.system.username = getenv('UserName');
% Unix style
if isempty(ad.control.system.username)
    ad.control.system.username = getenv('USER'); 
end
ad.control.system.platform = deblank(platform);
ad.control.system.matlab = version;
ad.control.system.trEPR = trEPRtoolboxRevision;

setappdata(hMainFigure,'data',ad.data);
setappdata(hMainFigure,'origdata',ad.origdata);
setappdata(hMainFigure,'configuration',ad.configuration);
setappdata(hMainFigure,'control',ad.control);


defaultBackground = get(hMainFigure,'Color');
guiSize = get(hMainFigure,'Position');
guiSize = guiSize([3,4]);

% Set some default layout parameters
mainPanelWidth = 260;
mainToggleButtonWidth = floor(mainPanelWidth/3);

% Create the main axis
% The mainAxes_panel contains all the axis-related ui elements
hPanelAxis = uipanel('Tag','mainAxes_panel',...
    'Parent',hMainFigure,...
    'Units','pixels',...
    'Position',[0,55,650,630],...
    'Title','',...
    'BorderType','none',...
    'BackgroundColor',defaultBackground,...
    'Visible','off',...
    'Visible','on'...
);

hPlotAxes = axes(...         % the axes for plotting selected plot
    'Tag','mainAxis',...
	'Parent', hPanelAxis, ...
    'FontUnit','Pixel','Fontsize',12,...
    'Units', 'Pixels', ...
    'Position',[70 95 500 500]);
%    'HandleVisibility','callback', ...

% Create the sliders
sl1_bgcolor = [1.0 0.7 0.7];
sl2_bgcolor = [1.0 1.0 0.8];
sl3_bgcolor = [0.8 1.0 1.0];

uicontrol('Tag','vert1_slider',...
    'Style', 'slider',...
	'Parent', hPanelAxis, ...
    'Min',1,'Max',100,'Value',50,...
    'Position', [595 95 15 500],...
    'BackgroundColor',sl1_bgcolor,...
    'TooltipString','Scroll through dataset along second axes',...
    'Enable','off',...
    'Callback', {@slider_v1_Callback}...
    );

uicontrol('Tag','vert2_slider',...
    'Style', 'slider',...
	'Parent', hPanelAxis, ...
    'Min',-1,'Max',1,'Value',0,...
    'Position', [615 95 15 500],...
    'BackgroundColor',sl2_bgcolor,...
    'TooltipString','Scale',...
    'Enable','off',...
    'Callback', {@slider_v2_Callback}...
    );

uicontrol('Tag','vert3_slider',...
    'Style', 'slider',...
	'Parent', hPanelAxis, ...
    'Min',-1,'Max',1,'Value',0,...
    'Position', [635 95 15 500],...
    'BackgroundColor',sl3_bgcolor,...
    'TooltipString','Displace',...
    'Enable','off',...
    'Callback', {@slider_v3_Callback}...
    );

uicontrol('Tag','horz1_slider',...
    'Style', 'slider',...
	'Parent', hPanelAxis, ...
    'Min',-1,'Max',1,'Value',0,...
    'Position', [70 20 500 15],...
    'BackgroundColor',sl2_bgcolor,...
    'TooltipString','Scale',...
    'Enable','off',...
    'Callback', {@slider_h1_Callback}...
    );

uicontrol('Tag','horz2_slider',...
    'Style', 'slider',...
	'Parent', hPanelAxis, ...
    'Min',-1,'Max',1,'Value',0,...
    'Position', [70 0 500 15],...
    'BackgroundColor',sl3_bgcolor,...
    'TooltipString','Displace',...
    'Enable','off',...
    'Callback', {@slider_h2_Callback}...
    );

uipanel(...
	'Parent', hPanelAxis, ...
    'Units','pixels','Position', [595 80 15 15],...
    'BorderType','none',...
    'BackgroundColor',sl1_bgcolor,...
    'Visible','on'...
    );
uipanel(...
	'Parent', hPanelAxis, ...
    'Units','pixels','Position', [615 80 15 15],...
    'BorderType','none',...
    'BackgroundColor',sl2_bgcolor,...
    'Visible','on'...
    );
uipanel(...
	'Parent', hPanelAxis, ...
    'Units','pixels','Position', [635 80 15 15],...
    'BorderType','none',...
    'BackgroundColor',sl3_bgcolor,...
    'Visible','on'...
    );
uipanel(...
	'Parent', hPanelAxis, ...
    'Units','pixels','Position', [570 20 15 15],...
    'BorderType','none',...
    'BackgroundColor',sl2_bgcolor,...
    'Visible','on'...
    );
uipanel(...
	'Parent', hPanelAxis, ...
    'Units','pixels','Position', [570 0 15 15],...
    'BorderType','none',...
    'BackgroundColor',sl3_bgcolor,...
    'Visible','on'...
    );

% Create buttons closeby the main axes
uicontrol('Tag','export_button',...
    'Style','pushbutton',...
	'Parent', hPanelAxis, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Export',...
    'TooltipString','Export current display as graphics file',...
    'pos',[590 0 60 25],...
    'Enable','off'...
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
    'Callback',{@reset_pushbutton_Callback}...
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
    'Callback',{@zoom_togglebutton_Callback}...
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
    'Callback',{@fullscale_pushbutton_Callback}...
    );

% Create (reserve) button list below horizontal sliders
% Create button group.
hbg_fb = uibuttongroup('Tag','functionButtonGroup',...
    'BackgroundColor',defaultBackground,...
    'BorderType','none',...
    'Units','Pixels',...
    'Position', [20 20 guiSize(1)-mainPanelWidth-60 25],...
    'Visible','off');
mainFbPanelWidth = get(hbg_fb,'Position');
mainFbPanelWidth = mainFbPanelWidth(3);
mainFbWidth = floor(mainFbPanelWidth/9);

uicontrol('Tag','functionButtonGroup_function1_pushbutton',...
    'Parent',hbg_fb,...
    'Style','pushbutton',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','About',...
    'TooltipString','Open "Help:About" window with basic information about the GUI and toolbox (F1)',...
    'pos',[0*mainFbWidth 0 mainFbWidth 25],...
    'Enable','on',...
    'Callback','trEPRgui_aboutwindow'...
    );
uicontrol('Tag','functionButtonGroup_function2_pushbutton',...
    'Parent',hbg_fb,...
    'Style','pushbutton',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Info',...
    'TooltipString','Show information about currently active dataset (F2)',...
    'pos',[1*mainFbWidth 0 mainFbWidth 25],...
    'Enable','off'...
    );
uicontrol('Tag','functionButtonGroup_function3_pushbutton',...
    'Parent',hbg_fb,...
    'Style','pushbutton',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','BLC',...
    'TooltipString','Perform baseline correction (BLC) on currently active dataset (new window, F3)',...
    'pos',[2*mainFbWidth 0 mainFbWidth 25],...
    'Enable','off'...
    );
uicontrol('Tag','functionButtonGroup_function4_pushbutton',...
    'Parent',hbg_fb,...
    'Style','pushbutton',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','ACC',...
    'TooltipString','Accumulate (currently visible) datasets (new window, F4)',...
    'pos',[3*mainFbWidth 0 mainFbWidth 25],...
    'Enable','on',...
    'Callback','trEPRgui_ACCwindow'...
    );
uicontrol('Tag','functionButtonGroup_function5_pushbutton',...
    'Parent',hbg_fb,...
    'Style','pushbutton',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','SVD',...
    'TooltipString','Perform basic singular value decomposition (SVD) on currently active dataset (new window, F5)',...
    'pos',[4*mainFbWidth 0 mainFbWidth 25],...
    'Enable','off'...
    );
uicontrol('Tag','functionButtonGroup_function6_pushbutton',...
    'Parent',hbg_fb,...
    'Style','pushbutton',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Fitting',...
    'TooltipString','Show basic fitting options for current display of currently active dataaet (new window, F6)',...
    'pos',[5*mainFbWidth 0 mainFbWidth 25],...
    'Enable','off'...
    );
uicontrol('Tag','functionButtonGroup_function7_pushbutton',...
    'Parent',hbg_fb,...
    'Style','pushbutton',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Function 7',...
    'TooltipString','Function 7',...
    'pos',[6*mainFbWidth 0 mainFbWidth 25],...
    'Enable','off'...
    );
uicontrol('Tag','functionButtonGroup_function8_pushbutton',...
    'Parent',hbg_fb,...
    'Style','pushbutton',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Function 8',...
    'TooltipString','Function 8',...
    'pos',[7*mainFbWidth 0 mainFbWidth 25],...
    'Enable','off'...
    );
uicontrol('Tag','functionButtonGroup_function9_pushbutton',...
    'Parent',hbg_fb,...
    'Style','pushbutton',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Status',...
    'TooltipString','Show status window (F9)',...
    'pos',[8*mainFbWidth 0 mainFbWidth 25],...
    'Enable','on',...
    'Callback','trEPRgui_statuswindow'...
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
    'TooltipString','',...
    'pos',[mainToggleButtonWidth 30 mainToggleButtonWidth 30],...
    'parent',hbg,...
    'HandleVisibility','off');
uicontrol('Tag','tbProcessing',...
    'Style','Toggle',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Processing',...
    'TooltipString','',...
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
uicontrol('Tag','tbReserve1',...
    'Style','Toggle',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Reserve',...
    'TooltipString','',...
    'pos',[mainToggleButtonWidth 0 mainToggleButtonWidth 30],...
    'parent',hbg,...
    'Enable','off',...
    'HandleVisibility','off');
uicontrol('Tag','tbHelp',...
    'Style','Toggle',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Help',...
    'TooltipString','',...
    'pos',[mainToggleButtonWidth*2 0 mainToggleButtonWidth 30],...
    'parent',hbg,...
    'HandleVisibility','off');

% Create the main control panels

try
    hp0 = guiWelcomePanel(...
        hMainFigure,...
        [guiSize(1)-mainPanelWidth-20 20 mainPanelWidth guiSize(2)-140]);
    
    guiLoadPanel(...
        hMainFigure,...
        [guiSize(1)-mainPanelWidth-20 20 mainPanelWidth guiSize(2)-140]);
    
    guiDatasetPanel(...
        hMainFigure,...
        [guiSize(1)-mainPanelWidth-20 20 mainPanelWidth guiSize(2)-140]);
    
    guiSliderPanel(...
        hMainFigure,...
        [guiSize(1)-mainPanelWidth-20 20 mainPanelWidth guiSize(2)-140]);
    
    guiMeasurePanel(...
        hMainFigure,...
        [guiSize(1)-mainPanelWidth-20 20 mainPanelWidth guiSize(2)-140]);
    
    guiDisplayPanel(...
        hMainFigure,...
        [guiSize(1)-mainPanelWidth-20 20 mainPanelWidth guiSize(2)-140]);
    
    guiProcessingPanel(...
        hMainFigure,...
        [guiSize(1)-mainPanelWidth-20 20 mainPanelWidth guiSize(2)-140]);
    
    guiAnalysisPanel(...
        hMainFigure,...
        [guiSize(1)-mainPanelWidth-20 20 mainPanelWidth guiSize(2)-140]);
    
    uipanel('Tag','reserve_panel',...
        'parent',hMainFigure,...
        'Title','Reserve',...
        'FontUnit','Pixel','Fontsize',12,...
        'FontWeight','bold',...
        'BackgroundColor',defaultBackground,...
        'Visible','off',...
        'Units','pixels',...
        'Position',[guiSize(1)-mainPanelWidth-20 20 mainPanelWidth guiSize(2)-140]);
    
    guiHelpPanel(...
        hMainFigure,...
        [guiSize(1)-mainPanelWidth-20 20 mainPanelWidth guiSize(2)-140]);
catch exception
    % Hm... something serious must have gone wrong...
    rethrow(exception);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Make the GUI visible.
set(hMainFigure,'Visible','on');
set(hp0,'Visible','on');

% Initialize some button group properties. 
set(hbg,'SelectionChangeFcn',{@tbg_Callback});
set(hbg,'SelectedObject',[]);  % None selected
set(hbg,'Visible','on');
    
set(hbg_fb,'Visible','on');
    
xlabel(hPlotAxes,'time / s');
ylabel(hPlotAxes,'intensity / a.u.');

% For test purposes, set axis limits
set(hPlotAxes,'YLim',[-.01,0.02]);
set(hPlotAxes,'XLim',[-.0001,0.0002]);
% set(hPlotAxes,'XLim',[-10 20000]);
    
% Display splash
try
    set(hMainFigure,'CurrentAxes',hPlotAxes);
    [path,~,~] = fileparts(mfilename('fullpath'));
    splash = imread(fullfile(path,'private','TREPRtoolboxSplash.png'),'png');
    %splash = imread(fullfile(path,'private','TAtoolboxSplash.png'),'png');
    image(splash);
    axis off          % Remove axis ticks and numbers
catch exception
    % If this happens, something probably more serious went wrong...
    throw(exception);
end

guidata(hMainFigure,guihandles);
if (nargout == 1)
    varargout{1} = hMainFigure;
end

% Set status message
add2status('trEPR GUI main window initialised successfully.');
%update_statuswindow(ad.control.status);

% Add keypress function to every element that can have one...
handles = findall(...
    allchild(hMainFigure),'style','pushbutton',...
    '-or','style','togglebutton',...
    '-or','style','edit',...
    '-or','style','listbox',...
    '-or','style','slider',...
    '-or','style','popupmenu');
for k=1:length(handles)
    set(handles(k),'KeyPressFcn',@guiKeyBindings);
end

% Set font sizes
% NOTE: THIS IS ONLY A VERY TEMPORARY SOLUTION...
% allHandles = cell2mat(struct2cell(guihandles));
% set(findall(allHandles,'Style','pushbutton'),'FontUnit','Pixel','Fontsize',12);
% set(findall(allHandles,'Style','togglebutton'),'FontUnit','Pixel','Fontsize',12);
% %set(findall(allHandles,'Style','Panel'),'FontUnit','Pixel','Fontsize',12);
% set(findall(allHandles,'Style','checkbox'),'FontUnit','Pixel','Fontsize',12);
% set(findall(allHandles,'Style','popupmenu'),'FontUnit','Pixel','Fontsize',12);
% set(findall(allHandles,'Style','edit'),'FontUnit','Pixel','Fontsize',12);
% set(findall(allHandles,'Style','text'),'FontUnit','Pixel','Fontsize',12);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function slider_v1_Callback(source,~)
    try
        % Get appdata of main window
        mainWindow = findobj('Tag','trepr_gui_mainwindow');
        ad = getappdata(mainWindow);
        
        % Depending on display type settings
        switch ad.control.axis.displayType
            case '1D along x'
                ad.data{ad.control.spectra.active}.display.position.y = ...
                    int16(get(source,'Value'));
            case '1D along y'
                ad.data{ad.control.spectra.active}.display.position.x = ...
                    int16(get(source,'Value'));
            otherwise
                msg = sprintf('Display type %s currently unsupported',displayType);
                add2status(msg);
        end
        
        % Update appdata of main window
        setappdata(mainWindow,'data',ad.data);
        
        % Update slider panel
        update_sliderPanel();
        
        %Update main axis
        update_mainAxis();
    catch exception
        try
            msgStr = ['An exception occurred. '...
                'The bug reporter should have been opened'];
            add2status(msgStr);
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

function slider_v2_Callback(source,~)
    try
        % Get appdata of main window
        mainWindow = findobj('Tag','trepr_gui_mainwindow');
        ad = getappdata(mainWindow);
        
        % Convert slider value to scaling factor
        if (get(source,'Value') > 0)
            scalingFactor = get(source,'Value')+1;
        else
            scalingFactor = 1/(abs(get(source,'Value'))+1);
        end
        
        % Depending on display type settings
        switch ad.control.axis.displayType
            case '2D plot'
                ad.data{ad.control.spectra.active}.display.scaling.y = ...
                    scalingFactor;
            case '1D along x'
                ad.data{ad.control.spectra.active}.display.scaling.z = ...
                    scalingFactor;
            case '1D along y'
                ad.data{ad.control.spectra.active}.display.scaling.z = ...
                    scalingFactor;
            otherwise
                msg = sprintf('Display type %s currently unsupported',displayType);
                add2status(msg);
        end
        
        % Update appdata of main window
        setappdata(mainWindow,'data',ad.data);
        
        % Update slider panel
        update_sliderPanel();
        
        %Update main axis
        update_mainAxis();
    catch exception
        try
            msgStr = ['An exception occurred. '...
                'The bug reporter should have been opened'];
            add2status(msgStr);
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

function slider_v3_Callback(source,~)
    try
        % Get appdata of main window
        mainWindow = findobj('Tag','trepr_gui_mainwindow');
        ad = getappdata(mainWindow);
        
        % Depending on display type settings
        switch ad.control.axis.displayType
            case '2D plot'
                ad.data{ad.control.spectra.active}.display.displacement.y = ...
                    get(source,'Value');
            case '1D along x'
                ad.data{ad.control.spectra.active}.display.displacement.z = ...
                    get(source,'Value');
            case '1D along y'
                ad.data{ad.control.spectra.active}.display.displacement.z = ...
                    get(source,'Value');
            otherwise
                msg = sprintf('Display type %s currently unsupported',displayType);
                add2status(msg);
        end
        
        % Update appdata of main window
        setappdata(mainWindow,'data',ad.data);
        
        % Update slider panel
        update_sliderPanel();
        
        %Update main axis
        update_mainAxis();
    catch exception
        try
            msgStr = ['An exception occurred. '...
                'The bug reporter should have been opened'];
            add2status(msgStr);
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

function slider_h1_Callback(source,~)
    try
        % Get appdata of main window
        mainWindow = findobj('Tag','trepr_gui_mainwindow');
        ad = getappdata(mainWindow);
        
        % Convert slider value to scaling factor
        if (get(source,'Value') > 0)
            scalingFactor = get(source,'Value')+1;
        else
            scalingFactor = 1/(abs(get(source,'Value'))+1);
        end
        
        % Depending on display type settings
        switch ad.control.axis.displayType
            case '2D plot'
                ad.data{ad.control.spectra.active}.display.scaling.x = ...
                    scalingFactor;
            case '1D along x'
                ad.data{ad.control.spectra.active}.display.scaling.x = ...
                    scalingFactor;
            case '1D along y'
                ad.data{ad.control.spectra.active}.display.scaling.y = ...
                    scalingFactor;
            otherwise
                msg = sprintf('Display type %s currently unsupported',displayType);
                add2status(msg);
        end
        
        % Update appdata of main window
        setappdata(mainWindow,'data',ad.data);
        
        % Update slider panel
        update_sliderPanel();
        
        %Update main axis
        update_mainAxis();
    catch exception
        try
            msgStr = ['An exception occurred. '...
                'The bug reporter should have been opened'];
            add2status(msgStr);
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

function slider_h2_Callback(source,~)
    try
        % Get appdata of main window
        mainWindow = findobj('Tag','trepr_gui_mainwindow');
        ad = getappdata(mainWindow);
        
        % Depending on display type settings
        switch ad.control.axis.displayType
            case '2D plot'
                ad.data{ad.control.spectra.active}.display.displacement.x = ...
                    get(source,'Value');
            case '1D along x'
                ad.data{ad.control.spectra.active}.display.displacement.x = ...
                    get(source,'Value');
            case '1D along y'
                ad.data{ad.control.spectra.active}.display.displacement.y = ...
                    get(source,'Value');
            otherwise
                msg = sprintf('Display type %s currently unsupported',displayType);
                add2status(msg);
        end
        
        % Update appdata of main window
        setappdata(mainWindow,'data',ad.data);
        
        % Update slider panel
        update_sliderPanel();
        
        %Update main axis
        update_mainAxis();
    catch exception
        try
            msgStr = ['An exception occurred. '...
                'The bug reporter should have been opened'];
            add2status(msgStr);
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

function zoom_togglebutton_Callback(source,~)
    try
        % Get appdata of main window
        mainWindow = findobj('Tag','trepr_gui_mainwindow');
        ad = getappdata(mainWindow);
        
        if (get(source,'Value'))
            zh = zoom(mainWindow);
            % set(zh,'UIContextMenu',handles.axisToolsContextMenu);
            set(zh,'Enable','on');
            set(zh,'Motion','both');
            set(zh,'Direction','in');
        else
            zh = zoom(mainWindow);
            set(zh,'Enable','off');
            refresh;
        end
    catch exception
        try
            msgStr = ['An exception occurred. '...
                'The bug reporter should have been opened'];
            add2status(msgStr);
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

function fullscale_pushbutton_Callback(~,~)
    try
        % Get appdata of main window
        mainWindow = findobj('Tag','trepr_gui_mainwindow');
        ad = getappdata(mainWindow);
        
        % Get handles of main window
        gh = guihandles(mainWindow);
        
        set(gh.zoom_togglebutton,'Value',0);
        zh = zoom(mainWindow);
        set(zh,'Enable','off');
        
        %Update main axis
        update_mainAxis();
    catch exception
        try
            msgStr = ['An exception occurred. '...
                'The bug reporter should have been opened'];
            add2status(msgStr);
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

function reset_pushbutton_Callback(source,~)
    try
        if (get(source,'Value') == 0) || (isempty(ad.control.spectra.active))
            return;
        end
        
        % Get appdata of main window
        mainWindow = findobj('Tag','trepr_gui_mainwindow');
        ad = getappdata(mainWindow);
        
        % Reset displacement and scaling for current spectrum
        ad.data{ad.control.spectra.active}.display.displacement.x = 0;
        ad.data{ad.control.spectra.active}.display.displacement.y = 0;
        ad.data{ad.control.spectra.active}.display.displacement.z = 0;
        
        ad.data{ad.control.spectra.active}.display.scaling.x = 1;
        ad.data{ad.control.spectra.active}.display.scaling.y = 1;
        ad.data{ad.control.spectra.active}.display.scaling.z = 1;
        
        % Update appdata of main window
        setappdata(mainWindow,'data',ad.data);
        
        % Update slider panel
        update_sliderPanel();
        
        %Update main axis
        update_mainAxis();
    catch exception
        try
            msgStr = ['An exception occurred. '...
                'The bug reporter should have been opened'];
            add2status(msgStr);
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

function tbg_Callback(source,~)
    try 
        status = switchMainPanel(get(get(source,'SelectedObject'),'String'));
        
        if status
            % Something went wrong...
            msgStr = 'Something went wrong with switching the panels.';
            add2status(msgStr);
        end
    catch exception
        try
            msgStr = ['An exception occurred. '...
                'The bug reporter should have been opened'];
            add2status(msgStr);
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

function closeGUI(~,~)
    try
        guiClose();
    catch exception
        try
            msgStr = ['An exception occurred. '...
                'The bug reporter should have been opened'];
            add2status(msgStr);
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

function keyBindings(src,evt)
    try
        guiKeyBindings(src,evt);
    catch exception
        try
            msgStr = ['An exception occurred. '...
                'The bug reporter should have been opened'];
            add2status(msgStr);
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

end