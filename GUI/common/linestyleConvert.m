function outstyle = linestyleConvert(style)
% LINESTYLECONVERT Convert line styles between symbol and descriptive
% words.
%
% Usage:
%   style = linestyleConvert(style)
%
%   style - string
%           symbol (understood by Matlab(r) as proper line style) or
%           descriptive word
%
% Descriptive words are handled case insensitive for convenience.
%
% See also: line, markertypeConvert

% Copyright (c) 2014, Till Biskup
% 2014-08-07

% If called without parameter, display help
if ~nargin && ~nargout
    help colorstr2rgb
    return;
end

outstyle = '';

% Parse input arguments using the inputParser functionality
try
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('style',@(x)ischar(x));
    p.parse(style);
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

styles = lineStyles;

if ~any(strcmpi(style,styles(:,1))) && ~any(strcmpi(style,styles(:,2)))
    trEPRmsg(['Unknown style "' style '"'],'warning')
    return;
end

if any(strcmpi(style,styles(:,1)))
    outstyle = styles{strcmpi(style,styles(:,1)),2};
end

if any(strcmpi(style,styles(:,2)))
    outstyle = styles{strcmpi(style,styles(:,2)),1};
end

end