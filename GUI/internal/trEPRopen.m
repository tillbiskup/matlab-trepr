function [status,warnings] = trEPRopen(filename, varargin)
% TREPROPEN Open file and display in GUI. Open trEPRgui main window if
% necessary.
%
% Usage
%   trEPRopen(filename)
%   status = trEPRopen(filename)
%
%   filename - string
%              name of a valid filename
%
%   status   - scalar
%              Return value for the exit status:
%               0: command successfully performed
%              -1: Invalid filename
%              -2: some other problems
%
%  warnings  - cell array
%              Contains warnings/error messages if any, otherwise empty

% (c) 2013, Till Biskup
% 2013-04-02

status = 0;
warnings = cell(0);

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('filename', @(x)ischar(x));
p.parse(filename,varargin{:});

% If file does not exist, return
if ~exist(filename,'file')
    status = -1;
    warnings{end+1} = sprintf('File %s does not exist.',filename);
    if nargout < 2
        disp(warnings{end});
    end
    return;
end

% Try to find out whether filename is a fully qualified filename
[path,~,~] = fileparts(filename);
if isempty(path)
    filename = fullfile(pwd,filename);
end

% If FileName is not a cell string, convert it into a cell string
if ~isa(filename,'cell')
    filename = cellstr(filename);
    %             tmp = FileName;
    %             FileName = cell(1);
    %             FileName{1} = tmp;
    %             clear tmp;
end

% Open trEPRgui
h = trEPRgui;

PWD = pwd;
try
    cd(fullfile(trEPRinfo('dir'),'GUI','private'));
    cmdLoad(h,filename);
    cmdShow(h,cell(0));
    cd(PWD);
catch exception
    cd(PWD);
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