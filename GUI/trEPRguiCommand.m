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
%             -4: command was a comment line
%             -5: command was empty
%
%  warnings - cell array
%             Contains warnings/error messages if any, otherwise empty

% Copyright (c) 2013-15, Till Biskup
% 2015-10-17

status = 0;
warnings = cell(0);

commentCharacter = {'%','#'};

% If called with no input arguments, just display help and exit
if (nargin==0)
    help trEPRguiCommand;
    return;
end

% Parse input arguments using the inputParser functionality
p = inputParser;            % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Include function name in error messages
p.KeepUnmatched = true;     % Enable errors on unmatched arguments
p.StructExpand = true;      % Enable passing arguments in a structure
p.addRequired('command', @(x)ischar(x));
p.parse(command,varargin{:});

% Is there currently a trEPRgui object?
mainWindow = trEPRguiGetWindowHandle();
if (isempty(mainWindow))
    warnings{end+1} = 'No trEPRgui window could be found.';
    status = -1;
    return;
end

% Remove leading and trailing whitespace
command = strtrim(command);

% Handle empty command: ignore
if isempty(command)
    status = -5;
    return;
end

% Handle comment lines - lines must start with comment character
if any(strncmp(command,commentCharacter,1))
    status = -4;
    return;
end

% Split multiple commands separated by "; "
commandSeparator = '; ';
if any(strfind(command,commandSeparator))
    commands = regexp(command,commandSeparator,'split');
    for iCommand = 1:length(commands)
        [status,warnings] = trEPRguiCommand(commands{iCommand});
    end
    return;
end

% Add command to command history
addCommandToHistory(command,mainWindow);

% For future use: parse command, split it at spaces, use first part as
% command, all other parts as options
[cmd,opt] = parseCommand(command);

% Expand variables
if ~isempty(opt)
    opt = expandVariables(opt,mainWindow);
end

% For now, just a list of internal commands and their translation into
% existing commands.
cmdMatch = guiCommands;

% Handle special situations, such as "?"
switch lower(cmd)
    case {'?','doc'}
        cmd = 'help';
end

if find(strcmpi(cmdMatch(:,1),cmd))
    fun = str2func(cmdMatch{(strcmpi(cmdMatch(:,1),cmd)),2});
    if cmdMatch{(strcmpi(cmdMatch(:,1),cmd)),4}
        arguments = cmdMatch((strcmpi(cmdMatch(:,1),cmd)),3);
        if ~isempty(arguments)
            if iscell(arguments)
                fun(arguments{:});
            else
                fun(arguments);
            end
        else
            fun();
        end
    end
elseif exist(['cmd' upper(cmd(1)) lower(cmd(2:end))],'file')
    fun = str2func(['cmd' upper(cmd(1)) lower(cmd(2:end))]);
    [cmdStatus,cmdWarnings] = fun(mainWindow,opt);
    if cmdStatus && ~isempty(cmdWarnings);
        warnings = [warnings cmdWarnings];
        status = -3;
    end
else
    % For debug purposes.
    disp(cmd);
    trEPRmsg(['Command "' cmd '" not understood.'],'warn')
    if ~isempty(opt)
        celldisp(opt);
    end
end

end

function addCommandToHistory(command,mainWindow)

% Get appdata from mainwindow
ad = getappdata(mainWindow);

% Add command to command history
ad.control.cmd.history{end+1} = command;
ad.control.cmd.historypos = length(ad.control.cmd.history);
setappdata(mainWindow,'control',ad.control);

end

function [cmd,opt] = parseCommand(command)

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

end

function opt = expandVariables(opt,mainWindow)

% Get appdata from mainwindow
ad = getappdata(mainWindow);

% Expand variables
for optIdx = 1:length(opt)
    % Check whether the option contains any variable, as apparent from
    % apperance of "$" character(s)
    if any(strfind(opt{optIdx},'$')) % strncmp(opt{optIdx},'$',1)
        % Get any variable in string, even if there are more than one and
        % even if they may contain a "#" character indicating dataset
        % indices.
        variables = regexp(opt{optIdx},'\$\w*\#?\d*','match');
        for variable = 1:length(variables)
            % Set replacement string to default value
            replacement = '';
            % Handle special case that additional index is provided with
            % variable
            if any(strfind(variables{variable},'#'))
                parts = regexp(variables{variable},'#','split');
                replacement = parts{1};
                datasetIdx = str2double(parts{2});
            end
            if isfield(ad.control.cmd.variables,variables{variable}(2:end))
                replacement = ...
                    ad.control.cmd.variables.(variables{variable}(2:end));
            else
                switch variables{variable}(2:end)
                    case {'ndatasets','numberofdatasets'}
                        replacement = num2str(length(ad.data));
                    case 'current'
                        replacement = num2str(ad.control.data.active);
                    case 'pwd'
                        replacement = evalin('base','pwd');
                    case 'today'
                        replacement = datestr(now,'yyyymmdd');
                    case 'label'
                        if exist('datasetIdx','var') && ~isempty(datasetIdx) ...
                                && datasetIdx <= length(ad.data)
                            replacement = ad.data{datasetIdx}.label;
                        else
                            replacement = ...
                                ad.data{ad.control.data.active}.label;
                        end
                    case 'date'
                        if exist('datasetIdx','var') && ~isempty(datasetIdx) ...
                                && datasetIdx <= length(ad.data) && ...
                                ~isempty(ad.data{datasetIdx}.parameters.date.start)
                            replacement = ...
                                datestr(ad.data{datasetIdx...
                                }.parameters.date.start,'yyyymmdd');
                        elseif ad.control.data.active
                            if ~isempty(ad.data{ad.control.data.active}.parameters.date.start)
                                replacement = ...
                                    datestr(ad.data{ad.control.data.active...
                                    }.parameters.date.start,'yyyymmdd');
                            end
                        end
                    otherwise
                        trEPRmsg(['Variable "' variables{variable} ...
                            '" seems not to exist.'],'warning');
                end
            end
            opt{optIdx} = strrep(opt{optIdx},...
                variables{variable},replacement);
        end
    end
end

end
