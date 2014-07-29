function data = trEPRdatasetApplyNormalisation(data,varargin)
% TREPRDATASETAPPLYNORMALISATION Apply smoothing to dataset.
%
% Within the GUI, smoothing is normally applied on the fly for display,
% according to the values of the respective fields in the data structure.
%
% This function takes the parameters and applies them to the dataset,
% resetting the values afterwards and writing a proper history record.
%
% Usage:
%   data = trEPRdatasetApplyNormalisation(data,parameters)
%
%   data       - struct
%                dataset conforming to trEPR dataset structure
%
%   parameters - struct
%                parameters for normalisation from GUI
%                necessary fields: dimension, type, displayType
%
% See also: trEPRdatasetApplyDisplacement, trEPRdatasetApplyScaling,
% trEPRdatasetApplySmoothing

% Copyright (c) 2014, Till Biskup
% 2014-07-29

% Parse input arguments using the inputParser functionality
try
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('data', @(x)isstruct(x));
    p.addRequired('parameters', @(x)isstruct(x));
    p.parse(data,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

% Check whether we have a proper dataset
if ~isfield(data,'format') || ~isfield(data.format,'name') || ...
        ~strcmpi(data.format.name,'trEPR toolbox')
    trEPRmsg([mfilename ': Problems with dataset'],'warning');
    return;
end

parameters = p.Results.parameters;

if ~isfield(parameters,'dimension') || ~isfield(parameters,'type') || ...
        ~isfield(parameters,'displayType')
    trEPRmsg([mfilename ': Problems with parameters'],'warning');
    return;
end

if isfield(parameters,'enable') && ~parameters.enable
    return;
end

if strcmpi(parameters.dimension,'1D')
    switch parameters.displayType(1)
        case 'x'
            data4Scaling = data.data(data.display.position.y,:);
        case 'y'
            data4Scaling = data.data(:,data.display.position.x);
    end
else
    data4Scaling = data.data;
end

switch lower(parameters.normalisationType)
    case 'pk2pk'
        normalisationFactor = ...
            1/(max(max(data4Scaling))-min(min(data4Scaling)));
    case 'area'
        normalisationFactor = 1/abs(sum(sum(data4Scaling)));
    case 'max'
        normalisationFactor = 1/max(max(data4Scaling));
    case 'min'
        normalisationFactor = 1/abs(min(min(data4Scaling)));
end

data.data = data.data .* normalisationFactor;


if isfield(data,'calculated') && ~isempty(data.calculated)
    data.calculated = data.calculated .* normalisationFactor;
end

% Write history record
history = trEPRdataStructure('history');
history.method = mfilename;
history.parameters = parameters;
data.history{end+1} = history;

end