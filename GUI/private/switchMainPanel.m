function status = switchMainPanel(panelName)

try
    % Get handles of main window
    mainWindow = findobj('Tag','trepr_gui_mainwindow');
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
        gh.reserve_panel ...
        gh.help_panel ...
        ];
    buttons = [...
        gh.tbLoad ...
        gh.tbDatasets ...
        gh.tbSlider ...
        gh.tbMeasure ...
        gh.tbDisplay ...
        gh.tbProcessing ...
        gh.tbAnalysis ...
        gh.tbReserve1 ...
        gh.tbHelp ...
        ];
    
    switch panelName
        case 'Load'
            set(panels,'Visible','off');
            set(buttons,'Value',0);
            set(gh.load_panel,'Visible','on');
            set(gh.tbLoad,'Value',1);
        case 'Datasets'
            set(panels,'Visible','off');
            set(buttons,'Value',0);
            set(gh.data_panel,'Visible','on');
            set(gh.tbDatasets,'Value',1);
            % Update both list boxes
            update_invisibleSpectra();
            update_visibleSpectra();
            update_datasetPanel();
        case 'Slider'
            set(panels,'Visible','off');
            set(buttons,'Value',0);
            set(gh.slider_panel,'Visible','on');
            set(gh.tbSlider,'Value',1);
            % Update slider panel
            update_sliderPanel();
        case 'Measure'
            set(panels,'Visible','off');
            set(buttons,'Value',0);
            set(gh.measure_panel,'Visible','on');
            set(gh.tbMeasure,'Value',1);
            % Update measure panel
            update_measurePanel();
        case 'Display'
            set(panels,'Visible','off');
            set(buttons,'Value',0);
            set(gh.display_panel,'Visible','on');
            set(gh.tbDisplay,'Value',1);
            % Update display panel
            update_displayPanel();
        case 'Processing'
            set(panels,'Visible','off');
            set(buttons,'Value',0);
            set(gh.processing_panel,'Visible','on');
            set(gh.tbProcessing,'Value',1);
            % Update processing panel
            update_processingPanel();
        case 'Analysis'
            set(panels,'Visible','off');
            set(buttons,'Value',0);
            set(gh.analysis_panel,'Visible','on');
            set(gh.tbAnalysis,'Value',1);
        case 'Help'
            set(panels,'Visible','off');
            set(buttons,'Value',0);
            set(gh.help_panel,'Visible','on');
            set(gh.tbHelp,'Value',1);
    end
    
    status = 0;
catch exception
    trEPRgui_bugreportwindow(exception);
    status = -1;
end

end