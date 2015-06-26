function [data] = trEPRdatasetMatch(data,varargin)
% TREPRDATASETMATCH Match range of datasets, using first dataset as
% "master" in case of interpolation.
%
% Necessary for, e.g., adding or subtracting two datasets from each other.
%
% Usage
%   [datasets] = trEPRdatasetMatch(datasets)
%   [datasets] = trEPRdatasetMatch(datasets,<parameter>,<value>)
%
% data - 1x2 cell
%        Datasets conforming to the trEPR toolbox data format
%
% Optional parameters that can be set:
%
%   dimension - string
%               dimension(s) the datasets should be matched
%               Possible values: "2D", "x", "y"
%               If not specified, "2D" will be assumed.
%               If one dataset is one-dimensional, the respective 1D mode
%               will be tried
%
% The function performs some basic checkings for the dataset format and
% whether the datasets overlap in the given dimension(s). In case both
% datasets have identical dimensions and axes values, they are returned
% immediately.
%
% The function *does not* check for units of the respective axes, therefore
% handle with care in case you change units and end up with still
% overlapping datasets.
%
% The second dataset is interpolated on top of the first dataset. A proper
% history record is added to both datasets.
%
% If the datasets do not overlap in the given dimension, the output
% parameter will be an empty cell array and a warning will be issued.
%
% See also: interp1, interp2

% Copyright (c) 2014-15, Till Biskup
% 2015-06-17

