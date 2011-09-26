function guiClose()

try
    % Get appdata of main window
    mainWindow = guiGetWindowHandle;
    ad = getappdata(mainWindow);

    % TODO: Check whether there is anything that is not saved...
    if ~isempty(ad.control.spectra.modified)
        answer = questdlg(...
            {'There are modified and still unsaved datasets. Close anyway?'...
            ' '...
            'Note that "Close" means that you loose the changes you made.'...
            ' '...
            'Other options: "Cancel".'},...
            'Warning: Modified Datasets...',...
            'Close','Cancel',...
            'Cancel');
        switch answer
            case 'Close'
            case 'Cancel'
                msgStr = {'Closing GUI aborted by user. ' ...
                    'Reason: Modified and unsaved datasets'};
                add2status(msgStr);
                return;
            otherwise
                return;
        end
    end
    
    % Close all GUI windows currently open
    delete(findobj('-regexp','Tag','trepr_gui_*'));
    
catch exception
    % Hm... that should really not happen.
    disp('Sorry, but there were some problems closing the GUI.');
    disp('Try "delete(handle)" with "handle" corresponding to GUI');
    throw(exception);
end

end