function dataset = trEPRFC(dataset,varargin)
% TREPRFC Correct frequency of dataset, i.e. shift field axis accordingly.
%
% Usage:
%   dataset = trEPRFC(dataset)
%   dataset = trEPRFC(dataset,<parameter>,<value>)
%
%   dataset   - struct
%               Dataset complying to trEPR toolbox dataset structure
%
% You can specify optional parameters as key-value pairs. Valid parameters
% and their values are:
%
%   frequency - scalar
%               Microwave frequency the dataset shall be corrected to
%               Default: 9.70 GHz
%
%   method    - string
%               Method to use: linear (constant offset for magnetic field
%               axis) or nonlinear (conversion of field axis in g axis and
%               afterwards reconversion in magnetic field axis).
%               Default: linear
%               NOTE: Currently only 'linear' is supported
%
%
% NOTE: Currently, the routine computes a DeltaB0 for the DeltaFrequency
% and shifts the magnetic field axis accordingly. This does not account for
% any intrinsic nonlinearity of the problem.

% Copyright (c) 2015, Till Biskup
% 2015-06-11

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('dataset', @(x)isstruct(x));
    p.addParamValue('frequency',9.7,@(x)isscalar(x));
    p.addParamValue('method','linear',@(x)any(strcmpi(x,{'linear'})));
    p.parse(dataset,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

assignParsedVariables(p.Results);

h = 6.62606957e-34;
muB = 9.27400968e-24;
ge = 2.00231930436153;

oldFrequency = dataset.parameters.bridge.MWfrequency.value;

% In case old and new frequency value are numerically identical, return
if abs(oldFrequency-frequency) < eps(oldFrequency)
    trEPRmsg('Frequency difference less than numerical accuracy','info');
    return;
end


DeltaNu = oldFrequency-frequency;
DeltaB0 = h*DeltaNu*1e9 / (ge*muB); % in T

% Convert field value according to axis unit
switch lower(dataset.axes.data(2).unit)
    case 'mt'
        DeltaB0 = DeltaB0 * 1e3;
    case 'g'
        DeltaB0 = DeltaB0 * 1e4;
    otherwise
        disp(['(WW) Unknown field unit "' dataset.axes.data(2).unit '".']);
        return;
end


% Apply changes to dataset
dataset.axes.data(2).values = dataset.axes.data(2).values - DeltaB0;
dataset.parameters.bridge.MWfrequency.value = frequency;
dataset.parameters.bridge.MWfrequency.values = ...
    dataset.parameters.bridge.MWfrequency.values - DeltaNu;

% Write history
history = trEPRdataStructure('history');
history.method = mfilename;

history.parameters = p.Results;
history.parameters = rmfield(history.parameters,'dataset');

dataset.history{end+1} = history;

end


function assignParsedVariables(structure)

parsedVariables = fieldnames(structure);
for variable = 1:length(parsedVariables)
    assignin('caller',parsedVariables{variable},...
        structure.(parsedVariables{variable}));
end

end
