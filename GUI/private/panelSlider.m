function handle = panelSlider(parentHandle,position)
% PANELSLIDER Add a panel for slider value display to a gui
%       Should only be called from within a GUI defining function.
%
%       Arguments: parent Handle and position vector.
%       TODO: Add guidata and appdata to list of arguments
%
%       Returns the handle of the added panel.

% Copyright (c) 2011-15, Till Biskup
% 2015-11-27

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

defaultBackground = get(parentHandle,'Color');

% Variables that definitely have to be stored otherwise (appdata.configure)
sl1_bgcolor = [1.0 0.7 0.7];
sl2_bgcolor = [1.0 1.0 0.8];
sl3_bgcolor = [0.8 1.0 1.0];

handle = uipanel('Tag','slider_panel',...
    'parent',parentHandle,...
    'Title','Slider values',...
    'FontUnit','Pixel','Fontsize',12,...
    'FontWeight','bold',...
    'BackgroundColor',defaultBackground,...
    'Visible','off',...
    'Units','pixels','Position',position);

% Create the "Slider values" panel
handle_size = get(handle,'Position');
uicontrol('Tag','slider_panel_description',...
    'Style','text',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'FontAngle','oblique',...
    'Position',[10 handle_size(4)-60 handle_size(3)-20 30],...
    'String',{'Display values of the sliders attached to the main axes (on the left)'}...
    );

handle_p1 = uipanel('Tag','slider_panel_position_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-200 handle_size(3)-20 130],...
    'Title','Position'...
    );
uicontrol('Tag','slider_panel_position_index_text',...
    'Style','text',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 85 (handle_size(3)-90)/2 25],...
    'String','index'...
    );
uicontrol('Tag','slider_panel_position_unit_text',...
    'Style','text',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 85 (handle_size(3)-90)/2 25],...
    'String','unit'...
    );
uicontrol('Tag','slider_panel_position_x_text',...
    'Style','text',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 65 35 20],...
    'String','x'...
    );
uicontrol('Tag','slider_panel_position_x_index_edit',...
    'Style','edit',...
    'Parent',handle_p1,...
    'BackgroundColor',sl1_bgcolor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 65 (handle_size(3)-90)/2 25],...
    'String','0',...
    'Callback',{@edit_Callback,'position_xindex'}...
    );
uicontrol('Tag','slider_panel_position_x_unit_edit',...
    'Style','edit',...
    'Parent',handle_p1,...
    'BackgroundColor',sl1_bgcolor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 65 (handle_size(3)-90)/2 25],...
    'String','0',...
    'Callback',{@edit_Callback,'position_xunit'}...
    );
uicontrol('Tag','slider_panel_position_y_text',...
    'Style','text',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 40 35 20],...
    'String','y'...
    );
uicontrol('Tag','slider_panel_position_y_index_edit',...
    'Style','edit',...
    'Parent',handle_p1,...
    'BackgroundColor',sl1_bgcolor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 40 (handle_size(3)-90)/2 25],...
    'String','0',...
    'Callback',{@edit_Callback,'position_yindex'}...
    );
uicontrol('Tag','slider_panel_position_y_unit_edit',...
    'Style','edit',...
    'Parent',handle_p1,...
    'BackgroundColor',sl1_bgcolor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 40 (handle_size(3)-90)/2 25],...
    'String','0',...
    'Callback',{@edit_Callback,'position_yunit'}...
    );
uicontrol('Tag','slider_panel_position_pick_text',...
    'Style','text',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 35 20],...
    'String','Pick'...
    );
uicontrol('Tag','slider_panel_position_pickmin_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 10 (handle_size(3)-90)/2 25],...
    'String','Min',...
    'TooltipString','Show position of absolute minimum of active dataset',...
    'Callback', {@pushbutton_Callback,'pickmin'}...
    );
uicontrol('Tag','slider_panel_position_pickmax_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 10 (handle_size(3)-90)/2 25],...
    'String','Max',...
    'TooltipString','Show position of absolute maximum of active dataset',...
    'Callback', {@pushbutton_Callback,'pickmax'}...
    );

handle_p2 = uipanel('Tag','slider_panel_scaling_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-335 handle_size(3)-20 125],...
    'Title','Scaling'...
    );
