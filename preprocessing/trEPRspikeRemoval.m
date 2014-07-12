function data = trEPRspikeRemoval(data,fieldPositions)
% TREPRSPIKEREMOVAL Remove artifacts in datasets using interpolation
% (table lookup).
%
% The function works on trEPR datasets.
%
% Usage
%   data = trEPRspikeRemoval(data,positions);
%
%   data      - struct
%               trEPR dataset
%
%   positions - vector
%               field positions of spikes to remove (in field units)
%
% The idea is based on the recording scheme of transient EPR where time
% traces are recorded one after the other. Particularly with automatic
% background correction within the transient recorder, detuning of the
% cavity after the last background measurement can lead to artifacts that
% might be possible to remove using 2D interpolation (table lookup).
%
% PLEASE NOTE: This operation is very close to data manipulation in a bad
%              way. Use entirely on your own risk knowing what you're
%              doing.

% (c) 2014, Till Biskup
% 2014-07-12

% If called without parameter, display help
if ~nargin && ~nargout
    help trEPRspikeRemoval
    return;
end

% Parse input arguments using the inputParser functionality
p = inputParser;            % Create an instance of the inputParser class.
p.FunctionName = mfilename; % include function name in error messages
p.KeepUnmatched = true;     % Enable errors on unmatched arguments
p.StructExpand = true;      % Enable passing arguments in a structure

p.addRequired('data', @(x)isstruct(x));
p.addOptional('fieldPositions','',@(x)isvector(x));
p.parse(data,fieldPositions);

% Prepare x,y vectors, Z matrix
x = data.axes.x.values;
y = data.axes.y.values;
Z = data.data;

% Get field positions
try
    positions = arrayfun(@(x)find(y==x),fieldPositions);
catch %#ok<CTCH>
    trEPRmsg('Problems finding positions in dataset.','warn');
    return;
end
yi = y(positions);

% Cut x,y vectors, Z matrix
Z(positions,:) = [];
y(positions) = [];

% Interpolate
if length(x) > 1
    data.data(positions,:) = interp2(x,y,Z,x,yi');
else
    data.data(positions,:) = interp1(y,Z,yi');
end

% Add history record to dataset
data.history{end+1} = trEPRdataStructure('history');
data.history{end}.method = mfilename;
data.history{end}.parameters = struct(...
    'positions',fieldPositions...
    );

end