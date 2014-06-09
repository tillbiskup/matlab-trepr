function [status,message] = trEPRremoveDatasetFromMainGUI(dataset,varargin)
% REMOVEDATASETFROMMAINGUI Remove dataset(s) from main GUI.
%
% Usage:
%   status = trEPRremoveDatasetFromMainGUI(dataset);
%   [status,message] = trEPRremoveDatasetFromMainGUI(dataset);
%
% Status:  0 - everything fine
%         -1 - no main GUI window found
%
% Message - string
%           In case of status <> 0 contains message telling user what went
%           wrong.

% (c) 2011-14, Till Biskup
% 2014-06-09

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
    mainWindow = trEPRguiGetWindowHandle();
    
    % Preset message
    message = '';
    
    % If there is no main GUI window, silently return
    if isempty(mainWindow)
        status = -1;
        message = 'No main GUI window found';
        return;
    end
    
    % Get appdata of main window
    ad = getappdata(mainWindow);

    % Cell array for labels of removed datasets
    removedDatasetsLabels = cell(length(dataset),1);
    
    % Ensure datasets are in descending order
    dataset = sort(dataset,'descend');
        
    % Remove dataset(s) from main GUI
    for k=1:length(dataset)
        if ~p.Results.force
            if ~any(ad.control.spectra.modified==dataset(k))
                [removedDatasetsLabels{k},ad] = removeDataset(dataset(k),ad);
            else
                remove = false;
                answer = questdlg(...
                    {'Dataset was modified. Remove anyway?'...
                    ' '...
                    'Note that "Remove" means that you loose the changes you made,'...
                    'but the (original) file will not be deleted from the file system.'...
                    ' '...
                    'Other options include "Save & Remove" or "Cancel".'},...
                    'Warning: Dataset Modified...',...
                    'Save & Remove','Remove','Cancel',...
                    'Save & Remove');
                switch answer
                    case 'Save & Remove'
                        status = trEPRsaveDatasetInMainGUI(dataset);
                        if status
                            % That means that something went wrong with the saveAs
                            return;
                        end
                        remove = true;
                    case 'Remove'
                        remove = true;
                    case 'Cancel'
                end
                if remove
                    [removedDatasetsLabels{k},ad] = ...
                        removeDataset(dataset(k),ad);
                end
            end
        else
            [removedDatasetsLabels{k},ad] = removeDataset(dataset(k),ad);
        end
    end
    
    % Write appdata
    setappdata(mainWindow,'data',ad.data);
    setappdata(mainWindow,'origdata',ad.data);
    setappdata(mainWindow,'control',ad.control);
    
    % Adding status line
    msg = cell(1,length(removedDatasetsLabels)+1);
    msg{1} = sprintf('Datasets successfully removed from main GUI');
    for k=1:length(removedDatasetsLabels)
        msg{k+1} = sprintf('  Label: %s',removedDatasetsLabels{k});
    end
    status = trEPRmsg(msg,'info');
    invStr = sprintf('%i ',ad.control.spectra.invisible);
    visStr = sprintf('%i ',ad.control.spectra.visible);
    msgStr = sprintf(...
        'Currently invisible: [ %s]; currently visible: [ %s]; total: %i',...
        invStr,visStr,length(ad.data));
    trEPRmsg(msgStr,'info');
    clear msgStr;
    
    % Update main GUI's axes and panels
    update_invisibleSpectra();
    update_visibleSpectra();
    update_datasetPanel();
    update_processingPanel();
    update_mainAxis();
    
    status = 0;
    
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

function [label,ad] = removeDataset(datasetIdx,ad)

label = ad.data{datasetIdx}.label;

% Remove dataset from data and origdata
ad.data(datasetIdx) = [];
ad.origdata(datasetIdx) = [];

% Remove dataset index from visible, invisible, modified
ad.control.spectra.visible(ad.control.spectra.visible==datasetIdx) = [];
ad.control.spectra.invisible(ad.control.spectra.invisible==datasetIdx) = [];
ad.control.spectra.modified(ad.control.spectra.modified==datasetIdx) = [];

% Renumber indices in visible, invisible, modified
ad.control.spectra.visible(ad.control.spectra.visible>datasetIdx) = ...
    ad.control.spectra.visible(ad.control.spectra.visible>datasetIdx) -1;
ad.control.spectra.invisible(ad.control.spectra.invisible>datasetIdx) = ...
    ad.control.spectra.invisible(ad.control.spectra.invisible>datasetIdx) -1;
ad.control.spectra.modified(ad.control.spectra.modified>datasetIdx) = ...
    ad.control.spectra.modified(ad.control.spectra.modified>datasetIdx) -1;

% Handle active dataset
% Get handles from handle
gh = guidata(ad.UsedByGUIData_m.trEPRgui);
visSelected = get(gh.data_panel_visible_listbox,'Value');

if isempty(ad.control.spectra.visible)
    ad.control.spectra.active = 0;
elseif visSelected > length(ad.data)
    ad.control.spectra.active = ad.control.spectra.visible(end);
else
    ad.control.spectra.active = ad.control.spectra.visible(visSelected);
end

end