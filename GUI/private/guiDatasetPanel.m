function handle = guiDatasetPanel(parentHandle,position)
% GUIDATASETPANEL Add a panel for dataset control to a gui
%       Should only be called from within a GUI defining function.
%
%       Arguments: parent Handle and position vector.
%
%       Returns the handle of the added panel.

% Copyright (c) 2011-13, Till Biskup
% 2013-02-06

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

defaultBackground = get(parentHandle,'Color');

handle = uipanel('Tag','data_panel',...
    'parent',parentHandle,...
    'Title','Dataset display',...
    'FontUnit','Pixel','Fontsize',12,...
    'FontWeight','bold',...
    'BackgroundColor',defaultBackground,...
    'Visible','off',...
    'Units','pixels','Position',position);

% Create the "Dataset display" panel
panel_size = get(handle,'Position');
uicontrol('Tag','data_panel_description',...
    'Style','text',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Left',...
    'FontAngle','oblique',...
    'Position',[10 panel_size(4)-60 panel_size(3)-20 30],...
    'String',{'Choose the datasets to be displayed in the main axes (on the left)'}...
    );

handle_p1 = uipanel('Tag','data_panel_invisible_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 panel_size(4)-165 panel_size(3)-20 95],...
    'Title','Invisible datasets'...
    );
uicontrol('Tag','data_panel_invisible_listbox',...
    'Style','listbox',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 panel_size(3)-40 65],...
    'String','',...
    'Callback',{@invisible_listbox_Callback}...
    );

handle_p2 = uipanel('Tag','data_panel_visible_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 panel_size(4)-315 panel_size(3)-20 100],...
    'Title','Visible datasets'...
    );
uicontrol('Tag','data_panel_visible_listbox',...
    'Style','listbox',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 panel_size(3)-40 70],...
    'String','',...
    'Callback',{@visible_listbox_Callback}...
    );

uicontrol('Tag','data_panel_showall_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 panel_size(4)-205 (panel_size(3)-20)/4 30],...
    'String','<html>&dArr;</html>',...
    'TooltipString','Show all spectra',...
    'Callback', {@pushbutton_Callback,'ShowAll'}...
    );
uicontrol('Tag','data_panel_show_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10+(panel_size(3)-20)/4 panel_size(4)-205 (panel_size(3)-20)/4 30],...
    'String','<html>&darr;</html>',...
    'TooltipString','Show currently highlighted spectrum',...
    'Callback', {@pushbutton_Callback,'Show'}...
    );
uicontrol('Tag','data_panel_hide_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10+(panel_size(3)-20)/4*2 panel_size(4)-205 (panel_size(3)-20)/4 30],...
    'String','<html>&uarr;</html>',...
    'TooltipString','Hide currently highlighted spectrum',...
    'Callback', {@pushbutton_Callback,'Hide'}...
    );
uicontrol('Tag','data_panel_hideall_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10+(panel_size(3)-20)/4*3 panel_size(4)-205 (panel_size(3)-20)/4 30],...
    'String','<html>&uArr;</html>',...
    'TooltipString','Hide all spectra',...
    'Callback', {@pushbutton_Callback,'HideAll'}...
    );

handle_p3 = uipanel('Tag','data_panel_multiple_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'FontUnit','Pixel','Fontsize',12,...
    'Position',[10 panel_size(4)-380 panel_size(3)-20 55],...
    'Title','Multiple datasets'...
    );
uicontrol('Tag','data_panel_combine_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p3,...
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
    'Parent',handle_p3,...
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

handle_p4 = uipanel('Tag','data_panel_currentlyactive_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'FontUnit','Pixel','Fontsize',12,...
    'Position',[10 panel_size(4)-470 panel_size(3)-20 80],...
    'Title','Currently active dataset'...
    );
uicontrol('Tag','data_panel_save_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p4,...
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
    'Parent',handle_p4,...
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
    'Parent',handle_p4,...
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
    'Parent',handle_p4,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 floor((panel_size(3)-40)/3) 25],...
    'String','Undo',...
    'TooltipString','Undo last operation on currently active dataset'...
    );
uicontrol('Tag','data_panel_getinfo_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p4,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[floor((panel_size(3)-40)/3)+10 10 floor((panel_size(3)-40)/3) 25],...
    'String','Get info',...
    'Callback', {@trEPRgui_infowindow}...
    );
