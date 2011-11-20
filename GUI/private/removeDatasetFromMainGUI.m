function status = removeDatasetFromMainGUI(dataset,varargin)
% REMOVEDATASETFROMMAINGUI Remove dataset(s) from main GUI.
%
% Usage:
%   status = appendDatasetToMainGUI(datasets);
%
% Status:  0 - everything fine
%         -1 - no main GUI window found

% (c) 2011, Till Biskup
% 2011-11-20

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('dataset', @(x)isnumeric(x));
p.addParamValue('force',false,@islogical);
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

    % Remove dataset(s) from main GUI
    for k=length(dataset):-1:1
        if ~p.Results.force
            if ~any(ad.control.spectra.modified==dataset)
                ad.data(dataset(k)) = [];
                ad.origdata(dataset(k)) = [];
                ad.control.spectra.visible(...
                    ad.control.spectra.visible==dataset(k)) = [];
                ad.control.spectra.invisible(...
                    ad.control.spectra.invisible==dataset(k)) = [];
                ad.control.spectra.modified(...
                    ad.control.spectra.modified==dataset(k)) = [];
                ad.control.spectra.visible(...
                    ad.control.spectra.visible>dataset(k)) = ...
                    ad.control.spectra.visible(...
                    ad.control.spectra.visible>dataset(k)) -1;
                ad.control.spectra.invisible(...
                    ad.control.spectra.invisible>dataset(k)) = ...
                    ad.control.spectra.invisible(...
                    ad.control.spectra.invisible>dataset(k)) -1;
                ad.control.spectra.modified(...
                    ad.control.spectra.modified>dataset(k)) = ...
                    ad.control.spectra.modified(...
                    ad.control.spectra.modified>dataset(k)) -1;
                if ad.control.spectra.active >= dataset(k)
                    ad.control.spectra.active = ad.control.spectra.active-1;
                end
            end
        else
            ad.data(dataset(k)) = [];
            ad.origdata(dataset(k)) = [];
            ad.control.spectra.visible(...
                ad.control.spectra.visible==dataset(k)) = [];
            ad.control.spectra.invisible(...
                ad.control.spectra.invisible==dataset(k)) = [];
            ad.control.spectra.modified(...
                ad.control.spectra.modified==dataset(k)) = [];
            ad.control.spectra.visible(...
                ad.control.spectra.visible>dataset(k)) = ...
                ad.control.spectra.visible(...
                ad.control.spectra.visible>dataset(k)) -1;
            ad.control.spectra.invisible(...
                ad.control.spectra.invisible>dataset(k)) = ...
                ad.control.spectra.invisible(...
                ad.control.spectra.invisible>dataset(k)) -1;
            ad.control.spectra.modified(...
                ad.control.spectra.modified>dataset(k)) = ...
                ad.control.spectra.modified(...
                ad.control.spectra.modified>dataset(k)) -1;
            if ad.control.spectra.active >= dataset(k)
                ad.control.spectra.active = ad.control.spectra.active-1;
            end
        end
    end
    
    % Write appdata
    setappdata(mainWindow,'data',ad.data);
    setappdata(mainWindow,'origdata',ad.data);
    setappdata(mainWindow,'control',ad.control);
    
    % Adding status line
    msg = {...
        sprintf('Datasets successfully removed from main GUI')...
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