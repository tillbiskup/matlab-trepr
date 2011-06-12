function handle = guiDisplayPanel(parentHandle,position)
% GUIWELCOMEPANEL Add a panel for display settings to a gui
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

handle = uipanel('Tag','display_panel',...
    'parent',parentHandle,...
    'Title','Display settings',...
    'FontWeight','bold',...
    'BackgroundColor',defaultBackground,...
    'Visible','off',...
    'Units','pixels','Position',position);

% Create the "Display settings" panel
handle_size = get(handle,'Position');
uicontrol('Tag','display_panel_description',...
    'Style','text',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'FontAngle','oblique',...
    'Position',[10 handle_size(4)-60 handle_size(3)-20 30],...
    'String',{'Set properties of the main axes (on the left), such as axes labels, ...'}...
    );

% Create buttongroup to switch between subpanels (pages)
hpbg = uibuttongroup('Tag','display_panel_pages_buttongroup',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'BorderType','none',...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-100 handle_size(3)-20 30],...
    'SelectionChangeFcn',{@pages_buttongroup_Callback}...
    );
uicontrol('Tag','display_panel_page1_pushbutton',...
    'Style','Toggle',...
    'BackgroundColor',defaultBackground,...
    'String','page 1',...
    'TooltipString','Show page 1 of this panel',...
    'pos',[handle_size(3)-20-(((handle_size(3)-20)/4)*4) 0 (handle_size(3)-20)/4 30],...
    'parent',hpbg,...
    'HandleVisibility','off',...
    'Value',1);
uicontrol('Tag','display_panel_page2_pushbutton',...
    'Style','Toggle',...
    'BackgroundColor',defaultBackground,...
    'String','page 2',...
    'TooltipString','Show page 2 of this panel',...
    'pos',[handle_size(3)-20-(((handle_size(3)-20)/4)*3) 0 (handle_size(3)-20)/4 30],...
    'parent',hpbg,...
    'HandleVisibility','off',...
    'Value',0);
uicontrol('Tag','display_panel_page3_pushbutton',...
    'Style','Toggle',...
    'BackgroundColor',defaultBackground,...
    'String','page 3',...
    'TooltipString','Show page 3 of this panel',...
    'pos',[handle_size(3)-20-(((handle_size(3)-20)/4)*2) 0 (handle_size(3)-20)/4 30],...
    'parent',hpbg,...
    'HandleVisibility','off',...
    'Value',0);
uicontrol('Tag','display_panel_page4_pushbutton',...
    'Style','Toggle',...
    'BackgroundColor',defaultBackground,...
    'String','page 4',...
    'TooltipString','Show page 4 of this panel',...
    'pos',[handle_size(3)-20-(((handle_size(3)-20)/4)) 0 (handle_size(3)-20)/4 30],...
    'parent',hpbg,...
    'HandleVisibility','off',...
    'Value',0);

% Create subpanels (pages)
handle_pp1 = uipanel('Tag','display_panel_page1_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'BorderType','none',...
    'Units','Pixels',...
    'Position',[10 10 handle_size(3)-20 handle_size(4)-110]...
    );
handle_pp2 = uipanel('Tag','display_panel_page2_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'BorderType','none',...
    'Units','Pixels',...
    'Position',[10 10 handle_size(3)-20 handle_size(4)-110],...
    'Visible','Off'...
    );
handle_pp3 = uipanel('Tag','display_panel_page3_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'BorderType','none',...
    'Units','Pixels',...
    'Position',[10 10 handle_size(3)-20 handle_size(4)-110],...
    'Visible','Off'...
    );
handle_pp4 = uipanel('Tag','display_panel_page4_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'BorderType','none',...
    'Units','Pixels',...
    'Position',[10 10 handle_size(3)-20 handle_size(4)-110],...
    'Visible','Off'...
    );

handle_p1 = uipanel('Tag','display_panel_axislabels_panel',...
    'Parent',handle_pp1,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[0 handle_size(4)-300 handle_size(3)-20 180],...
    'Title','Axis labels'...
    );
uicontrol('Tag','display_panel_axislabels_measure_text',...
    'Style','text',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[60 130 (handle_size(3)-90)/2 25],...
    'String','measure'...
    );
uicontrol('Tag','display_panel_axislabels_unit_text',...
    'Style','text',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 130 (handle_size(3)-90)/2 25],...
    'String','unit'...
    );
uicontrol('Tag','display_panel_axislabels_x_text',...
    'Style','text',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 110 35 20],...
    'String','x'...
    );
