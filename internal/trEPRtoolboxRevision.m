% TREPRTOOLBOXREVISION Return trEPR toolbox revision number and date
%
% Usage
%   trEPRtoolboxRevision
%   [revision] = trEPRtoolboxRevision;
%   [revision,date] = trEPRtoolboxRevision;
%
%   revision - string
%              version number of the trEPR toolbox
%   date     - string
%              date of the trEPR toolbox
%
% See also TREPRINFO.

% (c) 2007-11, Till Biskup
% 2011-11-01

function [ varargout ] = trEPRtoolboxRevision
% This is the place to centrally manage the revision number and date.
%
% THIS VALUES SHOULD ONLY BE CHANGED BY THE OFFICIAL MAINTAINER OF THE
% TOOLBOX!
%
% If you have questions, call the trEPRinfo routine at the command prompt
% and contact the maintainer via the email address given there.

trEPRtoolboxRevisionNumber = '0.3.0beta';
trEPRtoolboxRevisionDate = '2011-11-01';

switch nargout
    case 1
        % in case the function is called with one output parameter
        varargout{1} = trEPRtoolboxRevisionNumber;
    case 2
        % in case the function is called with two output parameters
        varargout{1} = trEPRtoolboxRevisionNumber;
        varargout{2} = trEPRtoolboxRevisionDate;
    otherwise
        % in case the function is called without output parameters
        fprintf('%s %s\n',trEPRtoolboxRevisionNumber,trEPRtoolboxRevisionDate)
end

end