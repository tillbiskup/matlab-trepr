function handle = guiAnalysisPanel(parentHandle,position)
% GUIANALYSISPANEL Add a panel displaying some analysis controls to a gui
%       Should only be called from within a GUI defining function.
%
%       Arguments: parent Handle and position vector.
%
%       Returns the handle of the added panel.

% (c) 2011-12, Till Biskup
% 2012-05-31

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

% Create the "Help" panel
handle_size = get(handle,'Position');
uicontrol('Tag','analysis_panel_description',...
    'Style','text',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'FontAngle','oblique',...
    'Position',[10 handle_size(4)-60 handle_size(3)-20 30],...
    'String',{'Diverse analysis tools such as data fitting, simulations, deconvolution (SVD), ...'}...
    );

handle_p1 = uipanel('Tag','analysis_panel_dataexport_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-170 handle_size(3)-20 100],...
    'Title','Export data'...
    );
uicontrol('Tag','analysis_panel_dataexport_description',...
    'Style','text',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'FontAngle','oblique',...
    'Position',[10 35 handle_size(3)-40 40],...
    'String',{'Export currently active dataset for external analysis.'}...
    );
uicontrol('Tag','analysis_panel_dataexport_format_text',...
    'Style','text',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','left',...
    'Units','Pixels',...
    'Position',[10 10 60 20],...
    'String','Format'...
    );
uicontrol('Tag','analysis_panel_dataexport_format_popupmenu',...
    'Style','popupmenu',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[handle_size(3)-190 15 100 20],...
    'String','glotaran',...
    'TooltipString','Select type of graphics file'...
    );
uicontrol('Tag','analysis_panel_dataexport_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[handle_size(3)-90 10 60 30],...
    'String','Export',...
    'TooltipString','Export current axis to graphics file with given format',...
    'Callback',{@pushbutton_Callback,'Export'}...
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

        switch lower(action)
            case 'export'
                if ~ad.control.spectra.active
                    return;
                end

                % Get export format
                exportFormats = cellstr(...
                    get(gh.analysis_panel_dataexport_format_popupmenu,'String'));
                exportFormat = exportFormats{...
                    get(gh.analysis_panel_dataexport_format_popupmenu,'Value')};
                                
                switch exportFormat
                    case 'glotaran'
                        % Generate default file name if possible, be very defensive
                        if ad.control.spectra.active
                            [~,f,~] = ...
                                fileparts(ad.data{ad.control.spectra.active}.file.name);
                            fileNameSuggested = f;
                            clear p f e;
                        else
                            fileNameSuggested = '';
                        end
                        % Ask user for file name
                        [fileName,pathName] = uiputfile(...
                            sprintf('*.%s','ascii'),...
                            'Get filename to export figure to',...
                            fileNameSuggested);
                        % If user aborts process, return
                        if fileName == 0
                            return;
                        end
                        % Create filename with full path
                        fileName = fullfile(pathName,fileName);
                        
                        busyWindow('start',...
                            'Trying to export dataset...<br />please wait.');
                        
                        % Export using export4glotaran
                        status = trEPRexport4glotaran(...
                            ad.data{ad.control.spectra.active},fileName);
                        if status
                            add2status(status);
                            busyWindow('stop',...
                                'Trying to export dataset...<br /><b>failed</b>.');
                        else
                            busyWindow('stop',...
                                'Trying to export dataset...<br /><b>done</b>.');
                        end
                        
                    otherwise
                        fprintf('%s%s "%s"\n',...
                            'trEPRgui : guiAnalysisPanel() : ',...
                            'pushbutton_Callback(): Unknown export format',...
                            exportFormat);
                        return;
                end
                
                % Add status message (mainly for debug reasons)
                % IMPORtrEPRNT: Has to go AFTER setappdata
                msgStr = sprintf('Exported dataset %i to format %s',...
                    ad.control.spectra.active,exportFormat);
                add2status(msgStr);
            otherwise
                fprintf('%s%s "%s"\n',...
                    'trEPRgui : guiAnalysisPanel() : ',...
                    'pushbutton_Callback(): Unknown action',...
                    action);
                return;
        end
    catch exception
        try
            msgStr = ['An exception occurred. '...
                'The bug reporter should have been opened'];
            add2status(msgStr);
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

end