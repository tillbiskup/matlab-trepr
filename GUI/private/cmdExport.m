function [status,warnings] = cmdExport(handle,opt,varargin)
% CMDEXPORT Command line command of the trEPR GUI.
%
% Usage:
%   cmdExport(handle,opt)
%   [status,warnings] = cmdExport(handle,opt)
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
%             -1: no GUI window found
%             -2: missing options
%             -3: some other problems
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
p.addRequired('opt', @(x)iscell(x));
%p.addOptional('opt',cell(0),@(x)iscell(x));
p.parse(handle,opt,varargin{:});
handle = p.Results.handle;
opt = p.Results.opt;

% Get command name from mfilename
cmd = mfilename;
cmd = lower(cmd(4:end));

% Is there the GUI requested?
if (isempty(handle))
    warnings{end+1} = 'No GUI window could be found.';
    status = -1;
    return;
end

% Get appdata from handle
ad = getappdata(handle);

% For convenience and shorter lines
active = ad.control.data.active;

% If there is no active dataset, return
if ~active
    warnings{end+1} = sprintf('Command "%s": No active dataset.',cmd);
    status = -3;
    return;
end

if isempty(opt)
    warnings{end+1} = sprintf(...
        'Command "%s": Not enough options. Use "help %s" to get some help.',cmd,cmd);
    status = -2;
    return;
end

% Check for correct first option
firstOption = {'fig','figure','axis','axes','1D','2D'};
if ~any(strcmpi(opt{1},firstOption))
    warnings{end+1} = sprintf(...
        'Command "%s": Option "%s" not understood.',cmd,opt{1});
    status = -3;
    return;
end

% Handle different things to export
switch lower(opt{1})
    case {'fig','figure','axis','axes'}
        % TODO: Handle additional optional parameters
        %       Call function saving the current axis
        % Handle actual work in an internal function
        [if_status,if_warnings] = if_exportFigure(handle,opt(2:end));
        % Deal with status and warnings from internal function
        if if_status
            status = if_status;
        end
        if ~isempty(if_warnings)
            for k=1:length(if_warnings)
                warnings{end+1} = if_warnings{k}; %#ok<AGROW>
            end
        end
        return;
    case '1d'
        % Handle actual work in an internal function
        [if_status,if_warnings] = if_export1Ddata(handle,opt(2:end));
        % Deal with status and warnings from internal function
        if if_status
            status = if_status;
        end
        if ~isempty(if_warnings)
            for k=1:length(if_warnings)
                warnings{end+1} = if_warnings{k}; %#ok<AGROW>
            end
        end
        return;
    case '2d'
        % Handle actual work in an internal function
        [if_status,if_warnings] = if_export2Ddata(handle,opt(2:end));
        % Deal with status and warnings from internal function
        if if_status
            status = if_status;
        end
        if ~isempty(if_warnings)
            for k=1:length(if_warnings)
                warnings{end+1} = if_warnings{k}; %#ok<AGROW>
            end
        end
        return;
    otherwise
        warnings{end+1} = sprintf(...
            'Command "%s": Option "%s" not understood.',cmd,opt{1});
        status = -3;
        return;
end

end

function [if_status,if_warnings] = if_exportFigure(handle,opt)
% IF_EXPORTFIGURE Internal function used to handle exporting figures.
%
% Please note: This internal function itself only prepares the function
% call for the actual function used to export the figure.

if_status = 0;
if_warnings = cell(0);

% Get appdata and handles of handle
ad = getappdata(handle);
gh = ad.guiHandles;

% Get export format
figExportFormats = cellstr(...
    get(gh.display_panel_axesexport_format_popupmenu,'String'));
exportFormat = figExportFormats{...
    get(gh.display_panel_axesexport_format_popupmenu,'Value')};

% Get file type to save to
fileTypes = cellstr(...
    get(gh.display_panel_axesexport_filetype_popupmenu,'String'));
fileType = fileTypes{...
    get(gh.display_panel_axesexport_filetype_popupmenu,'Value')};

% Check whether to save caption
% TODO: Replace with lookup in ad.control.panels.display.xxx
caption = get(gh.display_panel_axesexport_includecaption_checkbox,'Value');

