function trEPRplot(varargin)
% TREPRPLOT General plotting routine for trEPR datasets
%
% Usage
%   trEPRplot(dataset)
%   trEPRplot(axisHandle,dataset)
%   trEPRplot(dataset,parameters)
%   trEPRplot(axishandle,dataset,parameters)
%   trEPRplot(dataset,paramName,paramValue,...)
%
%   dataset    - struct
%                trEPR dataset according to dataset specifications
%
%   axisHandle - handle (OPTIONAL)
%                handle of the axis to plot to
%
%   parameters - struct
%                structure of parameters (key-value pairs)
%
% Please note that parameters can be provided both as struct containing
% respective fields or as key-value pairs directly in the function call.
% (Hint: Matlab(r) input parser is used to parse parameters.)

% Copyright (c) 2014-15, Till Biskup
% 2015-10-17

% PLEASE NOTE: The additional parameters are defined together with their
%              default values in the subfunction parseAdditionalParameters
%              below.

% Manual check for input arguments, as first argument is optional
if nargin < 1
    help trEPRplot;
    return;
end

% Check first argument for being axis handle, otherwise create axis handle
if ishghandle(varargin{1})
    if strcmpi(get(varargin{1},'Type'),'axes')
        axisHandle = varargin{1};
    else
        warning('trEPRplot:DatasetProblems',...
        'Problem with handle: not an axis handle...');
    end
    varargin(1) = [];
else
    figure();
    axisHandle = axes();
end

% Speed up Matlab using HG handle() wrapper
% http://undocumentedmatlab.com/blog/performance-accessing-handle-properties
axisHandle = handle(axisHandle);

% Get dataset
if isstruct(varargin{1}) && isfield(varargin{1},'format') ...
        && isfield(varargin{1}.format,'name') ...
        && strcmpi(varargin{1}.format.name,'trEPR toolbox')
    dataset = varargin{1};
else
    warning('trEPRplot:DatasetProblems',...
        'Problem with dataset...');
    return;
end

parameters = parseAdditionalParameters(varargin);

[x,y] = getXY(dataset);

% ATTENTION: Order of these functions could matter
[dataset,x,y] = applyDisplacement(dataset,parameters,x,y);
dataset       = applyNormalisation(dataset,parameters);
dataset       = applyFilter(dataset,parameters);
[dataset,x,y] = applyScaling(dataset,parameters,x,y);

parameters = getLimits(dataset,parameters,x,y);

