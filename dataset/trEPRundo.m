function undoneDataset = trEPRundo(dataset,varargin)
% TREPRUNDO Revert last change of dataset.
%
% Usage
%   undoneDataset = trEPRundo(dataset)
%
%   dataset       - struct
%                   Dataset complying to dataset structure of trEPR toolbox
%
%   undoneDataset - struct
%                   Dataset complying to dataset structure of trEPR toolbox

% Copyright (c) 2015, Till Biskup
% 2015-05-31

undoneDataset = dataset;

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('dataset', @(x)isstruct(x));
    p.parse(dataset,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

% We can work only in case we have "origdata"
if isempty(dataset.origdata)
    trEPRmsg('No origdata - can''t undo anything... sorry.','warning');
    return;
end

% If there is no history to undo, tell user
if isempty(dataset.history)
    trEPRmsg('No history to undo.','info');
    return;
end

undoneDataset.data = undoneDataset.origdata;
undoneDataset.history = cell(0);

% Apply previous history until one step before end
if length(dataset.history) < 2
    return;
end

try
    for step = 1:length(dataset.history)-1
        fun = str2func(dataset.history{step}.method);
        undoneDataset = fun(undoneDataset,dataset.history{step}.parameters);
    end
catch exception
    disp(['(EE) ' exception.message]);
    undoneDataset = dataset;
    return;
end

end