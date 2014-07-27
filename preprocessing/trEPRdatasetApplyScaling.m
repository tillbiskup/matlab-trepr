function data = trEPRdatasetApplyScaling(data,varargin)
% TREPRDATASETAPPLYSCALING Apply scaling to dataset.
%
% Within the GUI, scaling is normally applied on the fly for display,
% according to the values of the respective fields in the data structure.
%
% This function takes the parameters and applies them to the dataset,
% resetting the values afterwards and writing a proper history record.
%
% Usage:
%   data = trEPRdatasetApplyScaling(data)
%   data = trEPRdatasetApplyScaling(data,parameters)
%
%   data       - struct
%                dataset conforming to trEPR dataset structure
%
%   parameters - struct
%                parameters for scaling as in dataset structure
%
% See also: trEPRdatasetApplyDisplacement, trEPRdatasetApplySmoothing,
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
        ~isfield(data,'display') || ~isfield(data.display,'scaling') ...
        || ~all(isfield(data.display.scaling,{'calculated','data'}))
    trEPRmsg([mfilename ': Problems with dataset'],'warning');
    return;
end

if ~isempty(fieldnames(p.Results.parameters))
    data.display.scaling = p.Results.parameters;
end

% Scaling in x and y dimension should be symmetric around the centre
% Example: x = (x-(max(x)-min(x))/2).*scaling + (max(x)-min(x))/2;
data.axes.x.values = (data.axes.x.values-(max(data.axes.x.values)-...
    min(data.axes.x.values))/2).*data.display.scaling.data.x + ...
    (max(data.axes.x.values)-min(data.axes.x.values))/2;
data.axes.y.values = (data.axes.y.values-(max(data.axes.y.values)-...
    min(data.axes.y.values))/2).*data.display.scaling.data.y + ...
    (max(data.axes.y.values)-min(data.axes.y.values))/2;

data.data = data.data .* data.display.scaling.data.z;

if isfield(data,'calculated') && ~isempty(data.calculated)
    data.calculated = data.calculated .* data.display.scaling.calculated.z;
end

% Write history record
history = trEPRdataStructure('history');
history.method = mfilename;
history.parameters = data.display.scaling;
data.history{end+1} = history;

% Reset display parameters
default = trEPRdataStructure();
data.display.scaling = default.display.scaling;

end