uicontrol('Tag','slider_panel_scaling_index_text',...
    'Style','text',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 80 (handle_size(3)-90)/2 25],...
    'String','factor'...
    );
uicontrol('Tag','slider_panel_scaling_unit_text',...
    'Style','text',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 80 (handle_size(3)-90)/2 25],...
    'String','Delta in units',...
    'TooltipString','Difference to unscaled in units' ...
    );
uicontrol('Tag','slider_panel_scaling_x_text',...
    'Style','text',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 60 35 20],...
    'String','x'...
    );
uicontrol('Tag','slider_panel_scaling_x_index_edit',...
    'Style','edit',...
    'Parent',handle_p2,...
    'BackgroundColor',sl2_bgcolor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 60 (handle_size(3)-90)/2 25],...
    'String','0',...
    'Callback',{@edit_Callback,'scaling_xindex'}...
    );
uicontrol('Tag','slider_panel_scaling_x_unit_edit',...
    'Style','edit',...
    'Parent',handle_p2,...
    'BackgroundColor',sl2_bgcolor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 60 (handle_size(3)-90)/2 25],...
    'String','0',...
    'Callback',{@edit_Callback,'scaling_xunit'}...
    );
uicontrol('Tag','slider_panel_scaling_y_text',...
    'Style','text',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 35 35 20],...
    'String','y'...
    );
uicontrol('Tag','slider_panel_scaling_y_index_edit',...
    'Style','edit',...
    'Parent',handle_p2,...
    'BackgroundColor',sl2_bgcolor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 35 (handle_size(3)-90)/2 25],...
    'String','0',...
    'Callback',{@edit_Callback,'scaling_yindex'}...
    );
uicontrol('Tag','slider_panel_scaling_y_unit_edit',...
    'Style','edit',...
    'Parent',handle_p2,...
    'BackgroundColor',sl2_bgcolor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 35 (handle_size(3)-90)/2 25],...
    'String','0',...
    'Callback',{@edit_Callback,'scaling_yunit'}...
    );
uicontrol('Tag','slider_panel_scaling_z_text',...
    'Style','text',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 35 20],...
    'String','z'...
    );
uicontrol('Tag','slider_panel_scaling_z_index_edit',...
    'Style','edit',...
    'Parent',handle_p2,...
    'BackgroundColor',sl2_bgcolor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 10 (handle_size(3)-90)/2 25],...
    'String','0',...
    'Callback',{@edit_Callback,'scaling_zindex'}...
    );
uicontrol('Tag','slider_panel_scaling_z_unit_edit',...
    'Style','edit',...
    'Parent',handle_p2,...
    'BackgroundColor',sl2_bgcolor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 10 (handle_size(3)-90)/2 25],...
    'String','0',...
    'Callback',{@edit_Callback,'scaling_zunit'}...
    );

handle_p3 = uipanel('Tag','slider_panel_displacement_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-470 handle_size(3)-20 125],...
    'Title','Displacement'...
    );
uicontrol('Tag','slider_panel_displacement_index_text',...
    'Style','text',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 80 (handle_size(3)-90)/2 25],...
    'String','index'...
    );
uicontrol('Tag','slider_panel_displacement_unit_text',...
    'Style','text',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 80 (handle_size(3)-90)/2 25],...
    'String','unit'...
    );
uicontrol('Tag','slider_panel_displacement_x_text',...
    'Style','text',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 60 35 20],...
    'String','x'...
    );
uicontrol('Tag','slider_panel_displacement_x_index_edit',...
    'Style','edit',...
    'Parent',handle_p3,...
    'BackgroundColor',sl3_bgcolor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 60 (handle_size(3)-90)/2 25],...
    'String','0',...
    'Callback',{@edit_Callback,'displacement_xindex'}...
    );
uicontrol('Tag','slider_panel_displacement_x_unit_edit',...
    'Style','edit',...
    'Parent',handle_p3,...
    'BackgroundColor',sl3_bgcolor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 60 (handle_size(3)-90)/2 25],...
    'String','0',...
    'Callback',{@edit_Callback,'displacement_xunit'}...
    );
uicontrol('Tag','slider_panel_displacement_y_text',...
    'Style','text',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 35 35 20],...
    'String','y'...
    );
