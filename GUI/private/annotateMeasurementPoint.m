function [handle,varargout] = annotateMeasurementPoint(coordinates,varargin)
% ANNOTATEMEASUREMENTPOINT Highlight point in current axis
%
% COORDINATES - coordinates of point to highlight in axis units (not
% points)

% TODO
% - Make whole thing much more configurable
% - Add different types of annotation
%   * Possibly even annotation types that change direction depending on
%     position within the axis

% deltaX and deltaY in pixels
deltaXpx = 4;
deltaYpx = 6;

% Get limits and position of current axis
xLim = get(gca,'XLim');
yLim = get(gca,'YLim');
axisPosition = get(gca,'Position');

% Convert deltaX and deltaY from pixels in axis units
deltax = (xLim(2)-xLim(1))/axisPosition(3)*deltaXpx;
deltay = (yLim(2)-yLim(1))/axisPosition(4)*deltaYpx;

% Set xdata and ydata for patch
xdata = [coordinates(1)-deltax coordinates(1)+deltax ...
    coordinates(1)-deltax coordinates(1)+deltax];
ydata = [coordinates(2)-deltay coordinates(2)-deltay ...
    coordinates(2)+deltay coordinates(2)+deltay];
color = 'k';

% Plot the actual annotation
try
    handle = patch(xdata,ydata,color);
catch exception
    handle = -1;
    varargout{1} = exception;
end

end
