function [status,warnings] = cmdLoad(handle,varargin)
% CMDLOAD Command line command of the trEPR GUI.
%
% Usage:
%   cmdLoad(handle,opt)
%   [status,warnings] = cmdLoad(handle,opt)
%
%   handle  - handle
%             Handle of the window the command should be performed for
%
%   opt     - cell array
%             Options of the command
%
%   status  - scalar
%             Return value for the exit status:
%              0: command successfully performed
%             -1: GUI window found
%             -2: missing options
%             -3: Failed loading file(s)
%             -4: some other problems
%
%  warnings - cell array
%             Contains warnings/error messages if any, otherwise empty

% Copyright (c) 2013-15, Till Biskup
% 2015-10-18

status = 0;
warnings = cell(0);

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('handle', @(x)ishandle(x));
p.addOptional('opt',cell(0),@(x)iscell(x));
p.parse(handle,varargin{:});
handle = p.Results.handle;
opt = p.Results.opt;

% Get command name from mfilename
cmd = mfilename;
cmd = cmd(4:end);

% Is there the GUI requested?
if (isempty(handle))
    warnings{end+1} = 'No GUI window could be found.';
    status = -1;
    return;
end

% Get appdata from handle
ad = getappdata(handle);

if isempty(opt)
    FileName = getFileName();
    if isempty(FileName)
        return;
    end
else
    FileName = opt;
end

mainWindow = handle;

if isempty(FileName)
    warnings{end+1} = ['Command "' lower(cmd) ...
        '" needs at least one filename.'];
    return;
end

[path,name,ext] = fileparts(FileName{1});
if isempty(path)
    FileName = fullfile(ad.control.dirs.lastLoad,[name ext]);
end

% FileName is always a cell, as it comes from opt
% To prevent problems with trEPRload, check whether it is a one-element
% cell array and if so, convert it.
if iscell(FileName) && length(FileName) == 1
    FileName = FileName{1};
end

% Adding status line
trEPRmsg([{'Calling trEPRload and trying to load:'} FileName],'info');

trEPRbusyWindow('start','Trying to load spectra...<br />please wait.');

fileType = ad.control.panels.load.fileType;

[data,warnings] = trEPRload(FileName,...
    'combine',logical(ad.control.panels.load.fileTypes(fileType).combine),...
    'loadInfoFile',...
    logical(ad.control.panels.load.fileTypes(fileType).loadInfoFile));

% Get appdata, to make sure not to skip any messages that might be
% written by trEPRload
%ad = getappdata(mainWindow);

if isequal(data,0) || isempty(data)
    trEPRmsg('Data could not be loaded.','error');
    trEPRbusyWindow('stop','Trying to load spectra...<br /><b>failed</b>.');
    return;
end

if ~isempty(warnings)
    % Add warnings to status messages
    msgStr = cell(0);
    msgStr{end+1} = 'Some warnings occurred when trying to load ';
    if isa(FileName,'cell')
        FileName = char(FileName);
    end
    msgStr{end+1} = FileName;
    for k=1:length(warnings)
        if length(warnings{k})>1
            for m=1:length(warnings{k})
                msgStr{end+1} = ['Identifier: ' warnings{k}{m}.identifier]; %#ok<AGROW>
                msgStr{end+1} = ['Message:    ' warnings{k}{m}.message]; %#ok<AGROW>
            end
        else
            msgStr{end+1} = warnings{k}.identifier; %#ok<AGROW>
            msgStr{end+1} = warnings{k}.message; %#ok<AGROW>
        end
    end
    trEPRmsg(msgStr,'warning');
    clear msgStr;
end

% Check whether data{n}.data is numeric (very basic test for format)
fnNoData = cell(0);
nNoData = [];
if iscell(data)
    for k=1:length(data)
        if (isfield(data{k},'data') && ~isnumeric(data{k}.data))
            fnNoData{k} = data{k}.file.name;
            nNoData = [ nNoData k ]; %#ok<AGROW>
        elseif ~isfield(data{k},'data')
            nNoData = [ nNoData k ]; %#ok<AGROW>
        end
    end
    % Remove datasets from data cell array
    data(nNoData) = [];
else
    if not(isnumeric(data.data))
        fnNoData = data.file.name;
        data = [];
    end
end

% Add status line
if not (isempty(fnNoData))
    msgStr = cell(0);
    msgStr{length(msgStr)+1} = ...
        'The following files contained no numerical data (and were DISCARDED):';
    msg = [msgStr fnNoData];
    trEPRmsg(msg,'warning');
    clear msgStr msg;
end

if isempty(data)
    trEPRbusyWindow('stop','Trying to load spectra...<br /><b>failed</b>.');
    status = -4;
    warnings{end+1} = 'Failed loading file(s)';
    return;
end

% Get names of successfully loaded files
if iscell(data)
    fileNames = cell(0);
    for k = 1 : length(data)
        [p,fn,ext] = fileparts(data{k}.file.name);
        fileNames{k} = fullfile(p,[fn ext]);
        if ~isfield(data{k},'label') || isempty(data{k}.label)
            data{k}.label = [fn ext];
        end
    end
else
    fileNames = data.file.name;
    [~,fn,ext] = fileparts(data.file.name);
    if ~isfield(data,'label') || isempty(data.label)
        data.label = [fn ext];
    end
end

% Get indices of new datasets
% Necessary in case of further corrections applied to datasets
% after loading
newDataIdx = length(ad.data)+1 : 1 : length(ad.data)+length(data);

