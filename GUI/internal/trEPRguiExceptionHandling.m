function trEPRguiExceptionHandling(exception)
% GUIEXCEPTIONHANDLING Helper function for GUI handling exception in
% try-catch construct.
%
% Usage:
%   trEPRguiExceptionHandling(exception)
%
%   exception - MException object
%               exception catched by "catch" statement
%
% Example:
%   try
%       % some code...
%   catch exception
%       trEPRguiExceptionHandling(exception);
%   end
%
% See also: trEPRgui_bugreportwindow, trEPRmsg, MException

% Copyright (c) 2014, Till Biskup
% 2014-07-25

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