uicontrol('Tag','display_panel_axislabels_x_measure_edit',...
    'Style','edit',...
    'Parent',handle_p1,...
    'BackgroundColor',[1 1 1],...
    'Units','Pixels',...
    'Position',[60 110 (handle_size(3)-90)/2 25],...
    'String','index',...
    'Callback',{@axislabels_edit_Callback,'xmeasure'}...
    );
uicontrol('Tag','display_panel_axislabels_x_unit_edit',...
    'Style','edit',...
    'Parent',handle_p1,...
    'BackgroundColor',[1 1 1],...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 110 (handle_size(3)-90)/2 25],...
    'String','points',...
    'Callback',{@axislabels_edit_Callback,'xunit'}...
    );
uicontrol('Tag','display_panel_axislabels_y_text',...
    'Style','text',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 80 35 20],...
    'String','y'...
    );
uicontrol('Tag','display_panel_axislabels_y_measure_edit',...
    'Style','edit',...
    'Parent',handle_p1,...
    'BackgroundColor',[1 1 1],...
    'Units','Pixels',...
    'Position',[60 80 (handle_size(3)-90)/2 25],...
    'String','index',...
    'Callback',{@axislabels_edit_Callback,'ymeasure'}...
    );
uicontrol('Tag','display_panel_axislabels_y_unit_edit',...
    'Style','edit',...
    'Parent',handle_p1,...
    'BackgroundColor',[1 1 1],...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 80 (handle_size(3)-90)/2 25],...
    'String','points',...
    'Callback',{@axislabels_edit_Callback,'yunit'}...
    );
uicontrol('Tag','display_panel_axislabels_z_text',...
    'Style','text',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 50 35 20],...
    'String','z'...
    );
uicontrol('Tag','display_panel_axislabels_z_measure_edit',...
    'Style','edit',...
    'Parent',handle_p1,...
    'BackgroundColor',[1 1 1],...
    'Units','Pixels',...
    'Position',[60 50 (handle_size(3)-90)/2 25],...
    'String','index',...
    'Callback',{@axislabels_edit_Callback,'zmeasure'}...
    );
uicontrol('Tag','display_panel_axislabels_z_unit_edit',...
    'Style','edit',...
    'Parent',handle_p1,...
    'BackgroundColor',[1 1 1],...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 50 (handle_size(3)-90)/2 25],...
    'String','points',...
    'Callback',{@axislabels_edit_Callback,'zunit'}...
    );
uicontrol('Tag','display_panel_axislabels_getfromactivedataset_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[60 10 handle_size(3)-90 30],...
    'String','Get from active dataset',...
    'Enable','Off',...
    'Callback',{@axislabels_getfromactivedataset_pushbutton_Callback}...
    );

handle_p2 = uipanel('Tag','display_panel_axislimits_panel',...
    'Parent',handle_pp1,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[0 handle_size(4)-480 handle_size(3)-20 170],...
    'Title','Axis limits'...
    );
uicontrol('Tag','display_panel_axislimits_min_text',...
    'Style','text',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[60 120 (handle_size(3)-90)/2 25],...
    'String','min'...
    );
uicontrol('Tag','display_panel_axislimits_max_text',...
    'Style','text',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 120 (handle_size(3)-90)/2 25],...
    'String','max'...
    );
uicontrol('Tag','display_panel_axislimits_x_text',...
    'Style','text',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 100 35 20],...
    'String','x'...
    );
uicontrol('Tag','display_panel_axislimits_x_min_edit',...
    'Style','edit',...
    'Parent',handle_p2,...
    'BackgroundColor',[1 1 1],...
    'Units','Pixels',...
    'Position',[60 100 (handle_size(3)-90)/2 25],...
    'String','0',...
    'Callback',{@axislimits_edit_Callback,'xmin'}...
    );
uicontrol('Tag','display_panel_axislimits_x_max_edit',...
    'Style','edit',...
    'Parent',handle_p2,...
    'BackgroundColor',[1 1 1],...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 100 (handle_size(3)-90)/2 25],...
    'String','1',...
    'Callback',{@axislimits_edit_Callback,'xmax'}...
    );
uicontrol('Tag','display_panel_axislimits_y_text',...
    'Style','text',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 70 35 20],...
    'String','y'...
    );
uicontrol('Tag','display_panel_axislimits_y_min_edit',...
    'Style','edit',...
    'Parent',handle_p2,...
    'BackgroundColor',[1 1 1],...
    'Units','Pixels',...
    'Position',[60 70 (handle_size(3)-90)/2 25],...
    'String','0',...
    'Callback',{@axislimits_edit_Callback,'ymin'}...
    );
