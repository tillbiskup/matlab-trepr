function status = trEPRappendDatasetToMainGUI(dataset,varargin)
% APPENDDATASETTOMAINGUI Append dataset to main GUI.
%
% Usage:
%   status = trEPRappendDatasetToMainGUI(dataset);
%   status = trEPRappendDatasetToMainGUI(dataset,<parameter>,<value>);
%
%   dataset - struct | cell
%             structure conforming to trEPR dataset structure
%             alternatively: cell array of dataset structures
%
%   status  - scalar
%             status of the operation
%              0 - everything fine
%             -1 - no main GUI window found
%
% Optional parameters that can be set:
%
%   modified - boolean
%              whether to add the appended dataset to list of modified
%              datasets
%
% See also: trEPRrefreshDatasetInMainGUI, trEPRremoveDatasetFromMainGUI,
% trEPRsaveAsDatasetInMainGUI, trEPRsaveDatasetInMainGUI 

% Copyright (c) 2011-14, Till Biskup
% 2014-07-30

% Parse input arguments using the inputParser functionality
try
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('dataset', @(x)isstruct(x) || iscell(x));
    p.addParameter('modified',false,@islogical);
    p.parse(dataset,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

try
    % First, find main GUI window
    mainWindow = trEPRguiGetWindowHandle('trEPRgui');
    
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
    ad.control.data.visible(end+1) = newId;
    
    % Handle whether it should go to modified as well
    if (p.Results.modified)
        ad.control.data.modified(end+1) = newId;
    end
    
    % In case there is currently no active spectrum, make the newly
    % appended one the active one
    if ~(ad.control.data.active)
        ad.control.data.active = newId;
    end
    
    % Write appdata
    setappdata(mainWindow,'data',ad.data);
    setappdata(mainWindow,'origdata',ad.data);
    setappdata(mainWindow,'control',ad.control);
    
    % Adding status line
    msg = {...
        sprintf('Dataset %i successfully appended to main GUI',newId)...
        sprintf('Label: %s',dataset.label)...
        };
    status = trEPRmsg(msg,'info');
    
    % Update main GUI's axes and panels
    update_visibleSpectra();
    update_datasetPanel();
    update_processingPanel();
    update_mainAxis();
    
    status = 0;
    
catch exception
    trEPRexceptionHandling(exception);
end

end
