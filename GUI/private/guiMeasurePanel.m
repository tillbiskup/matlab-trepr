function handle = guiMeasurePanel(parentHandle,position)
% GUIWELCOMEPANEL Add a panel for measurements to a gui
%       Should only be called from within a GUI defining function.
%
%       Arguments: parent Handle and position vector.
%       TODO: Add guidata and appdata to list of arguments
%
%       Returns the handle of the added panel.

% (Leave a blank line following the help.)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

defaultBackground = get(parentHandle,'Color');

handle = uipanel('Tag','measure_panel',...
    'parent',parentHandle,...
    'Title','Measure',...
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
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'FontAngle','oblique',...
    'Position',[10 handle_size(4)-60 handle_size(3)-20 30],...
    'String',{'Measure points and distances between points in the main axes (on the left)'}...
    );

handle_p1 = uipanel('Tag','measure_panel_point1_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-210 handle_size(3)-20 140],...
    'Title','First point'...
    );
uicontrol('Tag','measure_panel_point1_index_text',...
    'Style','text',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[60 90 (handle_size(3)-90)/2 25],...
    'String','index'...
    );
uicontrol('Tag','measure_panel_point1_unit_text',...
    'Style','text',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 90 (handle_size(3)-90)/2 25],...
    'String','unit'...
    );
uicontrol('Tag','measure_panel_point1_x_text',...
    'Style','text',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 70 35 20],...
    'String','x1'...
    );
uicontrol('Tag','measure_panel_point1_x_index_edit',...
    'Style','edit',...
    'Parent',handle_p1,...
    'BackgroundColor',[1 1 1],...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60 70 (handle_size(3)-90)/2 25],...
    'String','0'...
    );
uicontrol('Tag','measure_panel_point1_x_unit_edit',...
    'Style','edit',...
    'Parent',handle_p1,...
    'BackgroundColor',[1 1 1],...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 70 (handle_size(3)-90)/2 25],...
    'String','0'...
    );
uicontrol('Tag','measure_panel_point1_y_text',...
    'Style','text',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 40 35 20],...
    'String','y1'...
    );
uicontrol('Tag','measure_panel_point1_y_index_edit',...
    'Style','edit',...
    'Parent',handle_p1,...
    'BackgroundColor',[1 1 1],...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60 40 (handle_size(3)-90)/2 25],...
    'String','0'...
    );
uicontrol('Tag','measure_panel_point1_y_unit_edit',...
    'Style','edit',...
    'Parent',handle_p1,...
    'BackgroundColor',[1 1 1],...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 40 (handle_size(3)-90)/2 25],...
    'String','0'...
    );
uicontrol('Tag','measure_panel_setslider_checkbox',...
    'Style','checkbox',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[60 10 handle_size(3)-90 20],...
    'String',' Set sliders (1 Pt)',...
    'ToolTip','Use picked point to set the position sliders in x and y dimension',...
    'Value',1,...
    'Callback',{@measure_setslider_checkbox_Callback}...
    );

handle_p2 = uipanel('Tag','measure_panel_point2_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-330 handle_size(3)-20 110],...
    'Title','Second point'...
    );
uicontrol('Tag','measure_panel_point2_index_text',...
    'Style','text',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[60 60 (handle_size(3)-90)/2 25],...
    'String','index'...
    );
uicontrol('Tag','measure_panel_point2_unit_text',...
    'Style','text',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 60 (handle_size(3)-90)/2 25],...
    'String','unit'...
    );
uicontrol('Tag','measure_panel_point2_x_text',...
    'Style','text',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 40 35 20],...
    'String','x2'...
    );
uicontrol('Tag','measure_panel_point2_x_index_edit',...
    'Style','edit',...
    'Parent',handle_p2,...
    'BackgroundColor',[1 1 1],...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60 40 (handle_size(3)-90)/2 25],...
    'String','0'...
    );
uicontrol('Tag','measure_panel_point2_x_unit_edit',...
    'Style','edit',...
    'Parent',handle_p2,...
    'BackgroundColor',[1 1 1],...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 40 (handle_size(3)-90)/2 25],...
    'String','0'...
    );
uicontrol('Tag','measure_panel_point2_y_text',...
    'Style','text',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 10 35 20],...
    'String','y2'...
    );
uicontrol('Tag','measure_panel_point2_y_index_edit',...
    'Style','edit',...
    'Parent',handle_p2,...
    'BackgroundColor',[1 1 1],...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60 10 (handle_size(3)-90)/2 25],...
    'String','0'...
    );
uicontrol('Tag','measure_panel_point2_y_unit_edit',...
    'Style','edit',...
    'Parent',handle_p2,...
    'BackgroundColor',[1 1 1],...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 10 (handle_size(3)-90)/2 25],...
    'String','0'...
    );

