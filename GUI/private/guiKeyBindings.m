function guiKeyBindings(src,evt)
% GUIKEYBINDINGS Private function to handle keypress events in the GUI and
% its windows/elements
%
% Arguments:
%     src - handle of calling source
%     evt - actual event, struct with fields "Character", "Modifier", "Key"

% (c) 2011-12, Till Biskup
% 2012-06-26

try
    if isempty(evt.Character) && isempty(evt.Key)
        % In case "Character" is the empty string, i.e. only modifier key
        % was pressed...
        return;
    end
    
    % Get appdata and handles of main window
    mainWindow = trEPRguiGetWindowHandle;
    ad = getappdata(mainWindow);
    gh = guihandles(mainWindow);
    
    % Use "src" to distinguish between callers - may be helpful later on
    
    if ~isempty(evt.Modifier)
        if (strcmpi(evt.Modifier{1},'command')) || ...
                (strcmpi(evt.Modifier{1},'control'))
            switch evt.Key
                % CLOSE GUI: Ctrl+w || Cmd+w
                case 'w'
                    guiClose();
                    return;
                % SWITCH PANEL: Ctrl/Cmd+1..9
                case '1'
                    status = switchMainPanel('Load');
                    if status
                        % Something went wrong...
                        trEPRmsg('Problems with switching panels.',...
                            'error');
                    end
                    return;
                case '2'
                    status = switchMainPanel('Datasets');
                    if status
                        % Something went wrong...
                        trEPRmsg('Problems with switching panels.',...
                            'error');
                    end
                    return;
                case '3'
                    status = switchMainPanel('Slider');
                    if status
                        % Something went wrong...
                        trEPRmsg('Problems with switching panels.',...
                            'error');
                    end
                    return;
                case '4'
                    status = switchMainPanel('Measure');
                    if status
                        % Something went wrong...
                        trEPRmsg('Problems with switching panels.',...
                            'error');
                    end
                    return;
                case '5'
                    status = switchMainPanel('Display');
                    if status
                        % Something went wrong...
                        trEPRmsg('Problems with switching panels.',...
                            'error');
                    end
                    return;
                case '6'
                    status = switchMainPanel('Processing');
                    if status
                        % Something went wrong...
                        trEPRmsg('Problems with switching panels.',...
                            'error');
                    end
                    return;
                case '7'
                    status = switchMainPanel('Analysis');
                    if status
                        % Something went wrong...
                        trEPRmsg('Problems with switching panels.',...
                            'error');
                    end
                    return;
                case '8'
                    return;
                case '9'
                    status = switchMainPanel('Configure');
                    if status
                        % Something went wrong...
                        trEPRmsg('Problems with switching panels.',...
                            'error');
                    end
                    return;
                % SWITCH DISPLAY MODE: Ctrl/Cmd+x/y/z
                case 'x'
                    switchDisplayType('1D along x');
                    return;
                case 'y'
                    switchDisplayType('1D along y');
                    return;
                case 'z'
                    switchDisplayType('2D plot');
                    return;
                % Other commands
                case 'i'
                    trEPRgui_infowindow();
                    return;
            end
        end
    end
    switch evt.Key
        case 'f1'
            trEPRgui_helpwindow();
            return;
        case 'f2'
            trEPRgui_aboutwindow();
            return;
        case 'f3'
            trEPRgui_infowindow();
            return;
        case 'f4'
            trEPRgui_ACCwindow();
            return;
        case 'f5'
            trEPRgui_AVGwindow();
            return;
        case 'f6'
            trEPRgui_BLCwindow();
            return;
        case 'f8'
            if exist('trEPRgui_SIMwindow','file')
                trEPRgui_SIMwindow();
            end
            return;
        case 'f10'
            trEPRgui_statuswindow();
            return;
        case 'delete'
            if ~ad.control.spectra.active
                return;
            end
            if src == gh.data_panel_visible_listbox
                if ~isempty(evt.Modifier) && (strcmpi(evt.Modifier{1},'shift'))
                    [status,message] = trEPRremoveDatasetFromMainGUI(...
                        ad.control.spectra.active,'force',true);
                    if status
                        trEPRmsg(message,'warning');
                    end
                else
                    [status,message] = trEPRremoveDatasetFromMainGUI(...
                        ad.control.spectra.active);
                    if status
                        trEPRmsg(message,'warning');
                    end
                end
            end
        case 'backspace'
            if ~ad.control.spectra.active
                return;
            end
            if src == gh.data_panel_visible_listbox
                if ~isempty(evt.Modifier) && (strcmpi(evt.Modifier{1},'shift'))
                    [status,message] = trEPRremoveDatasetFromMainGUI(...
                        ad.control.spectra.active,'force',true);
                    if status
                        trEPRmsg(message,'warning');
                    end
                else
                    [status,message] = trEPRremoveDatasetFromMainGUI(...
                        ad.control.spectra.active);
                    if status
                        trEPRmsg(message,'warning');
                    end
                end
            end
        case 'pageup'
            if ~ad.control.spectra.active || ...
                    length(ad.control.spectra.visible) == 1
                return;
            end
            idx = find(ad.control.spectra.visible==ad.control.spectra.active);
            if idx < length(ad.control.spectra.visible)
                ad.control.spectra.active = ad.control.spectra.visible(idx+1);
            else
                ad.control.spectra.active = ad.control.spectra.visible(1);
            end
            setappdata(mainWindow,'control',ad.control);
            update_mainAxis();
            update_visibleSpectra();
        case 'pagedown'
            if ~ad.control.spectra.active || ...
                    length(ad.control.spectra.visible) == 1
                return;
            end
            idx = find(ad.control.spectra.visible==ad.control.spectra.active);
            if idx == 1
                ad.control.spectra.active = ad.control.spectra.visible(end);
            else
                ad.control.spectra.active = ad.control.spectra.visible(idx-1);
            end
            setappdata(mainWindow,'control',ad.control);
            update_mainAxis();
            update_visibleSpectra();
        otherwise
%             disp(evt);
%             fprintf('       Caller: %i\n\n',src);
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