uicontrol('Tag','slider_panel_displacement_y_index_edit',...
    'Style','edit',...
    'Parent',handle_p3,...
    'BackgroundColor',sl3_bgcolor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 35 (handle_size(3)-90)/2 25],...
    'String','0',...
    'Callback',{@edit_Callback,'displacement_yindex'}...
    );
uicontrol('Tag','slider_panel_displacement_y_unit_edit',...
    'Style','edit',...
    'Parent',handle_p3,...
    'BackgroundColor',sl3_bgcolor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 35 (handle_size(3)-90)/2 25],...
    'String','0',...
    'Callback',{@edit_Callback,'displacement_yunit'}...
    );
uicontrol('Tag','slider_panel_displacement_z_text',...
    'Style','text',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 35 20],...
    'String','z'...
    );
uicontrol('Tag','slider_panel_displacement_z_index_edit',...
    'Style','edit',...
    'Parent',handle_p3,...
    'BackgroundColor',sl3_bgcolor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 10 (handle_size(3)-90)/2 25],...
    'String','0',...
    'Callback',{@edit_Callback,'displacement_zindex'}...
    );
uicontrol('Tag','slider_panel_displacement_z_unit_edit',...
    'Style','edit',...
    'Parent',handle_p3,...
    'BackgroundColor',sl3_bgcolor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 10 (handle_size(3)-90)/2 25],...
    'String','0',...
    'Callback',{@edit_Callback,'displacement_zunit'}...
    );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function edit_Callback(source,~,action)
    try        
        % Get appdata and gui handles of main window
        mainWindow = trEPRguiGetWindowHandle;
        ad = getappdata(mainWindow);
        gh = ad.guiHandles;

        active = ad.control.data.active;
        
        if ~active || isempty(active)
            return;
        end
        
        % Be as robust as possible: if there is no axes, default is indices
        [y,x] = size(ad.data{active}.data);
        x = linspace(1,x,x);
        y = linspace(1,y,y);
        if (isfield(ad.data{active},'axes') ...
                && isfield(ad.data{active}.axes,'data') ...
                && isfield(ad.data{active}.axes.data(1),'values') ...
                && not (isempty(ad.data{active}.axes.data(1).values)))
            x = ad.data{active}.axes.data(1).values;
        end
        if (isfield(ad.data{active},'axes') ...
                && isfield(ad.data{active}.axes,'data') ...
                && isfield(ad.data{active}.axes.data(2),'values') ...
                && not (isempty(ad.data{active}.axes.data(2).values)))
            y = ad.data{active}.axes.data(2).values;
        end
        
        switch lower(action)
            case 'position_xindex'
                value = trEPRguiSanitiseNumericInput(...
                    get(source,'String'),1:length(x),'round',true);
                if ~isnan(value)
                    ad.data{active}.display.position.data(1) = value;
                end
            case 'position_xunit'
                value = trEPRguiSanitiseNumericInput(...
                    get(source,'String'),x,'map',true);
                if ~isnan(value)
                    ad.data{active}.display.position.data(1) = find(x==value);
                end
            case 'position_yindex'
                value = trEPRguiSanitiseNumericInput(...
                    get(source,'String'),1:length(y),'round',true);
                if ~isnan(value)
                    ad.data{active}.display.position.data(2) = value;
                end
            case 'position_yunit'
                value = trEPRguiSanitiseNumericInput(...
                    get(source,'String'),y,'map',true);
                if ~isnan(value)
                    ad.data{active}.display.position.data(2) = find(y==value);
                end
            case 'displacement_xindex'
                value = trEPRguiSanitiseNumericInput(...
                    get(source,'String'),-length(x):length(x));
                if ~isnan(value)
                    ad.data{active}.display.displacement.data(1) = value;
                end
            case 'displacement_xunit'
                vector = -(x(2)-x(1))*length(x):x(2)-x(1):(x(2)-x(1))*length(x);
                value = trEPRguiSanitiseNumericInput(...
                    get(source,'String'),vector,'map',true);
                if ~isnan(value)
                    ad.data{active}.display.displacement.data(1) = ...
                        find(vector==value)-(length(vector)+1)/2;
                end
            case 'displacement_yindex'
                value = trEPRguiSanitiseNumericInput(...
                    get(source,'String'),-length(y):length(y));
                if ~isnan(value)
                    ad.data{active}.display.displacement.data(2) = value;
                end
            case 'displacement_yunit'
                vector = -(y(2)-y(1))*length(y):y(2)-y(1):(y(2)-y(1))*length(y);
                value = trEPRguiSanitiseNumericInput(...
                    get(source,'String'),vector,'map',true);
                if ~isnan(value)
                    ad.data{active}.display.displacement.data(2) = ...
                        find(vector==value)-(length(vector)+1)/2;
                end
            case 'displacement_zindex'
                value = trEPRguiSanitiseNumericInput(get(source,'String'),...
                    [get(gh.vert3_slider,'Min'),get(gh.vert3_slider,'Max')]);
                if ~isnan(value)
                    ad.data{active}.display.displacement.data(3) = value;
                end
            case 'displacement_zunit'
                if ad.control.axis.normalisation.enable
                    if strcmpi(ad.control.axis.normalisation.dimension,'1D')
                        switch lower(ad.control.axis.normalisation.type)
                            case 'pk-pk'
                                z = [0 1];
                            case 'area'
                                z(1) = min(min(ad.data{active}.data/...
                                    sum(sum(ad.data{active}.data))));
                                z(2) = max(max(ad.data{active}.data/...
                                    sum(sum(ad.data{active}.data))));
                            case 'max'
                                z(1) = min(min(ad.data{active}.data/...
                                    max(max(ad.data{active}.data))));
                                z(2) = max(max(ad.data{active}.data/...
                                    max(max(ad.data{active}.data))));
                            case 'min'
                                z(1) = min(min(ad.data{active}.data/...
                                    min(min(ad.data{active}.data))));
                                z(2) = max(max(ad.data{active}.data/...
                                    min(min(ad.data{active}.data))));
                        end
                    else
                        switch lower(ad.control.axis.normalisation.type)
                            case 'pk-pk'
                                z = [0 1];
                            case 'area'
                                z(1) = min(min(ad.data{active}.data/...
                                    sum(sum(ad.data{active}.data))));
                                z(2) = max(max(ad.data{active}.data/...
                                    sum(sum(ad.data{active}.data))));
                            case 'max'
                                z(1) = min(min(ad.data{active}.data/...
                                    max(max(ad.data{active}.data))));
                                z(2) = max(max(ad.data{active}.data/...
                                    max(max(ad.data{active}.data))));
                            case 'min'
                                z(1) = min(min(ad.data{active}.data/...
                                    min(min(ad.data{active}.data))));
                                z(2) = max(max(ad.data{active}.data/...
                                    min(min(ad.data{active}.data))));
                        end
                    end
                else
                    z(1) = min(min(ad.data{active}.data));
                    z(2) = max(max(ad.data{active}.data));
                    
                end
                value = trEPRguiSanitiseNumericInput(get(source,'String'),...
                    [z(1)-z(2),abs(z(1)-z(2))]);                
                % "round" is due to rounding mistakes that otherwise make
                % problems with the slider values...
                % If you don't understand what's going on here, DON'T TOUCH!
                if ~isnan(value)
                    ad.data{active}.display.displacement.z = ...
                        round(...
                        value*(...
                        (max(max(ad.data{active}.data)) - ...
                        min(min(ad.data{active}.data)))/(z(2)-z(1))...
                        )*1e7)/1e7;
                end
            case 'scaling_xindex'
                value = trEPRguiSanitiseNumericInput(get(source,'String'),...
                    [1/((get(gh.horz1_slider,'Max')*2)),...
                    (get(gh.horz1_slider,'Max')*2)]);
                if ~isnan(value)
                    ad.data{active}.display.scaling.x = value;
                end
            case 'scaling_xunit'
                value = trEPRguiSanitiseNumericInput(get(source,'String'),...
                    [-(x(end)-x(1))/(get(gh.horz1_slider,'Max')*2),...
                    (x(end)-x(1)*(get(gh.horz1_slider,'Max')))]);
                if ~isnan(value)
                    ad.data{active}.display.scaling.x = 1+value/(x(end)-x(1));
                end
            case 'scaling_yindex'
                value = trEPRguiSanitiseNumericInput(get(source,'String'),...
                    [1/((get(gh.horz1_slider,'Max')*2)),...
                    (get(gh.horz1_slider,'Max')*2)]);
                if ~isnan(value)
                    ad.data{active}.display.scaling.y = value;
                end
            case 'scaling_yunit'
                value = trEPRguiSanitiseNumericInput(get(source,'String'),...
                    [-(y(end)-y(1))/(get(gh.horz1_slider,'Max')*2),...
                    (y(end)-y(1)*(get(gh.horz1_slider,'Max')))]);
                if ~isnan(value)
                    ad.data{active}.display.scaling.y = 1+value/(y(end)-y(1));
                end
            case 'scaling_zindex'
                value = trEPRguiSanitiseNumericInput(get(source,'String'),...
                    [1/((get(gh.vert2_slider,'Max')*2)),...
                    (get(gh.vert2_slider,'Max')*2)]);
                if ~isnan(value)
                    ad.data{active}.display.scaling.z = value;
                end
            case 'scaling_zunit'
                if ad.control.axis.normalisation.enable
                    if strcmpi(ad.control.axis.normalisation.dimension,'1D')
                        switch lower(ad.control.axis.normalisation.type)
                            case 'pk-pk'
                                z = [0 1];
                            case 'area'
                                z(1) = min(min(ad.data{active}.data/...
                                    sum(sum(ad.data{active}.data))));
                                z(2) = max(max(ad.data{active}.data/...
                                    sum(sum(ad.data{active}.data))));
                            case 'max'
                                z(1) = min(min(ad.data{active}.data/...
                                    max(max(ad.data{active}.data))));
                                z(2) = max(max(ad.data{active}.data/...
                                    max(max(ad.data{active}.data))));
                            case 'min'
                                z(1) = min(min(ad.data{active}.data/...
                                    min(min(ad.data{active}.data))));
                                z(2) = max(max(ad.data{active}.data/...
                                    min(min(ad.data{active}.data))));
                        end
                    else
                        switch lower(ad.control.axis.normalisation.type)
                            case 'pk-pk'
                                z = [0 1];
                            case 'area'
                                z(1) = min(min(ad.data{active}.data/...
                                    sum(sum(ad.data{active}.data))));
                                z(2) = max(max(ad.data{active}.data/...
                                    sum(sum(ad.data{active}.data))));
                            case 'max'
                                z(1) = min(min(ad.data{active}.data/...
                                    max(max(ad.data{active}.data))));
                                z(2) = max(max(ad.data{active}.data/...
                                    max(max(ad.data{active}.data))));
                            case 'min'
                                z(1) = min(min(ad.data{active}.data/...
                                    min(min(ad.data{active}.data))));
                                z(2) = max(max(ad.data{active}.data/...
                                    min(min(ad.data{active}.data))));
                        end
                    end
                else
                    z(1) = min(min(ad.data{ad.control.data.active}.data));
                    z(2) = max(max(ad.data{ad.control.data.active}.data));
                    
                end
                value = trEPRguiSanitiseNumericInput(get(source,'String'),...
                    [-(z(2)-z(1))/(get(gh.vert2_slider,'Max')*2),...
                    (z(2)-z(1)*(get(gh.vert2_slider,'Max')))]);
                if ~isnan(value)
                    ad.data{ad.control.data.active}.display.scaling.z = ...
                        1+value/(z(2)-z(1));
                end
            otherwise
                trEPRoptionUnknown(action);
                return;
        end
        
        % If value is empty or NaN after conversion to numeric, restore
        % previous entry and return
        if isempty(value) || isnan(value)
            % Update slider panel
            update_sliderPanel();
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

function pushbutton_Callback(~,~,action)

try
    if isempty(action)
        return;
    end
    mainWindow = trEPRguiGetWindowHandle;
    
    switch lower(action)
        case 'pickmin'
            cmdPick(mainWindow,{'min'});
            return;
        case 'pickmax'
            cmdPick(mainWindow,{'max'});
            return;
        otherwise
            trEPRoptionUnknown(action);
            return;
    end
catch exception
    trEPRexceptionHandling(exception)
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Utility functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
