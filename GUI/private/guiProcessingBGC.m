function guiProcessingBGC(datasetnum)
% GUIPROCESSINGBGC Wrapper between trEPR GUI and actual background
% processing function.
%
% Normally only called from within the trEPR GUI.

% (c) 2011-12, Till Biskup
% 2012-06-27

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
ad.data{datasetnum}.data = ...
    fun(ad.data{datasetnum}.data,...
    'numBGprofiles',numBGprofiles);


% Add modified spectrum to list of modified spectra
if isempty(ad.control.spectra.modified==datasetnum)
    ad.control.spectra.modified = [...
        ad.control.spectra.modified ...
        datasetnum];
end

% Add record to history
ad.data{datasetnum}.history{end+1} = struct(...
    'date',datestr(now,31),...
    'method',method,...
    'system',struct(...
    'username',ad.control.system.username,...
    'platform',ad.control.system.platform,...
    'matlab',ad.control.system.matlab,...
    'trEPR',ad.control.system.trEPR...
    ),...
    'parameters',struct(...
    'numBGprofiles',numBGprofiles ...
    ),...
    'info',''...
    );

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