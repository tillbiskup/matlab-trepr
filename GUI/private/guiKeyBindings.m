function guiKeyBindings(src,evt)
% GUIKEYBINDINGS Private function to handle keypress events in the GUI and
% its windows/elements
%
% Arguments:
%     src - handle of calling source
%     evt - actual event, struct with fields "Character", "Modifier", "Key"

% Copyright (c) 2011-15, Till Biskup
% 2015-10-18

try
    if isempty(evt.Character) && isempty(evt.Key)
        % In case "Character" is the empty string, i.e. only modifier key
        % was pressed...
        return;
    end
    
    % Get appdata and handles of main window
    mainWindow = trEPRguiGetWindowHandle;
    ad = getappdata(mainWindow);
    gh = ad.guiHandles;
    
    % Use "src" to distinguish between callers - may be helpful later on
    
    panels = {...
        'Load' ...
        'Datasets' ...
        'Slider' ...
        'Measure' ...
        'Display' ...
        'Processing' ...
        'Analysis' ...
        'Internal' ...
        'Configure' ...
        };
    
    if ~isempty(evt.Modifier)
        if (strcmpi(evt.Modifier{1},'command')) || ...
                (strcmpi(evt.Modifier{1},'control'))
            switch evt.Key
                % CLOSE GUI: Ctrl+w || Cmd+w
                case 'w'
                    guiClose();
                    return;
                % SWITCH PANEL: Ctrl/Cmd+1..9
                case {'1','2','3','4','5','6','7','8','9'}
                    status = switchMainPanel(panels{str2double(evt.Key)});
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
                case 'l'
                    trEPRguiSetMode('command');
                    return;
                case 'o'
                    cmdLoad(mainWindow);
                    return;
                case 's'
                    cmdSave(mainWindow,cell(0));
                    return;
            end
        end
    end
    switch evt.Key
        case 'f1'
            trEPRgui_helpwindow('page',['panels/' ad.control.panels.active]);
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
        case 'f12'
            fn = fullfile(trEPRinfo('dir'),'GUI','private','helptexts',...
                'main','internal','ee');
            textWindow(fn);
            return;
        case 'delete'
            if ~ad.control.data.active
                return;
            end
            if src == gh.data_panel_visible_listbox
                if ~isempty(evt.Modifier) && (strcmpi(evt.Modifier{1},'shift'))
                    [status,message] = trEPRremoveDatasetFromMainGUI(...
                        ad.control.data.active,'force',true);
                    if status
                        trEPRmsg(message,'warning');
                    end
                else
                    [status,message] = trEPRremoveDatasetFromMainGUI(...
                        ad.control.data.active);
                    if status
                        trEPRmsg(message,'warning');
                    end
                end
            end
        case 'backspace'
            if ~ad.control.data.active
                return;
            end
            if src == gh.data_panel_visible_listbox
                if ~isempty(evt.Modifier) && (strcmpi(evt.Modifier{1},'shift'))
                    [status,message] = trEPRremoveDatasetFromMainGUI(...
                        ad.control.data.active,'force',true);
                    if status
                        trEPRmsg(message,'warning');
                    end
                else
                    [status,message] = trEPRremoveDatasetFromMainGUI(...
                        ad.control.data.active);
                    if status
                        trEPRmsg(message,'warning');
                    end
                end
            end
        case 'pagedown'
            cmdShow(mainWindow,{'next'});
        case 'pageup'
            cmdShow(mainWindow,{'prev'});
        % Keys for mode switching
        case {'c','d'}
            if ad.control.data.active && ...
                    ~strcmpi(ad.control.mode,'command') && ...
                    ~strcmpi(ad.control.axis.displayType,'2D plot')
                trEPRguiSetMode(evt.Key);
            end
        case {'s','z','m','p'}
            if ad.control.data.active && ...
                    ~strcmpi(ad.control.mode,'command')
                trEPRguiSetMode(evt.Key);
            end
        case 'escape'
            trEPRguiSetMode('none');
        case {'uparrow','downarrow','leftarrow','rightarrow'}
            if any(strcmpi(ad.control.mode,{'scroll','scale','displace'}))
                funHandle = str2func(['gui' ad.control.mode]);
                % TODO: Handle arrow keys
                if ~isempty(evt.Modifier) && ...
                        ((strcmpi(evt.Modifier{1},'command')) || ...
                        (strcmpi(evt.Modifier{1},'control')))
                    switch evt.Key
                        case 'uparrow'
                            funHandle('y',+10);
                        case 'downarrow'
                            funHandle('y',-10);
                        case 'leftarrow'
                            funHandle('x',-10);
                        case 'rightarrow'
                            funHandle('x',+10);
                    end
                elseif ~isempty(evt.Modifier) && ...
                        (strcmpi(evt.Modifier{1},'alt'))
                    switch evt.Key
                        case 'uparrow'
                            funHandle('y','last');
                        case 'downarrow'
                            funHandle('y','first');
                        case 'leftarrow'
                            funHandle('x','first');
                        case 'rightarrow'
                            funHandle('x','last');
                    end
                elseif ~isempty(evt.Modifier) && ...
                        (strcmpi(evt.Modifier{1},'shift'))
                else
                    switch evt.Key
                        case 'uparrow'
                            funHandle('y',+1);
                        case 'downarrow'
                            funHandle('y',-1);
                        case 'leftarrow'
                            funHandle('x',-1);
                        case 'rightarrow'
                            funHandle('x',+1);
                    end
                end
            end
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
