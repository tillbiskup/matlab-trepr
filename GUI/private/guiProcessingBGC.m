function guiProcessingBGC(datasetnum)
% GUIPROCESSINGBGC Wrapper between trEPR GUI and actual background
% processing function.
%
% Normally only called from within the trEPR GUI.

% Copyright (c) 2011-13, Till Biskup
% 2013-09-10

method = 'trEPRBGC';
fun = str2func(method);

numBGprofiles = 5;

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

% Perform real task
ad.data{datasetnum} = ...
    fun(ad.data{datasetnum},'numBGprofiles',numBGprofiles);


% Add modified spectrum to list of modified spectra
if ~any(ad.control.data.modified==datasetnum)
    ad.control.data.modified = [...
        ad.control.data.modified ...
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
    'numBGprofiles',...
    numBGprofiles ...
    );
trEPRmsg(msg,'info');
clear msg;
end
