function status = appendDatasetToMainGUI(dataset)
% APPENDDATASETTOMAINGUI Append dataset to main GUI.
%
% Usage:
%   status = appendDatasetToMainGUI(dataset);
%
% Status:  0 - everything fine
%         -1 - no main GUI window found

try
    % First, find main GUI window
    mainWindow = guiGetWindowHandle('trEPRgui');
    
    % If there is no main GUI window, silently return
    if isempty(mainWindow)
        status = -1;
        return;
    end
    
    % Get appdata of main window
    ad = getappdata(mainWindow);
    
    % Append dataset to data cell array of main GUI
    ad.data{end+1} = dataset;
    ad.origdata{end+1} = dataset;
    
    % Get ID of newly appended dataset
    newId = length(ad.data);
    
    % Make new dataset immediately visible
    ad.control.spectra.visible(end+1) = newId;
    
    % TODO: Handle whether it should go to modified as well
    
    % Write appdata
    setappdata(mainWindow,'data',ad.data);
    setappdata(mainWindow,'origdata',ad.data);
    setappdata(mainWindow,'control',ad.control);
    
    % Adding status line
    msgStr = cell(0);
    msgStr{length(msgStr)+1} = ...
        sprintf('Dataset successfully appended to main GUI');
    status = add2status(msgStr);
    clear msgStr msg;
    
    % Update main GUI's axes and panels
    update_visibleSpectra();
    update_datasetPanel();
    update_processingPanel();
    update_mainAxis();
    
    status = 0;
    
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