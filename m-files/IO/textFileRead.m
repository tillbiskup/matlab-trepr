function text = textFileRead(filename,varargin)
% Read text file and save all lines to the output argument (a cell array).
% The line ends will not be conserved (use of fgetl internally).

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
    tline = fgetl(fid);
    if ~ischar(tline)
        break
    end
    if parser.Results.LineNumbers
        text{k} = sprintf('%i: %s',k,tline);
    else
        text{k} = tline;
    end
    k=k+1;
end
fclose(fid);