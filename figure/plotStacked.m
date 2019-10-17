function h = plotStacked(x,y,varargin)
% PLOTSTACKED Plot several 1D data traces (e.g., slices of 2D data) on top
% of each other, trying to "compress" the traces as much as possible and
% using the default Matlab "ColorOrder" and "LineStyleOrder".
%
% Usage:
%   plotStacked(x,y);
%   plotStacked(x,y,'percentage',<scalar>);
%   plotStacked(x,y,'yTicks',true);
%   plotStacked(x,y,options);
%   h = plotStacked(...);
%
%   x          - vector
%                x axis values
%
%   y          - matrix
%                1D data traces
%
%   percentage - scalar (OPTIONAL)
%                Additional spacing between traces as fraction of total
%                plot height.
%                Default: 10
%
%   yTick      - boolean (OPTIONAL)
%                Whether to plot y axis ticks
%                Default: false
%
%   options    - struct (OPTIONAL)
%                Structure containing fields for the optional parameters
%
%   h          - handle
%                Handle of plot window
%                
% Please note that you can pass optional parameters as a structure with the
% appropriate fields as well. Field names (as well as the names of the
% optional parameters) are case insensitive.
%
% PLOTSTACKED tries to "compress" the 1D traces as much as possible. If the
% optional parameter "percentage" is not given, ten percent of the overall
% "height" of the stacked traces when plotted directly on top of each other
% is added as an additional spacing between the traces.
%
% Current limitation: All traces need to have the same length and share a
% common x axis (first argument).
%
% See also PLOT

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
p.addRequired('x', @(arg)isvector(arg) && ~isscalar(arg));
p.addRequired('y', @(arg)ismatrix(arg) && ~isscalar(arg) ...
    && any(eq(length(x),size(y))));
% Add optional parameters with default values
p.addParameter('percentage',10,@isscalar);
p.addParameter('yTick',false,@islogical);
% Parse input arguments
p.parse(x,y,varargin{:});

% Get number of 1D traces
dimY = size(y);
no1Dtraces = dimY(dimY~=length(x));

% Ensure that x is a column vector
x = reshape(x,[],1);

% Ensure that traces are stored in columns
if size(y,1) ~= length(x)
    y = y';
end

% Get deltas in y direction
deltas = abs(min(y(:,2:end)-y(:,1:end-1)));

% Calculate a proper difference between each trace
% Therefore, calculate the overall space used and take a percentage of this
additionalDelta = (abs(min(y(:,1))) + max(y(:,end)) + sum(deltas)) * ...
    p.Results.percentage/100;

% Add deltas and additionalDelta to traces
for delta = 1:length(deltas)
    y(:,delta+1) = ...
        y(:,delta+1)+sum(deltas(1:delta)) + delta*additionalDelta;
end

% Quick and dirty multiplot
hh = plot(repmat(x,1,no1Dtraces),y);

if ~p.Results.yTick
    set(gca,'YTick',[]);
end

if nargout
    h = hh;
end

end
