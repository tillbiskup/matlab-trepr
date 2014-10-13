function handle = guiAnalysisPanel(parentHandle,position)
% GUIANALYSISPANEL Add a panel displaying some analysis controls to a gui
%       Should only be called from within a GUI defining function.
%
%       Arguments: parent Handle and position vector.
%
%       Returns the handle of the added panel.

% Copyright (c) 2011-14, Till Biskup
% 2014-10-13

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

defaultBackground = get(parentHandle,'Color');

handle = uipanel('Tag','analysis_panel',...
    'parent',parentHandle,...
    'Title','Data analysis',...
    'FontUnit','Pixel','Fontsize',12,...
    'FontWeight','bold',...
    'BackgroundColor',defaultBackground,...
    'Visible','off',...
    'Units','pixels','Position',position);

% Create the panel
handle_size = get(handle,'Position');


% Create buttongroup to switch between subpanels (pages)
hpbg = uibuttongroup('Tag','analysis_panel_pages_buttongroup',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'BorderType','none',...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-60 handle_size(3)-20 30],...
    'SelectionChangeFcn',{@pages_buttongroup_Callback}...
    );
uicontrol('Tag','analysis_panel_page1_pushbutton',...
    'Style','Toggle',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','1',...
    'TooltipString','Page 1: Frequency drift, net polarisation, BG positions, ...',...
    'pos',[0 0 (handle_size(3)-20)/2 30],...
    'parent',hpbg,...
    'HandleVisibility','off',...
    'Value',1);
uicontrol('Tag','analysis_panel_page2_pushbutton',...
    'Style','Toggle',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','2',...
    'TooltipString','Page 2: Data export in 1D and 2D',...
    'pos',[(((handle_size(3)-20)/2)) 0 (handle_size(3)-20)/2 30],...
    'parent',hpbg,...
    'HandleVisibility','off',...
    'Value',0);

% Create subpanels (pages)
handle_pp1 = uipanel('Tag','analysis_panel_page1_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'BorderType','none',...
    'Units','Pixels',...
    'Position',[5 10 handle_size(3)-10 handle_size(4)-60]...
    );
handle_pp2 = uipanel('Tag','analysis_panel_page2_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'BorderType','none',...
    'Units','Pixels',...
    'Position',[5 10 handle_size(3)-10 handle_size(4)-60],...
    'Visible','Off'...
    );

handle_p11 = uipanel('Tag','analysis_panel_mwfrequencydrift_panel',...
    'Parent',handle_pp1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[5 handle_size(4)-140 handle_size(3)-20 60],...
    'Title','MW Frequency drift'...
    );
uicontrol('Tag','analysis_panel_mwfrequencydrift_description',...
    'Style','text',...
    'Parent',handle_p11,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'FontAngle','oblique',...
    'Position',[10 10 handle_size(3)-110 30],...
    'String',{'Analyse MW frequency drift of current dataset.'}...
    );
uicontrol('Tag','analysis_panel_mwfrequencydrift_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p11,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[handle_size(3)-90 10 60 30],...
    'String','Show',...
    'TooltipString','Plot MW frequency drift for currently active dataset',...
    'Callback',{@pushbutton_Callback,'MWfreqDriftPlot'}...
    );

handle_p12 = uipanel('Tag','analysis_panel_netpolarisation_panel',...
    'Parent',handle_pp1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[5 handle_size(4)-210 handle_size(3)-20 60],...
    'Title','Net polarisation'...
    );
uicontrol('Tag','analysis_panel_netpolarisation_description',...
    'Style','text',...
    'Parent',handle_p12,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'FontAngle','oblique',...
    'Position',[10 10 handle_size(3)-110 30],...
    'String',{'Analyse net polarisation of current dataset.'}...
    );
uicontrol('Tag','analysis_panel_netpolarisation_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p12,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[handle_size(3)-90 10 60 30],...
    'String','Show',...
    'TooltipString','Plot net polarisation as function of time for currently active dataset',...
    'Callback',{@pushbutton_Callback,'NetPolarisationPlot'}...
    );

handle_p13 = uipanel('Tag','analysis_panel_bgpositions_panel',...
    'Parent',handle_pp1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[5 handle_size(4)-300 handle_size(3)-20 80],...
    'Title','BG positions'...
    );
