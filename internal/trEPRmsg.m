function status = trEPRmsg(message,varargin)
% TREPRADD2STATUS Helper function adding a status message to the status
% cell array of the appdata of the trEPR GUI
%
% Usage:
%   trEPRmsg(message)
%   status = trEPRmsg(message)
%   status = trEPRmsg(message,level)
%
%   message - string/cell array
%             Status message
%
%   level   - string (OPTIONAL)
%             Level of the message
%             Currently possible values: info, warning, error, debug
%
%   status  - scalar
%             Return value for the exit status:
%             -1: no trEPRgui window found
%             -2: trEPRgui window appdata don't contain necessary fields
%              0: successfully updated status
%
% NOTE: If there is currently no trEPR GUI window open, the message will
% get displayed on the Matlab(tm) command line.

% (c) 2011-12, Till Biskup
% 2012-06-26

% Define log levels
% IDEA is to have the log levels sorted in descending order of their
% importance, to be able to query the set log level
logLevels = {'error','warning','info','debug','all'};

% Append indicator for message level, if present
logLevelAbbr = '';
logLevel = '';
if nargin > 1 && ischar(varargin{1})
    logLevel = varargin{1};
    switch lower(varargin{1})
        case 'debug'
            logLevelAbbr = '(DD) ';
        case 'info'
            logLevelAbbr = '(II) ';
        case 'warning'
            logLevelAbbr = '(WW) ';
        case 'error'
            logLevelAbbr = '(EE) ';
        otherwise
            fprintf('Unknown log level "%s"\n',varargin{1});
    end
end

% Is there currently a trEPRgui object?
mainwindow = trEPRguiGetWindowHandle();
if (isempty(mainwindow))
    % Display message in main window
    if iscell(message)
        for k=1:length(message)
            disp(message(k));
        end
    else
        disp(message);
    end
    status = -1;
    return;
end

% Get appdata from mainwindow
ad = getappdata(mainwindow);

% Check for availability of necessary fields in appdata
if (isfield(ad,'control') == 0) || (isfield(ad.control,'status') == 0)
    if iscell(message)
        for k=1:length(message)
            disp(message(k));
        end
    else
        disp(message);
    end
    status = -2;
    return;
end

% Prepend date and time to statusmessage
if ischar(message)
    message = ...
        sprintf('%s(%s) %s',logLevelAbbr,datestr(now,31),message);
elseif iscell(message)
    message{1} = ...
        sprintf('%s(%s) %s',logLevelAbbr,datestr(now,31),message{1});
    if (length(message) > 1)
        for k=2:length(message)
            message{k} = sprintf('%s  %s',logLevelAbbr,message{k});
        end
    end
end

% Append status message to cell array of status messages
if isfield(ad.control,'messages') && ~isempty(logLevel)
    % If we have a field ad.control.messages.debug.level, compare log level
    % set there to log level of message - see above for definition of log
    % levels.
    if find(strcmpi(logLevels,ad.control.messages.debug.level)) >= ...
            find(strcmpi(logLevels,logLevel))
        ad.control.status = [ ad.control.status message ];
    end
else
    ad.control.status = [ ad.control.status message ];
end

% Push appdata back to main gui
setappdata(mainwindow,'control',ad.control);

% Update status window
% As MATLAB(TM) had some problems with calling a private function in some
% special context, change the directory to the "private" dir, call the
% function that's located there, and afterwards return to original dir.
PWD = pwd;
cd(fileparts(mfilename('fullpath')));
trEPRguiUpdateStatusWindow(ad.control.status);
cd(PWD);

status = 0;

end