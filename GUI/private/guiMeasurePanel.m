function handle = guiMeasurePanel(parentHandle,position)
% GUIMEASUREPANEL Add a panel for measurements to a gui
%       Should only be called from within a GUI defining function.
%
%       Arguments: parent Handle and position vector.
%       TODO: Add guidata and appdata to list of arguments
%
%       Returns the handle of the added panel.

% Copyright (c) 2011-14, Till Biskup
% 2014-07-25

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

defaultBackground = get(parentHandle,'Color');

handle = uipanel('Tag','measure_panel',...
    'parent',parentHandle,...
    'Title','Measure',...
    'FontUnit','Pixel','Fontsize',12,...
    'FontWeight','bold',...
    'BackgroundColor',defaultBackground,...
    'Visible','off',...
    'Units','pixels','Position',position);

% Create the "Measurement" panel
handle_size = get(handle,'Position');
uicontrol('Tag','measure_panel_description',...
    'Style','text',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'FontAngle','oblique',...
    'Position',[10 handle_size(4)-60 handle_size(3)-20 30],...
    'String',{'Measure points and distances in currently active dataset'}...
    );

handle_p1 = uipanel('Tag','measure_panel_coordinates_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-315 handle_size(3)-20 245],...
    'Title','Coordinates'...
    );
uicontrol('Tag','measure_panel_point1_index_text',...
    'Style','text',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 200 (handle_size(3)-90)/2 25],...
    'String','index'...
    );
uicontrol('Tag','measure_panel_point1_unit_text',...
    'Style','text',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 200 (handle_size(3)-90)/2 25],...
    'String','unit'...
    );
uicontrol('Tag','measure_panel_point1_x_text',...
    'Style','text',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 180 35 20],...
    'String','x1'...
    );
uicontrol('Tag','measure_panel_point1_x_index_edit',...
    'Style','edit',...
    'Parent',handle_p1,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60 180 (handle_size(3)-90)/2 25],...
    'String','0'...
    );
uicontrol('Tag','measure_panel_point1_x_unit_edit',...
    'Style','edit',...
    'Parent',handle_p1,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 180 (handle_size(3)-90)/2 25],...
    'String','0'...
    );
uicontrol('Tag','measure_panel_point1_y_text',...
    'Style','text',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 150 35 20],...
    'String','y1'...
    );
uicontrol('Tag','measure_panel_point1_y_index_edit',...
    'Style','edit',...
    'Parent',handle_p1,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60 150 (handle_size(3)-90)/2 25],...
    'String','0'...
    );
uicontrol('Tag','measure_panel_point1_y_unit_edit',...
    'Style','edit',...
    'Parent',handle_p1,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 150 (handle_size(3)-90)/2 25],...
    'String','0'...
    );
uicontrol('Tag','measure_panel_point2_x_text',...
    'Style','text',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 110 35 20],...
    'String','x2'...
    );
uicontrol('Tag','measure_panel_point2_x_index_edit',...
    'Style','edit',...
    'Parent',handle_p1,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60 110 (handle_size(3)-90)/2 25],...
    'String','0'...
    );
uicontrol('Tag','measure_panel_point2_x_unit_edit',...
    'Style','edit',...
    'Parent',handle_p1,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 110 (handle_size(3)-90)/2 25],...
    'String','0'...
    );
uicontrol('Tag','measure_panel_point2_y_text',...
    'Style','text',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 80 35 20],...
    'String','y2'...
    );
uicontrol('Tag','measure_panel_point2_y_index_edit',...
    'Style','edit',...
    'Parent',handle_p1,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60 80 (handle_size(3)-90)/2 25],...
    'String','0'...
    );
uicontrol('Tag','measure_panel_point2_y_unit_edit',...
    'Style','edit',...
    'Parent',handle_p1,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 80 (handle_size(3)-90)/2 25],...
    'String','0'...
    );
uicontrol('Tag','measure_panel_distance_x_text',...
    'Style','text',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 40 35 20],...
    'String','Dx'...
    );
uicontrol('Tag','measure_panel_distance_x_index_edit',...
    'Style','edit',...
    'Parent',handle_p1,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60 40 (handle_size(3)-90)/2 25],...
    'String','0'...
    );
uicontrol('Tag','measure_panel_distance_x_unit_edit',...
    'Style','edit',...
    'Parent',handle_p1,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 40 (handle_size(3)-90)/2 25],...
    'String','0'...
    );
uicontrol('Tag','measure_panel_distance_y_text',...
    'Style','text',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 35 20],...
    'String','Dy'...
    );
