function text = textFileRead(filename)
% Read text file and save all lines to the output argument. The line ends
% will be conserved (use of fgets internally).

% Parse input arguments using the inputParser functionality
parser = inputParser;   % Create an instance of the inputParser class.
parser.FunctionName = mfilename; % Function name included in error messages
parser.KeepUnmatched = true; % Enable errors on unmatched arguments
parser.StructExpand = true; % Enable passing arguments in a structure
parser.addRequired('filename', @ischar);
parser.parse(filename);

text = '';
fid = fopen(filename);
if fid < 0
    return
end
    
while 1
    tline = fgets(fid);
    if ~ischar(tline)
        break
    end
    text = sprintf('%s%s',text,tline);
end
fclose(fid);