switch lower(parameters.dimension)
    case '1d'
        switch lower(parameters.direction)
            case 'x'
                if parameters.stdev && isfield(dataset,'avg') ...
                        && strcmpi(dataset.avg.dimension,'y')
                    hPlot = errorbar(x,dataset.data(parameters.position,:),...
                        dataset.avg.stdev);
                else
                    hPlot = plot(x,dataset.data(parameters.position,:));
                end
                axisHandle.XLim = parameters.xLimits;
                axisHandle.YLim = [ ...
                    parameters.zLimits(1)-0.02*diff(parameters.zLimits) ...
                    parameters.zLimits(2)+0.02*diff(parameters.zLimits) ];
                % Axis labels
                xlabel(axisHandle,axisLabelString(...
                    parameters.xMeasure,parameters.xUnit));
                if parameters.showYaxis
                    ylabel(axisHandle,axisLabelString(...
                        parameters.zMeasure,parameters.zUnit));
                end
            case 'y'
                if parameters.stdev && isfield(dataset,'avg') ...
                        && strcmpi(dataset.avg.dimension,'x')
                    hPlot = errorbar(y,dataset.data(:,parameters.position),...
                        dataset.avg.stdev);
                else
                    hPlot = plot(y,dataset.data(:,parameters.position));
                end
                axisHandle.XLim = parameters.yLimits;
                axisHandle.YLim = [ ...
                    parameters.zLimits(1)-0.02*diff(parameters.zLimits) ...
                    parameters.zLimits(2)+0.02*diff(parameters.zLimits) ];
                % Axis labels
                xlabel(axisHandle,axisLabelString(...
                    parameters.yMeasure,parameters.yUnit));
                if parameters.showYaxis
                    ylabel(axisHandle,axisLabelString(...
                        parameters.zMeasure,parameters.zUnit));
                end
        end
        % Handle plot appearance
        set(hPlot,...
            'Color',parameters.color,...
            'LineStyle',parameters.lineStyle,...
            'Marker',parameters.marker,...
            'MarkerEdgeColor',parameters.markerEdgeColor,...
            'MarkerFaceColor',parameters.markerFaceColor,...
            'MarkerSize',parameters.markerSize,...
            'LineWidth',parameters.lineWidth);
        % Handle zero line plotting
        if parameters.zeroLine
            % Do we have a zero line already?
            hZeroLine = findobj(axisHandle,'-depth',1,'Tag','zeroLine');
            % If so, delete it
            if ~isempty(hZeroLine)
                delete(hZeroLine);
            end
            % Plot zero line
            line(axisHandle.XLim,[0 0],...
                'Color',parameters.zeroLineColor,...
                'LineWidth',parameters.zeroLineWidth,...
                'LineStyle',parameters.zeroLineStyle,...
                'Tag','zeroLine',...
                'Parent',axisHandle);
        end
    case '2d'
        % Plot
        [data,y] = interpMissing(dataset.data,y);
        imagesc(x,y,data,parameters.zLimits);
        axisHandle.YDir = 'normal';
        axisHandle.XLim = parameters.xLimits;
        axisHandle.YLim = parameters.yLimits;
        % Axis labels
        xlabel(axisHandle,...
            axisLabelString(parameters.xMeasure,parameters.xUnit));
        if parameters.showYaxis
            ylabel(axisHandle,...
                axisLabelString(parameters.yMeasure,parameters.yUnit));
        end
    case '3d'
        trEPRmsg('3D plots not supported yet','warning');
end

end


function parameters = parseAdditionalParameters(inputArguments)

parameters = struct();

% Get dataset from first inputArgument
dataset = inputArguments{1};

% Set defaults used if no additional parameters are given
parameters.dimension              = '2D';
parameters.direction              = 'y';
parameters.position               = 1;
parameters.xMeasure               = dataset.axes.data(1).measure;
parameters.yMeasure               = dataset.axes.data(2).measure;
parameters.zMeasure               = dataset.axes.data(3).measure;
parameters.xUnit                  = dataset.axes.data(1).unit;
parameters.yUnit                  = dataset.axes.data(2).unit;
parameters.zUnit                  = dataset.axes.data(3).unit;
parameters.xLimits                = [];
parameters.yLimits                = [];
parameters.zLimits                = [];
parameters.displacement           = [0 0 0];
parameters.scaling                = [1 1 1];
parameters.normalisation          = false;
parameters.normalisationDimension = '1D';
parameters.normalisationType      = 'pk-pk';
parameters.xFilterFunction        = '';
parameters.xFilterWidth           = 1;
parameters.yFilterFunction        = '';
parameters.yFilterWidth           = 1;
parameters.showYaxis              = true;
parameters.symmetric              = true;
parameters.stdev                  = false;
parameters.zeroLine               = true;
parameters.zeroLineColor          = [0.5 0.5 0.5];
parameters.zeroLineStyle          = '--';
parameters.zeroLineWidth          = 1;
parameters.color                  = [0 0 0];
parameters.lineStyle              = '-';
parameters.lineWidth              = 1;
parameters.marker                 = 'none';
parameters.markerEdgeColor        = 'auto';
parameters.markerFaceColor        = 'none';
parameters.markerSize             = 6;

