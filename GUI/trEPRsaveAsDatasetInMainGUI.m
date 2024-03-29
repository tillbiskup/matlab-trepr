function [status,message] = trEPRsaveAsDatasetInMainGUI(id,varargin)
% SAVEASDATASETINMAINGUI Save dataset in main GUI under different name.
%
% Usage:
%   status = trEPRsaveAsDatasetInMainGUI(id);
%
% Status:  0 - everything fine
%         -1 - no main GUI window found
%
% Message - string
%           In case of status <> 0 contains message telling user what went
%           wrong.

% Copyright (c) 2011-17, Till Biskup
% 2017-03-09

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('id', @(x)isnumeric(x));
p.addOptional('filename','',@(x)ischar(x));
p.parse(id,varargin{:});

try
    % First, find main GUI window
    mainWindow = trEPRguiGetWindowHandle();
        
    % Preset message
    message = '';
    
    % Set file extension
    zipext = '.tez';

    % If there is no main GUI window, silently return
    if isempty(mainWindow)
        status = -1;
        message = 'No main GUI window found';
        return;
    end
    
    % Get appdata of main window
    ad = getappdata(mainWindow);
      
    % Create default filename
    if isempty(p.Results.filename) || isdir(p.Results.filename)
        filename = suggestFilename(mainWindow,'Type','file');
    else
        [path,name,~] = fileparts(p.Results.filename);
        filename = fullfile(path,name);
    end
    ad.data{id}.file.name = [filename zipext];

    % Need to test for existing file and in case, change default name
    if (exist(ad.data{id}.file.name,'file'))
        [fpath,fname,~] = fileparts(ad.data{id}.file.name);
        % 1. Check whether name ends with -NNN (where NNN are numbers)
        % 2. existingFiles = dir(sprintf('%s*',filename));
        % 2a. If name ends with -NNN, remove "-NNN" from filename before
        % 3. regexp existingFiles for "-NNN" pattern
        % 4. Get highest "-NNN" pattern and increment "NNN"
        % 5. Use filename with incremented "NNN" as new default filename
        if (regexp(fname,'_\d+$'))
            filesInDir = ...
                dir(sprintf('%s*',fullfile(fpath,regexprep(fname,'_\d+$',''))));
        else
            filesInDir = dir(sprintf('%s*',fullfile(fpath,fname)));
        end
        increment=0;
        numbers = [];
        for idx=1:length(filesInDir)
            token = regexp(filesInDir(idx).name,'_(\d+)\..*$','tokens');
            if ~isempty(token)
                increment=increment+1;
                numbers(increment) = str2double(token{1});
            end
        end
        if (~isempty(numbers));
            number = max(numbers)+1;
        else
            number = 1;
        end
        ad.data{id}.file.name = fullfile(...
            fpath,...
            sprintf('%s_%i%s',fname,number,zipext));
    end
    
    if isempty(p.Results.filename)
        % Show dialog for file selection
        [FileName,PathName,~] = uiputfile(...
            zipext,...
            'Save dataset in a new file',...
            ad.data{id}.file.name);
        
        if (FileName == 0)
            status = -1;
            return;
        end
        
        % Set filename to save in
        ad.data{id}.file.name = fullfile(PathName, FileName);
    end
    
    for idx = 1:length(ad.data)
        if (strcmp(ad.data{idx}.file.name,ad.data{id}.file.name)) && (idx ~= id)
            answer = questdlg(...
                {'WARNING: You''re about to save the current dataset to the file'...
                ad.data{id}.file.name ...
                ' '...
                'A dataset loaded from a file with that name has been loaded to the GUI!'...
                ' '...
                'Please use "Save as" and choose a different name or press "Cancel".'},...
                'Warning: Dataset with same filename loaded to GUI...',...
                'Save as','Cancel',...
                'Cancel');
            switch answer
                case 'Save as'
                    status = saveAsDatasetInMainGUI(id);
                    return;
                case 'Cancel'
                    return;
                otherwise
                    return;
            end
        end
    end
    
    trEPRbusyWindow('start','Trying to save spectra...<br />please wait.');
    
    % Do the actual saving
    [ saveStatus, exception ] = ...
        trEPRsave(ad.data{id}.file.name,ad.data{id});
    
    % In case something went wrong
    if ~isempty(saveStatus)
        % Adding status line
        msgStr = cell(0);
        msgStr{end+1} = ...
            sprintf('Problems when trying to save "%s" to file',...
            ad.data{id}.label);
        msgStr{end+1} = ad.data{id}.file.name;
        msgStr = [ msgStr saveStatus ];
        status = trEPRmsg(msgStr,'error');
        trEPRbusyWindow('stop','Trying to save spectra...<br /><b>failed</b>.');
        clear msgStr;
        return;
    else
        % Get second output parameter from trEPRsave, i.e. filename
        % (See help of trEPRsave for details)
        filename = exception;
    end
    
    % Remove from modified
    ad.control.data.modified(...
        (ad.control.data.modified == id)) = [];
        
    % Set last save dir
    [filepath,filename,~] = fileparts(ad.data{id}.file.name);
    if isdir(fullfile(filepath,filename))
        ad.control.dirs.lastSave = fullfile(filepath,filename);
    elseif isempty(ad.control.dirs.lastSave)
        ad.control.dirs.lastSave = pwd;
    else
        ad.contro.dirs.lastSave = filepath;
    end
        
    % Write appdata
    setappdata(mainWindow,'data',ad.data);
    setappdata(mainWindow,'origdata',ad.data);
    setappdata(mainWindow,'control',ad.control);
    
    % Adding status line
    msg = {...
        sprintf('Dataset %i successfully saved',id)...
        sprintf('Label: %s',ad.data{id}.label)...
        sprintf('File: %s',filename)...
        };
    status = trEPRmsg(msg,'info');
    
    % Update main GUI's axes and panels
    update_visibleSpectra();
    update_datasetPanel();
    update_processingPanel();
    update_mainAxis();
    
    trEPRbusyWindow('stop','Trying to save spectra...<br /><b>done</b>.');
    trEPRbusyWindow('deletedelayed');
    status = 0;
    
catch exception
    trEPRexceptionHandling(exception);
end

    
end
