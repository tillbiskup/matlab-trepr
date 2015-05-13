function trEPRplotArrows(axisHandle,varargin)
% TREPRPLOTARROWS Add arrows representing A and E for polarissation to
% plot.
%
% Usage
%   trEPRplotArrows(axisHandle)
%
%   axisHandle - handle
%                Handle of axis to plot arrows to
%

% Copyright (c) 2015, Till Biskup
% 2015-05-13

% Some settings that should go in configuration or else
arrowLength = 0.15;    % in normalised coordinates
hDisplacement = 0.03; % in normalised coordinates
vDisplacement = 0.05; % in normalised coordinates

axisPosition = get(axisHandle,'Position');
ylimits = get(axisHandle,'YLim');

% Check if we have a horizontal zero line, else return
if prod(ylimits) > 0
    return;
end

% Get position of zero line in normalised coordinates
% NOTE: Normalised coordinates are with respect to figure window, **not**
% with respect to axis.
zeroLinePosition = 1/diff(ylimits)*abs(ylimits(1))...
    +diff([1-sum(axisPosition([2,4])),axisPosition(2)])/2;

% TODO: Get noise level in normalised coordinates

% Normalise coordinates by height of axis
normalisationFactor = axisPosition(4);
arrowLength = arrowLength * normalisationFactor;

% Plot arrows
annotation('arrow',[axisPosition(1)+hDisplacement axisPosition(1)+hDisplacement],[zeroLinePosition+vDisplacement zeroLinePosition+vDisplacement+arrowLength],...
    'HeadStyle','plain','HeadLength',10,'HeadWidth',6);
annotation('textbox',[axisPosition(1)+hDisplacement-0.01 zeroLinePosition+vDisplacement+arrowLength 0.02 0.04],...
    'HorizontalAlignment','center','VerticalAlignment','bottom','EdgeColor','none','String','A');

annotation('arrow',[axisPosition(1)+hDisplacement axisPosition(1)+hDisplacement],[zeroLinePosition-vDisplacement zeroLinePosition-vDisplacement-arrowLength],...
    'HeadStyle','plain','HeadLength',10,'HeadWidth',6);
annotation('textbox',[axisPosition(1)+hDisplacement-0.01 zeroLinePosition-vDisplacement-arrowLength-0.04 0.02 0.04],...
    'HorizontalAlignment','center','VerticalAlignment','top','EdgeColor','none','String','E');
