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

% Copyright (c) 2014, Till Biskup
% 2014-07-23

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
        imagesc(x,y,dataset.data,parameters.zLimits);
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
parameters.xMeasure               = dataset.axes.x.measure;
parameters.yMeasure               = dataset.axes.y.measure;
parameters.zMeasure               = dataset.axes.z.measure;
parameters.xUnit                  = dataset.axes.x.unit;
parameters.yUnit                  = dataset.axes.y.unit;
parameters.zUnit                  = dataset.axes.z.unit;
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
        p.addParamValue('dimension',parameters.dimension,...
            @(x)any(strcmpi(x,{'1d','2d','3d'})));
        p.addParamValue('direction',parameters.direction,...
            @(x)any(strcmpi(x,{'x','y'})));
        p.addParamValue('position',parameters.position,@(x)isscalar(x));
        p.addParamValue('xMeasure',parameters.xMeasure,@(x)ischar(x));
        p.addParamValue('yMeasure',parameters.yMeasure,@(x)ischar(x));
        p.addParamValue('zMeasure',parameters.zMeasure,@(x)ischar(x));
        p.addParamValue('xUnit',parameters.xUnit,@(x)ischar(x));
        p.addParamValue('yUnit',parameters.yUnit,@(x)ischar(x));
        p.addParamValue('zUnit',parameters.zUnit,@(x)ischar(x));
        p.addParamValue('xLimits',parameters.xLimits,...
            @(x)isvector(x) && (isempty(x) || length(x) == 2));
        p.addParamValue('yLimits',parameters.yLimits,...
            @(x)isvector(x) && (isempty(x) || length(x) == 2));
        p.addParamValue('zLimits',parameters.zLimits,...
            @(x)isvector(x) && (isempty(x) || length(x) == 2));
        p.addParamValue('displacement',parameters.displacement,...
            @(x)isvector(x) && (isempty(x) || length(x) == 3));
        p.addParamValue('scaling',parameters.scaling,...
            @(x)isvector(x) && (isempty(x) || length(x) == 3));
        p.addParamValue('normalisation',parameters.normalisation,...
            @(x)islogical(x));
        p.addParamValue('normalisationDimension',...
            parameters.normalisationDimension,@(x)ischar(x));
        p.addParamValue('normalisationType',...
            parameters.normalisationType,@(x)ischar(x));
        p.addParamValue('xFilterFunction',parameters.xFilterFunction,...
            @(x)ischar(x));
        p.addParamValue('xFilterWidth',parameters.xFilterWidth,...
            @(x)isscalar(x));
        p.addParamValue('yFilterFunction',parameters.yFilterFunction,...
            @(x)ischar(x));
        p.addParamValue('yFilterWidth',parameters.yFilterWidth,...
            @(x)isscalar(x));
        p.addParamValue('showYaxis',parameters.showYaxis,@(x)islogical(x));
        p.addParamValue('symmetric',parameters.symmetric,@(x)islogical(x));
        p.addParamValue('stdev',parameters.stdev,@(x)islogical(x));
        p.addParamValue('zeroLine',parameters.zeroLine,@(x)islogical(x));
        p.addParamValue('zeroLineColor',parameters.zeroLineColor,...
            @(x)isvector(x) && length(x) == 3);
        p.addParamValue('zeroLineStyle',parameters.zeroLineStyle,...
            @(x)ischar(x));
        p.addParamValue('zeroLineWidth',parameters.zeroLineWidth,...
            @(x)isscalar(x));
        p.addParamValue('color',parameters.color,...
            @(x)isvector(x) && length(x) == 3);
        p.addParamValue('lineStyle',parameters.lineStyle,...
            @(x)ischar(x));
        p.addParamValue('lineWidth',parameters.lineWidth,...
            @(x)isscalar(x));
        p.addParamValue('marker',parameters.marker,@(x)ischar(x));
        p.addParamValue('markerEdgeColor',parameters.markerEdgeColor,...
            @(x)ischar(x));
        p.addParamValue('markerFaceColor',parameters.markerFaceColor,...
            @(x)ischar(x));
        p.addParamValue('markerSize',parameters.markerSize,...
            @(x)isscalar(x));

        p.parse(inputArguments{2:end});
        
        parameters = p.Results;
    catch exception
        throw(exception)
    end
end

end

function [x,y] = getXY(dataset)

[y,x] = size(dataset.data);
x = linspace(1,x,x);
y = linspace(1,y,y);
if (isfield(dataset,'axes') ...
        && isfield(dataset.axes,'x') ...
        && isfield(dataset.axes.x,'values') ...
        && ~isempty(dataset.axes.x.values))
    x = dataset.axes.x.values;
end
if (isfield(dataset,'axes') ...
        && isfield(dataset.axes,'y') ...
        && isfield(dataset.axes.y,'values') ...
        && ~isempty(dataset.axes.y.values))
    y = dataset.axes.y.values;
end

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
x = (x-(max(x)-min(x))/2).*parameters.scaling(1) + (max(x)-min(x))/2;
y = (y-(max(y)-min(y))/2).*parameters.scaling(2) + (max(y)-min(y))/2;
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