% Add data to main GUI (appdata)
[rows,cols] = size(data);
if rows == 1
    ad.data = [ ad.data data ];
    ad.origdata = [ ad.origdata data ];
elseif cols == 1
    ad.data = [ ad.data data' ];
    ad.origdata = [ ad.origdata data' ];
end

setappdata(mainWindow,'data',ad.data);
setappdata(mainWindow,'origdata',ad.origdata);

% Adding status line
if length(data)>1 plural='s';else plural='';end %#ok<SEPEX>
msgStr = sprintf('%i dataset%s successfully loaded:',length(data),plural);
trEPRmsg([{msgStr} fileNames],'info');
clear msgStr;

trEPRbusyWindow('stop','Trying to load spectra...<br /><b>done</b>.');
trEPRbusyWindow('deletedelayed');

% Get appdata again after making changes to it before
ad = getappdata(mainWindow);

% Check whether dataset shall be made visible upon load
if ad.control.panels.load.fileTypes(fileType).visibleUponLoad
    % Add new loaded spectra to "visible"
    ad.control.data.visible = [...
        ad.control.data.visible ...
        newDataIdx...
        ];
    ad.control.data.active = newDataIdx(end);
else
    % Add new loaded spectra to "invisible"
    ad.control.data.invisible = [...
        ad.control.data.invisible ...
        newDataIdx...
        ];
end

setappdata(mainWindow,'control',ad.control);

% Handle dataset corrections when checked
% pretrigger offset compensation
if ad.control.panels.load.fileTypes(fileType).POC
    for k=1:length(newDataIdx)
        guiProcessingPOC(newDataIdx(k));
    end
    % As guiProcessingPOC changes appdata, reload them
    ad = getappdata(handle);
end

% background subtraction
if ad.control.panels.load.fileTypes(fileType).BGC
    for k=1:length(newDataIdx)
        guiProcessingBGC(newDataIdx(k));
    end
    % As guiProcessingBGC changes appdata, reload them
    ad = getappdata(handle);
end

% convert units
if ad.control.panels.load.fileTypes(fileType).convertUnits
    conversions = regexp(ad.configuration.load.convert,',','split');
    for k=1:length(newDataIdx)
        for conversion = 1:length(conversions)
            cmdConvert(handle,...
                {num2str(newDataIdx(k)),conversions{conversion}});
        end
    end
end

% Try to load axis labels from file
if ad.control.panels.load.fileTypes(fileType).determineAxisLabels
    if (isfield(ad.data{newDataIdx(end)},'axes'))
        ad.control.axis.labels.x.measure = ...
            ad.data{newDataIdx(end)}.axes.data(1).measure;
        ad.control.axis.labels.x.unit = ...
            ad.data{newDataIdx(end)}.axes.data(1).unit;
        ad.control.axis.labels.y.measure = ...
            ad.data{newDataIdx(end)}.axes.data(2).measure;
        ad.control.axis.labels.y.unit = ...
            ad.data{newDataIdx(end)}.axes.data(2).unit;
        ad.control.axis.labels.z.measure = ...
            ad.data{newDataIdx(end)}.axes.data(3).measure;
        ad.control.axis.labels.z.unit = ...
            ad.data{newDataIdx(end)}.axes.data(3).unit;
    end
    setappdata(mainWindow,'control',ad.control);
end

update_invisibleSpectra;
update_visibleSpectra;
update_mainAxis;
update_processingPanel;

end

function FileName = getFileName()

FilterSpec = '*.*';

% Get the appdata of the main window
mainWindow = trEPRguiGetWindowHandle;
ad = getappdata(mainWindow);

% Set directory where to load files from
if isfield(ad,'control') && isfield(ad.control,'dirs') && ...
        isfield(ad.control.dirs,'lastLoad')  && ...
        ~isempty(ad.control.dirs.lastLoad)
    startDir = ad.control.dirs.lastLoad;
else
    startDir = pwd;
end

fileType = ad.control.panels.load.fileType;

if ad.control.panels.load.fileTypes(fileType).loadDir
    FileName = uigetdir(...
        startDir,...
        'Select directory to load'...
        );
    PathName = '';
else
    [FileName,PathName,~] = uigetfile(...
        FilterSpec,...
        'Select file(s) to load',...
        'MultiSelect','on',...
        startDir...
        );
end

% If the user cancels file selection, print status message and return
if isequal(FileName,0)
    FileName = '';
    trEPRmsg('Loading dataset(s) cancelled by user.','info');
    return;
end

% In case of files, not a directory, add path to filename
if exist('PathName','var') && exist(PathName,'file')
    % In case of multiple files
    if iscell(FileName)
        for k = 1 : length(FileName)
            FileName{k} = fullfile(PathName,FileName{k});
        end
    else
        FileName = fullfile(PathName,FileName);
    end
end

% Set lastLoadDir in appdata
if exist(PathName,'dir')    
    ad.control.dirs.lastLoad = PathName;
else
    if iscell(FileName)
        ad.control.dirs.lastLoad = FileName{1};
    elseif ad.control.panels.load.fileTypes(fileType).loadDir
        ad.control.dirs.lastLoad = ...
            FileName(1:find(FileName==filesep,1,'last')-1);
    else
        ad.control.dirs.lastLoad = FileName;
    end
end
setappdata(mainWindow,'control',ad.control);

% If FileName is not a cell string, convert it into a cell string
if ~isa(FileName,'cell')
    FileName = cellstr(FileName);
end

end
