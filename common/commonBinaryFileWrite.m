function status = commonBinaryFileWrite(filename,data,varargin)
% COMMONBINARYFILEWRITE Write data to file as binary.
%
% Usage:
%   status = commonBinaryFileWrite(filename,data)
%   status = commonBinaryFileWrite(filename,data,precision)
%
%   filename  - string
%               name of a valid (text) file to write to
%
%   data      - numeric
%               data that shall get written as binary to the file
%
%   precision - string
%               Precision used for writing binary data
%               Default: 'real*8'
%               
% See also: fwrite, commonBinaryFileRead, commonTextFileRead,
% commonTextFileWrite

% Copyright (c) 2015, Till Biskup
% 2015-03-25

status = '';

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('filename', @ischar);
    p.addRequired('data', @isnumeric);
    p.addOptional('precision','real*8',@ischar);
    p.parse(filename,data,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

fid = fopen(filename,'w+');
if fid < 0
    status = 'Problems opening file';
    return
end

count = fwrite(fid,data,p.Results.precision);

fclose(fid);

% Check whether all elements have been written
[y,x] = size(data);
if count ~= x*y
    status = sprintf('Problems with writing: %i of %i elements written',...
        count,x*y);
end

end