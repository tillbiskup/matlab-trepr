function tags = testDuplicateTags(handle,varargin)
% TESTDUPLICATETAGS Check for duplicate tag names in GUI.
%
% Usage
%   testDuplicateTags(handle)
%   tags = testDuplicateTags(handle)
%
%   handle - handle of the GUI to test
%            GUI must be open and handle must be a valid Matlab(r) handle
%
%   tags   - cell array
%            Names of the duplicate tags, if any. Empty if no duplicates
%            are found.

% Copyright (c) 2013-15, Till Biskup
% 2015-10-18

% Predefine output
tags = cell(0);

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('handle', @(x)ishandle(x));
    p.parse(handle,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

% Get appdata of handle
ad = getappdata(handle);

% Get field names (aka tags)
tagNames = fieldnames(ad.guiHandles);

% Preallocate cell array of tags for speed
tags = cell(length(tagNames),1);

% Test for duplicates
for k=1:length(tagNames)
    if max(size(ad.guiHandles.(tagNames{k}))) > 1
        tags{k} = tagNames{k};
    end
end

% Remove empty elements from cell
tags = tags(~cellfun('isempty',tags));

