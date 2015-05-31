function [data,status] = commonBinaryFileRead(filename,varargin)
% COMMONBINARYFILEREAD Read binary file and return numeric data. 
%
% Usage:
%   data = commonBinaryFileRead(filename);
%   data = commonBinaryFileRead(filename,precision);
%
%   filename  - string
%               name of a valid (binary) file to read
%
%   data      - numeric
%               numeric data read from binary file
%
%   precision - string
%               Precision used for writing binary data
%               Default: 'real*8'
%
% See also: fileread, commonBinaryFileWrite, commonTextFileRead,
% commonTextFileWrite

% Copyright (c) 2015, Till Biskup
% 2015-03-25

data = [];
status = '';

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('filename', @(x)ischar(x) || exist(x,'file'));
    p.addOptional('precision','real*8',@ischar);
    p.parse(filename,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

fid = fopen(filename,'r');
if fid < 0
    status = 'Problems opening file';
    return
end

data = fread(fid,inf,p.Results.precision);

fclose(fid);

end