function outString = commonCamelCase(inStrings)
% COMMONCAMELCASE Concatenate strings using camel case.
%
% Usage:
%   outString = commonCamelCase(inStrings)
%
%   inStrings - cell array (of strings)
%               two or more strings to be concatenated
%
%   outString - string
%               camelCased concatenated string

% Copyright (c) 2015, Till Biskup
% Copyright (c) 2015, Deborah Meyer
% 2015-03-06

% Assign output parameter
outString = '';

% Parse input arguments using the inputParser functionality
p = inputParser;            % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true;     % Enable errors on unmatched arguments
p.StructExpand = true;      % Enable passing arguments in a structure
% Add optional parameters, with default values
p.addRequired('inStrings',@(x)(iscell(x) && length(x)>1));
% Parse input arguments
p.parse(inStrings);

% Check if all elements of inStrings are strings
if ~all(cellfun(@ischar,inStrings))
    return;
end

for inString = 1:length(inStrings)-1
    if isstrprop(inStrings{inString}(end),'lower')
        inStrings{inString+1}(1) = upper(inStrings{inString+1}(1));
    else
        inStrings{inString+1}(1) = lower(inStrings{inString+1}(1));
    end
end

outString = [inStrings{:}];

end