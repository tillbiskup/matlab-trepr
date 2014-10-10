function [status,bugReport] = trEPRbugReportHelper(exception)
% TREPRBUGREPORTHELPER Function to help filing usable bug reports.
% 
% Usage:
%    trEPRbugReportHelper(exception);
%    status = trEPRbugReportHelper(exception);
%
% Parameters:
%    exception - object of class MException
%    status    - number (0 = OK, -1 = failed)
%    bugReport - cell array of strings containing the bug report

% Copyright (c) 2011-14, Till Biskup
% 2014-10-10

% Set name and version of Toolbox (makes it easier to reuse this script
% later on) 
tbname = 'trEPR toolbox';
tbversion = trEPRinfo('version');

% If we got no input show message and exit
if ~nargin
    disp('Sorry, but no exception object specified.');
    disp('If you want to catch the last exception from the command line,');
    disp('use "exception = MException.last"');
    % Return with status -1
    status = -1;
    bugReport = cell(0);
    return;
end

% Serious compatibility problems with earlier MATLAB(TM) versions that had
% no MException object. Therefore, check Matlab(TM) version.
v = ver('Matlab');
tk = regexp(v.Version,'(\d+)\.(\d+)','tokens');
if (str2double(tk{1}{1}) < 7) || ...
        ((str2double(tk{1}{1}) == 7) && (str2double(tk{1}{2}) < 5))
    disp('Sorry, but your version of Matlab(TM) has no MException object yet.');
    disp(['Your version of Matlab(TM) is ' version]);
    disp('There is currently no way to use the bug report helper...');
    status = -1;
    bugReport = cell(0);
    return;
end

% First of all, get current date and time
dateTime = datestr(clock);

% Get exception in nicely readable form - MATLAB(TM) helps here a lot
msgString = getReport(exception, 'extended', 'hyperlinks', 'off');

% Try to get status message from toolbox GUI
mainGuiWindow = trEPRguiGetWindowHandle();
if ishandle(mainGuiWindow)
    ad = getappdata(mainGuiWindow);
    % Check for availability of necessary fields in appdata
    if (isfield(ad,'control') ~= 0) && (isfield(ad.control,'status') ~= 0)
        tbStatusMessages = ad.control.status.messages;
    end
else
    tbStatusMessages = {...
         'There seems to be no trEPR GUI main window...',...
        };
end

bugReport = cell(0);
bugReport{end+1} = sprintf('General information:');
bugReport{end+1} = sprintf('--------------------');
bugReport{end+1} = ' ';
bugReport{end+1} = sprintf('Date:               %s',dateTime);
bugReport{end+1} = sprintf('Toolbox:            %s',tbname);
bugReport{end+1} = sprintf('Toolbox Release:    %s',tbversion);
bugReport{end+1} = sprintf('Platform:           %s',platform);
bugReport{end+1} = sprintf('MATLAB(TM) version: %s',version);
bugReport{end+1} = ' ';
bugReport{end+1} = sprintf('Exception caught:');
bugReport{end+1} = sprintf('-----------------');
bugReport{end+1} = ' ';
bugReport{end+1} = sprintf(msgString);
bugReport{end+1} = ' ';
bugReport{end+1} = sprintf('Status messages from GUI:');
bugReport{end+1} = sprintf('-------------------------');
bugReport{end+1} = ' ';
bugReport = [ bugReport tbStatusMessages ];

status = 0;

end
