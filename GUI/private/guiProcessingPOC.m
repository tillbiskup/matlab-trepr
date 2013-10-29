function guiProcessingPOC(datasetnum)
% guiProcessingPOC Wrapper between trEPR GUI and actual pretrigger offset
% correction function.
%
% Normally only called from within the trEPR GUI.

% (c) 2011-13, Till Biskup
% 2013-10-29

method = 'trEPRPOC';
fun = str2func(method);

% Get appdata of main window
mainWindow = trEPRguiGetWindowHandle();
ad = getappdata(mainWindow);

% Check whether operation has been applied to that dataset before
for k=1:length(ad.data{datasetnum}.history)
    if (isequal(ad.data{datasetnum}.history{k}.method,method))
        trEPRmsg(...
            ['Operation "' method '" has been applied already '...
            'to this dataset. Nothing done.'],'warning');
        return;
    end
end

if (isfield(ad.data{datasetnum},'parameters') && ...
        isfield(ad.data{datasetnum}.parameters,'transient') && ...
        isfield(ad.data{datasetnum}.parameters.transient,'triggerPosition') && ...
        ~isempty(ad.data{datasetnum}.parameters.transient.triggerPosition))
    ad.data{datasetnum} = fun(ad.data{datasetnum});
else
    return;
end

% Add modified spectrum to list of modified spectra
if ~any(ad.control.spectra.modified==datasetnum)
    ad.control.spectra.modified = [...
        ad.control.spectra.modified ...
        datasetnum];
end

% Update appdata of main window
% IMPORTANT: Needs to be done BEFORE writing the status message!
setappdata(mainWindow,'data',ad.data);
setappdata(mainWindow,'control',ad.control);

%Update main axis
update_mainAxis();

% Add message to status line
msg = cell(1,2);
msg{1} = sprintf(...
    'Operation "%s" applied to dataset "%s"',...
    method,...
    ad.data{datasetnum}.label...
    );
msg{2} = sprintf(...
    'with parameter %s = %i',...
    'triggerPosition',...
    ad.data{datasetnum}.parameters.transient.triggerPosition...
    );
trEPRmsg(msg,'info');
clear msg;
end