% Find common string within two strings, starting from the beginning of the
% string with the lookup.
%
% INPUT ARGUMENTS
%   strings   - cell array of the strings to compare
%   minLength - minimum length of the common string
%
% OUTPUT ARGUMENTS
%   match     - common string, empty string if nothing found

function match = commonString(strings,varargin)
% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('strings', @iscell);
p.addOptional('minLength','1',@isscalar);
%p.addParamValue('minLength',1,@isscalar);
p.parse(strings,varargin{:});

% Get length of strings
for k=1:length(strings)
    stringLengths(k) = length(strings{k});
end

for k=0:min(stringLengths)-p.Results.minLength
    if length(strmatch(strings{1}(1:end-k),strings)) == length(strings)
        match = strings{1}(1:end-k);
        break;
    end
end

if ~exist('match','var')
    match = '';
end
    