uicontrol('Tag','display_panel_axislimits_y_max_edit',...
    'Style','edit',...
    'Parent',handle_p2,...
    'BackgroundColor',[1 1 1],...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 70 (handle_size(3)-90)/2 25],...
    'String','1',...
    'Callback',{@axislimits_edit_Callback,'ymax'}...
    );
uicontrol('Tag','display_panel_axislimits_z_text',...
    'Style','text',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 40 35 20],...
    'String','z'...
    );
uicontrol('Tag','display_panel_axislimits_z_min_edit',...
    'Style','edit',...
    'Parent',handle_p2,...
    'BackgroundColor',[1 1 1],...
    'Units','Pixels',...
    'Position',[60 40 (handle_size(3)-90)/2 25],...
    'String','-1',...
    'Callback',{@axislimits_edit_Callback,'zmin'}...
    );
uicontrol('Tag','display_panel_axislimits_z_max_edit',...
    'Style','edit',...
    'Parent',handle_p2,...
    'BackgroundColor',[1 1 1],...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 40 (handle_size(3)-90)/2 25],...
    'String','1',...
    'Callback',{@axislimits_edit_Callback,'zmax'}...
    );
uicontrol('Tag','display_panel_axislimits_auto_checkbox',...
    'Style','checkbox',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[60 10 handle_size(3)-90 20],...
    'String',' determine automatically',...
    'Value',1,...
    'Callback',{@axislimits_auto_checkbox_Callback}...
    );

handle_p3 = uipanel('Tag','display_panel_grid_panel',...
    'Parent',handle_pp2,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[0 handle_size(4)-180 handle_size(3)-20 60],...
    'Title','Grid'...
    );
uicontrol('Tag','display_panel_grid_x_togglebutton',...
    'Style','Toggle',...
    'BackgroundColor',defaultBackground,...
    'String','X',...
    'TooltipString','Show grid in x',...
    'pos',[handle_size(3)-30-(((handle_size(3)-40)/4)*4) 10 (handle_size(3)-40)/4 30],...
    'parent',handle_p3,...
    'HandleVisibility','off',...
    'Value',0,...
    'Callback',{@grid_x_togglebutton_Callback}...
    );
uicontrol('Tag','display_panel_grid_y_togglebutton',...
    'Style','Toggle',...
    'BackgroundColor',defaultBackground,...
    'String','Y',...
    'TooltipString','Show grid in y',...
    'pos',[handle_size(3)-30-(((handle_size(3)-40)/4)*3) 10 (handle_size(3)-40)/4 30],...
    'parent',handle_p3,...
    'HandleVisibility','off',...
    'Value',0,...
    'Callback',{@grid_y_togglebutton_Callback}...
    );
uicontrol('Tag','display_panel_grid_minor_togglebutton',...
    'Style','Toggle',...
    'BackgroundColor',defaultBackground,...
    'String','minor',...
    'TooltipString','Show minor grid',...
    'pos',[handle_size(3)-30-(((handle_size(3)-40)/4)*2) 10 (handle_size(3)-40)/4 30],...
    'parent',handle_p3,...
    'HandleVisibility','off',...
    'Value',0,...
    'Callback',{@grid_minor_togglebutton_Callback}...
    );
uicontrol('Tag','display_panel_grid_zero_togglebutton',...
    'Style','Toggle',...
    'BackgroundColor',defaultBackground,...
    'String','zero',...
    'TooltipString','Show dashed line at zero',...
    'pos',[handle_size(3)-30-(((handle_size(3)-40)/4)) 10 (handle_size(3)-40)/4 30],...
    'parent',handle_p3,...
    'HandleVisibility','off',...
    'Value',1,...
    'Callback',{@grid_zero_togglebutton_Callback}...
    );


handle_p4 = uipanel('Tag','display_panel_legend_panel',...
    'Parent',handle_pp2,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[0 handle_size(4)-250 handle_size(3)-20 60],...
    'Title','Legend display and position'...
    );
uicontrol('Tag','display_panel_legend_auto_togglebutton',...
    'Style','Toggle',...
    'BackgroundColor',defaultBackground,...
    'String','auto',...
    'TooltipString','Display legend automatically (in best position)',...
    'pos',[10 10 (handle_size(3)-40)/5 30],...
    'parent',handle_p4,...
    'HandleVisibility','off',...
    'Value',0,...
    'Callback',{@grid_legend_togglebutton_Callback}...
    );
uicontrol('Tag','display_panel_legend_nw_togglebutton',...
    'Style','Toggle',...
    'BackgroundColor',defaultBackground,...
    'String','NW',...
    'TooltipString','Display legend in upper left corner',...
    'pos',[handle_size(3)-30-(((handle_size(3)-50)/5)*4) 10 (handle_size(3)-50)/5 30],...
    'parent',handle_p4,...
    'HandleVisibility','off',...
    'Value',0,...
    'Callback',{@grid_legend_togglebutton_Callback}...
    );
