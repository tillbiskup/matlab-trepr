function guiClose()
% GUICLOSE Private function to close GUI and at the same time close all
% subwindows that might still be open.

% Copyright (c) 2011-14, Till Biskup
% 2014-07-27

try
    % Get appdata of main window
    mainWindow = trEPRguiGetWindowHandle;
    ad = getappdata(mainWindow);

    % TODO: Check whether there is anything that is not saved...
    if ~isempty(ad.control.data.modified)
        answer = questionDialogue(...
            ['There are modified and still unsaved datasets. '...
            'Close anyway?<br>Note that &quot;close&quot; means that '...
            'you <em>loose all your unsaved changes</em>.'...
            '<br>Alternative option: Cancel and return to GUI.'],...
            'title','Warning: Modified datasets...',...
            'icon','warning',...
            'WindowStyle','modal',...
            'Buttons',{'Close','Cancel'},...
            'defaultButton','Cancel'...
            );
        switch answer
            case 'Close'
            case 'Cancel'
                msgStr = {'Closing GUI aborted by user. ' ...
                    'Reason: Modified and unsaved datasets'};
                trEPRmsg(msgStr,'info');
                return;
            otherwise
                return;
        end
    end
    
    % Check whether to save history
    if ad.control.cmd.historysave
        [histsavestat,histsavewarn] = trEPRgui_cmd_saveHistory2File();
        if histsavestat
            trEPRmsg(histsavewarn,'warn');
        end
    end
    
    % Close all GUI windows currently open
    delete(findobj('-regexp','Tag','trEPRgui_*'));
    
    % Stop garbage collector
    guiGarbageCollector('stop');

catch exception
    % Hm... that should really not happen.
    disp('Sorry, but there were some problems closing the GUI.');
    disp('Try "delete(handle)" with "handle" corresponding to GUI');
    throw(exception);
end

end