uicontrol('Tag','data_panel_duplicate_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p4,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[(floor((panel_size(3)-40)/3)*2)+10 10 floor((panel_size(3)-40)/3) 25],...
    'TooltipString','Duplicate currently active dataset',...
    'String','Duplicate',...
    'Callback', {@pushbutton_Callback,'Duplicate'}...
    );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
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

        switch action
            case 'Show'
                cmdShow(mainWindow,{});
                return;
            case 'Hide'                
                cmdHide(mainWindow,{});
                return;
            case 'Combine'
                % If no datasets are loaded, return
                if isempty(ad.data)
                    return;
                end
                trEPRgui_combinewindow();
                return;
            case 'ShowAll'
                cmdShow(mainWindow,{'all'});
                return;
            case'HideAll'
                cmdHide(mainWindow,{'all'});
                return;
            case 'Save'
                % Get selected item of listbox
                selected = get(gh.data_panel_visible_listbox,'Value');
                
                % Get id of selected spectrum
                selectedId = ad.control.spectra.visible(selected);
                
                trEPRsaveDatasetInMainGUI(selectedId);
            case 'SaveAs'
                % Get selected item of listbox
                selected = get(gh.data_panel_visible_listbox,'Value');
                
                % Get id of selected spectrum
                selectedId = ad.control.spectra.visible(selected);
                
                trEPRsaveAsDatasetInMainGUI(selectedId);
            case 'Remove'
                % Get selected item of listbox
                selected = get(gh.data_panel_visible_listbox,'Value');
                
                % Get id of selected spectrum
                selectedId = ad.control.spectra.visible(selected);
                
                trEPRremoveDatasetFromMainGUI(selectedId);
            case 'Duplicate'
                cmdDuplicate(mainWindow,{});
            otherwise
                st = dbstack;
                trEPRmsg(...
                    [st.name ' : unknown action "' action '"'],...
                    'warning');
                return;
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

function visible_listbox_Callback(~,~)
    try
        % Get appdata of main window
        mainWindow = trEPRguiGetWindowHandle;
        ad = getappdata(mainWindow);
        
        % Get handles of main window
        gh = guihandles(mainWindow);
        
        ad.control.spectra.active = ad.control.spectra.visible(...
            get(gh.data_panel_visible_listbox,'Value')...
            );
        
        % Update appdata of main window
        setappdata(mainWindow,'control',ad.control);
        
        % If user double clicked on list entry
        if strcmp(get(gcf,'SelectionType'),'open')
            datasetChangeLabel(ad.control.spectra.active);
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

function invisible_listbox_Callback(source,~)
    try
        % Get appdata of main window
        mainWindow = trEPRguiGetWindowHandle;
        ad = getappdata(mainWindow);
        
        % If user double clicked on list entry
        if strcmp(get(gcf,'SelectionType'),'open')
            datasetChangeLabel(...
                ad.control.spectra.invisible(...
                get(source,'Value')...
                ));
        end
        update_invisibleSpectra();
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

function checkbox_Callback(source,~,action)
    try
        if isempty(action)
            return;
        end
        
        % Get appdata of main window
        mainWindow = trEPRguiGetWindowHandle;
        ad = getappdata(mainWindow);
        
        switch action
            case 'showonlyactive'
                ad.control.axis.onlyActive = get(source,'Value');
            otherwise
                st = dbstack;
                trEPRmsg(...
                    [st.name ' : unknown action "' action '"'],...
                    'warning');
                return;
        end
        setappdata(mainWindow,'control',ad.control);
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Utility functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function datasetChangeLabel(index)
    try
        % Get appdata of main window
        mainWindow = trEPRguiGetWindowHandle;
        ad = getappdata(mainWindow);
        
        ad.data{index}.label = trEPRgui_setLabelWindow(ad.data{index}.label);
        % Update appdata of main window
        setappdata(mainWindow,'data',ad.data);
        
        % Add status message (mainly for debug reasons)
        % IMPORtrEPRNT: Has to go AFTER setappdata
        msgStr = cell(0,1);
        msgStr{end+1} = sprintf(...
            'Changed label of dataset %i to "%s"',...
            ad.control.spectra.active,...
            ad.data{index}.label);
        invStr = sprintf('%i ',ad.control.spectra.invisible);
        visStr = sprintf('%i ',ad.control.spectra.visible);
        msgStr{end+1} = sprintf(...
            'Currently invisible: [ %s]; currently visible: [ %s]; total: %i',...
            invStr,visStr,length(ad.data));
        trEPRmsg(msgStr,'info');
        clear msgStr;
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