% Handle additional options
% Please note: These options of the internal function are a subset of the
%              original options the command was called with.
% Order of checking does matter to a certain extend, as the last remaining
% option is used as a filename, if any.
if ~isempty(opt)
    % Check for image format
    formatidx = strncmpi('format=',opt,6);
    if ~isempty(formatidx)
        formatstr = opt(formatidx);
        % Remove respective entries from opt cell array
        opt(formatidx) = [];
        if ~isempty(formatstr)
            exportFormat = formatstr{1}(8:end);
        end
    end
    
    % Check for file type
    typeidx = strncmpi('type=',opt,4);
    if ~isempty(typeidx)
        typestr = opt(typeidx);
        % Remove respective entries from opt cell array
        opt(typeidx) = [];
        if ~isempty(typestr)
            fileType = typestr{1}(6:end);
        end
    end
    
    % Check for caption options
    captionidx = strncmpi('caption=',opt,7);
    if ~isempty(captionidx)
        captionstr = opt{captionidx}(9:end);
        % Remove respective entries from opt cell array
        opt(captionidx) = [];
        if ~isempty(captionstr)
            switch lower(captionstr)
                case {'yes','y','true','1'}
                    caption = true;
                case {'no','n','false','0'}
                    caption = false;
            end
        end
    end
    
    % Finally, take remaining options as file name
    if ~isempty(opt)
        fileName = strtrim(sprintf('%s',opt{:}));
    end
end

% Important: First generate filename suggestion and ask user for
% filename, then start redrawing the figure in a new figure window.
% If the user quits the file selection dialogue box, nothing is
% left to close in this case.

if ~exist('fileName','var')
    fileNameSuggested = suggestFilename(handle,'Type','figure');
    
    % Ask user for file name
    [fileName,pathName] = uiputfile(...
        sprintf('*.%s',fileType),...
        'Get filename to export figure to',...
        fileNameSuggested);
    % If user aborts process, return
    if fileName == 0
        return;
    end
    % Create filename with full path
    fileName = fullfile(pathName,fileName);
else
    [pathName,fileName,~] = fileparts(fileName);
end

% set lastFigSave Dir in appdata
if exist(pathName,'dir')
    ad.control.dirs.lastFigSave = pathName;
end
setappdata(handle,'control',ad.control);

% Open new figure window
newFig = figure();

% Make new figure window invisible
set(newFig,'Visible','off');

% Plot into new figure window
% Check whether to plot title, yticks, yaxis
update_mainAxis(newFig,...
    'title',get(gh.display_panel_axesexport_includetitle_checkbox,'Value'),...
    'noyticks',get(gh.display_panel_axesexport_removeyticks_checkbox,'Value'),...
    'noyaxis',get(gh.display_panel_axesexport_removeyaxis_checkbox,'Value'),...
    'nobox',get(gh.display_panel_axesexport_removebox_checkbox,'Value'));

% Check whether to plot colorbar
if strcmpi(ad.control.axis.displayType,'2d plot') && ...
    ad.control.axis.colormap.colorbar
    cbar = colorbar;
    ad.control.axis.labels.z.measure = 'Intensity';
    if ~isempty(ad.control.axis.labels.z.measure)
        if isempty(ad.control.axis.labels.z.unit)
            ylabel(cbar,['{\it' ad.control.axis.labels.z.measure '}']);
        else
            ylabel(cbar,['{\it' ad.control.axis.labels.z.measure ...
                '} / ' ad.control.axis.labels.z.unit]);
        end
    end
end

% Check whether to open caption GUI
if caption
    trEPRgui_figureCaptionwindow(fileName);
end

% Save figure, depending on settings for file type and format
status = fig2file(newFig,fileName,...
    'fileType',fileType,'exportFormat',exportFormat);
if status
    trEPRmsg(status,'warning');
end

% Close figure window
close(newFig);

end

function [if_status,if_warnings] = if_export1Ddata(handle,opt)
% IF_EXPORT1DDATA Internal function used to handle exporting 1D data.
%
% Please note: This internal function itself only prepares the function
% call for the actual function used to export the data.

if_status = 0;
if_warnings = cell(0);

% Get appdata and handles of handle
ad = getappdata(handle);
gh = ad.guiHandles;

% Set default options
multipleFiles = get(...
    gh.datasets_panel_dataexport1D_multiplefiles_checkbox,'value');