uicontrol('Tag','display_panel_legend_ne_togglebutton',...
    'Style','Toggle',...
    'BackgroundColor',defaultBackground,...
    'String','NE',...
    'TooltipString','Display legend in upper right corner',...
    'pos',[handle_size(3)-30-(((handle_size(3)-50)/5)*3) 10 (handle_size(3)-50)/5 30],...
    'parent',handle_p4,...
    'HandleVisibility','off',...
    'Value',0,...
    'Callback',{@grid_legend_togglebutton_Callback}...
    );
uicontrol('Tag','display_panel_legend_sw_togglebutton',...
    'Style','Toggle',...
    'BackgroundColor',defaultBackground,...
    'String','SW',...
    'TooltipString','Display legend in lower left corner',...
    'pos',[handle_size(3)-30-(((handle_size(3)-50)/5)*2) 10 (handle_size(3)-50)/5 30],...
    'parent',handle_p4,...
    'HandleVisibility','off',...
    'Value',0,...
    'Callback',{@grid_legend_togglebutton_Callback}...
    );
uicontrol('Tag','display_panel_legend_se_togglebutton',...
    'Style','Toggle',...
    'BackgroundColor',defaultBackground,...
    'String','SE',...
    'TooltipString','Display legend in lower right corner',...
    'pos',[handle_size(3)-30-(((handle_size(3)-50)/5)) 10 (handle_size(3)-50)/5 30],...
    'parent',handle_p4,...
    'HandleVisibility','off',...
    'Value',0,...
    'Callback',{@grid_legend_togglebutton_Callback}...
    );

handle_p5 = uipanel('Tag','display_panel_normalise_panel',...
    'Parent',handle_pp2,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[0 handle_size(4)-320 handle_size(3)-20 60],...
    'Title','Normalise'...
    );
uicontrol('Tag','display_panel_normalise_pkpk_togglebutton',...
    'Style','Toggle',...
    'BackgroundColor',defaultBackground,...
    'String','Pk-Pk = 1',...
    'TooltipString','Normalise peak-peak to 1',...
    'pos',[handle_size(3)-30-(((handle_size(3)-40)/2)*2) 10 (handle_size(3)-40)/2 30],...
    'parent',handle_p5,...
    'HandleVisibility','off',...
    'Value',0,...
    'Callback',{@normalise_togglebutton_Callback}...
    );
uicontrol('Tag','display_panel_normalise_amplitude_togglebutton',...
    'Style','Toggle',...
    'BackgroundColor',defaultBackground,...
    'String','amplitude = 1',...
    'TooltipString','Normalise amplitude to 1',...
    'pos',[handle_size(3)-30-(((handle_size(3)-40)/2)) 10 (handle_size(3)-40)/2 30],...
    'parent',handle_p5,...
    'HandleVisibility','off',...
    'Value',0,...
    'Callback',{@normalise_togglebutton_Callback}...
    );

handle_p6 = uipanel('Tag','display_panel_highlight_panel',...
    'Parent',handle_pp2,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[0 handle_size(4)-450 handle_size(3)-20 120],...
    'Title','Highlight of current dataset'...
    );
uicontrol('Tag','display_panel_highlight_checkbox',...
    'Style','checkbox',...
    'Parent',handle_p6,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[60 75 handle_size(3)-40 20],...
    'String',' highlight currently active',...
    'Value',1,...
    'Callback',{@highlight_checkbox_Callback}...
    );
uicontrol('Tag','display_panel_highlight_method_text',...
    'Style','text',...
    'Parent',handle_p6,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 40 40 20],...
    'String','method'...
    );
uicontrol('Tag','display_panel_highlight_value_text',...
    'Style','text',...
    'Parent',handle_p6,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 10 40 20],...
    'String','value'...
    );
uicontrol('Tag','display_panel_highlight_method_popupmenu',...
    'Style','popupmenu',...
    'Parent',handle_p6,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[60 40 handle_size(3)-85 20],...
    'String','color|linewidth|linestyle|marker',...
    'Callback',{@highlight_method_popupmenu_Callback}...
    );
uicontrol('Tag','display_panel_highlight_value_popupmenu',...
    'Style','popupmenu',...
    'Parent',handle_p6,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[60 10 handle_size(3)-85 20],...
    'String','blue|green|red|cyan|magenta|yellow|black',...
    'Callback',{@highlight_value_popupmenu_Callback}...
    );