% Parse input arguments using the inputParser functionality
try
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('data', @(x)iscell(x) && all(size(x) == [1 2]));
    p.addParamValue('dimension','2D',...
        @(x)ischar(x) && any(strcmpi(x,{'2d','x','y'})));
    p.parse(data,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

% Basic check for dataset format
for dataset = 1:length(data)
    if ~isfield(data{dataset},'format') || ...
            ~isfield(data{dataset}.format,'name') || ...
            ~strcmpi(data{dataset}.format.name,'trEPR toolbox')
        trEPRmsg([mfilename ': Problems with dataset(s)'],'warning');
        return;
    end
end

% Check for identical dimensions and axis values of the datasets
% NOTE: Units are *not* checked
if all(size(data{1}.data) == size(data{2}.data)) && ...
        all(data{1}.axes.data(1).values == data{2}.axes.data(1).values) && ...
        all(data{1}.axes.data(2).values == data{2}.axes.data(2).values)
    trEPRmsg([mfilename ': Datasets have identical dimensions'],'info');
    return;
end

try
    switch lower(p.Results.dimension)
        case '2d'
            data = match2D(data);
        case {'x','y'}
            data = match1D(data,p.Results.dimension);
    end
catch exception
    trEPRexceptionHandling(exception);
end

end

function data = match2D(data)

if min(size(data{1}.data))==1 || min(size(data{2}.data))==1
    data = match1D(data);
    return;
end

dimensions = {'x','y'};

% Get overlapping area in both dimensions
for dim = 1:length(dimensions)
    limit.(dimensions{dim}).value(1) = max([...
        min(data{1}.axes.data(dim).values) ...
        min(data{2}.axes.data(dim).values)]);
    limit.(dimensions{dim}).value(2) = min([...
        max(data{1}.axes.data(dim).values) ...
        max(data{2}.axes.data(dim).values)]);
    
    % Get limits for first dataset in both dimensions using interp1 with
    % option 'nearest' for nearest neighbour table lookup of the respective
    % indices
    % Example idx = interp1(xvalues,1:length(xvalues),xlimit,'nearest');
    limit.(dimensions{dim}).index(1) = ...
        interp1(data{1}.axes.data(dim).values,...
        1:length(data{1}.axes.data(dim).values),...
        limit.(dimensions{dim}).value(1),'nearest');
    limit.(dimensions{dim}).index(2) = ...
        interp1(data{1}.axes.data(dim).values,...
        1:length(data{1}.axes.data(dim).values),...
        limit.(dimensions{dim}).value(2),'nearest');
    
    % Check for non-overlapping datasets
    if any(isnan(limit.(dimensions{dim}).index))
        trEPRmsg([mfilename ': Datasets seem not to overlap'],'warning');       
        data = {};
        return;
    end
    
    % Cut axes of first dataset
    data{1}.axes.data(dim).values = ...
        data{1}.axes.data(dim).values(...
        limit.(dimensions{dim}).index(1):limit.(dimensions{dim}).index(2));
end

% Cut data area of first dataset
data{1}.data = data{1}.data(...
    limit.y.index(1):limit.y.index(2),limit.x.index(1):limit.x.index(2));

% Interpolate data of second dataset
% Note: For whatever reason, not using meshgrid seems not to work...
[x1,y1] = meshgrid(data{1}.axes.data(1).values,data{1}.axes.data(2).values);
[x2,y2] = meshgrid(data{2}.axes.data(1).values,data{2}.axes.data(2).values);
data{2}.data = interp2(x2,y2,data{2}.data,x1,y1,'spline');

% Copy axis values from dataset 1 to dataset 2
for dim = 1:length(dimensions)
    data{2}.axes.data(dim).values = ...
        data{1}.axes.data(dim).values;
end

end

function data = match1D(data,varargin)

% Default dimension
dimension = 2;

if nargin > 1
    dimension = find(strcmpi(varargin{1},{'x','y'}));
end

if size(data{1}.data,1) == 1 || size(data{2}.data,1) == 1
    dimension = 1;
elseif size(data{1}.data,2) == 1 || size(data{2}.data,2) == 1
    dimension = 2;
end

% Get overlapping area in respective dimension
limit(dimension).value(1) = max([...
    min(data{1}.axes.data(dimension).values) ...
    min(data{2}.axes.data(dimension).values)]);
limit(dimension).value(2) = min([...
    max(data{1}.axes.data(dimension).values) ...
    max(data{2}.axes.data(dimension).values)]);

% Set default values for limit.(dimension).index
limit(1).index = [1 size(data{1}.data,2)];
limit(2).index = [1 size(data{1}.data,1)];

% Get limits for first dataset in respective dimension using interp1 with
% option 'nearest' for nearest neighbour table lookup of the respective
% indices
% Example idx = interp1(xvalues,1:length(xvalues),xlimit,'nearest');
limit(dimension).index(1) = ...
    interp1(data{1}.axes.data(dimension).values,...
    1:length(data{1}.axes.data(dimension).values),...
    limit(dimension).value(1),'nearest');
limit(dimension).index(2) = ...
    interp1(data{1}.axes.data(dimension).values,...
    1:length(data{1}.axes.data(dimension).values),...
    limit(dimension).value(2),'nearest');

% Check for non-overlapping datasets
if any(isnan(limit(dimension).index))
    trEPRmsg([mfilename ': Datasets seem not to overlap'],'warning');
    data = {};
    return;
end

% Cut respective axis of first dataset
data{1}.axes.data(dimension).values = ...
    data{1}.axes.data(dimension).values(...
    limit(dimension).index(1):limit(dimension).index(2));

% Cut data area of first dataset
data{1}.data = data{1}.data(...
    limit(2).index(1):limit(2).index(2),limit(1).index(1):limit(1).index(2));

% Interpolate data of second dataset
switch dimension
    case 1
        for slice=1:size(data{2}.data,1)
            data{2}.newdata(slice,:) = ...
                interp1(data{2}.axes.data(1).values,data{2}.data(slice,:),...
                data{1}.axes.data(1).values,'spline');
        end
        data{2}.data = data{2}.newdata;
        data{2} = rmfield(data{2},'newdata');
    case 2
        for slice=1:size(data{2}.data,2)
            data{2}.newdata(:,slice) = ...
                interp1(data{2}.axes.data(2).values,data{2}.data(:,slice),...
                data{1}.axes.data(2).values,'spline');
        end
        data{2}.data = data{2}.newdata;
        data{2} = rmfield(data{2},'newdata');
end

% Copy axis values from first to second dataset
data{2}.axes.data(dimension).values = data{1}.axes.data(dimension).values;

end