handle_p3 = uipanel('Tag','measure_panel_distance_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-450 handle_size(3)-20 110],...
    'Title','Distance between points'...
    );
uicontrol('Tag','measure_panel_distance_index_text',...
    'Style','text',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[60 60 (handle_size(3)-90)/2 25],...
    'String','index'...
    );
uicontrol('Tag','measure_panel_distance_unit_text',...
    'Style','text',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 60 (handle_size(3)-90)/2 25],...
    'String','unit'...
    );
uicontrol('Tag','measure_panel_distance_x_text',...
    'Style','text',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 40 35 20],...
    'String','Dx'...
    );
uicontrol('Tag','measure_panel_distance_x_index_edit',...
    'Style','edit',...
    'Parent',handle_p3,...
    'BackgroundColor',[1 1 1],...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60 40 (handle_size(3)-90)/2 25],...
    'String','0'...
    );
uicontrol('Tag','measure_panel_distance_x_unit_edit',...
    'Style','edit',...
    'Parent',handle_p3,...
    'BackgroundColor',[1 1 1],...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 40 (handle_size(3)-90)/2 25],...
    'String','0'...
    );
uicontrol('Tag','measure_panel_distance_y_text',...
    'Style','text',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 10 35 20],...
    'String','Dy'...
    );
uicontrol('Tag','measure_panel_distance_y_index_edit',...
    'Style','edit',...
    'Parent',handle_p3,...
    'BackgroundColor',[1 1 1],...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60 10 (handle_size(3)-90)/2 25],...
    'String','0'...
    );
uicontrol('Tag','measure_panel_distance_y_unit_edit',...
    'Style','edit',...
    'Parent',handle_p3,...
    'BackgroundColor',[1 1 1],...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 10 (handle_size(3)-90)/2 25],...
    'String','0'...
    );

uicontrol('Tag','measure_panel_1point_togglebutton',...
    'Style','togglebutton',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 50 (handle_size(3)-20)/3 30],...
    'String','1 Point',...
    'Callback',{@measure_1point_togglebutton_Callback}...
    );
uicontrol('Tag','measure_panel_2points_togglebutton',...
    'Style','togglebutton',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10+(handle_size(3)-20)/3 50 (handle_size(3)-20)/3 30],...
    'String','2 Points',...
    'Callback',{@measure_2points_togglebutton_Callback}...
    );
uicontrol('Tag','measure_panel_clear_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10+((handle_size(3)-20)/3)*2 50 (handle_size(3)-20)/3 30],...
    'String','Clear',...
    'Callback',{@clear_pushbutton_Callback}...
    );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function measure_setslider_checkbox_Callback(source,~)
    % Get appdata of main window
    mainWindow = findobj('Tag','trepr_gui_mainwindow');
    ad = getappdata(mainWindow);

    ad.control.measure.setslider = get(source,'Value');
    
    % Update appdata of main window
    setappdata(mainWindow,'control',ad.control);  
    
    % Update slider panel
    update_sliderPanel();

    %Update main axis
    update_mainAxis();    
end

function measure_1point_togglebutton_Callback(source,~)
    % Get appdata of main window
    mainWindow = findobj('Tag','trepr_gui_mainwindow');
    ad = getappdata(mainWindow);
    
    % Get guihandles of main window
    gh = guihandles(mainWindow);

    if (get(source,'Value'))
        set(gh.measure_panel_2points_togglebutton,'Value',0);
        set(mainWindow,'WindowButtonMotionFcn',@trackPointer);
%         set(mainWindow,'WindowButtonDownFcn',@if_singleMeasurementPoint);
    else
        set(mainWindow,'WindowButtonMotionFcn','');
        set(mainWindow,'WindowButtonDownFcn','');
        refresh;
    end
    
end

function measure_2points_togglebutton_Callback(source,~)
    % Get appdata of main window
    mainWindow = findobj('Tag','trepr_gui_mainwindow');
    ad = getappdata(mainWindow);
    
    % Get guihandles of main window
    gh = guihandles(mainWindow);

    if (get(source,'Value'))
        set(gh.measure_panel_1point_togglebutton,'Value',0);
    end
end

function clear_pushbutton_Callback(source,~)
    % Get appdata of main window
    mainWindow = findobj('Tag','trepr_gui_mainwindow');
    ad = getappdata(mainWindow);
    
    % Get guihandles of main window
    gh = guihandles(mainWindow);

    set(gh.measure_panel_1point_togglebutton,'Value',0);
    set(gh.measure_panel_2points_togglebutton,'Value',0);

    % Switch off pointer functions
    set(mainWindow,'WindowButtonMotionFcn','');
    set(mainWindow,'WindowButtonDownFcn','');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Utility functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end