uicontrol('Tag','analysis_panel_showbgpositions_checkbox',...
    'Style','checkbox',...
    'Parent',handle_p13,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 40 (handle_size(3)-70) 20],...
    'String',' Show BG positions',...
    'TooltipString',sprintf('%s\n%s\n%s',...
    'Toggle between displaying background scan positions.',...
    'Depending on the recording mode, background scans are performed',...
    'regularly throughout the measurement whose position (in time) is shown here.'),...
    'Value',0,...
    'Callback',{@checkbox_Callback,'BGpositions'}...
    );
uicontrol('Tag','analysis_panel_bgpositions_offset_text',...
    'Style','text',...
    'Parent',handle_p13,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','left',...
    'Units','Pixels',...
    'Position',[10 10 150 20],...
    'TooltipString','...',...
    'String','Offset (field steps)'...
    );
uicontrol('Tag','analysis_panel_bgpositions_offset_edit',...
    'Style','edit',...
    'Parent',handle_p13,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[140 10 60 25],...
    'String','0',...
    'TooltipString','...',...
    'Callback',{@edit_Callback,'BGpositionsShift'}...
    );
uicontrol('Tag','analysis_panel_bgpositions_help_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p13,...
    'BackgroundColor',defaultBackground,...
    'ForegroundColor',[0 0 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'FontWeight','bold',...
    'String','?',...
    'TooltipString','Display help about displaying BG positions',...
    'Position',[handle_size(3)-55 10 25 25],...
    'Enable','on',...
    'Callback',{@pushbutton_Callback,'BGpositionsHelp'}...
    );



handle_p21 = uipanel('Tag','analysis_panel_dataexport1D_panel',...
    'Parent',handle_pp2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[5 handle_size(4)-290 handle_size(3)-20 210],...
    'Title','Export 1D data'...
    );
uicontrol('Tag','analysis_panel_dataexport1D_filetype_text',...
    'Style','text',...
    'Parent',handle_p21,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','left',...
    'Units','Pixels',...
    'Position',[10 158 60 20],...
    'String','Format'...
    );
uicontrol('Tag','analysis_panel_dataexport1D_filetype_popupmenu',...
    'Style','popupmenu',...
    'Parent',handle_p21,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[70 160 handle_size(3)-100 20],...
    'String','ASCII',...
    'TooltipString','Select 1D export format'...
    );
uicontrol('Tag','analysis_panel_dataexport1D_header_text',...
    'Style','text',...
    'Parent',handle_p21,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','left',...
    'Units','Pixels',...
    'Position',[10 125 150 20],...
    'TooltipString','Character(s) the header starts with; default: "%" (Matlab)',...
    'String','Header starts with'...
    );
uicontrol('Tag','analysis_panel_dataexport1D_header_edit',...
    'Style','edit',...
    'Parent',handle_p21,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[170 125 60 25],...
    'String','%',...
    'TooltipString','Character the header should start with'...
    );
uicontrol('Tag','analysis_panel_dataexport1D_include_text',...
    'Style','text',...
    'Parent',handle_p21,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','left',...
    'Units','Pixels',...
    'Position',[10 93 60 20],...
    'String','Include'...
    );
uicontrol('Tag','analysis_panel_dataexport1D_includeaxis_checkbox',...
    'Style','checkbox',...
    'Parent',handle_p21,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[handle_size(3)-190 95 70 20],...
    'String',' Axis',...
    'TooltipString','Toggle between including or excluding axis values',...
    'Value',1 ...
    );
uicontrol('Tag','analysis_panel_dataexport1D_includestdev_checkbox',...
    'Style','checkbox',...
    'Parent',handle_p21,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[handle_size(3)-120 95 110 20],...
    'String',' Std. dev.',...
    'TooltipString','Toggle between including or excluding std. dev. values',...
    'Value',0 ...
    );
uicontrol('Tag','analysis_panel_dataexport1D_includeinfofile_checkbox',...
    'Style','checkbox',...
    'Parent',handle_p21,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[handle_size(3)-190 70 70 20],...
    'String',' Info file',...
    'TooltipString','Toggle between including info file in header',...
    'Enable','inactive',...
    'Value',0 ...
    );
uicontrol('Tag','analysis_panel_dataexport1D_includesimulation_checkbox',...
    'Style','checkbox',...
    'Parent',handle_p21,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[handle_size(3)-120 70 110 20],...
    'String',' Simulation',...
    'TooltipString','Toggle between including or excluding simulation (calculated values)',...
    'Enable','inactive',...
    'Value',0 ...
    );
uicontrol('Tag','analysis_panel_dataexport1D_multiplefiles_text',...
    'Style','text',...
    'Parent',handle_p21,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','left',...
    'Units','Pixels',...
    'Position',[10 42 60 20],...
    'String','Multiple'...
    );
uicontrol('Tag','analysis_panel_dataexport1D_multiple1file_checkbox',...
    'Style','checkbox',...
    'Parent',handle_p21,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[handle_size(3)-190 45 70 20],...
    'String',' 1 file',...
    'TooltipString','Export multiple datasets in one single file',...
    'Value',0,...
    'Callback',{@checkbox_Callback,'multiple1file'} ...
    );
uicontrol('Tag','analysis_panel_dataexport1D_multiplefiles_checkbox',...
    'Style','checkbox',...
    'Parent',handle_p21,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[handle_size(3)-120 45 110 20],...
    'String',' n files',...
    'TooltipString','Export multiple datasets in multiple files',...
    'Value',0,...
    'Callback',{@checkbox_Callback,'multiplefiles'} ...
    );
uicontrol('Tag','analysis_panel_dataexport1D_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p21,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[handle_size(3)-90 10 60 30],...
    'String','Export',...
    'TooltipString',sprintf('%s\n%s',...
    'Export currently active dataset in current (x or y) display',...
    'to file with given type'),...
    'Callback',{@pushbutton_Callback,'dataExport1D'}...
    );

handle_p22 = uipanel('Tag','analysis_panel_dataexport2D_panel',...
    'Parent',handle_pp2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[5 handle_size(4)-480 handle_size(3)-20 185],...
    'Title','Export 2D data'...
    );
uicontrol('Tag','analysis_panel_dataexport2D_format_text',...
    'Style','text',...
    'Parent',handle_p22,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','left',...
    'Units','Pixels',...
    'Position',[10 135 60 20],...
    'String','Format'...
    );
uicontrol('Tag','analysis_panel_dataexport2D_format_popupmenu',...
    'Style','popupmenu',...
    'Parent',handle_p22,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[70 137 handle_size(3)-100 20],...
    'String','glotaran|ASCII',...
    'TooltipString','Select 2D export format'...
    );
uicontrol('Tag','analysis_panel_dataexport2D_header_text',...
    'Style','text',...
    'Parent',handle_p22,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','left',...
    'Units','Pixels',...
    'Position',[10 100 150 20],...
    'TooltipString','Character(s) the header starts with; default: "%" (Matlab)',...
    'String','Header starts with'...
    );
uicontrol('Tag','analysis_panel_dataexport2D_header_edit',...
    'Style','edit',...
    'Parent',handle_p22,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[170 100 60 25],...
    'String','%',...
    'TooltipString','Character the header should start with'...
    );
uicontrol('Tag','analysis_panel_dataexport2D_include_text',...
    'Style','text',...
    'Parent',handle_p22,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','left',...
    'Units','Pixels',...
    'Position',[10 68 60 20],...
    'String','Include'...
    );
uicontrol('Tag','analysis_panel_dataexport2D_includeaxes_checkbox',...
    'Style','checkbox',...
    'Parent',handle_p22,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[handle_size(3)-190 70 70 20],...
    'String',' Axes',...
    'TooltipString','Toggle between including or excluding axis values',...
    'Value',1 ...
    );
uicontrol('Tag','analysis_panel_dataexport2D_includeinfofile_checkbox',...
    'Style','checkbox',...
    'Parent',handle_p22,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[handle_size(3)-190 45 160 20],...
    'String',' Info file (in header)',...
    'TooltipString','Toggle between including info file in header',...
    'Enable','inactive',...
    'Value',0 ...
    );
uicontrol('Tag','analysis_panel_dataexport2D_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p22,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[handle_size(3)-90 10 60 30],...
    'String','Export',...
    'TooltipString','Export current dataset in a format understood by glotaran',...
    'Callback',{@pushbutton_Callback,'Export'}...
    );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pages_buttongroup_Callback(source,~)
    try
        page_panels = [handle_pp1 handle_pp2];
        set(page_panels,'Visible','off');
        set(page_panels(...
            str2double(get(get(source,'SelectedObject'),'String'))),...
            'Visible','on');
        %update_analysisPanel();
        update_visibleSpectra();
    catch exception
        trEPRexceptionHandling(exception)
    end
end

end % End main function

function pushbutton_Callback(~,~,action)

try
    if isempty(action)
        return;
    end
    
    % Get appdata of main window
    mainWindow = trEPRguiGetWindowHandle();
    ad = getappdata(mainWindow);
    
    % Get handles of main window
    gh = guihandles(mainWindow);
    
    active = ad.control.data.active;
    
    switch lower(action)
        case 'export'
            [status,warnings] = cmdExport(mainWindow,{'2D'});
            if status
                TAmsg(warnings,'warning');
            end
        case 'dataexport1d'
            [status,warnings] = cmdExport(mainWindow,{'1D'});
            if status
                TAmsg(warnings,'warning');
            end
        case 'mwfreqdriftplot'
            if ~ad.control.data.active
                return;
            end
            active = ad.control.data.active;
            if isscalar(ad.data{active}.parameters.bridge.MWfrequency.value) && ...
                    ~isfield(ad.data{active}.parameters.bridge.MWfrequency,'values') && ...
                    (~isfield(ad.data{active}.parameters.bridge.calibration,'values') || ...
                    length(ad.data{active}.parameters.bridge.calibration.values) < 2)
                msgbox('Currently active dataset has not enough frequency values.',...
                    'Frequency Drift Plot','warn');
                trEPRmsg(['Frequency drift analysis failed: ' ...
                    'Dataset has not enough frequency values.'],...
                    'warning');
                return;
            end
            trEPRgui_MWfrequencyDriftwindow();
        case 'netpolarisationplot'
            if ~ad.control.data.active
                return;
            end
            active = ad.control.data.active;
            if isscalar(ad.data{active}.axes.x.values) || ...
                    isscalar(ad.data{active}.axes.y.values)
                msgbox('Currently active dataset has insufficient dimensions for net polarisation analysis.',...
                    'Net Polarisation Plot','warn');
                trEPRmsg(['Net polarisation analysis failed: ' ...
                    'Dataset has insufficient dimensions.'],...
                    'warning');
                return;
            end
            trEPRgui_NetPolarisationwindow();
        case 'bgpositionshelp'
            trEPRgui_helpwindow();
        otherwise
            trEPRoptionUnknown(action);
            return;
    end
catch exception
    trEPRexceptionHandling(exception)
end

end

function checkbox_Callback(source,~,action)

try
    if isempty(action)
        return;
    end
    
    % Get appdata and GUI handles of main GUI
    mainWindow = trEPRguiGetWindowHandle();
    ad = getappdata(mainWindow);
    
    switch lower(action)
        case 'bgpositions'
            ad.control.axis.BGpositions.enable = get(source,'Value');
        case 'multiple1file'
            % Turn off "multiplefiles" checkbox
            set(gh.analysis_panel_dataexport1D_multiplefiles_checkbox,...
                'Value',0);
        case 'multiplefiles'
            % Turn off "multiple1file" checkbox
            set(gh.analysis_panel_dataexport1D_multiple1file_checkbox,...
                'Value',0);
        otherwise
            trEPRoptionUnknown(action);
            return;
    end
    setappdata(mainWindow,'control',ad.control);
    
    % Update main axis
    update_mainAxis();
catch exception
    trEPRexceptionHandling(exception)
end

end

function edit_Callback(source,~,action)

try
    if isempty(action)
        return;
    end
    
    % Get appdata and handles of main GUI
    mainWindow = trEPRguiGetWindowHandle();
    ad = getappdata(mainWindow);
    
    active = ad.control.data.active;
    if isempty(active) && ~active
        return;
    end
    
    value = trEPRguiSanitiseNumericInput(get(source,'String'));
    if isnan(value)
        update_displayPanel();
        return;
    end
    
    switch action
        case 'BGpositionsShift'
            ad.control.axis.BGpositions.shift = value;
        otherwise
            trEPRoptionUnknown(action);
            return;
    end
    setappdata(mainWindow,'control',ad.control);
    % Update main axis
    update_mainAxis();
catch exception
    trEPRexceptionHandling(exception)
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Utility functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
