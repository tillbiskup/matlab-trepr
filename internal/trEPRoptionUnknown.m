function trEPRguiOptionUnknown(option,varargin)
% GUIOPTIONUNKNOWN Helper function handling the situation that a given
% option is not available, mostly in a switch-case statement
%
% Usage:
%   trEPRguiOptionUnknown(option)
%   trEPRguiOptionUnknown(option,optionName)
%
%   option     - string
%                option that is not understood
%
%   optionName - string (OPTIONAL)
%                name of the option (defaults to "option")
%
% Example:
%   switch option
%       case 'something'
%           % some code...
%       otherwise
%           trEPRguiOptionUnknown(option);
%   end
%
% See also: trEPRexceptionHandling

% Copyright (c) 2014, Till Biskup
% 2014-07-25

% Parse input arguments using the inputParser functionality
p = inputParser;            % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Include function name in error messages
p.KeepUnmatched = true;     % Enable errors on unmatched arguments
p.StructExpand = true;      % Enable passing arguments in a structure

p.addRequired('option',@(x)ischar(x));
p.addOptional('optionName','option',@(x)ischar(x));
p.parse(option,varargin{:});

stack = dbstack;
trEPRmsg(...
    [stack(2).name ' : unknown ' p.Results.optionName ' "' option '"'],...
    'warning');

end