handle_p7 = uipanel('Tag','display_panel_gaxis_panel',...
    'Parent',handle_pp3,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[0 handle_size(4)-390 handle_size(3)-20 60],...
    'Title','g axis'...
    );

handle_p8 = uipanel('Tag','display_panel_currentaxis_panel',...
    'Parent',handle_pp3,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[0 handle_size(4)-180 handle_size(3)-20 60],...
    'Title','Current axis'...
    );
uicontrol('Tag','display_panel_currentaxis_export_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p8,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 10 floor((handle_size(3)-40)/3) 30],...
    'String','Export'...
    );
uicontrol('Tag','display_panel_currentaxis_detach_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p8,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[floor((handle_size(3)-40)/3)+10 10 floor((handle_size(3)-40)/3) 30],...
    'String','Detach'...
    );
uicontrol('Tag','display_panel_currentaxis_3dplot_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p8,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[(floor((handle_size(3)-40)/3)*2)+10 10 floor((handle_size(3)-40)/3) 30],...
    'String','3D plot'...
    );

handle_p0 = uipanel('Tag','display_panel_displaytype_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 10 handle_size(3)-20 50],...
    'Title','Display type'...
    );
uicontrol('Tag','display_panel_displaytype_popupmenu',...
    'Style','popupmenu',...
    'Parent',handle_p0,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'Position',[10 10 handle_size(3)-40 20],...
    'String','2D plot|1D along x|1D along y',...
    'Callback', {@displaytype_popupmenu_Callback}...
    );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pages_buttongroup_Callback(source,~)
    page_panels = [handle_pp1 handle_pp2 handle_pp3 handle_pp4];
    val = get(get(source,'SelectedObject'),'String');
    switch val
        case 'page 1'
            set(page_panels,'Visible','off');
            set(handle_pp1,'Visible','on');         
        case 'page 2'
            set(page_panels,'Visible','off');
            set(handle_pp2,'Visible','on');
        case 'page 3'
            set(page_panels,'Visible','off');
            set(handle_pp3,'Visible','on');         
        case 'page 4'
            set(page_panels,'Visible','off');
            set(handle_pp4,'Visible','on');         
    end
end

function axislabels_edit_Callback(source,~,label)
    % Get appdata of main window
    mainWindow = findobj('Tag','trepr_gui_mainwindow');
    ad = getappdata(mainWindow);
    
    switch label
        case 'xmeasure'
            ad.control.axis.labels.x.measure = get(source,'String');
        case 'xunit'
            ad.control.axis.labels.x.unit = get(source,'String');
        case 'ymeasure'
            ad.control.axis.labels.y.measure = get(source,'String');
        case 'yunit'
            ad.control.axis.labels.y.unit = get(source,'String');
        case 'zmeasure'
            ad.control.axis.labels.z.measure = get(source,'String');
        case 'zunit'
            ad.control.axis.labels.z.unit = get(source,'String');
        otherwise
            msgstr = { 'Unknown axis label in callback function call.' ...
                sprintf('Function "%s" in file "%s"',...
                'axislabels_edit_Callback',...
                mfilename ...
                )...
                };
            status = add2status(msgstr);
            return;
    end
    
    % Update appdata of main window
    setappdata(mainWindow,'control',ad.control);  

    %Update main axis
    update_mainAxis();    
end

function axislabels_getfromactivedataset_pushbutton_Callback(~,~)
    % Get appdata of main window
    mainWindow = findobj('Tag','trepr_gui_mainwindow');
    ad = getappdata(mainWindow);

    if (isempty(ad.control.spectra.active))
        return;
    end

    if (isfield(ad.data{ad.control.spectra.active},'axes'))
        if (isfield(ad.data{ad.control.spectra.active}.axes,'x') && ...
                isfield(ad.data{ad.control.spectra.active}.axes.x,'measure'))
            ad.control.axis.labels.x.measure = ...
                ad.data{ad.control.spectra.active}.axes.x.measure;
        end
        if (isfield(ad.data{ad.control.spectra.active}.axes,'x') && ...
                isfield(ad.data{ad.control.spectra.active}.axes.x,'unit'))
            ad.control.axis.labels.x.unit = ...
                ad.data{ad.control.spectra.active}.axes.x.unit;
        end
        if (isfield(ad.data{ad.control.spectra.active}.axes,'y') && ...
                isfield(ad.data{ad.control.spectra.active}.axes.y,'measure'))
            ad.control.axis.labels.y.measure = ...
                ad.data{ad.control.spectra.active}.axes.y.measure;
        end
        if (isfield(ad.data{ad.control.spectra.active}.axes,'y') && ...
                isfield(ad.data{ad.control.spectra.active}.axes.y,'unit'))
            ad.control.axis.labels.y.unit = ...
                ad.data{ad.control.spectra.active}.axes.y.unit;
        end
        if (isfield(ad.data{ad.control.spectra.active}.axes,'z') && ...
                isfield(ad.data{ad.control.spectra.active}.axes.z,'measure'))
            ad.control.axis.labels.z.measure = ...
                ad.data{ad.control.spectra.active}.axes.z.measure;
        end
        if (isfield(ad.data{ad.control.spectra.active}.axes,'z') && ...
                isfield(ad.data{ad.control.spectra.active}.axes.z,'unit'))
            ad.control.axis.labels.z.unit = ...
                ad.data{ad.control.spectra.active}.axes.z.unit;
        end
    end
    
    % Update appdata of main window
    setappdata(mainWindow,'control',ad.control);  
    
    % Update display panel
    update_displayPanel();

    %Update main axis
    update_mainAxis();    
