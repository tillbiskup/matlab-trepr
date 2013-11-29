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

% (c) 2013, Till Biskup
% 2013-11-29

% Predefine output
tags = cell(0); %#ok<NASGU>

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('handle', @(x)ishandle(x));

% Get appdata of handle
ad = getappdata(handle);

% Get field names (aka tags)
tagNames = fieldnames(ad.UsedByGUIData_m);

% Preallocate cell array of tags for speed
tags = cell(length(tagNames),1);

% Test for duplicates
for k=1:length(tagNames)
    if max(size(ad.UsedByGUIData_m.(tagNames{k}))) > 1
        tags{k} = tagNames{k};
    end
end

% Remove empty elements from cell
tags = tags(~cellfun('isempty',tags));

