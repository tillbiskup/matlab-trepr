function handle = panelDatasets(parentHandle,position)
% PANELDATASETS Add a panel for dataset control to a gui
%       Should only be called from within a GUI defining function.
%
%       Arguments: parent Handle and position vector.
%
%       Returns the handle of the added panel.

% Copyright (c) 2011-15, Till Biskup
% 2015-05-31

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

defaultBackground = get(parentHandle,'Color');

handle = uipanel('Tag','data_panel',...
    'parent',parentHandle,...
    'Title','Datasets',...
    'FontUnit','Pixel','Fontsize',12,...
    'FontWeight','bold',...
    'BackgroundColor',defaultBackground,...
    'Visible','off',...
    'Units','pixels','Position',position);

% Create the "Dataset display" panel
panel_size = get(handle,'Position');

% Create buttongroup to switch between subpanels (pages)
hpbg = uibuttongroup('Tag','datasets_panel_pages_buttongroup',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'BorderType','none',...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 panel_size(4)-55 panel_size(3)-20 30],...
    'SelectionChangeFcn',{@pages_buttongroup_Callback}...
    );
uicontrol('Tag','datasets_panel_page1_pushbutton',...
    'Style','Toggle',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','1',...
    'TooltipString','Page 1: Toggle visibility, combine, save, remove, duplicate',...
    'pos',[0 0 (panel_size(3)-20)/2 30],...
    'parent',hpbg,...
    'HandleVisibility','off',...
    'Value',1);
uicontrol('Tag','datasets_panel_page2_pushbutton',...
    'Style','Toggle',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','2',...
    'TooltipString','Page 2: Data export in 1D and 2D',...
    'pos',[(((panel_size(3)-20)/2)) 0 (panel_size(3)-20)/2 30],...
    'parent',hpbg,...
    'HandleVisibility','off',...
    'Value',0);

% Create subpanels (pages)
handle_pp1 = uipanel('Tag','datasets_panel_page1_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'BorderType','none',...
    'Units','Pixels',...
    'Position',[5 10 panel_size(3)-10 panel_size(4)-60]...
    );
handle_pp2 = uipanel('Tag','datasets_panel_page2_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'BorderType','none',...
    'Units','Pixels',...
    'Position',[5 10 panel_size(3)-10 panel_size(4)-60],...
    'Visible','Off'...
    );

handle_pp1_1 = uipanel('Tag','data_panel_invisible_panel',...
    'Parent',handle_pp1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[5 panel_size(4)-175 panel_size(3)-20 95],...
    'Title','Invisible datasets'...
    );
uicontrol('Tag','data_panel_invisible_listbox',...
    'Style','listbox',...
    'Parent',handle_pp1_1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 panel_size(3)-40 65],...
    'String','',...
    'Callback',{@invisible_listbox_Callback}...
    );

handle_pp1_2 = uipanel('Tag','data_panel_visible_panel',...
    'Parent',handle_pp1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[5 panel_size(4)-325 panel_size(3)-20 100],...
    'Title','Visible datasets'...
    );
uicontrol('Tag','data_panel_visible_listbox',...
    'Style','listbox',...
    'Parent',handle_pp1_2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 panel_size(3)-40 70],...
    'String','',...
    'Callback',{@visible_listbox_Callback}...
    );

uicontrol('Tag','data_panel_showall_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_pp1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[5 panel_size(4)-215 (panel_size(3)-20)/4 30],...
    'String','<html>&dArr;</html>',...
    'TooltipString','Show all spectra',...
    'Callback', {@pushbutton_Callback,'ShowAll'}...
    );
uicontrol('Tag','data_panel_show_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_pp1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[5+(panel_size(3)-20)/4 panel_size(4)-215 (panel_size(3)-20)/4 30],...
    'String','<html>&darr;</html>',...
    'TooltipString','Show currently highlighted spectrum',...
    'Callback', {@pushbutton_Callback,'Show'}...
    );
