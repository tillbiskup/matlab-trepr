function guiMeasure(action,nPoints)
% GUIMEASURE Private function to handle displacing of datasets
%
% Arguments:
%     action  - string
%               Action to be performed: on|off|reset
%     nPoints - scalar
%               Number of points: 1 - pick mode; 2 - measure mode

% Copyright (c) 2013-15, Till Biskup
% 2015-10-17

try
    % Get appdata of main window
    mainWindow = trEPRguiGetWindowHandle();
    ad = getappdata(mainWindow);
    % Get guihandles of main window
    gu = ad.UsedByGUIData_m;
    %gh = guihandles(mainWindow);
    
    % Set position for dataset
    switch lower(action)
        case 'on'
            switch nPoints
                case 1
                    % Switch off other togglebutton
                    set(gh.measure_panel_distance_togglebutton,'Value',0);
                    
                    % Switch zoom mode off
                    zh = zoom(mainWindow);
                    set(zh,'Enable','off');
                    refresh;
                    set(gh.zoom_togglebutton,'Value',0);
                    
                    % Reset display of values
                    clearFields();
                    
                    % Set nPoints to measure in appdata
                    ad.control.measure.nPoints = 1;
                    % Set number of current point in appdata
                    ad.control.measure.point = 1;
                case 2
                    % Switch off other togglebutton
                    set(gh.measure_panel_point_togglebutton,'Value',0);
                    
                    % Switch zoom mode off
                    zh = zoom(mainWindow);
                    set(zh,'Enable','off');
                    refresh;
                    set(gh.zoom_togglebutton,'Value',0);
                    
                    % Set nPoints to measure in appdata
                    ad.control.measure.nPoints = 2;
                    % Set number of current point in appdata
                    ad.control.measure.point = 1;
                otherwise
            end
            % Update appdata of main window
            setappdata(mainWindow,'control',ad.control);
            
            % Set pointer callback functions
            set(mainWindow,'WindowButtonMotionFcn',@trackPointer);
            set(mainWindow,'WindowButtonDownFcn',@switchMeasurePointer);
            return;
        case 'off'
            % Reset nPoints to measure in appdata
            ad.control.measure.nPoints = 0;
            % Reset number of point in appdata
            ad.control.measure.point = 0;
            
            % Update appdata of main window
            setappdata(mainWindow,'control',ad.control);
            
            % Reset pointer callback functions
            set(mainWindow,'WindowButtonMotionFcn','');
            set(mainWindow,'WindowButtonDownFcn','');
            
            % Reset pointer
            set(mainWindow,'Pointer','arrow');
            
            update_measurePanel();

            update_mainAxis();
            
            % Update display - REALLY NECESSARY?
            refresh;
            return;
        case 'clear'
            measureEnd();
            clearFields();
            
            update_measurePanel();
            return;
    end
catch exception
    trEPRexceptionHandling(exception);
end

end

function clearFields()

try
    % Get appdata of main window
    mainWindow = trEPRguiGetWindowHandle();
    ad = getappdata(mainWindow);
    % Get guihandles of main window
    gh = guihandles(mainWindow);
    
    % Reset edit fields
    set(gh.measure_panel_point1_x_index_edit,'String','0');
    set(gh.measure_panel_point1_x_unit_edit,'String','0');
    set(gh.measure_panel_point1_y_index_edit,'String','0');
    set(gh.measure_panel_point1_y_unit_edit,'String','0');
    set(gh.measure_panel_point1_z_unit_edit,'String','0');
    set(gh.measure_panel_point2_x_index_edit,'String','0');
    set(gh.measure_panel_point2_x_unit_edit,'String','0');
    set(gh.measure_panel_point2_y_index_edit,'String','0');
    set(gh.measure_panel_point2_y_unit_edit,'String','0');
    set(gh.measure_panel_point2_z_unit_edit,'String','0');
    set(gh.measure_panel_distance_x_index_edit,'String','0');
    set(gh.measure_panel_distance_x_unit_edit,'String','0');
    set(gh.measure_panel_distance_y_index_edit,'String','0');
    set(gh.measure_panel_distance_y_unit_edit,'String','0');
    set(gh.measure_panel_distance_z_unit_edit,'String','0');
    
    % Clear fields in data structure of currently active dataset
    active = ad.control.data.active;
    for idx = 1:length(ad.data{active}.display.measure.point)
        ad.data{active}.display.measure.point(idx).index = [];
        ad.data{active}.display.measure.point(idx).unit = [];
    end
    
    % Update appdata of main window
    setappdata(mainWindow,'data',ad.data);
catch exception
    trEPRexceptionHandling(exception);
end

end

function switchMeasurePointer(~,~)

