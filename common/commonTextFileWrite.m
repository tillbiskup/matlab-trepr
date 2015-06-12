function status = commonTextFileWrite(filename,text)
% COMMONTEXTFILEWRITE Write cell array as text to file.
%
% Usage:
%   status = commonTextFileWrite(filename,text);
%
%   filename - string
%              name of a valid (text) file to write to
%
%   text     - cell array
%              text that shall get written to the file
%
% See also: commonTextFileRead, commonBinaryFileWrite, commonBinaryFileRead

% Copyright (c) 2012-15, Till Biskup
% 2015-03-25

status = '';

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('filename', @ischar);
    p.addRequired('text', @(x)iscell(x) || ischar(x));
    p.parse(filename,text);
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

fid = fopen(filename,'w+');
if fid < 0
    status = 'Problems opening file';
    return
end

if iscell(text)
    for k=1:length(text)
        if ischar(text{k})
            fprintf(fid,'%s\n',text{k});
        end
    end
else
    fprintf(fid,'%s\n',text);
end


fclose(fid);

end