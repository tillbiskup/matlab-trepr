function dataset = trEPRadd(datasets)
% Add data of several datasets together
%
% Useful in case you have recorded a series of datasets consecutively on a
% sample and simply want to add the data of each measurement to one
% dataset.
%
% In contrast to all the checks of the trEPRACC routine, this routine
% assumes that everything is setup to simply add the data together.
%
% Usage
%   dataset = trEPRadd(datasets)
%
%   datasets - cell
%              list of structures conforming to the trEPR toolbox dataset
%
%   dataset  - struct
%              structure conforming to the trEPR toolbox dataset
%              containing the summed data of the individual datasets
%
% See also trEPRACC

% Copyright (c) 2020, Till Biskup
% 2020-11-14

% Assign default output
data = struct();

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('datasets', @(x)iscell(x) && isstruct(x{1}));
    % p.addParameter('infoFileName','',@ischar);
    p.parse(datasets);
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

% Assign output to first dataset in input list
dataset = datasets{1};

data = [];
averages = 0;
for nr = 1:length(datasets)
    data(:, :, nr) = datasets{nr}.data;
    averages = ...
        averages + datasets{nr}.parameters.recorder.averages;
end
dataset.data = sum(data, 3);
dataset.parameters.recorder.averages = averages;

% Write history record
history_record = trEPRdataStructure('history');
history_record.method = mfilename;

dataset.history{end+1} = history_record;

end