% Parse additional parameters if available, using Matlab(r) inputParser
if length(inputArguments) > 1
    try
        % Parse input arguments using the inputParser functionality
        p = inputParser;            % Create instance of the inputParser class.
        p.FunctionName = mfilename; % Function name included in error messages
        p.KeepUnmatched = true;     % Enable errors on unmatched arguments.
        p.StructExpand = true;      % Enable passing arguments in a structure.
        p.addParameter('dimension',parameters.dimension,...
            @(x)any(strcmpi(x,{'1d','2d','3d'})));
        p.addParameter('direction',parameters.direction,...
            @(x)any(strcmpi(x,{'x','y'})));
        p.addParameter('position',parameters.position,@(x)isscalar(x));
        p.addParameter('xMeasure',parameters.xMeasure,@(x)ischar(x));
        p.addParameter('yMeasure',parameters.yMeasure,@(x)ischar(x));
        p.addParameter('zMeasure',parameters.zMeasure,@(x)ischar(x));
        p.addParameter('xUnit',parameters.xUnit,@(x)ischar(x));
        p.addParameter('yUnit',parameters.yUnit,@(x)ischar(x));
        p.addParameter('zUnit',parameters.zUnit,@(x)ischar(x));
        p.addParameter('xLimits',parameters.xLimits,...
            @(x)isvector(x) && (isempty(x) || length(x) == 2));
        p.addParameter('yLimits',parameters.yLimits,...
            @(x)isvector(x) && (isempty(x) || length(x) == 2));
        p.addParameter('zLimits',parameters.zLimits,...
            @(x)isvector(x) && (isempty(x) || length(x) == 2));
        p.addParameter('displacement',parameters.displacement,...
            @(x)isvector(x) && (isempty(x) || length(x) == 3));
        p.addParameter('scaling',parameters.scaling,...
            @(x)isvector(x) && (isempty(x) || length(x) == 3));
        p.addParameter('normalisation',parameters.normalisation,...
            @(x)islogical(x));
        p.addParameter('normalisationDimension',...
            parameters.normalisationDimension,@(x)ischar(x));
        p.addParameter('normalisationType',...
            parameters.normalisationType,@(x)ischar(x));
        p.addParameter('xFilterFunction',parameters.xFilterFunction,...
            @(x)ischar(x));
        p.addParameter('xFilterWidth',parameters.xFilterWidth,...
            @(x)isscalar(x));
        p.addParameter('yFilterFunction',parameters.yFilterFunction,...
            @(x)ischar(x));
        p.addParameter('yFilterWidth',parameters.yFilterWidth,...
            @(x)isscalar(x));
        p.addParameter('showYaxis',parameters.showYaxis,@(x)islogical(x));
        p.addParameter('symmetric',parameters.symmetric,@(x)islogical(x));
        p.addParameter('stdev',parameters.stdev,@(x)islogical(x));
        p.addParameter('zeroLine',parameters.zeroLine,@(x)islogical(x));
        p.addParameter('zeroLineColor',parameters.zeroLineColor,...
            @(x)isvector(x) && length(x) == 3);
        p.addParameter('zeroLineStyle',parameters.zeroLineStyle,...
            @(x)ischar(x));
        p.addParameter('zeroLineWidth',parameters.zeroLineWidth,...
            @(x)isscalar(x));
        p.addParameter('color',parameters.color,...
            @(x)isvector(x) && length(x) == 3);
        p.addParameter('lineStyle',parameters.lineStyle,...
            @(x)ischar(x));
        p.addParameter('lineWidth',parameters.lineWidth,...
            @(x)isscalar(x));
        p.addParameter('marker',parameters.marker,@(x)ischar(x));
        p.addParameter('markerEdgeColor',parameters.markerEdgeColor,...
            @(x)ischar(x));
        p.addParameter('markerFaceColor',parameters.markerFaceColor,...
            @(x)ischar(x));
        p.addParameter('markerSize',parameters.markerSize,...
            @(x)isscalar(x));

        p.parse(inputArguments{2:end});
        
        parameters = p.Results;
    catch exception
        trEPRexceptionHandling(exception);
    end
end

end

function [x,y] = getXY(dataset)

x = dataset.axes.data(1).values;
y = dataset.axes.data(2).values;

end

function [dataset,x,y] = applyDisplacement(dataset,parameters,x,y)

x = x + parameters.displacement(1);
y = y + parameters.displacement(2);
dataset.data = dataset.data + parameters.displacement(3);

end

function dataset = applyNormalisation(dataset,parameters)

if ~parameters.normalisation
    return;
end

if strcmpi(parameters.normalisationDimension,'1D') && ...
        strcmpi(parameters.dimension,'1D')
    switch parameters.direction
        case 'x'
            data = dataset.data(parameters.position,:);
        case 'y'
            data = dataset.data(:,parameters.position);
    end