end

function axislimits_edit_Callback(source,~,limit)
    % Get appdata of main window
    mainWindow = findobj('Tag','trepr_gui_mainwindow');
    ad = getappdata(mainWindow);
    
    switch limit
        case 'xmin'
            ad.control.axis.limits.x.min = str2num(get(source,'String'));
        case 'xmax'
            % Test whether value is larger than min for same axis
            if (str2num(get(source,'String')) > ad.control.axis.limits.x.min)
                ad.control.axis.limits.x.max = str2num(get(source,'String'));
            else
                set(source,'String',num2str(ad.control.axis.limits.x.max));
                msgstr = 'Upper limit of an axis must be always bigger than lower limit.';
                status = add2status(msgstr);
                return;
            end
        case 'ymin'
            ad.control.axis.limits.y.min = str2num(get(source,'String'));
        case 'ymax'
            % Test whether value is larger than min for same axis
            if (str2num(get(source,'String')) > ad.control.axis.limits.y.min)
                ad.control.axis.limits.y.max = str2num(get(source,'String'));
            else
                set(source,'String',num2str(ad.control.axis.limits.y.max));
                msgstr = 'Upper limit of an axis must be always bigger than lower limit.';
                status = add2status(msgstr);
                return;
            end
        case 'zmin'
            ad.control.axis.limits.z.min = str2num(get(source,'String'));
        case 'zmax'
            % Test whether value is larger than min for same axis
            if (str2num(get(source,'String')) > ad.control.axis.limits.z.min)
                ad.control.axis.limits.z.max = str2num(get(source,'String'));
            else
                set(source,'String',num2str(ad.control.axis.limits.z.max));
                msgstr = 'Upper limit of an axis must be always bigger than lower limit.';
                status = add2status(msgstr);
                return;
            end
        otherwise
            msgstr = { 'Unknown axis limit in callback function call.' ...
                sprintf('Function "%s" in file "%s"',...
                'axislimits_edit_Callback',...
                mfilename ...
                )...
                };
            status = add2status(msgstr);
            return;
    end
    
    % Update appdata of main window
    setappdata(mainWindow,'control',ad.control);  

    %Update main axis
    update_mainAxis();
end

function axislimits_auto_checkbox_Callback(source,~)
    % Get appdata of main window
    mainWindow = findobj('Tag','trepr_gui_mainwindow');
    ad = getappdata(mainWindow);

    ad.control.axis.limits.auto = get(source,'Value');
    
    % Update appdata of main window
    setappdata(mainWindow,'control',ad.control);  
    
    % Update display panel
    update_displayPanel();

    %Update main axis
    update_mainAxis();
end

function highlight_checkbox_Callback(source,~)
    % Get appdata of main window
    mainWindow = findobj('Tag','trepr_gui_mainwindow');
    ad = getappdata(mainWindow);

    % Get handles of main window
    gh = guihandles(mainWindow);

    if (get(source,'Value'))
        set(gh.display_panel_highlight_method_popupmenu,...
            'Enable','On');
        set(gh.display_panel_highlight_value_popupmenu,...
            'Enable','On');
    else
        set(gh.display_panel_highlight_method_popupmenu,...
            'Enable','Off');
        set(gh.display_panel_highlight_value_popupmenu,...
            'Enable','Off');
    end
end

