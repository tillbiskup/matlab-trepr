function status = trEPRmsg(message,varargin)
% TREPRMSG Helper function adding a status message to the status cell array
% of the appdata of the trEPR GUI 
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

% Copyright (c) 2011-14, Till Biskup
% 2014-07-12

% Define log levels
% IDEA is to have the log levels sorted in descending order of their
% importance, to be able to query the set log level
logLevels = {'error','warning','info','debug','all'};

% Append indicator for message level, if present
logLevelAbbr = '';
logLevel = '';
if nargin > 1 && ischar(varargin{1})
    logLevel = varargin{1};
    switch lower(logLevel)
        case {'debug','d'}
            logLevelAbbr = '(DD) ';
            logLevel = 'debug';
        case {'info','i'}
            logLevelAbbr = '(II) ';
            logLevel = 'info';
        case {'warning','warn','w'}
            logLevelAbbr = '(WW) ';
            logLevel = 'warning';
        case {'error','err','e'}
            logLevelAbbr = '(EE) ';
            logLevel = 'error';
        otherwise
            fprintf('Unknown log level "%s"\n',logLevel);
    end
end

% Is there currently a trEPRgui object?
mainWindow = trEPRguiGetWindowHandle();
if (isempty(mainWindow))
    % Display message in main window
    if iscell(message)
        for k=1:length(message)
            disp(message(k));
        end
    else
        disp([logLevelAbbr message]);
    end
    status = -1;
    return;
end

% Get appdata from mainwindow
ad = getappdata(mainWindow);
% Get handles from main GUI
gh = guidata(mainWindow);

% Check for availability of necessary fields in appdata
if ~isfield(ad,'control') || ~isfield(ad.control,'status')
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
    if iscell(message{1})
        message{1} = ...
            sprintf('%s(%s) %s',logLevelAbbr,datestr(now,31),char(message{1}));
    else
        message{1} = ...
            sprintf('%s(%s) %s',logLevelAbbr,datestr(now,31),message{1});
    end
    if (length(message) > 1)
        for k=2:length(message)
            if iscell(message{k})
                if length(message{k}) > 1
                    for m=1:length(message{k})
                        message{k+m} = ...
                            sprintf('%s  %s',logLevelAbbr,message{k}{m});
                    end
                else
                    message{k} = sprintf('%s  %s',logLevelAbbr,char(message{k}));
                end
            else
                message{k} = sprintf('%s  %s',logLevelAbbr,message{k});
            end
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

% Update main gui status lights if necessary
if ~isempty(logLevel)
    switch lower(logLevel)
        case 'warning'
            set(gh.status_panel_status_text,'String','WW');
            set(gh.status_panel_status_text,'BackgroundColor',[.9 .9 .7]);
        case 'error'
            set(gh.status_panel_status_text,'String','EE');
            set(gh.status_panel_status_text,'BackgroundColor',[.9 .7 .7]);
    end
end

% Push appdata back to main gui
setappdata(mainWindow,'control',ad.control);

% Update status window
trEPRguiUpdateStatusWindow(ad.control.status);

status = 0;

end
