function text = textFileRead(filename,varargin)
% TEXTFILEREAD Read text file and return all lines as cell array. 
% The line ends will not be conserved (use of fgetl internally). 
%
% Usage:
%   text = textFileRead(filename);
%
%   filename - string
%              name of a valid (text) file to read
%   text     - cell array
%              contains all lines of the textfile
%

% Copyright (c) 2011, Till Biskup
% 2011-11-05

% Parse input arguments using the inputParser functionality
parser = inputParser;   % Create an instance of the inputParser class.
parser.FunctionName = mfilename; % Function name included in error messages
parser.KeepUnmatched = true; % Enable errors on unmatched arguments
parser.StructExpand = true; % Enable passing arguments in a structure
parser.addRequired('filename', @ischar);
parser.addParamValue('LineNumbers',logical(false),@islogical);
parser.parse(filename,varargin{:});

text = {};
fid = fopen(filename);
if fid < 0
    return
end

k=1;
while 1
    if feof(fid)
        break
    end
    %tline = fgetl(fid);
    if parser.Results.LineNumbers
        text{k} = sprintf('%i: %s',k,fgetl(fid));
    else
        text{k} = fgetl(fid);
    end
    k=k+1;
end
fclose(fid);
