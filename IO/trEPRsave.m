function varargout = trEPRsave(filename,struct)
% TREPRSAVE Save data from the trEPR toolbox as ZIP-compressed XML files
%
% Usage
%   trEPRsave(filename,struct)
%   [status] = trEPRsave(filename,struct)
%   [status,exception] = trEPRsave(filename,struct)
%
%   filename  - string
%               name of a valid filename
%   data      - struct
%               structure containing data and additional fields
%
%   status    - cell array
%               empty if there are no warnings
%   exception - object
%               empty if there are no exceptions
%
% See also TREPRLOAD

% Copyright (c) 2010-12, Till Biskup
% 2012-06-08

% Parse input arguments using the inputParser functionality
parser = inputParser;   % Create an instance of the inputParser class.
parser.FunctionName = mfilename; % Function name included in error messages
parser.KeepUnmatched = true; % Enable errors on unmatched arguments
parser.StructExpand = true; % Enable passing arguments in a structure
parser.addRequired('filename', @ischar);
parser.addRequired('struct', @isstruct);
parser.parse(filename,struct);

[status,exception] = commonSave(filename,struct,'extension','.tez');

% Assign output parameters
switch nargout
    case 1
        varargout{1} = status;
    case 2
        varargout{1} = status;
        varargout{2} = exception;
    otherwise
        % Do nothing (and _not_ loop!)
end

end
