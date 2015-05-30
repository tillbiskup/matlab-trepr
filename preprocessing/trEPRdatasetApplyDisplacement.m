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

% Copyright (c) 2014-15, Till Biskup
% 2015-05-30

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

if length(data.axes.data(1).values)>1
    data.axes.data(1).values = data.axes.data(1).values + ...
        data.display.displacement.data(1)*diff(data.axes.data(1).values([1,2]));
end
if length(data.axes.data(2).values)>1
    data.axes.data(2).values = data.axes.data(2).values + ...
        data.display.displacement.data(2)*diff(data.axes.data(2).values([1,2]));
end

data.data = data.data + data.display.displacement.data(3);

if isfield(data,'calculated') && ~isempty(data.calculated)
    data.calculated = ...
        data.calculated + data.display.displacement.calculated(3);
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
