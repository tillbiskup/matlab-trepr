function [combinedDataset,status] = trEPRcombine(datasets,varargin)
% TREPRCOMBINE Combine datasets contained in the input parameter to a
% single dataset.
%
% Usage
%   [combinedDatset,status] = trEPRcombine(datasets)
%   [combinedDatset,status] = trEPRcombine(datasets,'label','sometext')
%
% datasets        - cell array
%                   Cell array of datasets in trEPR toolbox format
%
% combinedDataset - struct
%                   Combined dataset in trEPR toolbox format
%                   Empty if something went wrong. In this case, status
%                   contains a message.
%
% status          - string
%                   Status message
%                   Empty if everything went well.
%                   If something went wrong, status contains a message
%                   describing the problem in more detail.
%              
% As you can see in the example above, you can specify a label as
% parameter/value pair. This label is used for the combined dataset,
% otherwise the label of the first dataset that is combined gets used.
%

% (c) 2011, Till Biskup
% 2011-11-21

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('datasets', @(x)iscell(x));
p.addParamValue('label','', @(x)ischar(x));
p.parse(datasets,varargin{:});

try
    status = '';
    
    if length(datasets) < 2
        combinedDataset = [];
        status = 'There is no point in combining a single dataset...';
        return;
    end
    
    dimensions = zeros(length(datasets),2);
    for k=1:length(datasets)
        dimensions(k,:) = size(datasets{k}.data);
    end
    
    % Very basic test: Equal size at least in one dimension
    if (length(unique(dimensions(:,1)))>1) && (length(unique(dimensions(:,2)))>1)
        combinedDataset = [];
        status = ['Datasets have different size in both dimensions. '...
            'Therefore they cannot be combined.'];
        return;
    end
    
    % First step: Assign most of the parameters of the combined dataset by
    % using the parameters from the first dataset
    combinedDataset = datasets{1};
    % Assign label
    if ~isempty(p.Results.label)
        combinedDataset.label = p.Results.label;
    end
    
    if (length(unique(dimensions(:,1)))==1) ...
            && (length(unique(dimensions(:,2)))==1) ...
            && (unique(dimensions(:,1))==1)
        for k=2:length(datasets)
            combinedDataset.data = ...
                [ combinedDataset.data; datasets{k}.data ];
        end
        combinedDataset.axes.y.values = linspace(...
            datasets{1}.parameters.field.start.value,...
            datasets{end}.parameters.field.stop.value,...
            length(datasets));
        combinedDataset.parameters.field.start.value = ...
            datasets{1}.parameters.field.start.value;
        combinedDataset.parameters.field.stop.value = ...
            datasets{end}.parameters.field.stop.value;
        combinedDataset.parameters.field.step.value = ...
            combinedDataset.axes.y.values(2)-combinedDataset.axes.y.values(1);
        combinedDataset.parameters.field.start.unit = ...
            combinedDataset.axes.y.unit;
        combinedDataset.parameters.field.stop.unit = ...
            combinedDataset.axes.y.unit;
        combinedDataset.parameters.field.step.unit = ...
            combinedDataset.axes.y.unit;
    end
    
    % In case that we have identical dimensions along x (cols, therefore
    % dimension 2), and dimension along x is larger than max along y, add
    % datasets together (assuming that always the longer dimension is the
    % one that stays fixed)
    if (length(unique(dimensions(:,2)))==1) ...
            && unique(dimensions(:,2)) > max(unique(dimensions(:,1))) ...
            && max(unique(dimensions(:,1))) > 1
    end
    
catch exception
    throw(exception);
end

end