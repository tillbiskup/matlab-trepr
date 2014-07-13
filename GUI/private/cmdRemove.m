function [status,warnings] = cmdRemove(handle,opt,varargin)
% CMDREMOVE Command line command of the trEPR GUI.
%
% Usage:
%   cmdRemove(handle,opt)
%   [status,warnings] = cmdRemove(handle,opt)
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
%             -3: some other problems
%
%  warnings - cell array
%             Contains warnings/error messages if any, otherwise empty

% Copyright (c) 2013-14, Till Biskup
% 2014-06-24

status = 0;
warnings = cell(0);

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('handle', @(x)ishandle(x));
p.addRequired('opt', @(x)iscell(x));
p.parse(handle,opt,varargin{:});
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
% Get handles from handle
gh = guidata(handle);

% For convenience and shorter lines
active = ad.control.spectra.active;

if isempty(ad.data)
    warnings{end+1} = ['Command "' lower(cmd) '" needs datasets.'];
    return;
end

try
    if isempty(opt)
        if active
            % Get selected item of listbox
            selected = get(gh.data_panel_visible_listbox,'Value');
            
            % Get id of selected spectrum
            selectedId = ad.control.spectra.visible(selected);
            
            trEPRremoveDatasetFromMainGUI(selectedId);
            return;
        else
            return;
        end
    end
    
    switch lower(opt{1})
        case 'visible'
            if isempty(ad.control.spectra.visible)
                return;
            end
            visible = sort(ad.control.spectra.visible,'descend');
            if length(opt) > 1 &&  strcmpi(opt{2},'force')
                trEPRremoveDatasetFromMainGUI(visible,'force',true);
            else
                trEPRremoveDatasetFromMainGUI(visible);
            end
            return;
        case 'invisible'
            if isempty(ad.control.spectra.invisible)
                return;
            end
            invisible = sort(ad.control.spectra.invisible,'descend');
            if length(opt) > 1 && strcmpi(opt{2},'force')
                trEPRremoveDatasetFromMainGUI(invisible,'force',true);
            else
                trEPRremoveDatasetFromMainGUI(invisible);
            end
            return;
        case 'all'
            if isempty(ad.data)
                return;
            end
            datasets=length(ad.data):-1:1;
            if length(opt) > 1 &&  strcmpi(opt{2},'force')
                trEPRremoveDatasetFromMainGUI(datasets,'force',true);
            else
                trEPRremoveDatasetFromMainGUI(datasets);
            end
            return;
        case 'force'
            if length(opt) > 1
                opt{1} = opt{2};
                opt{2} = 'force';
                [status,warnings] = cmdRemove(handle,opt);
            elseif active
                % Get selected item of listbox
                selected = get(gh.data_panel_visible_listbox,'Value');
                
                % Get id of selected spectrum
                selectedId = ad.control.spectra.visible(selected);
                
                trEPRremoveDatasetFromMainGUI(selectedId,'force',true);
                return;
            else
                return;
            end
        otherwise
            status = -3;
            warnings{end+1} = ['Option ' opt{1} ' not understood.'];
            return;
    end
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