function highlight_method_popupmenu_Callback(source,eventdata)
    % Get appdata of main window
    mainWindow = findobj('Tag','trepr_gui_mainwindow');
    ad = getappdata(mainWindow);

    % Get handles of main window
    gh = guihandles(mainWindow);

    highlightTypes = cellstr(get(source,'String'));
    highlightType = highlightTypes{get(source,'Value')};
    ad.control.axis.highlight.method = highlightType;
    
    switch highlightType
        case 'color'
            set(gh.display_panel_highlight_value_popupmenu,...
                'String','blue|green|red|cyan|magenta|yellow|black');
            set(gh.display_panel_highlight_value_popupmenu,...
                'Value',1);
        case 'linewidth'
            set(gh.display_panel_highlight_value_popupmenu,...
                'String','1 px|2 px|3 px|4 px|5 px');    
            set(gh.display_panel_highlight_value_popupmenu,...
                'Value',1);
        case 'linestyle'
            set(gh.display_panel_highlight_value_popupmenu,...
                'String','solid|dashed|dotted|dash-dotted');    
            set(gh.display_panel_highlight_value_popupmenu,...
                'Value',1);
        case 'marker'
            set(gh.display_panel_highlight_value_popupmenu,...
                'String','plus|circle|asterisk|point|cross|square|diamond|triangle up|triangle down|triangle right|triangle left|pentagram|hexagram');    
            set(gh.display_panel_highlight_value_popupmenu,...
                'Value',1);
        otherwise
            msg = sprintf('Highlight type %s currently unsupported',highlightType);
            add2status(msg);
    end
    
    % Update appdata of main window
    setappdata(mainWindow,'control',ad.control);  

    % Update highlight_value_popupmenu
    highlight_value_popupmenu_Callback(source,eventdata);
    
    %Update main axis
    update_mainAxis();    
end

function highlight_value_popupmenu_Callback(source,eventdata)
    % Get appdata of main window
    mainWindow = findobj('Tag','trepr_gui_mainwindow');
    ad = getappdata(mainWindow);

    % Get handles of main window
    gh = guihandles(mainWindow);

    highlightValues = ...
        cellstr(get(gh.display_panel_highlight_value_popupmenu,'String'));
    highlightValue = ...
        highlightValues{get(gh.display_panel_highlight_value_popupmenu,'Value')};

    highlight = struct();
    highlight.color = struct(...
        'blue','b',...
        'green','g',...
        'red','r',...
        'cyan','c',...
        'magenta','m',...
        'yellow','y',...
        'black','k');
    highlight.linewidth = struct(...
        'n1px',1,...
        'n2px',2,...
        'n3px',3,...
        'n4px',4,...
        'n5px',5);
    highlight.linestyle = struct(...
        'solid','-',...
        'dashed','--',...
        'dotted',':',...
        'dashdotted','-.');
    highlight.marker = struct(...
        'plus','+',...
        'circle','o',...
        'asterisk','*',...
        'point','.',...
        'cross','x',...
        'square','s',...
        'diamond','d',...
        'triangleup','^',...
        'triangledown','v',...
        'triangleright','>',...
        'triangleleft','<',...
        'pentagram','p',...
        'hexagram','h');

    ad.control.axis.highlight.value = ...
        getfield(getfield(highlight,ad.control.axis.highlight.method),...
        regexprep(strrep(strrep(highlightValue,' ',''),'-',''),'^([0-9])','n$1'));
    
    % Update appdata of main window
    setappdata(mainWindow,'control',ad.control);  
    
    %Update main axis
    update_mainAxis();    
end

function grid_x_togglebutton_Callback(source,eventdata)
    % Get appdata of main window
    mainWindow = findobj('Tag','trepr_gui_mainwindow');
    ad = getappdata(mainWindow);
    
    if (get(source,'Value'))
        ad.control.axis.grid.x = 'on';
    else
        ad.control.axis.grid.x = 'off';
    end

    % Update appdata of main window
    setappdata(mainWindow,'control',ad.control);  
    
    %Update main axis
    update_mainAxis();    
end

function grid_y_togglebutton_Callback(source,eventdata)
    % Get appdata of main window
    mainWindow = findobj('Tag','trepr_gui_mainwindow');
    ad = getappdata(mainWindow);
    
    if (get(source,'Value'))
        ad.control.axis.grid.y = 'on';
    else
        ad.control.axis.grid.y = 'off';
    end

    % Update appdata of main window
    setappdata(mainWindow,'control',ad.control);  
    
    %Update main axis
    update_mainAxis();    
end

function grid_minor_togglebutton_Callback(source,~)
    % Get appdata of main window
    mainWindow = findobj('Tag','trepr_gui_mainwindow');
    ad = getappdata(mainWindow);
    
    if (get(source,'Value'))
        ad.control.axis.grid.minor = 'on';
    else
        ad.control.axis.grid.minor = 'off';
    end
    
    % Update appdata of main window
    setappdata(mainWindow,'control',ad.control);  
    
    %Update main axis
    update_mainAxis();    
end