uicontrol('Tag','data_panel_hide_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_pp1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[5+(panel_size(3)-20)/4*2 panel_size(4)-215 (panel_size(3)-20)/4 30],...
    'String','<html>&uarr;</html>',...
    'TooltipString','Hide currently highlighted spectrum',...
    'Callback', {@pushbutton_Callback,'Hide'}...
    );
uicontrol('Tag','data_panel_hideall_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_pp1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[5+(panel_size(3)-20)/4*3 panel_size(4)-215 (panel_size(3)-20)/4 30],...
    'String','<html>&uArr;</html>',...
    'TooltipString','Hide all spectra',...
    'Callback', {@pushbutton_Callback,'HideAll'}...
    );

handle_pp1_3 = uipanel('Tag','data_panel_multiple_panel',...
    'Parent',handle_pp1,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'FontUnit','Pixel','Fontsize',12,...
    'Position',[5 panel_size(4)-390 panel_size(3)-20 55],...
    'Title','Multiple datasets'...
    );
uicontrol('Tag','data_panel_combine_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_pp1_3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 floor((panel_size(3)-40)/3) 25],...
    'TooltipString',sprintf('%s\n%s',...
    'Combine multiple datasets into one',...
    '(e.g., if forgotten to check "combine" at load)'),...
    'String','Combine',...
    'Callback',{@pushbutton_Callback,'Combine'}...
    );
uicontrol('Tag','data_panel_showonlyactive_checkbox',...
    'Style','checkbox',...
    'Parent',handle_pp1_3,...
    'BackgroundColor',defaultBackground,...
    'Enable','on',...
    'TooltipString','Check to display only the currently active dataset',...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[20+floor((panel_size(3)-40)/3) 10 floor((panel_size(3)-40)/3*2)-10 25],...
    'String',' Show only active',...
    'Value',0,...
    'Callback',{@checkbox_Callback,'showonlyactive'}...
    );

handle_pp1_4 = uipanel('Tag','data_panel_currentlyactive_panel',...
    'Parent',handle_pp1,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'FontUnit','Pixel','Fontsize',12,...
    'Position',[5 panel_size(4)-480 panel_size(3)-20 80],...
    'Title','Currently active dataset'...
    );
uicontrol('Tag','data_panel_save_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_pp1_4,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 35 floor((panel_size(3)-40)/3) 25],...
    'String','Save',...
    'TooltipString','Save currently active spectrum',...
    'Callback', {@pushbutton_Callback,'Save'}...
    );
uicontrol('Tag','data_panel_saveas_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_pp1_4,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[floor((panel_size(3)-40)/3)+10 35 floor((panel_size(3)-40)/3) 25],...
    'String','Save as',...
    'TooltipString','Save currently active spectrum under different filename',...
    'Callback', {@pushbutton_Callback,'SaveAs'}...
    );
uicontrol('Tag','data_panel_remove_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_pp1_4,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[(floor((panel_size(3)-40)/3)*2)+10 35 floor((panel_size(3)-40)/3) 25],...
    'String','Remove',...
    'TooltipString',sprintf('%s\n%s',...
    'Remove currently active spectrum from GUI',...
    '(does not delete the file)'),...
    'Callback', {@pushbutton_Callback,'Remove'}...
    );
uicontrol('Tag','data_panel_undo_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_pp1_4,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 floor((panel_size(3)-40)/3) 25],...
    'String','Undo',...
    'TooltipString','Undo last operation on currently active dataset',...
    'Callback', {@pushbutton_Callback,'Undo'}...
    );
uicontrol('Tag','data_panel_getinfo_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_pp1_4,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[floor((panel_size(3)-40)/3)+10 10 floor((panel_size(3)-40)/3) 25],...
    'String','Get info',...
    'TooltipString','Open info window giving full access to parameters',...
    'Callback', {@trEPRgui_infowindow}...
    );
