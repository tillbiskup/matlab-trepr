function status = switchMainPanel(panelName)
% SWITCHMAINPANEL Private function to switch between panels of the main GUI
%
% panelName - string with the name of the panel, i.e. the value of the
%             return value of the buttongroup keypress event (aka the
%             'String' value of the respective button pressed)
%
% status    - return value of the function. Either 0 (OK) or -1 (failed)

% Copyright (c) 2011-14, Till Biskup
% 2014-08-14

try
    % Get handles of main window
    mainWindow = trEPRguiGetWindowHandle;
    ad = getappdata(mainWindow);
    gh = guihandles(mainWindow);
    
    panels = [...
        gh.welcome_panel ...
        gh.load_panel ...
        gh.data_panel ...
        gh.slider_panel ...
        gh.measure_panel ...
        gh.display_panel ...
        gh.processing_panel ...
        gh.analysis_panel ...
        gh.internal_panel ...
        gh.configure_panel ...
        ];
    buttons = [...
        gh.tbLoad ...
        gh.tbDatasets ...
        gh.tbSlider ...
        gh.tbMeasure ...
        gh.tbDisplay ...
        gh.tbProcessing ...
        gh.tbAnalysis ...
        gh.tbInternal ...
        gh.tbConfigure ...
        ];
    
    switch lower(panelName)
        case 'load'
            set(panels,'Visible','off');
            set(buttons,'Value',0);
            set(gh.load_panel,'Visible','on');
            set(gh.tbLoad,'Value',1);
        case 'datasets'
            set(panels,'Visible','off');
            set(buttons,'Value',0);
            set(gh.data_panel,'Visible','on');
            set(gh.tbDatasets,'Value',1);
            % Update both list boxes
            update_invisibleSpectra();
            update_visibleSpectra();
            update_datasetPanel();
        case 'slider'
            set(panels,'Visible','off');
            set(buttons,'Value',0);
            set(gh.slider_panel,'Visible','on');
            set(gh.tbSlider,'Value',1);
            % Update slider panel
            update_sliderPanel();
        case 'measure'
            set(panels,'Visible','off');
            set(buttons,'Value',0);
            set(gh.measure_panel,'Visible','on');
            set(gh.tbMeasure,'Value',1);
            % Update measure panel
            update_measurePanel();
        case 'display'
            set(panels,'Visible','off');
            set(buttons,'Value',0);
            set(gh.display_panel,'Visible','on');
            set(gh.tbDisplay,'Value',1);
            % Update display panel
            update_displayPanel();
        case 'processing'
            set(panels,'Visible','off');
            set(buttons,'Value',0);
            set(gh.processing_panel,'Visible','on');
            set(gh.tbProcessing,'Value',1);
            % Update processing panel
            update_processingPanel();
        case 'analysis'
            set(panels,'Visible','off');
            set(buttons,'Value',0);
            set(gh.analysis_panel,'Visible','on');
            set(gh.tbAnalysis,'Value',1);
        case 'internal'
            set(panels,'Visible','off');
            set(buttons,'Value',0);
            set(gh.internal_panel,'Visible','on');
            set(gh.tbInternal,'Value',1);
            update_internalPanel();
        case 'configure'
            set(panels,'Visible','off');
            set(buttons,'Value',0);
            set(gh.configure_panel,'Visible','on');
            set(gh.tbConfigure,'Value',1);
        otherwise
            trEPRoptionUnknown(panelName,'panel');
            return;
    end
    
    ad = getappdata(mainWindow);
    ad.control.panels.active = lower(panelName);
    setappdata(mainWindow,'control',ad.control);
    
    status = 0;
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
    status = -1;
end

end
