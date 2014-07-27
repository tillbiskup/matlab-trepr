function data = trEPRdatasetApplySmoothing(data,varargin)
% TREPRDATASETAPPLYSMOOTHING Apply smoothing to dataset.
%
% Within the GUI, smoothing is normally applied on the fly for display,
% according to the values of the respective fields in the data structure.
%
% This function takes the parameters and applies them to the dataset,
% resetting the values afterwards and writing a proper history record.
%
% Usage:
%   data = trEPRdatasetApplySmoothing(data)
%   data = trEPRdatasetApplySmoothing(data,parameters)
%
%   data       - struct
%                dataset conforming to trEPR dataset structure
%
%   parameters - struct
%                parameters for smoothing as in dataset structure
%
% See also: trEPRdatasetApplyDisplacement, trEPRdatasetApplyScaling,
% trEPRdatasetApplyNormalisation

% Copyright (c) 2014, Till Biskup
% 2014-07-27

% Parse input arguments using the inputParser functionality
try
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('data', @(x)isstruct(x));
    p.addOptional('parameters',struct(),@(x)isstruct(x));
    p.parse(data,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

% Check whether we have a proper dataset
if ~isfield(data,'format') || ~isfield(data.format,'name') || ...
        ~strcmpi(data.format.name,'trEPR toolbox') || ...
        ~isfield(data,'display') || ~isfield(data.display,'smoothing') ...
        || ~all(isfield(data.display.smoothing,{'calculated','data'}))
    trEPRmsg([mfilename ': Problems with dataset'],'warning');
    return;
end

if ~isempty(fieldnames(p.Results.parameters))
    data.display.smoothing = p.Results.parameters;
end

if ~isempty(data.display.smoothing.data.x.filterfun) ...
        && data.display.smoothing.data.x.parameters.width > 0
    filterFun = ...
        str2func(['trEPRfilter_' data.display.smoothing.data.x.filterfun]);
    for rows = 1:size(data.data,1)
        data.data(rows,:) = filterFun(data.data(rows,:),...
            data.display.smoothing.data.x.parameters);
    end
end

if ~isempty(data.display.smoothing.data.y.filterfun) ...
        && data.display.smoothing.data.y.parameters.width > 0
    filterFun = ...
        str2func(['trEPRfilter_' data.display.smoothing.data.y.filterfun]); 
    for cols = 1:size(data.data,2)
        data.data(:,cols) = filterFun(data.data(:,cols),...
            data.display.smoothing.data.y.parameters);
    end
end

if isfield(data,'calculated') && ~isempty(data.calculated)
    if ~isempty(data.display.smoothing.calculated.x.filterfun) ...
            && data.display.smoothing.calculated.x.parameters.width > 0
        filterFun = str2func(['trEPRfilter_' ...
            data.display.smoothing.calculated.x.filterfun]);
        for rows = 1:size(data.calculated,1)
            data.calculated(rows,:) = filterFun(data.calculated(rows,:),...
                data.display.smoothing.calculated.x.parameters);
        end
    end
    
    if ~isempty(data.display.smoothing.calculated.y.filterfun) ...
            && data.display.smoothing.calculated.y.parameters.width > 0
        filterFun = str2func(['trEPRfilter_' ...
            data.display.smoothing.calculated.y.filterfun]);
        for cols = 1:size(data.calculated,2)
            data.calculated(:,cols) = filterFun(data.calculated(:,cols),...
                data.display.smoothing.calculated.y.parameters);
        end
    end
end

% Write history record
history = trEPRdataStructure('history');
history.method = mfilename;
history.parameters = data.display.smoothing;
data.history{end+1} = history;

% Reset display parameters
default = trEPRdataStructure();
data.display.smoothing = default.display.smoothing;

end