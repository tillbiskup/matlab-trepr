function status = trEPRadd2status(statusmessage,varargin)
% TREPRADD2STATUS Helper function adding a status message to the status
% cell array of the appdata of the trEPR GUI
%
% Usage:
%   trEPRadd2status(message)
%   status = trEPRadd2status(message)
%   status = trEPRadd2status(message,level)
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
% TREPRADD2STATUS is deprecated and will be removed in a future release.
% Use TREPRMSG instead. 
%
% See also TREPRMSG

% Copyright (c) 2012, Till Biskup
% 2012-06-26

% Display warning for use of deprecated function
warning(['The function ' mfilename ' is deprecated and will be removed '...
    'in a future version. Use ' 'trEPRmsg' ' instead.'],'trEPRdeprecated');

% Call new function
status = trEPRmsg(statusmessage,varargin);

end