uicontrol('Tag','data_panel_duplicate_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_pp1_4,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[(floor((panel_size(3)-40)/3)*2)+10 10 floor((panel_size(3)-40)/3) 25],...
    'TooltipString','Duplicate currently active dataset',...
    'String','Duplicate',...
    'Callback', {@pushbutton_Callback,'Duplicate'}...
    );


handle_pp2_1 = uipanel('Tag','datasets_panel_dataexport1D_panel',...
    'Parent',handle_pp2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[5 panel_size(4)-290 panel_size(3)-20 210],...
    'Title','Export 1D data'...
    );
uicontrol('Tag','datasets_panel_dataexport1D_filetype_text',...
    'Style','text',...
    'Parent',handle_pp2_1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','left',...
    'Units','Pixels',...
    'Position',[10 158 60 20],...
    'String','Format'...
    );
uicontrol('Tag','datasets_panel_dataexport1D_filetype_popupmenu',...
    'Style','popupmenu',...
    'Parent',handle_pp2_1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[70 160 panel_size(3)-100 20],...
    'String','ASCII',...
    'TooltipString','Select 1D export format'...
    );
uicontrol('Tag','datasets_panel_dataexport1D_header_text',...
    'Style','text',...
    'Parent',handle_pp2_1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','left',...
    'Units','Pixels',...
    'Position',[10 125 150 20],...
    'TooltipString','Character(s) the header starts with; default: "%" (Matlab)',...
    'String','Header starts with'...
    );
uicontrol('Tag','datasets_panel_dataexport1D_header_edit',...
    'Style','edit',...
    'Parent',handle_pp2_1,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[170 125 60 25],...
    'String','%',...
    'TooltipString','Character the header should start with'...
    );
uicontrol('Tag','datasets_panel_dataexport1D_include_text',...
    'Style','text',...
    'Parent',handle_pp2_1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','left',...
    'Units','Pixels',...
    'Position',[10 93 60 20],...
    'String','Include'...
    );
uicontrol('Tag','datasets_panel_dataexport1D_includeaxis_checkbox',...
    'Style','checkbox',...
    'Parent',handle_pp2_1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[panel_size(3)-190 95 70 20],...
    'String',' Axis',...
    'TooltipString','Toggle between including or excluding axis values',...
    'Value',1 ...
    );
uicontrol('Tag','datasets_panel_dataexport1D_includestdev_checkbox',...
    'Style','checkbox',...
    'Parent',handle_pp2_1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[panel_size(3)-120 95 90 20],...
    'String',' Std. dev.',...
    'TooltipString','Toggle between including or excluding std. dev. values',...
    'Value',0 ...
    );
uicontrol('Tag','datasets_panel_dataexport1D_includeinfofile_checkbox',...
    'Style','checkbox',...
    'Parent',handle_pp2_1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[panel_size(3)-190 70 70 20],...
    'String',' Info file',...
    'TooltipString','Toggle between including info file in header',...
    'Enable','inactive',...
    'Value',0 ...
    );
uicontrol('Tag','datasets_panel_dataexport1D_includesimulation_checkbox',...
    'Style','checkbox',...
    'Parent',handle_pp2_1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[panel_size(3)-120 70 90 20],...
    'String',' Simulation',...
    'TooltipString','Toggle between including or excluding simulation (calculated values)',...
    'Value',0 ...
    );
uicontrol('Tag','datasets_panel_dataexport1D_multiplefiles_text',...
    'Style','text',...
    'Parent',handle_pp2_1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','left',...
    'Units','Pixels',...
    'Position',[10 42 60 20],...
    'String','Multiple'...
    );
uicontrol('Tag','datasets_panel_dataexport1D_multiple1file_checkbox',...
    'Style','checkbox',...
    'Parent',handle_pp2_1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[panel_size(3)-190 45 70 20],...
    'String',' 1 file',...
    'TooltipString','Export multiple datasets in one single file',...
    'Value',0,...
    'Callback',{@checkbox_Callback,'multiple1file'} ...
    );
