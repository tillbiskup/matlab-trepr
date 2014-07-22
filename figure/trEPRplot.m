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
% 2014-07-22

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

switch lower(parameters.displayType)
    case '1d'
        switch lower(parameters.direction)
            case 'x'
            case 'y'
        end
    case '2d'
        if parameters.symmetric
            clims = [-max(abs([min(min(dataset.data)) ...
                max(max(dataset.data))])) ...
                max(abs([min(min(dataset.data)) max(max(dataset.data))]))];
        else
            clims = [min(min(dataset.data)) max(max(dataset.data))];
        end
        if ~isempty(parameters.clims)
            clims = parameters.clims;
        end
        % For very special cases where limits are identical
        % (example: user subtracted dataset from itself)
        % Reason: clims must be monotonically increasing
        if min(clims) == max(clims)
            clims(1) = clims(1)-1e-9;
            clims(2) = clims(2)+1e-9;
        end
        imagesc(x,y,dataset.data,clims);
        axisHandle.YDir = 'normal';
        % Plot axis labels
        xlabel(axisHandle,...
            axisLabelString(parameters.xMeasure,parameters.xUnit));
        if parameters.showYaxis
            ylabel(axisHandle,...
                axisLabelString(parameters.yMeasure,parameters.yUnit));
        end
        if ~isempty(parameters.xLimits)
            axisHandle.XLim = parameters.xLimits;
        end
        if ~isempty(parameters.yLimits)
            axisHandle.YLim = parameters.yLimits;
        end
    case '3d'
end

end


function parameters = parseAdditionalParameters(inputArguments)

parameters = struct();

% Get dataset from first inputArgument
dataset = inputArguments{1};

% Set defaults used if no additional parameters are given
parameters.displayType = '2D';
parameters.direction = 'y';
parameters.xMeasure = dataset.axes.x.measure;
parameters.yMeasure = dataset.axes.y.measure;
parameters.zMeasure = dataset.axes.z.measure;
parameters.xUnit = dataset.axes.x.unit;
parameters.yUnit = dataset.axes.y.unit;
parameters.zUnit = dataset.axes.z.unit;
parameters.xLimits = [];
parameters.yLimits = [];
parameters.zLimits = [];
parameters.showYaxis = true;
parameters.symmetric = true;
parameters.clims = [];

% Parse additional parameters if available, using Matlab(r) inputParser
if length(inputArguments) > 1
    try
        % Parse input arguments using the inputParser functionality
        p = inputParser;            % Create instance of the inputParser class.
        p.FunctionName = mfilename; % Function name included in error messages
        p.KeepUnmatched = true;     % Enable errors on unmatched arguments.
        p.StructExpand = true;      % Enable passing arguments in a structure.
        p.addParamValue('displayType',parameters.displayType,...
            @(x)any(strcmpi(x,{'1d','2d','3d'})));
        p.addParamValue('direction',parameters.direction,...
            @(x)any(strcmpi(x,{'x','y'})));
        p.addParamValue('xMeasure',parameters.xMeasure,@(x)ischar(x));
        p.addParamValue('yMeasure',parameters.yMeasure,@(x)ischar(x));
        p.addParamValue('zMeasure',parameters.zMeasure,@(x)ischar(x));
        p.addParamValue('xUnit',parameters.xUnit,@(x)ischar(x));
        p.addParamValue('yUnit',parameters.yUnit,@(x)ischar(x));
        p.addParamValue('zUnit',parameters.zUnit,@(x)ischar(x));
        p.addParamValue('showYaxis',parameters.showYaxis,@(x)islogical(x));
        p.addParamValue('symmetric',parameters.symmetric,@(x)islogical(x));
        p.addParamValue('clims',parameters.clims,...
            @(x)isvector(x) && (isempty(x) || length(x) == 2));
        p.addParamValue('xLimits',parameters.xLimits,...
            @(x)isvector(x) && (isempty(x) || length(x) == 2));
        p.addParamValue('yLimits',parameters.yLimits,...
            @(x)isvector(x) && (isempty(x) || length(x) == 2));
        p.addParamValue('zLimits',parameters.zLimits,...
            @(x)isvector(x) && (isempty(x) || length(x) == 2));
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

function axisLabel = axisLabelString(measure,unit)

if isempty(unit) || all(isspace(unit))
    axisLabel = measure;
    return;
end

axisLabel = sprintf('{\\it %s} / %s',measure,unit); 

end