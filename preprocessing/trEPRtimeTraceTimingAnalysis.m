function difftimes = trEPRtimeTraceTimingAnalysis(dataset)
% TREPRTIMETRACETIMINGANALYSIS Return vector with time spent between saving
% two time traces (aka, measuring and setting field). Helpful for
% statistics about the spectrometer needing more time than expected.
%
% Usage:
%   difftimes = trEPRtimeTraceTimingAnalysis(dataset)
%
%   dataset   - structure
%               trEPR dataset
%
%   difftimes - vector
%               time spent between saving two time traces, in seconds
%
% The result could be printed for visual inspection. Please be aware that
% at least the Freiburg data are recorded normally in a fashion where a
% background trace is recorded every n-th time trace. This makes for
% "spikes" in the resulting plot.

% Copyright (c) 2016, Till Biskup
% 2016-08-29

difftimes = [];

if wrongInput(dataset)
    return;
end

posixTimeStamps = convertTimeStamps(dataset);

posixTimeStamps = sort(posixTimeStamps);

difftimes = posixTimeStamps(2:end)-posixTimeStamps(1:end-1);

end

function result = wrongInput(dataset)

ISSTRUCT = isstruct(dataset);
HASFIELDS = isfield(dataset,'format') && isfield(dataset.format,'version');
PROPERVERSION = str2double(dataset.format.version) >= 1.14;

result = ~( ISSTRUCT && HASFIELDS && PROPERVERSION );

end

function posixTimeStamps = convertTimeStamps(dataset)

posixTimeStamps = cellfun(...
    @(x)datevec2posixtime(datevec(x,31)),...
    dataset.parameters.transient.timeStamp);

end