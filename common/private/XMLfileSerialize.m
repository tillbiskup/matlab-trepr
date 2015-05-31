function XMLfileSerialize(filename)
% XMLFILESERIALIZE Serialise a XML File (read XML file and write complete
% content back into the same file as one single line).
%
% Usage:
%   XMLfileSerialize(filename)

% Copyright (c) 2010-2015, Till Biskup
% 2015-03-25

% Parse input arguments using the inputParser functionality
p = inputParser;            % Create inputParser instance
p.FunctionName = mfilename; % Include function name in error messages
p.KeepUnmatched = true;     % Enable errors on unmatched arguments
p.StructExpand = true;      % Enable passing arguments in a structure
p.addRequired('filename', @(x)ischar(x) || iscell(x));
p.parse(filename);

% Do the real stuff
if ~exist(filename,'file')
    fprintf('"%s" seems not to be a valid filename. Abort.',filename);
    return;
end
txt = commonTextFileRead(filename);
fid2 = fopen(filename,'wt');
for k=1:length(txt)
    fprintf(fid2,'%s',strtrim(txt{k}));
end
fclose(fid2);
end