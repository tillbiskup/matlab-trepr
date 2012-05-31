function guiClose()
% GUICLOSE Private function to close GUI and at the same time close all
% subwindows that might still be open.

% (c) 11, Till Biskup
% 2012-05-31

try
    % Get appdata of main window
    mainWindow = trEPRguiGetWindowHandle;
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
                trEPRadd2status(msgStr);
                return;
            otherwise
                return;
        end
    end
    
    % Close all GUI windows currently open
    delete(findobj('-regexp','Tag','trEPRgui_*'));
    
catch exception
    % Hm... that should really not happen.
    disp('Sorry, but there were some problems closing the GUI.');
    disp('Try "delete(handle)" with "handle" corresponding to GUI');
    throw(exception);
end

end