uicontrol('Tag','datasets_panel_dataexport1D_multiplefiles_checkbox',...
    'Style','checkbox',...
    'Parent',handle_pp2_1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[panel_size(3)-120 45 90 20],...
    'String',' n files',...
    'TooltipString','Export multiple datasets in multiple files',...
    'Value',0,...
    'Callback',{@checkbox_Callback,'multiplefiles'} ...
    );
uicontrol('Tag','datasets_panel_dataexport1D_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_pp2_1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[panel_size(3)-90 10 60 30],...
    'String','Export',...
    'TooltipString',sprintf('%s\n%s',...
    'Export currently active dataset in current (x or y) display',...
    'to file with given type'),...
    'Callback',{@pushbutton_Callback,'export1d'}...
    );

handle_pp2_2 = uipanel('Tag','datasets_panel_dataexport2D_panel',...
    'Parent',handle_pp2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[5 panel_size(4)-480 panel_size(3)-20 185],...
    'Title','Export 2D data'...
    );
uicontrol('Tag','datasets_panel_dataexport2D_format_text',...
    'Style','text',...
    'Parent',handle_pp2_2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','left',...
    'Units','Pixels',...
    'Position',[10 135 60 20],...
    'String','Format'...
    );
uicontrol('Tag','datasets_panel_dataexport2D_format_popupmenu',...
    'Style','popupmenu',...
    'Parent',handle_pp2_2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[70 137 panel_size(3)-100 20],...
    'String','glotaran|ASCII',...
    'TooltipString','Select 2D export format'...
    );
uicontrol('Tag','datasets_panel_dataexport2D_header_text',...
    'Style','text',...
    'Parent',handle_pp2_2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','left',...
    'Units','Pixels',...
    'Position',[10 100 150 20],...
    'TooltipString','Character(s) the header starts with; default: "%" (Matlab)',...
    'String','Header starts with'...
    );
uicontrol('Tag','datasets_panel_dataexport2D_header_edit',...
    'Style','edit',...
    'Parent',handle_pp2_2,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[170 100 60 25],...
    'String','%',...
    'TooltipString','Character the header should start with'...
    );
uicontrol('Tag','datasets_panel_dataexport2D_include_text',...
    'Style','text',...
    'Parent',handle_pp2_2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','left',...
    'Units','Pixels',...
    'Position',[10 68 60 20],...
    'String','Include'...
    );
uicontrol('Tag','datasets_panel_dataexport2D_includeaxes_checkbox',...
    'Style','checkbox',...
    'Parent',handle_pp2_2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[panel_size(3)-190 70 70 20],...
    'String',' Axes',...
    'TooltipString','Toggle between including or excluding axis values',...
    'Value',1 ...
    );
uicontrol('Tag','datasets_panel_dataexport2D_includeinfofile_checkbox',...
    'Style','checkbox',...
    'Parent',handle_pp2_2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[panel_size(3)-190 45 160 20],...
    'String',' Info file (in header)',...
    'TooltipString','Toggle between including info file in header',...
    'Enable','inactive',...
    'Value',0 ...
    );
