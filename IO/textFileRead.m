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
% See also: fileread

% Copyright (c) 2011-14, Till Biskup
% 2014-09-23

text = cell(0);

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('filename', @(x)ischar(x) || exist(x,'file'));
    p.addParameter('LineNumbers',logical(false),@islogical);
    p.parse(filename,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

text = regexp(fileread(filename),'\n','split');

if p.Results.LineNumbers
    lineNumbers = cellstr(num2str((1:length(text))'));
    for line = 1:length(text)
        text{line} = sprintf('%s: %s',lineNumbers{line},text{line});
    end
end

end
