function [status,warnings] = trEPRguiCommand(command,varargin)
% TREPRGUICOMMAND Helper function dealing with the command line of the
% trEPR GUI.
%
% Usage:
%   trEPRguiCommand(command)
%   [status,warnings] = trEPRguiCommand(command)
%
%   command - string
%             Command to be executed
%
%   status  - scalar
%             Return value for the exit status:
%              0: command successfully performed
%             -1: no trEPRgui window found
%             -2: trEPRgui window appdata don't contain necessary fields
%             -3: some other problems
%
%  warnings - cell array
%             Contains warnings/error messages if any, otherwise empty

% (c) 2013, Till Biskup
% 2013-02-18

status = 0;
warnings = cell(0);

% If called with no input arguments, just display help and exit
if (nargin==0)
    help trEPRguiCommand;
    return;
end

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('command', @(x)ischar(x));
%p.addOptional('command','',@(x)ischar(x));
p.parse(command,varargin{:});

% Is there currently a trEPRgui object?
mainWindow = trEPRguiGetWindowHandle();
if (isempty(mainWindow))
    warnings{end+1} = 'No trEPRgui window could be found.';
    status = -1;
    return;
end

if isempty(command)
    warnings{end+1} = 'Command empty.';
    status = -3;
    return;
end

% Get appdata from mainwindow
ad = getappdata(mainWindow);
% % Get handles from main GUI
% gh = guidata(mainWindow);

% Add command to command history
ad.control.cmd.history{end+1} = command;
ad.control.cmd.historypos = length(ad.control.cmd.history);
setappdata(mainWindow,'control',ad.control);

% For future use: parse command, split it at spaces, use first part as
% command, all other parts as options
input = regexp(command,' ','split');
cmd = input{1};
if (length(input) > 1)
    opt = input(2:end);
    % Remove empty opts
    opt = opt(~cellfun('isempty',opt));
else
    opt = cell(0);
end

% For now, just a list of internal commands and their translation into
% existing commands.
% Currently, just a struct with field names equivalent to the commands
% Field name  = command as entered on the command line
% Field value = actual Matlab command issued
cmdMatch = struct(...
    'info',   'trEPRgui_infowindow',...
    'acc',    'trEPRgui_ACCwindow',...
    'avg',    'trEPRgui_AVGwindow',...
    'blc',    'trEPRgui_BLCwindow',...
    'sim',    'trEPRgui_SIMwindow',...
    'status', 'trEPRgui_statuswindow',...
    'combine','trEPRgui_combinewindow',...
    'netpol', 'trEPRgui_NetPolarisationwindow',...
    'mwfreq', 'trEPRgui_MWfrequencyDriftwindow', ...
    'label',  'trEPRgui_setLabelWindow' ...
    );

if isfield(cmdMatch,lower(cmd))
    fun = str2func(cmdMatch.(lower(cmd)));
    fun();
elseif strcmpi(cmd,'help')
    if ~isempty(opt)
        switch lower(opt{1})
            case 'help'
                trEPRgui_helpwindow();
            case 'about'
                trEPRgui_aboutwindow();
            case 'modules'
                trEPRgui_moduleswindow();
            otherwise
                trEPRmsg(['Option "' opt{1} ...
                    '" not known for command help.'],'warning');
        end
    else
        trEPRgui_helpwindow();
    end
elseif exist(['cmd' upper(cmd(1)) lower(cmd(2:end))],'file')
    fun = str2func(['cmd' upper(cmd(1)) lower(cmd(2:end))]);
    [cmdStatus,cmdWarnings] = fun(mainWindow,opt);
    if cmdStatus
        warnings = [warnings cmdWarnings];
        status = -3;
    end
else
    % For debug purposes.
    disp(cmd);
    if ~isempty(opt)
        celldisp(opt);
    end
end

end