uicontrol('Tag','datasets_panel_dataexport2D_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_pp2_2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[panel_size(3)-90 10 60 30],...
    'String','Export',...
    'TooltipString','Export current dataset in a format understood by glotaran',...
    'Callback',{@pushbutton_Callback,'export2d'}...
    );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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
    
    switch lower(action)
        case 'show'
            cmdShow(mainWindow,{});
            return;
        case 'hide'
            cmdHide(mainWindow,{});
            return;
        case 'combine'
            % If no datasets are loaded, return
            if isempty(ad.data)
                return;
            end
            trEPRgui_combinewindow();
            return;
        case 'showall'
            cmdShow(mainWindow,{'all'});
            return;
        case'hideall'
            cmdHide(mainWindow,{'all'});
            return;
        case 'save'
            % Get selected item of listbox
            selected = get(gh.data_panel_visible_listbox,'Value');
            
            % Get id of selected spectrum
            selectedId = ad.control.data.visible(selected);
            
            trEPRsaveDatasetInMainGUI(selectedId);
        case 'saveas'
            % Get selected item of listbox
            selected = get(gh.data_panel_visible_listbox,'Value');
            
            % Get id of selected spectrum
            selectedId = ad.control.data.visible(selected);
            
            trEPRsaveAsDatasetInMainGUI(selectedId);
        case 'remove'
            % Get selected item of listbox
            selected = get(gh.data_panel_visible_listbox,'Value');
            
            % Get id of selected spectrum
            selectedId = ad.control.data.visible(selected);
            
            trEPRremoveDatasetFromMainGUI(selectedId);
        case 'duplicate'
            cmdDuplicate(mainWindow,{});
        case 'undo'
            cmdUndo(mainWindow,{});
        case 'export2d'
            [status,warnings] = cmdExport(mainWindow,{'2D'});
            if status
                TAmsg(warnings,'warning');
            end
        case 'export1d'
            [status,warnings] = cmdExport(mainWindow,{'1D'});
            if status
                TAmsg(warnings,'warning');
            end
        otherwise
            trEPRoptionUnknown(action);
            return;
    end
catch exception
    trEPRexceptionHandling(exception)
end

end

function visible_listbox_Callback(~,~)

try
    % Get appdata of main window
    mainWindow = trEPRguiGetWindowHandle;
    ad = getappdata(mainWindow);
    
    % Get handles of main window
    gh = guihandles(mainWindow);
    
    ad.control.data.active = ad.control.data.visible(...
        get(gh.data_panel_visible_listbox,'Value')...
        );
    
    % Update appdata of main window
    setappdata(mainWindow,'control',ad.control);
    
    % If user double clicked on list entry
    if strcmp(get(gcf,'SelectionType'),'open')
        cmdLabel(mainWindow,{});
    end
    
    % Update processing panel
    update_processingPanel();
    
    % Update slider panel
    update_sliderPanel();
    
    % Update visible spectra listboxes (in diverse panels!)
    update_visibleSpectra();
    
    %Update main axis
    update_mainAxis();
catch exception
    trEPRexceptionHandling(exception)
end

end

function invisible_listbox_Callback(source,~)
    try
        % Get appdata of main window
        mainWindow = trEPRguiGetWindowHandle;
        ad = getappdata(mainWindow);
        
        % If user double clicked on list entry
        if strcmp(get(gcf,'SelectionType'),'open')
            cmdLabel(mainWindow,{num2str(ad.control.data.invisible(...
                get(source,'Value')))});
        end
        update_invisibleSpectra();
    catch exception
        trEPRexceptionHandling(exception)
    end
end

function checkbox_Callback(source,~,action)

try
    if isempty(action)
        return;
    end
    
    % Get appdata of main window
    mainWindow = trEPRguiGetWindowHandle;
    ad = getappdata(mainWindow);
    gh = guihandles(mainWindow);
    
    switch lower(action)
        case 'showonlyactive'
            ad.control.axis.onlyActive = get(source,'Value');
        case 'multiple1file'
            % Turn off "multiplefiles" checkbox
            set(gh.datasets_panel_dataexport1D_multiplefiles_checkbox,...
                'Value',0);
        case 'multiplefiles'
            % Turn off "multiple1file" checkbox
            set(gh.datasets_panel_dataexport1D_multiple1file_checkbox,...
                'Value',0);
        otherwise
            trEPRoptionUnknown(action);
            return;
    end
    setappdata(mainWindow,'control',ad.control);
    update_mainAxis();
catch exception
    trEPRexceptionHandling(exception)
end

end