else
    data = dataset.data;
end

switch lower(parameters.normalisationType)
    case 'pk2pk'
        normalisationFactor = 1/(max(max(data))-min(min(data)));
    case 'area'
        normalisationFactor = 1/abs(sum(sum(data)));
    case 'max'
        normalisationFactor = 1/max(max(data));
    case 'min'
        normalisationFactor = 1/abs(min(min(data)));
end

dataset.data = dataset.data .* normalisationFactor;

end

function dataset = applyFilter(dataset,parameters)

if ~isempty(parameters.xFilterFunction) && parameters.xFilterWidth > 1
    filterFun = str2func(['trEPRfilter_' parameters.xFilterFunction]);
    for rows = 1:size(dataset.data,1)
        dataset.data(rows,:) = filterFun(dataset.data(rows,:),...
            parameters.xFilterWidth);
    end
end

if ~isempty(parameters.yFilterFunction) && parameters.yFilterWidth > 1
    filterFun = str2func(['trEPRfilter_' parameters.yFilterFunction]);
    for cols = 1:size(dataset.data,2)
        dataset.data(cols,:) = filterFun(dataset.data(cols,:),...
            parameters.yFilterWidth);
    end
end

end

function [dataset,x,y] = applyScaling(dataset,parameters,x,y)

% Saling should be symmetric around the centre in x and y dimension
x = (x-x(1)-(max(x)-min(x))/2).*parameters.scaling(1) ...
    + (max(x)-min(x))/2 + x(1);
y = (y-y(1)-(max(y)-min(y))/2).*parameters.scaling(2) ...
    + (max(y)-min(y))/2 + y(1);
dataset.data = dataset.data .* parameters.scaling(3);

end

function parameters = getLimits(dataset,parameters,x,y)

if isempty(parameters.xLimits)
    parameters.xLimits = [x(1) x(end)];
end

if isempty(parameters.yLimits)
    parameters.yLimits = [y(1) y(end)];
end

if isempty(parameters.zLimits)
    if parameters.symmetric
        parameters.zLimits = [-max(abs([min(min(dataset.data)) ...
            max(max(dataset.data))])) ...
            max(abs([min(min(dataset.data)) ...
            max(max(dataset.data))]))];
    else
        parameters.zLimits = ...
            [min(min(dataset.data)) max(max(dataset.data))];
    end
end
% For very special cases where limits are identical
% (example: user subtracted dataset from itself)
% Reason: clims for imagesc must be monotonically increasing
if min(parameters.zLimits) == max(parameters.zLimits)
    parameters.zLimits(1) = parameters.zLimits(1)-1e-9;
    parameters.zLimits(2) = parameters.zLimits(2)+1e-9;
end

end

function axisLabel = axisLabelString(measure,unit)

if isempty(measure)
    axisLabel = '';
    return;
end

if isempty(unit) || all(isspace(unit))
    axisLabel = measure;
    return;
end

axisLabel = sprintf('{\\it %s} / %s',measure,unit); 

end


function TF = isEquidistant(vector)

TF = true;

if length(vector) < 2
    return;
end

diffs = vector(2:end)-vector(1:end-1);
TF = all(diffs==diffs(1));

end

function [interpData,interpAxis] = interpMissing(data,axis)

interpData = data;
interpAxis = axis;

if isEquidistant(axis)
    return;
end

diffs = axis(2:end)-axis(1:end-1);

% Assume that the axis is generally equidistant, but has holes
holes = find(~eq(diffs,diffs(1)));

% ATTENTION: Matlab seems somewhat stupid and makes rounding errors that
% end up with inequalities that are not there... therefore, we have to
% check carefully for the difference between two traces.
for hole = length(holes):-1:1
    % As noMissingTraces will be used for indexing, it needs to be
    % integer-like
    noMissingTraces = ...
        round(((axis(holes(hole)+1)-axis(holes(hole)))/diffs(1))-1);
    if noMissingTraces > 0
        interpData = [...
            interpData(1:holes(hole),:) ; ...
            zeros(noMissingTraces,size(data,2)) ; ...
            interpData(holes(hole)+1:end,:) ...
            ];
    end
end

end
