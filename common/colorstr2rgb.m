function rgb = colorstr2rgb(color)
% COLORSTR2rgb Convert color string into RGB vector.
%
% Usage:
%   rgb = colorstr2rgb(colorstring)
%
%   colorstring - string
%                 Color string
%                 One of: r,g,b,c,m,y,k
%
%   rgb         - 1x3 vector
%                 Color vector (RGB)
%                 Values for each element are between 0 and 1
%
% NOTE: If colorstring is already an RGB vector, it will silently be
% returned directly. Therefore, you can savely apply colorstr2rgb to any
% colour specification Matlab(r) understands to get an RGB vector.

% Copyright (c) 2014, Till Biskup
% 2014-08-06

% If called without parameter, display help
if ~nargin && ~nargout
    help colorstr2rgb
    return;
end

rgb = [];

% Parse input arguments using the inputParser functionality
try
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('color',@(x)ischar(x) || (isvector(x) && length(x) == 3));
    p.parse(color);
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

if isvector(color) && length(color) == 3
    rgb = color;
    return;
end

colorStrings = {...
    'b',[0 0 1]; ...
    'g',[0 1 0]; ...
    'r',[1 0 0]; ...
    'c',[0 1 1]; ...
    'm',[1 0 1]; ...
    'y',[1 1 0]; ...
    'k',[0 0 0]; ...
    'w',[1 1 1]; ...
    };

if ischar(color)
    rgb = colorStrings{strcmpi(color,colorStrings(:,1)),2};
end
        
end
