function outtype = markertypeConvert(type)
% MARKERTYPECONVERT Convert marker types between symbol and descriptive
% words.
%
% Usage:
%   type = markertypeConvert(type)
%
%   type - string
%          symbol (understood by Matlab(r) as proper marker type) or
%          descriptive word
%
% Descriptive words are handled case insensitive for convenience.
%
% See also: line, linestyleConvert

% Copyright (c) 2014, Till Biskup
% 2014-08-07

% If called without parameter, display help
if ~nargin && ~nargout
    help colorstr2rgb
    return;
end

outtype = '';

% Parse input arguments using the inputParser functionality
try
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('type',@(x)ischar(x));
    p.parse(type);
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

types = markerTypes;

if ~any(strcmpi(type,types(:,1))) && ~any(strcmpi(type,types(:,2)))
    trEPRmsg(['Unknown marker type "' type '"'],'warning')
    return;
end

if any(strcmpi(type,types(:,1)))
    outtype = types{strcmpi(type,types(:,1)),2};
end

if any(strcmpi(type,types(:,2)))
    outtype = types{strcmpi(type,types(:,2)),1};
end

end