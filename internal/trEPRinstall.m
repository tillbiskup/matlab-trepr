function varargout = trEPRinstall()
% TREPRINSTALL Installing the trEPR Toolbox on your system
%
% Usage
%   trEPRinstall
%   status = trEPRinstall
%
%   status    - string
%               Empty if everything went fine, otherwise contains message.
%

% Copyright (c) 2012-15, Till Biskup
% 2015-10-20

status = 0;

% There are several tasks a good installation program should perform:
%
% 1. Adding the toolbox paths to the Matlab(tm) search path
%
% 2. Checking the configuration files and update to new parameters

% First of all, check whether there is already a toolbox installed
if exist('trEPRgui','file')
    installed = true;
else
    installed = false;
end

fprintf('\n');
fprintf('==================================================================\n');
fprintf('\n');
if installed
    fprintf(' WELCOME. This will update\n');
else
    fprintf(' WELCOME. This will install\n');
end
fprintf('\n');
fprintf('     trEPR toolbox\n');
fprintf('     - a Matlab(tm) toolbox for transient EPR spectra  \n');
fprintf('\n');
fprintf(' on your system.\n');
fprintf('\n');
fprintf('==================================================================\n');
fprintf('\n');
if installed
    userQuestion = 'Do you want to update the toolbox now? Y/n [Y]: ';
else
    userQuestion = 'Do you want to install the toolbox now? Y/n [Y]: ';
end
reply = input(userQuestion, 's');
if isempty(reply)
    reply = 'Y';
end
if ~strcmpi(reply,'y')
    if installed
        fprintf('\nUpdate aborted... good-bye.\n\n');
    else
        fprintf('\nInstallation aborted... good-bye.\n\n');
    end
    return;
end

%-------------------------------------------------------------------------
% ADDING TOOLBOX PATHS
paths = getToolboxPaths(trEPRinfo('dir'));

% Print paths that get added
if installed
    fprintf('\nRefreshing the following paths in the Matlab(tm) search path:\n\n');
else
    fprintf('\nAdding the following paths to the Matlab(tm) search path:\n\n');
end
cellfun(@(x)fprintf('  %s\n',char(x)),paths);

% Actually add
cellfun(@(x)addpath(char(x)),paths);

% Trying to save path
fprintf('\nSaving path... ')
spstatus = savepath;
if spstatus
    fprintf('FAILED!\n');
    % Test whether global pathdef.m is writable
    pathdefFileName = fullfile(matlabroot,'toolbox','local','pathdef.m');
    fh = fopen(pathdefFileName,'w');
    if fh == -1
        fprintf('\n   You have no write permissions to the file\n   %s.\n',...
            pathdefFileName);
        fprintf('   Therefore, you need to manually save the Matlab path.\n');
    else
        close(fh);
    end 
else
    fprintf('done.\n');
end

%-------------------------------------------------------------------------
% UPDATING CONFIGURATION - only if installed before
if installed
    fprintf('\nUpdating configuration... ');
    confFiles = trEPRconf('files');
    if isempty(confFiles)
        fprintf('done.\n');
    else
        fprintf('\n\n')
        for k=1:length(confFiles)
            [~,cfname,cfext] = fileparts(confFiles{k});
            fprintf('  merging %s%s\n',cfname,cfext);
            try
                tocopy = trEPRiniFileRead(confFiles{k},...
                    'typeConversion',true);
                master = trEPRiniFileRead([confFiles{k} '.dist'],...
                    'typeConversion',true);
                newConf = commonStructCopy(master,tocopy);
                header = 'Configuration file for trEPR toolbox';
                trEPRiniFileWrite(confFiles{k},...
                    newConf,'header',header,'overwrite',true);
            catch exception
                status = exception.message;
                fprintf('    (EE) some problems occurred...\n');
                fprintf('    (EE) "%s"\n    (EE) %s, line %i\n',...
                    exception.message,...
                    exception.stack(1).name,exception.stack(1).line);
            end
        end
        fprintf('\ndone.\n');
    end
end

%-------------------------------------------------------------------------
% CHECK FOR CONFIGURATION DIRECTORY
confDir = trEPRparseDir('~/.trepr');
if ~exist(confDir,'dir')
    try
        fprintf('\nCreating local config directory... ');
        mkdir(confDir);
        fprintf('done.\n');
    catch exception
        status = exception.message;
        fprintf('failed! Perhaps no write permission?\n');
    end
end
snapshotDir = trEPRparseDir(fullfile(confDir,'snapshots'));
if ~exist(snapshotDir,'dir')
    try
        fprintf('\nCreating directory for snapshots... ');
        mkdir(snapshotDir);
        fprintf('done.\n');
    catch exception
        status = exception.message;
        fprintf('failed! Perhaps no write permission?\n');
    end
end
scriptDir = trEPRparseDir(fullfile(confDir,'scripts'));
if ~exist(scriptDir,'dir')
    try
        fprintf('\nCreating directory for CMD scripts... ');
        mkdir(scriptDir);
        fprintf('done.\n');
    catch exception
        status = exception.message;
        fprintf('failed! Perhaps no write permission?\n');
    end
end

fprintf('\nCongratulations! The trEPR Toolbox has been ')
if installed
    fprintf('updated ')
else
    fprintf('installed ')
end
fprintf('on your system.\n\n');
fprintf('Please, find below a bit of information about the current install.\n\n')

trEPRinfo;
fprintf('\n');

if nargout
    varargout{1} = status;
end


end

function directories = getToolboxPaths(path)
% GETTOOLBOXPATHS Internal function returning all subdirectories of the
% current toolbox installation.
directories = {path};
traverse(path);
    function traverse(directory)
        list = dir(directory);
        for k=1:length(list)
            if list(k).isdir && ~strncmp(list(k).name,'.',1) && ...
                    ~strcmp(list(k).name,'private')
                directories{end+1} = fullfile(directory,list(k).name); %#ok<AGROW>
                traverse(fullfile(directory,list(k).name));
            end
        end
    end
end