try
    % Get appdata of main window
    mainWindow = trEPRguiGetWindowHandle;
    ad = getappdata(mainWindow);
    
    % Depending on nPoints
    switch ad.control.measure.nPoints
        case 1
            assignPointsToDataStructure();
            measureEnd();
            return;
        case 2
            % Set number of point in appdata
            switch ad.control.measure.point
                case 1
                    ad.control.measure.point = 2;
                case 2
                    assignPointsToDataStructure();
                    measureEnd();
                    return;
                otherwise
                    trEPRoptionUnknown(ad.control.measure.point,...
                        'point');
                    return;
            end
        otherwise
            trEPRoptionUnknown(ad.control.measure.nPoints,...
                'nPoints');
            return;
    end
    
    % Update appdata of main window
    setappdata(mainWindow,'control',ad.control);
catch exception
    trEPRexceptionHandling(exception);
end

end

function measureEnd()

try
    % Get appdata of main window
    mainWindow = trEPRguiGetWindowHandle;
    ad = getappdata(mainWindow);
    
    % Get guihandles of main window
    gh = guihandles(mainWindow);
    
    % Reset nPoints to measure in appdata
    ad.control.measure.nPoints = 0;
    % Reset number of point in appdata
    ad.control.measure.point = 0;
    % Update appdata of main window
    setappdata(mainWindow,'control',ad.control);
    
    % Reset pointer callback functions
    set(mainWindow,'WindowButtonMotionFcn','');
    set(mainWindow,'WindowButtonDownFcn','');
    
    % Reset pointer
    set(mainWindow,'Pointer','arrow');
    
    % Switch off togglebuttons
    set(gh.measure_panel_point_togglebutton,'Value',0);
    set(gh.measure_panel_distance_togglebutton,'Value',0);
    
    % Reset GUI mode
    trEPRguiSetMode('none');
    
    % Update display - REALLY NECESSARY?
    refresh;
catch exception
    trEPRexceptionHandling(exception);
end

end

function assignPointsToDataStructure()

try
    % Get appdata of main window
    mainWindow = trEPRguiGetWindowHandle;
    ad = getappdata(mainWindow);
    
    % Get guihandles of main window
    gh = guihandles(mainWindow);
    
    % To shorten lines, assign id of currently active dataset to var
    active = ad.control.data.active;
    
    % Assign index and value to data structure of currently active dataset
    ad.data{active}.display.measure.point(1).index = [...
        str2double(get(gh.measure_panel_point1_x_index_edit,'String'))...
        str2double(get(gh.measure_panel_point1_y_index_edit,'String'))...
        ];
    ad.data{active}.display.measure.point(1).unit = [...
        str2double(get(gh.measure_panel_point1_x_unit_edit,'String'))...
        str2double(get(gh.measure_panel_point1_y_unit_edit,'String'))...
        ];
    if (ad.control.measure.nPoints == 2)
        ad.data{active}.display.measure.point(2).index = [...
            str2double(get(gh.measure_panel_point2_x_index_edit,'String'))...
            str2double(get(gh.measure_panel_point2_y_index_edit,'String'))...
            ];
        ad.data{active}.display.measure.point(2).unit = [...
            str2double(get(gh.measure_panel_point2_x_unit_edit,'String'))...
            str2double(get(gh.measure_panel_point2_y_unit_edit,'String'))...
            ];
    end
    
    % Set slider values accordingly, if configured to do so
    if (ad.control.measure.setslider)
        switch ad.control.axis.displayType
            case '2D plot'
                ad.data{active}.display.position.data(1) = ...
                    ad.data{active}.display.measure.point(1).index(1);
                ad.data{active}.display.position.data(2) = ...
                    ad.data{active}.display.measure.point(1).index(2);
            case '1D along x'
                ad.data{active}.display.position.data(1) = ...
                    ad.data{active}.display.measure.point(1).index(1);
            case '1D along y'
                ad.data{active}.display.position.data(2) = ...
                    ad.data{active}.display.measure.point(1).index(2);
            otherwise
                trEPRoptionUnknown(ad.control.axis.displayType,...
                    'display type');
                return;
        end
    end
    
    % Update appdata of main window
    setappdata(mainWindow,'data',ad.data);
    
    % Set POI and DOI if configured to do so
    % IMPORTANT: Need to do so after data has been updated
    if (ad.control.measure.setcharacteristics)
        if (ad.control.measure.nPoints == 1)
            cmdPoi(trEPRguiGetWindowHandle,cell(0));
        end
        if (ad.control.measure.nPoints == 2)
            cmdDoi(trEPRguiGetWindowHandle,cell(0));
        end
    end
catch exception
    trEPRexceptionHandling(exception);
end

end