uicontrol('Tag','measure_panel_distance_y_index_edit',...
    'Style','edit',...
    'Parent',handle_p1,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60 10 (handle_size(3)-90)/2 25],...
    'String','0'...
    );
uicontrol('Tag','measure_panel_distance_y_unit_edit',...
    'Style','edit',...
    'Parent',handle_p1,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 10 (handle_size(3)-90)/2 25],...
    'String','0'...
    );

handle_p2 = uipanel('Tag','measure_panel_settings_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-405 handle_size(3)-20 80],...
    'Title','Settings'...
    );
uicontrol('Tag','measure_panel_setcharacteristics_checkbox',...
    'Style','checkbox',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 35 handle_size(3)-20 20],...
    'String',' Set characteristics (POI/DOI)',...
    'ToolTip','Set picked point/distance as POI/DOI of currently active dataset',...
    'Value',1,...
    'Callback',{@checkbox_Callback,'characteristics'}...
    );
uicontrol('Tag','measure_panel_setslider_checkbox',...
    'Style','checkbox',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 handle_size(3)-20 20],...
    'String',' Set sliders (1 Pt)',...
    'ToolTip','Use picked point to set the position sliders in x and/or y dimension',...
    'Value',1,...
    'Callback',{@checkbox_Callback,'point'}...
    );


uicontrol('Tag','measure_panel_point_togglebutton',...
    'Style','togglebutton',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 40 (handle_size(3)-20)/3 30],...
    'String','Point',...
    'ToolTip','Pick single point in currently active dataset',...
    'Callback',{@togglebutton_Callback,'point'}...
    );
uicontrol('Tag','measure_panel_distance_togglebutton',...
    'Style','togglebutton',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10+(handle_size(3)-20)/3 40 (handle_size(3)-20)/3 30],...
    'String','Distance',...
    'ToolTip','Pick two points subsequently and measure distance in currently active dataset',...
    'Callback',{@togglebutton_Callback,'distance'}...
    );
uicontrol('Tag','measure_panel_clear_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10+((handle_size(3)-20)/3)*2 40 (handle_size(3)-20)/3 30],...
    'String','Clear',...
    'ToolTip','Clear measurement in currently active dataset',...
    'Callback',{@pushbutton_Callback,'clear'}...
    );
uicontrol('Tag','measure_panel_poi_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 (handle_size(3)-20)/3 30],...
    'String','Set POI',...
    'ToolTip','Set (first) picked point as point of interest (POI) in currently active dataset',...
    'Callback',{@pushbutton_Callback,'poi'}...
    );
uicontrol('Tag','measure_panel_doi_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10+(handle_size(3)-20)/3 10 (handle_size(3)-20)/3 30],...
    'String','Set DOI',...
    'ToolTip','Set measured distance as distance of interest (DOI) in currently active dataset',...
    'Callback',{@pushbutton_Callback,'doi'}...
    );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try
    % Set setslider checkbox
    % Get appdata of main window
    mainWindow = trEPRguiGetWindowHandle;
    ad = getappdata(mainWindow);
    
    % Get guihandles of main window
    gh = guihandles(mainWindow);
    
    set(gh.measure_panel_setslider_checkbox,...
        'Value',ad.configuration.measure.setslider);
catch exception
    trEPRexceptionHandling(exception)
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function checkbox_Callback(source,~,action)
    try
        % Get appdata of main window
        mainWindow = trEPRguiGetWindowHandle;
        ad = getappdata(mainWindow);
        
        switch lower(action)
            case 'point'
                ad.control.measure.setslider = get(source,'Value');
            case 'characteristics'
                ad.control.measure.setcharacteristics = get(source,'Value');
        end
        
        % Update appdata of main window
        setappdata(mainWindow,'control',ad.control);
        
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
        switch lower(action)
            case 'point'
                if (get(source,'Value'))
                    trEPRguiSetMode('pick');
                else
                    trEPRguiSetMode('none');
                end
            case 'distance'
                if (get(source,'Value'))
                    trEPRguiSetMode('measure');
                else
                    trEPRguiSetMode('none');
                end
            otherwise
                trEPRoptionUnknown(action);
                return;
        end
    catch exception
        trEPRexceptionHandling(exception)
    end
end

function pushbutton_Callback(~,~,action)
    try
        switch lower(action)
            case 'clear'
                guiMeasure('clear',0);
                trEPRguiSetMode('none');
            case 'poi'
                cmdPoi(trEPRguiGetWindowHandle,cell(0));
            case 'doi'
                cmdDoi(trEPRguiGetWindowHandle,cell(0));
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