allTraces = any(cell2mat(...
    get([gh.datasets_panel_dataexport1D_multiplefiles_checkbox,...
    gh.datasets_panel_dataexport1D_multiple1file_checkbox],'value')));

% Handle additional options
% Please note: These options of the internal function are a subset of the
%              original options the command was called with.
% Order of checking does matter to a certain extend, as the last remaining
% option is used as a filename, if any.
if ~isempty(opt)
    
    % Check which datasets should be exported, default is what is set in
    % the GUI
    currentidx = strcmpi('current',opt);
    if any(currentidx)
        % Remove respective entries from opt cell array
        opt(currentidx) = [];
    end
    allidx = strcmpi('all',opt);
    if any(allidx)
        % Remove respective entries from opt cell array
        opt(allidx) = [];
        allTraces = true;
    end
    
    % Check which datasets should be exported, default is what is set in
    % the GUI
    singleidx = strcmpi('single',opt);
    if any(singleidx)
        % Remove respective entries from opt cell array
        opt(singleidx) = [];
        multipleFiles = false;
    end
    multipleidx = strcmpi('multiple',opt);
    if any(multipleidx)
        % Remove respective entries from opt cell array
        opt(multipleidx) = [];
        multipleFiles = true;
    end
    
    % Check for file type
    typeidx = strncmpi('type=',opt,5);
    typestr = opt(typeidx);
    % Remove respective entries from opt cell array
    opt(typeidx) = [];
    if ~isempty(typestr)
        fileType = typestr{1}(6:end);
    end
    
    % Finally, take remaining options as file name
    if ~isempty(opt)
        if allTraces
            if_warnings{end+1} = sprintf(...
                'Command "%s": Single filename with multiple files!',cmd,opt{1});
            if_status = -3;
            return;
        end
        if length(opt) > 1
            fileName = strtrim(sprintf('%s_',opt{:}));
        else
            fileName = strtrim(opt{:});
        end
    end
end

if ~exist('fileType','var')
    % Get file type to save to
    fileTypes = cellstr(...
        get(gh.datasets_panel_dataexport1D_filetype_popupmenu,'String'));
    fileType = fileTypes{...
        get(gh.datasets_panel_dataexport1D_filetype_popupmenu,'Value')};
end

% Set directory where to save files to
if isfield(ad,'control') && isfield(ad.control,'dir') && ...
        isfield(ad.control.dir,'lastExport')  && ...
        ~isempty(ad.control.dir.lastExport)
    startDir = ad.control.dir.lastExport;
else
    startDir = pwd;
end

switch fileType
    case 'ASCII'
        fileExtension = 'dat';
    otherwise
        fileExtension = '';
end

if ~exist('fileName','var')
    % Ask user for file name
    [~,f,~] = ...
        fileparts(ad.data{ad.control.data.active}.file.name);
    fileNameSuggested = fullfile(startDir,[f '-1D']);
    clear f;
    [fileName,pathName] = uiputfile(...
        sprintf('*.%s',fileExtension),...
        sprintf('Filename for dataset "%s"',...
        ad.data{ad.control.data.active}.label),...
        fileNameSuggested);
    % If user aborts process, return
    if fileName == 0
        return;
    end
    % Create filename with full path
    fileName = fullfile(pathName,fileName);
end

if ~isempty(fileExtension)
    fileName = [fileName '.' fileExtension];
end

