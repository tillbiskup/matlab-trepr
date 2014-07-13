function xmlFileSerialize(filename)
% XMLFILESERIALIZE Serialise a XML File (read XML file and write complete
% content back into the same file as one single line).
%
% Usage:
%   xmlFileSerialize(filename)

% Copyright (c) 2010-2012, Till Biskup
% 2012-06-10

% Parse input arguments using the inputParser functionality
parser = inputParser;   % Create an instance of the inputParser class.
parser.FunctionName = mfilename; % Function name included in error messages
parser.KeepUnmatched = true; % Enable errors on unmatched arguments
parser.StructExpand = true; % Enable passing arguments in a structure
parser.addRequired('filename', @(x)ischar(x) || iscell(x));
parser.parse(filename);
% Do the real stuff
if ~exist(filename,'file')
    fprintf('"%s" seems not to be a valid filename. Abort.',filename);
    return;
end
txt = textFileRead(filename);
fid2 = fopen(filename,'wt');
for k=1:length(txt)
    fprintf(fid2,'%s',strtrim(txt{k}));
end
fclose(fid2);
end
