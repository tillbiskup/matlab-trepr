function handle = guiMeasurePanel(parentHandle,position)
% GUIWELCOMEPANEL Add a panel for measurements to a gui
%       Should only be called from within a GUI defining function.
%
%       Arguments: parent Handle and position vector.
%       TODO: Add guidata and appdata to list of arguments
%
%       Returns the handle of the added panel.

% (c) 2011-12, Till Biskup
% 2012-06-26

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
    'String',{'Measure points and distances between points in the main axes (on the left)'}...
    );

handle_p1 = uipanel('Tag','measure_panel_point1_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-205 handle_size(3)-20 135],...
    'Title','First point'...
    );
uicontrol('Tag','measure_panel_point1_index_text',...
    'Style','text',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 90 (handle_size(3)-90)/2 25],...
    'String','index'...
    );
uicontrol('Tag','measure_panel_point1_unit_text',...
    'Style','text',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 90 (handle_size(3)-90)/2 25],...
    'String','unit'...
    );
uicontrol('Tag','measure_panel_point1_x_text',...
    'Style','text',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 70 35 20],...
    'String','x1'...
    );
uicontrol('Tag','measure_panel_point1_x_index_edit',...
    'Style','edit',...
    'Parent',handle_p1,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60 70 (handle_size(3)-90)/2 25],...
    'String','0'...
    );
uicontrol('Tag','measure_panel_point1_x_unit_edit',...
    'Style','edit',...
    'Parent',handle_p1,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 70 (handle_size(3)-90)/2 25],...
    'String','0'...
    );
uicontrol('Tag','measure_panel_point1_y_text',...
    'Style','text',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 40 35 20],...
    'String','y1'...
    );
uicontrol('Tag','measure_panel_point1_y_index_edit',...
    'Style','edit',...
    'Parent',handle_p1,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60 40 (handle_size(3)-90)/2 25],...
    'String','0'...
    );
uicontrol('Tag','measure_panel_point1_y_unit_edit',...
    'Style','edit',...
    'Parent',handle_p1,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 40 (handle_size(3)-90)/2 25],...
    'String','0'...
    );
uicontrol('Tag','measure_panel_setslider_checkbox',...
    'Style','checkbox',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 10 handle_size(3)-90 20],...
    'String',' Set sliders (1 Pt)',...
    'ToolTip','Use picked point to set the position sliders in x and/or y dimension',...
    'Value',1,...
    'Callback',{@measure_setslider_checkbox_Callback}...
    );

handle_p2 = uipanel('Tag','measure_panel_point2_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-320 handle_size(3)-20 105],...
    'Title','Second point'...
    );
uicontrol('Tag','measure_panel_point2_index_text',...
    'Style','text',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 60 (handle_size(3)-90)/2 25],...
    'String','index'...
    );
uicontrol('Tag','measure_panel_point2_unit_text',...
    'Style','text',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 60 (handle_size(3)-90)/2 25],...
    'String','unit'...
    );
uicontrol('Tag','measure_panel_point2_x_text',...
    'Style','text',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 40 35 20],...
    'String','x2'...
    );
uicontrol('Tag','measure_panel_point2_x_index_edit',...
    'Style','edit',...
    'Parent',handle_p2,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60 40 (handle_size(3)-90)/2 25],...
    'String','0'...
    );
uicontrol('Tag','measure_panel_point2_x_unit_edit',...
    'Style','edit',...
    'Parent',handle_p2,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 40 (handle_size(3)-90)/2 25],...
    'String','0'...
    );
uicontrol('Tag','measure_panel_point2_y_text',...
    'Style','text',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 35 20],...
    'String','y2'...
    );
uicontrol('Tag','measure_panel_point2_y_index_edit',...
    'Style','edit',...
    'Parent',handle_p2,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60 10 (handle_size(3)-90)/2 25],...
    'String','0'...
    );
uicontrol('Tag','measure_panel_point2_y_unit_edit',...
    'Style','edit',...
    'Parent',handle_p2,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 10 (handle_size(3)-90)/2 25],...
    'String','0'...
    );

handle_p3 = uipanel('Tag','measure_panel_distance_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-435 handle_size(3)-20 105],...
    'Title','Distance between points'...
    );
uicontrol('Tag','measure_panel_distance_index_text',...
    'Style','text',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 60 (handle_size(3)-90)/2 25],...
    'String','index'...
    );
uicontrol('Tag','measure_panel_distance_unit_text',...
    'Style','text',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 60 (handle_size(3)-90)/2 25],...
    'String','unit'...
    );
uicontrol('Tag','measure_panel_distance_x_text',...
    'Style','text',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 40 35 20],...
    'String','Dx'...
    );
uicontrol('Tag','measure_panel_distance_x_index_edit',...
    'Style','edit',...
    'Parent',handle_p3,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60 40 (handle_size(3)-90)/2 25],...
    'String','0'...
    );
uicontrol('Tag','measure_panel_distance_x_unit_edit',...
    'Style','edit',...
    'Parent',handle_p3,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 40 (handle_size(3)-90)/2 25],...
    'String','0'...
    );