% If multipleFiles is set, meaning that multiple visible datasets should be
% saved each to a separate file
if multipleFiles

    % Iterate over each visible dataset
    for idx = 1:length(ad.control.data.visible)
        % Ask user for filename
        [~,f,~] = ...
            fileparts(ad.data{ad.control.data.visible(idx)}.file.name);
        fileNameSuggested = fullfile(startDir,[f '-1D']);
        clear f;
        % Ask user for file name
        [fileName,pathName] = uiputfile(...
            sprintf('*.%s',fileExtension),...
            sprintf('Filename for dataset "%s"',...
            ad.data{ad.control.data.visible(idx)}.label),...
            fileNameSuggested);
        % If user aborts process, return
        if fileName == 0
            return;
        end
        % Create filename with full path
        fileName = fullfile(pathName,fileName);
        
        % set lastExport Dir in appdata
        if exist(pathName,'dir')
            ad.control.dir.lastExport = pathName;
        end
        setappdata(handle,'control',ad.control);
        
        % Create parameters structure
        export1Dparameters = struct();
        switch ad.control.axis.displayType
            case '1D along x'
                export1Dparameters.crosssection.direction = 'x';
                export1Dparameters.crosssection.position = ...
                    ad.data{ad.control.data.visible(idx)}.display.position.data(2);
            case '1D along y'
                export1Dparameters.crosssection.direction = 'y';
                export1Dparameters.crosssection.position = ...
                    ad.data{ad.control.data.visible(idx)}.display.position.data(1);
            otherwise
                msg = 'Cannot determine cross section direction (2D mode)';
                trEPRmsg(msg,'error');
                msgbox(msg,'Error with exporting 1D','error');
        end
        export1Dparameters.header.character = ...
            get(gh.datasets_panel_dataexport1D_header_edit,'String');
        export1Dparameters.axis.include = ...
            get(gh.datasets_panel_dataexport1D_includeaxis_checkbox,'Value');
        export1Dparameters.stdev.include = ...
            get(gh.datasets_panel_dataexport1D_includestdev_checkbox,'Value');
        export1Dparameters.calculated.include = ...
            get(gh.datasets_panel_dataexport1D_includesimulation_checkbox,...
            'Value');
        export1Dparameters.file.type = fileType;
        export1Dparameters.file.overwrite = 1;
        
        % Save 1D cross section, depending on settings for file type and
        % additional parameters
        status = trEPRexport1D(...
            ad.data{ad.control.data.visible(idx)},...
            fileName,export1Dparameters);
        if status
            trEPRmsg(status,'warning');
            msgbox(status,'Problems with exporting 1D','warn');
        else
            msgbox(sprintf('%s\n%s',...
                'Current 1D display successfully exported to file',...
                fileName),...
                'Exporting 1D','help');
        end
    end
    
else
    
    % If no filename is provided, ask user for filename
    if ~exist('fileName','var')
        % Suggest file name if possible
        [~,f,~] = ...
            fileparts(ad.data{ad.control.data.active}.file.name);
        fileNameSuggested = fullfile(startDir,[f '-1D']);
        clear f;
        % Ask user for file name
        [fileName,pathName] = uiputfile(...
            sprintf('*.%s',fileExtension),...
            'Get filename to save 1D cross section of currently active dataset to',...
            fileNameSuggested);
        % If user aborts process, return
        if fileName == 0
            return;
        end
        % Create filename with full path
        fileName = fullfile(pathName,fileName);
    end
    
    % set lastExport Dir in appdata
    if ~exist('pathName','var')
        pathName = pwd;
    end
    if exist(pathName,'dir')
        ad.control.dir.lastExport = pathName;
    end
    setappdata(handle,'control',ad.control);
    
    % Create parameters structure
    export1Dparameters = struct();
    switch ad.control.axis.displayType
        case '1D along x'
            export1Dparameters.crosssection.direction = 'x';
            export1Dparameters.crosssection.position = ...
                ad.data{ad.control.data.active}.display.position.data(2);
        case '1D along y'
            export1Dparameters.crosssection.direction = 'y';
            export1Dparameters.crosssection.position = ...
                ad.data{ad.control.data.active}.display.position.data(1);
        otherwise
            msg = 'Cannot determine cross section direction (2D mode)';
            trEPRmsg(msg,'error');
            msgbox(msg,'Error with exporting 1D','error');
    end
    export1Dparameters.header.character = ...
        get(gh.datasets_panel_dataexport1D_header_edit,'String');
    export1Dparameters.axis.include = ...
        get(gh.datasets_panel_dataexport1D_includeaxis_checkbox,'Value');
    export1Dparameters.stdev.include = ...
        get(gh.datasets_panel_dataexport1D_includestdev_checkbox,'Value');
    export1Dparameters.calculated.include = ...
        get(gh.datasets_panel_dataexport1D_includesimulation_checkbox,...
        'Value');
    export1Dparameters.file.type = fileType;
    export1Dparameters.file.overwrite = 1;
    
    % Save 1D cross section, depending on settings for file type and
    % additional parameters
    status = trEPRexport1D(...
        ad.data{ad.control.data.active},fileName,export1Dparameters);
    if status
        trEPRmsg(status,'warning');
        msgbox(status,'Problems with exporting 1D','warn');
    else
        msgbox(sprintf('%s\n%s',...
            'Current 1D display successfully exported to file',...
            fileName),...
            'Exporting 1D','help');
    end
    
