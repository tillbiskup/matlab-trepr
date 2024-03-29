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

% Copyright (c) 2011-18, Till Biskup
% 2018-01-25

% Assign default output
combinedDataset = struct();
status = '';

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('datasets', @(x)iscell(x));
    p.addParameter('label','', @(x)ischar(x));
    p.parse(datasets,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

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
    % Fix MWfrequency values
    combinedDataset.parameters.bridge.MWfrequency.values = ...
        combinedDataset.parameters.bridge.MWfrequency.value;
    % Assign label
    if ~isempty(p.Results.label)
        combinedDataset.label = p.Results.label;
    end
    
    % Second step: Combine data
    if (length(unique(dimensions(:,1)))==1) ...
            && (length(unique(dimensions(:,2)))==1) ...
            && (unique(dimensions(:,1))==1)
        combinedDataset.data = ...
            zeros(length(datasets),size(datasets{1}.data,2));
        combinedDataset.origdata = combinedDataset.data;
        for k=1:length(datasets)
            % numeric data
            combinedDataset.data(k,:) = datasets{k}.data;
            combinedDataset.origdata(k,:) = datasets{k}.origdata;
            % axis values
            combinedDataset.axes.data(2).values(k) = ...
                datasets{k}.axes.data(2).values;
            % MW frequency
            if ~isempty(datasets{k}.parameters.bridge.MWfrequency.values)
                combinedDataset.parameters.bridge.MWfrequency.values(k) = ...
                    datasets{k}.parameters.bridge.MWfrequency.value;
            end
            % TimeStamp
            if ~isempty(datasets{k}.parameters.transient.timeStamp)
                combinedDataset.parameters.transient.timeStamp{k} = ...
                    datasets{k}.parameters.transient.timeStamp{1};
            end
        end
        
        % Fix field parameters
        combinedDataset.parameters.field.start.value = ...
            combinedDataset.axes.data(2).values(1);
        combinedDataset.parameters.field.stop.value = ...
            combinedDataset.axes.data(2).values(end);
        % Field step is only an assumption - continuous and equidistant
        combinedDataset.parameters.field.step.value = ...
            combinedDataset.axes.data(2).values(2)-...
            combinedDataset.axes.data(2).values(1);
        combinedDataset.parameters.field.start.unit = ...
            combinedDataset.axes.data(2).unit;
        combinedDataset.parameters.field.stop.unit = ...
            combinedDataset.axes.data(2).unit;
        combinedDataset.parameters.field.step.unit = ...
            combinedDataset.axes.data(2).unit;
    end
catch exception
    throw(exception);
end

end