function grid_zero_togglebutton_Callback(source,~)
    % Get appdata of main window
    mainWindow = findobj('Tag','trepr_gui_mainwindow');
    ad = getappdata(mainWindow);
    
    ad.control.axis.grid.zero = get(source,'Value');

    % Update appdata of main window
    setappdata(mainWindow,'control',ad.control);  
    
    % Update main axis
    update_mainAxis();    
end

function grid_legend_togglebutton_Callback(source,~)
    % Get appdata of main window
    mainWindow = findobj('Tag','trepr_gui_mainwindow');
    ad = getappdata(mainWindow);

    % Get handles of main window
    gh = guihandles(mainWindow);
 
    % For some currently unknown reason, findobj seems not to work. The
    % parent handle behaves weird...
    legendButtons = [...
        gh.display_panel_legend_auto_togglebutton ...
        gh.display_panel_legend_nw_togglebutton ...
        gh.display_panel_legend_ne_togglebutton ...
        gh.display_panel_legend_sw_togglebutton ...
        gh.display_panel_legend_se_togglebutton ...
        ];
    
    switch source
        case gh.display_panel_legend_auto_togglebutton
            if (get(source,'Value'))
                ad.control.axis.legend.location = 'Best';
                set(legendButtons,'Value',0);
                set(source,'Value',1);
            else
                ad.control.axis.legend.location = 'none';
                set(legendButtons,'Value',0);
            end
        case gh.display_panel_legend_nw_togglebutton
            if (get(source,'Value'))
                ad.control.axis.legend.location = 'NorthWest';
                set(legendButtons,'Value',0);
                set(source,'Value',1);
            else
                ad.control.axis.legend.location = 'none';
                set(legendButtons,'Value',0);
            end
        case gh.display_panel_legend_ne_togglebutton
            if (get(source,'Value'))
                ad.control.axis.legend.location = 'NorthEast';
                set(legendButtons,'Value',0);
                set(source,'Value',1);
            else
                ad.control.axis.legend.location = 'none';
                set(legendButtons,'Value',0);
            end
        case gh.display_panel_legend_sw_togglebutton
            if (get(source,'Value'))
                ad.control.axis.legend.location = 'SouthWest';
                set(legendButtons,'Value',0);
                set(source,'Value',1);
            else
                ad.control.axis.legend.location = 'none';
                set(legendButtons,'Value',0);
            end
        case gh.display_panel_legend_se_togglebutton
            if (get(source,'Value'))
                ad.control.axis.legend.location = 'SouthEast';
                set(legendButtons,'Value',0);
                set(source,'Value',1);
            else
                ad.control.axis.legend.location = 'none';
                set(legendButtons,'Value',0);
            end
    end

    % Update appdata of main window
    setappdata(mainWindow,'control',ad.control);  
    
    %Update main axis
    update_mainAxis();    
end

function normalise_togglebutton_Callback(source,~)
    % Get appdata of main window
    mainWindow = findobj('Tag','trepr_gui_mainwindow');
    ad = getappdata(mainWindow);

    % Get handles of main window
    gh = guihandles(mainWindow);
 
    % For some currently unknown reason, findobj seems not to work. The
    % parent handle behaves weird...
    normaliseButtons = [...
        gh.display_panel_normalise_pkpk_togglebutton ...
        gh.display_panel_normalise_amplitude_togglebutton ...
        ];
    
    switch source
        case gh.display_panel_normalise_pkpk_togglebutton
            if (get(source,'Value'))
                ad.control.axis.normalisation = 'pkpk';
                set(normaliseButtons,'Value',0);
                set(source,'Value',1);
            else
                ad.control.axis.normalisation = 'none';
                set(normaliseButtons,'Value',0);
            end
        case gh.display_panel_normalise_amplitude_togglebutton
            if (get(source,'Value'))
                ad.control.axis.normalisation = 'amplitude';
                set(normaliseButtons,'Value',0);
                set(source,'Value',1);
            else
                ad.control.axis.normalisation = 'none';
                set(normaliseButtons,'Value',0);
            end
    end
    
    % Update appdata of main window
    setappdata(mainWindow,'control',ad.control);  
    
    %Update main axis
    update_mainAxis();    
    
    %Update slider panel
    update_sliderPanel();    
end


function displaytype_popupmenu_Callback(source,eventdata)
    % Get appdata of main window
    mainWindow = findobj('Tag','trepr_gui_mainwindow');
    ad = getappdata(mainWindow);

    displayTypes = cellstr(get(source,'String'));
    displayType = displayTypes{get(source,'Value')};
    ad.control.axis.displayType = displayType;
    
    % Update appdata of main window
    setappdata(mainWindow,'control',ad.control);
    
    update_mainAxis();
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Utility functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end