end

end

function [if_status,if_warnings] = if_export2Ddata(handle,opt)
% IF_EXPORT2DDATA Internal function used to handle exporting 2D data.
%
% Please note: This internal function itself only prepares the function
% call for the actual function used to export the data.

if_status = 0;
if_warnings = cell(0);

% Get appdata and handles of handle
ad = getappdata(handle);
gh = ad.guiHandles;

% Handle additional options
% Please note: These options of the internal function are a subset of the
%              original options the command was called with.
% Order of checking does matter to a certain extend, as the last remaining
% option is used as a filename, if any.
if ~isempty(opt)
    
    % Check for file type
    typeidx = strncmpi('type=',opt,6);
    typestr = opt(typeidx);
    % Remove respective entries from opt cell array
    opt(typeidx) = [];
    if ~isempty(typestr)
        exportFormat = typestr{1}(8:end);
    end
    
    % Finally, take remaining options as file name
    if ~isempty(opt)
        fileName = strtrim('%s',opt{:});
    end
end

if ~exist('fileType','var')
    % Get file type to save to
    exportFormats = cellstr(...
        get(gh.datasets_panel_dataexport2D_format_popupmenu,'String'));
    exportFormat = exportFormats{...
        get(gh.datasets_panel_dataexport2D_format_popupmenu,'Value')};
end

% Set directory where to save files to
if isfield(ad,'control') && isfield(ad.control,'dir') && ...
        isfield(ad.control.dir,'lastExport')  && ...
        ~isempty(ad.control.dir.lastExport)
    startDir = ad.control.dir.lastExport;
else
    startDir = pwd;
end

exportParameters = struct();

switch exportFormat
    case 'glotaran'
        fileExtension = 'ascii';
        exportFunctionName = 'trEPRexport4glotaran';
    case 'ASCII'
        fileExtension = 'ascii';
        exportFunctionName = 'trEPRexport2D';
        exportParameters.includeAxes = logical(...
            get(gh.datasets_panel_dataexport2D_includeaxes_checkbox,'Value'));
        exportParameters.commentChar = ...
            get(gh.datasets_panel_dataexport2D_header_edit,'String');
    otherwise
        trEPRoptionUnknown(exportFormat);
        return;
end

% If no filename is provided, ask user for filename
if ~exist('fileName','var')
    % Suggest file name if possible
    [~,f,~] = ...
        fileparts(ad.data{ad.control.data.active}.file.name);
    fileNameSuggested = fullfile(startDir,[f '-2D' exportFormat]);
    clear f;
    % Ask user for file name
    [fileName,pathName] = uiputfile(...
        sprintf('*.%s',fileExtension),...
        'Get filename to save 2D data currently active dataset to',...
        fileNameSuggested);
    % If user aborts process, return
    if fileName == 0
        return;
    end
    % Create filename with full path
    fileName = fullfile(pathName,fileName);
end

% set lastExport Dir in appdata
if exist(pathName,'dir')
    ad.control.dir.lastExport = pathName;
end
setappdata(handle,'control',ad.control);

exportFunction = str2func(exportFunctionName);

trEPRbusyWindow('start',...
    'Trying to export dataset...<br />please wait.');

% Export using export4glotaran
status = exportFunction(...
    ad.data{ad.control.data.active},fileName,...
    exportParameters);
if status
    trEPRmsg(status,'error');
    trEPRbusyWindow('stop',...
        'Trying to export dataset...<br /><b>failed</b>.');
else
    trEPRbusyWindow('stop',...
        'Trying to export dataset...<br /><b>done</b>.');
    trEPRbusyWindow('deletedelayed');
end

% Add status message (mainly for debug reasons)
% IMPORTANT: Has to go AFTER setappdata
msgStr = sprintf('Exported dataset %i to format %s',...
    ad.control.data.active,exportFormat);
trEPRmsg(msgStr,'info');

end
