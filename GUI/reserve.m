hPlotAxes = axes(...         % the axes for plotting selected plot
	'Parent', hMainFigure, ...
    'Units', 'Pixels', ...
    'Position',[70 150 500 500]);
%    'HandleVisibility','callback', ...

% Create the sliders
sl1_bgcolor = [1.0 0.7 0.7];
sl2_bgcolor = [1.0 1.0 0.8];
sl3_bgcolor = [0.8 1.0 1.0];

hsl_v1 = uicontrol('Tag','vert1_slider',...
    'Style', 'slider',...
    'Min',1,'Max',100,'Value',50,...
    'Position', [595 150 15 500],...
    'BackgroundColor',sl1_bgcolor,...
    'TooltipString','',...
    'Callback', {@slider_v1_Callback});

hsl_v2 = uicontrol('Tag','vert2_slider',...
    'Style', 'slider',...
    'Min',1,'Max',100,'Value',50,...
    'Position', [615 150 15 500],...
    'BackgroundColor',sl2_bgcolor,...
    'TooltipString','',...
    'Callback', {@slider_v2_Callback});

hsl_v3 = uicontrol('Tag','vert3_slider',...
    'Style', 'slider',...
    'Min',1,'Max',100,'Value',50,...
    'Position', [635 150 15 500],...
    'BackgroundColor',sl3_bgcolor,...
    'TooltipString','',...
    'Callback', {@slider_v3_Callback});

hsl_h1 = uicontrol('Tag','horz1_slider',...
    'Style', 'slider',...
    'Min',1,'Max',100,'Value',50,...
    'Position', [70 75 500 15],...
    'BackgroundColor',sl2_bgcolor,...
    'TooltipString','',...
    'Callback', {@slider_h1_Callback});

hsl_h2 = uicontrol('Tag','horz2_slider',...
    'Style', 'slider',...
    'Min',1,'Max',100,'Value',50,...
    'Position', [70 55 500 15],...
    'BackgroundColor',sl3_bgcolor,...
    'TooltipString','',...
    'Callback', {@slider_h2_Callback});

uipanel(...
    'Units','pixels','Position', [595 135 15 15],...
    'BorderType','none',...
    'BackgroundColor',sl1_bgcolor,...
    'Visible','on'...
    );
uipanel(...
    'Units','pixels','Position', [615 135 15 15],...
    'BorderType','none',...
    'BackgroundColor',sl2_bgcolor,...
    'Visible','on'...
    );
uipanel(...
    'Units','pixels','Position', [635 135 15 15],...
    'BorderType','none',...
    'BackgroundColor',sl3_bgcolor,...
    'Visible','on'...
    );
uipanel(...
    'Units','pixels','Position', [570 75 15 15],...
    'BorderType','none',...
    'BackgroundColor',sl2_bgcolor,...
    'Visible','on'...
    );
uipanel(...
    'Units','pixels','Position', [570 55 15 15],...
    'BorderType','none',...
    'BackgroundColor',sl3_bgcolor,...
    'Visible','on'...
    );

% Create buttons closeby the main axes
uicontrol('Tag','export_button',...
    'Style','pushbutton',...
    'BackgroundColor',defaultBackground,...
    'String','Export',...
    'TooltipString','Export current display as graphics file',...
    'pos',[590 55 60 25]...
    );
uicontrol('Tag','reset_button',...
    'Style','pushbutton',...
    'BackgroundColor',defaultBackground,...
    'String','Reset',...
    'TooltipString','Reset all slider settings to their default values',...
    'pos',[590 80 60 25]...
    );
uicontrol('Tag','plus_button',...
    'Style','pushbutton',...
    'BackgroundColor',defaultBackground,...
    'String','+',...
    'TooltipString','Zoom into current axis display',...
    'pos',[600 105 25 25]...
    );
uicontrol('Tag','fullscale_button',...
    'Style','pushbutton',...
    'BackgroundColor',defaultBackground,...
    'String','FS',...
    'TooltipString','Fullscale (reset zoom on main axes)',...
    'pos',[625 105 25 25]...
    );
