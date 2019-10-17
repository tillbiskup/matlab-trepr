function h = plot2d(C,varargin)
% PLOT2D Plot 2D data in various ways specified by user.
%
% Usage
%   plot2d(C)
%   plot2d(x,y,C)
%   plot2d(x,y,C,options)
%   h = plot2d(...)
%
%   C          - matrix
%                Actual data to plot
%
%   x          - vector
%                x axis values
%
%   y          - vector
%                y axis values
%
%   options    - struct (OPTIONAL)
%                Structure containing fields for the optional parameters
%
% See also IMAGE, IMAGESC, CONTOUR, CONTOURF

% Copyright (c) 2014, Till Biskup
% 2014-03-01

% Assign output parameter
if nargout
    h = [];
end

% Parse input arguments using the inputParser functionality
p = inputParser;            % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Include function name in error messages
p.KeepUnmatched = true;     % Enable errors on unmatched arguments
p.StructExpand = true;      % Enable passing arguments in a structure
% Add required input arguments
p.addRequired('C', @isnumeric);
% Add optional parameters
p.addOptional('x', @isnumeric);
p.addOptional('y', @isnumeric);
% Add optional parameters with default values
%p.addParameter('yTick',false,@islogical);
% Parse input arguments
p.parse(C,varargin{:});

% Handle x,y as (OPTIONAL) first two parameters
if isnumeric(p.Results.x)
    xvalues = p.Results.C;
    C = p.Results.x;
else
    xvalues = 1:size(C,2);
end

if isnumeric(p.Results.y)
    yvalues = p.Results.x;
    C = p.Results.y;
else
    yvalues = 1:size(C,1);
end

% Actual plotting
hh = imagesc(xvalues,yvalues,C);
set(gca,'YDir','normal');

if nargout
    h = hh;
end

end
