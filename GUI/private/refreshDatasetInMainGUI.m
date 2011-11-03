function status = refreshDatasetInMainGUI(dataset,id,varargin)
% REFRESHDATASETINMAINGUI Append dataset to main GUI.
%
% Usage:
%   status = refreshDatasetInMainGUI(dataset,id);
%
% Status:  0 - everything fine
%         -1 - no main GUI window found

% (c) 2011, Till Biskup
% 2011-11-03

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('dataset', @(x)isstruct(x) || iscell(x));
p.addParamValue('modified',false,@islogical);
p.parse(dataset,varargin{:});

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
    
    % Refresh dataset in main GUI
    ad.data{id} = dataset;
    ad.origdata{id} = dataset;
    
    % Handle whether it should go to modified as well
    if (p.Results.modified) && ~find(ad.control.spectra.modified==id)
        ad.control.spectra.modified(end+1) = id;
    end
    
    % Write appdata
    setappdata(mainWindow,'data',ad.data);
    setappdata(mainWindow,'origdata',ad.data);
    setappdata(mainWindow,'control',ad.control);
    
    % Adding status line
    msg = {...
        sprintf('Dataset %i successfully refreshed in main GUI',id)...
        sprintf('Label: %s',dataset.label)...
        };
    status = add2status(msg);
    
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