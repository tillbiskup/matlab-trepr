function data = trEPRdatasetApplyDisplacement(data,varargin)
% TREPRDATASETAPPLYDISPLACEMENT Apply displacement to dataset.
%
% Within the GUI, displacement is normally applied on the fly for display,
% according to the values of the respective fields in the data structure.
%
% This function takes the parameters and applies them to the dataset,
% resetting the values afterwards and writing a proper history record.
%
% Usage:
%   data = trEPRdatasetApplyDisplacement(data)
%   data = trEPRdatasetApplyDisplacement(data,parameters)
%
%   data       - struct
%                dataset conforming to trEPR dataset structure
%
%   parameters - struct
%                parameters for displacement as in dataset structure
%
% See also: trEPRdatasetApplyScaling, trEPRdatasetApplySmoothing,
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
        ~isfield(data,'display') || ~isfield(data.display,'displacement') ...
        || ~all(isfield(data.display.displacement,{'calculated','data'}))
    trEPRmsg([mfilename ': Problems with dataset'],'warning');
    return;
end

if ~isempty(fieldnames(p.Results.parameters))
    data.display.displacement = p.Results.parameters;
end

data.axes.x.values = data.axes.x.values + data.display.displacement.data.x;
data.axes.y.values = data.axes.y.values + data.display.displacement.data.y;

data.data = data.data + data.display.displacement.data.z;

if isfield(data,'calculated') && ~isempty(data.calculated)
    data.calculated = ...
        data.calculated + data.display.displacement.calculated.z;
end

% Write history record
history = trEPRdataStructure('history');
history.method = mfilename;
history.parameters = data.display.displacement;
data.history{end+1} = history;

% Reset display parameters
default = trEPRdataStructure();
data.display.displacement = default.display.displacement;

end