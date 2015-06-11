function text = commonTextFileRead(filename,varargin)
% COMMONTEXTFILEREAD Read text file and return all lines as cell array. 
% The line ends will not be conserved (use of fgetl internally). 
%
% Usage:
%   text = commonTextFileRead(filename);
%
%   filename - string
%              name of a valid (text) file to read
%
%   text     - cell array
%              contains all lines of the textfile
%
% See also: fileread, commonTextFileWrite, commonBinaryFileRead,
% commonBinaryFileWrite

% Copyright (c) 2011-15, Till Biskup
% 2015-03-25

text = cell(0);

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('filename', @(x)ischar(x) || exist(x,'file'));
    p.addParamValue('LineNumbers',logical(false),@islogical);
    p.parse(filename,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

text = regexp(fileread(filename),'\n','split');

% Remove last element if empty
if isempty(text{end})
    text(end) = [];
end

if p.Results.LineNumbers
    lineNumbers = cellstr(num2str((1:length(text))'));
    for line = 1:length(text)
        text{line} = sprintf('%s: %s',lineNumbers{line},text{line});
    end
end

end