uicontrol('Tag','measure_panel_distance_y_text',...
    'Style','text',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 35 20],...
    'String','Dy'...
    );
uicontrol('Tag','measure_panel_distance_y_index_edit',...
    'Style','edit',...
    'Parent',handle_p3,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60 10 (handle_size(3)-90)/2 25],...
    'String','0'...
    );
uicontrol('Tag','measure_panel_distance_y_unit_edit',...
    'Style','edit',...
    'Parent',handle_p3,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Enable','inactive',...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 10 (handle_size(3)-90)/2 25],...
    'String','0'...
    );

uicontrol('Tag','measure_panel_1point_togglebutton',...
    'Style','togglebutton',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 (handle_size(3)-20)/3 30],...
    'String','1 Point',...
    'Callback',{@measure_1point_togglebutton_Callback}...
    );
uicontrol('Tag','measure_panel_2points_togglebutton',...
    'Style','togglebutton',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10+(handle_size(3)-20)/3 10 (handle_size(3)-20)/3 30],...
    'String','2 Points',...
    'Callback',{@measure_2points_togglebutton_Callback}...
    );
uicontrol('Tag','measure_panel_clear_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10+((handle_size(3)-20)/3)*2 10 (handle_size(3)-20)/3 30],...
    'String','Clear',...
    'Callback',{@clear_pushbutton_Callback}...
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
    try
        msgStr = ['An exception occurred in ' ...
            exception.stack(1).name  '.'];
        trEPRmsg(msgStr,'error');
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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function measure_setslider_checkbox_Callback(source,~)
    try
        % Get appdata of main window
        mainWindow = trEPRguiGetWindowHandle;
        ad = getappdata(mainWindow);
        
        ad.control.measure.setslider = get(source,'Value');
        
        % Update appdata of main window
        setappdata(mainWindow,'control',ad.control);
        
        % Update slider panel
        update_sliderPanel();
        
        %Update main axis
        update_mainAxis();
    catch exception
        try
            msgStr = ['An exception occurred in ' ...
                exception.stack(1).name  '.'];
            trEPRmsg(msgStr,'error');
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

function measure_1point_togglebutton_Callback(source,~)
    try
        % Get appdata of main window
        mainWindow = trEPRguiGetWindowHandle;
        ad = getappdata(mainWindow);
        
        % Get guihandles of main window
        gh = guihandles(mainWindow);
        
        if (get(source,'Value'))
            % Switch off other togglebutton
            set(gh.measure_panel_2points_togglebutton,'Value',0);
            
            % Reset display of values
            clearFields();
            
            % Set nPoints to measure in appdata
            ad.control.measure.nPoints = 1;
            % Set number of current point in appdata
            ad.control.measure.point = 1;
            % Update appdata of main window
            setappdata(mainWindow,'control',ad.control);
            
            % Set pointer callback functions
            set(mainWindow,'WindowButtonMotionFcn',@trackPointer);
            set(mainWindow,'WindowButtonDownFcn',@switchMeasurePointer);
        else
            % Reset nPoints to measure in appdata
            ad.control.measure.nPoints = 0;
            % Reset number of point in appdata
            ad.control.measure.point = 0;
            % Update appdata of main window
            setappdata(mainWindow,'control',ad.control);
            
            % Reset pointer callback functions
            set(mainWindow,'WindowButtonMotionFcn','');
            set(mainWindow,'WindowButtonDownFcn','');
            
            % Update display - REALLY NECESSARY?
            refresh;
        end
    catch exception
        try
            msgStr = ['An exception occurred in ' ...
                exception.stack(1).name  '.'];
            trEPRmsg(msgStr,'error');
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

function measure_2points_togglebutton_Callback(source,~)
    try
        % Get appdata of main window
        mainWindow = trEPRguiGetWindowHandle;
        ad = getappdata(mainWindow);
        
        % Get guihandles of main window
        gh = guihandles(mainWindow);
        
        if (get(source,'Value'))
            % Switch off other togglebutton
            set(gh.measure_panel_1point_togglebutton,'Value',0);
            
            % Set nPoints to measure in appdata
            ad.control.measure.nPoints = 2;
            % Set number of current point in appdata
            ad.control.measure.point = 1;
            % Update appdata of main window
            setappdata(mainWindow,'control',ad.control);
            
            % Set pointer callback functions
            set(mainWindow,'WindowButtonMotionFcn',@trackPointer);
            set(mainWindow,'WindowButtonDownFcn',@switchMeasurePointer);
        else
            % Reset nPoints to measure in appdata
            ad.control.measure.nPoints = 0;
            % Reset number of point in appdata
            ad.control.measure.point = 0;
            % Update appdata of main window
            setappdata(mainWindow,'control',ad.control);
            
            % Reset pointer callback functions
            set(mainWindow,'WindowButtonMotionFcn','');
            set(mainWindow,'WindowButtonDownFcn','');
            
            % Update display - REALLY NECESSARY?
            refresh;
        end
    catch exception
        try
            msgStr = ['An exception occurred in ' ...
                exception.stack(1).name  '.'];
            trEPRmsg(msgStr,'error');
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

function clear_pushbutton_Callback(~,~)
    try
        measureEnd();
        clearFields();
    catch exception
        try
            msgStr = ['An exception occurred in ' ...
                exception.stack(1).name  '.'];
            trEPRmsg(msgStr,'error');
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

function switchMeasurePointer(~,~)
    try
        % Get appdata of main window
        mainWindow = trEPRguiGetWindowHandle;
        ad = getappdata(mainWindow);
        
        % Depending on nPoints
        switch ad.control.measure.nPoints
            case 1
                measureEnd();
                assignPointsToDataStructure();
            case 2
                % Set number of point in appdata
                switch ad.control.measure.point
                    case 1
                        ad.control.measure.point = 2;
                    case 2
                        measureEnd();
                        assignPointsToDataStructure();
                    otherwise
                        % That shall never happen!
                        st = dbstack;
                        trEPRmsg(...
                            [st.name ' : unknown point "' ...
                            ad.control.measure.point '"'],'warning');
                        return;
                end
            otherwise
                % That shall never happen!
                st = dbstack;
                trEPRmsg(...
                    [st.name ' : unknown nPoints "' ...
                    ad.control.measure.nPoints '"'],'warning');
                return;
        end
        
        % Update appdata of main window
        setappdata(mainWindow,'control',ad.control);
    catch exception
        try
            msgStr = ['An exception occurred in ' ...
                exception.stack(1).name  '.'];
            trEPRmsg(msgStr,'error');
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
        set(gh.measure_panel_1point_togglebutton,'Value',0);
        set(gh.measure_panel_2points_togglebutton,'Value',0);
        
        % Update display - REALLY NECESSARY?
        refresh;
    catch exception
        try
            msgStr = ['An exception occurred in ' ...
                exception.stack(1).name  '.'];
            trEPRmsg(msgStr,'error');
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

function assignPointsToDataStructure()
    try
        % Get appdata of main window
        mainWindow = trEPRguiGetWindowHandle;
        
        % Get guihandles of main window
        gh = guihandles(mainWindow);
        
        % To shorten lines, assign id of currently active dataset to var
        active = ad.control.spectra.active;
        
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
                    ad.data{active}.display.position.x = ...
                        ad.data{active}.display.measure.point(1).index(1);
                    ad.data{active}.display.position.y = ...
                        ad.data{active}.display.measure.point(1).index(2);
                case '1D along x'
                    ad.data{active}.display.position.x = ...
                        ad.data{active}.display.measure.point(1).index(1);
                case '1D along y'
                    ad.data{active}.display.position.y = ...
                        ad.data{active}.display.measure.point(1).index(1);
                otherwise
                    % That shall never happen
                    st = dbstack;
                    trEPRmsg(...
                        [st.name ' : unknown display type "' ...
                        ad.control.axis.displayType '"'],...
                        'warning');
                    return;
            end
        end
        
        % Update appdata of main window
        setappdata(mainWindow,'data',ad.data);
    catch exception
        try
            msgStr = ['An exception occurred in ' ...
                exception.stack(1).name  '.'];
            trEPRmsg(msgStr,'error');
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

function clearFields()
    try
        % Get appdata of main window
        mainWindow = trEPRguiGetWindowHandle;
        
        % Get guihandles of main window
        gh = guihandles(mainWindow);
        
        % Reset edit fields
        set(gh.measure_panel_point1_x_index_edit,'String','0');
        set(gh.measure_panel_point1_x_unit_edit,'String','0');
        set(gh.measure_panel_point1_y_index_edit,'String','0');
        set(gh.measure_panel_point1_y_unit_edit,'String','0');
        set(gh.measure_panel_point2_x_index_edit,'String','0');
        set(gh.measure_panel_point2_x_unit_edit,'String','0');
        set(gh.measure_panel_point2_y_index_edit,'String','0');
        set(gh.measure_panel_point2_y_unit_edit,'String','0');
        set(gh.measure_panel_distance_x_index_edit,'String','0');
        set(gh.measure_panel_distance_x_unit_edit,'String','0');
        set(gh.measure_panel_distance_y_index_edit,'String','0');
        set(gh.measure_panel_distance_y_unit_edit,'String','0');
        
        % Clear fields in data structure of currently active dataset
        ad.data{ad.control.spectra.active}.display.measure.point(1).index = [];
        ad.data{ad.control.spectra.active}.display.measure.point(1).unit = [];
        ad.data{ad.control.spectra.active}.display.measure.point(2).index = [];
        ad.data{ad.control.spectra.active}.display.measure.point(2).unit = [];
        
        % Update appdata of main window
        setappdata(mainWindow,'data',ad.data);
    catch exception
        try
            msgStr = ['An exception occurred in ' ...
                exception.stack(1).name  '.'];
            trEPRmsg(msgStr,'error');
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
        

end