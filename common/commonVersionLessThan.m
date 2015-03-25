function result = commonVersionLessThan(currentVersion,referenceVersion)
% COMMONVERSIONLESSTHAN Compare version (e.g., of a toolbox) against a
% reference version, assuming for both versions a three-digit scheme
% "a.b.c" with a, b, c being integer numbers.
%
% Usage:
%   result = commonVersionLessThan(currentVersion,referenceVersion)
%
%   currentVersion   - string
%                      Version that shall be compared to reference.
%
%   referenceVersion - string
%                      Version that shall be compared against.
%
%   result           - boolean
%                      true if currentVersion is less than
%                      referenceVersion, false otherwise.
%
% Based on an idea used in the Matlab(r) function verLessThan.
%
% See also: verLessThan

% Copyright (c) 2015, Till Biskup
% 2015-03-24

result = logical(false);

try
    % Parse input arguments using the inputParser functionality.
    p = inputParser;             % Create inputParser instance.
    p.FunctionName  = mfilename; % Include function name in error messages.
    p.KeepUnmatched = true;      % Enable errors on unmatched arguments.
    p.StructExpand  = true;      % Enable passing arguments in a structure.
    p.addRequired('currentVersion',@(x)ischar(x));
    p.addRequired('referenceVersion',@(x)ischar(x));
    p.parse(currentVersion,referenceVersion);
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

result = (sign(versionString2Number(currentVersion) - ...
    versionString2Number(referenceVersion)) * [1; .1; .01]) < 0;

end

function versionNumber = versionString2Number(versionString)

versionNumber = sscanf(versionString, '%d.%d.%d')';
if length(versionNumber) < 3
    for idx = length(versionNumber)+1:3
        versionNumber(idx) = 0; % zero-fill to 3 elements
    end
end

end