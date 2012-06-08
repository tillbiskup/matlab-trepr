function varargout = trEPRsave(filename,struct)
% TREPRSAVE Save data from the trEPR toolbox as ZIP-compressed XML files
%
% Usage
%   trEPRsave(filename,struct)
%   [status] = trEPRsave(filename,struct)
%   [status,exception] = trEPRsave(filename,struct)
%
%   filename  - string
%               name of a valid filename
%   data      - struct
%               structure containing data and additional fields
%
%   status    - cell array
%               empty if there are no warnings
%   exception - object
%               empty if there are no exceptions
%
% See also TREPRLOAD

% (c) 2010-12, Till Biskup
% 2012-06-08

% Parse input arguments using the inputParser functionality
parser = inputParser;   % Create an instance of the inputParser class.
parser.FunctionName = mfilename; % Function name included in error messages
parser.KeepUnmatched = true; % Enable errors on unmatched arguments
parser.StructExpand = true; % Enable passing arguments in a structure
parser.addRequired('filename', @ischar);
parser.addRequired('struct', @isstruct);
parser.parse(filename,struct);

try
    % Set file extensions
    zipext = '.tez';
    xmlext = '.xml';
    datext = '.dat';
    % Set status
    status = cell(0);
    % Do the real stuff
    [pathstr, name] = fileparts(filename);
    if isfield(struct,'data')
        data = struct.data;
        struct = rmfield(struct,'data');
        %save(fullfile(tempdir,[name offext]),'data','-ascii');
        stat = writeBinary(fullfile(tempdir,[name datext]),data);
        if ~isempty(stat)
            status{end+1} = sprintf(...
                'Problems writing file %s%s:\n   %s',...
                name,datext,stat);
        end
        [structpathstr, structname] = fileparts(struct.file.name);
        struct.file.name = fullfile(structpathstr,[structname zipext]);
        docNode = struct2xml(struct);
        xmlwrite(fullfile(tempdir,[name xmlext]),docNode);
        zip(fullfile(pathstr,[name zipext]),...
            {fullfile(tempdir,[name datext]),...
            fullfile(tempdir,[name xmlext])});
        movefile([fullfile(pathstr,[name zipext]) '.zip'],...
            fullfile(pathstr,[name zipext]));
        delete(fullfile(tempdir,[name xmlext]));
        delete(fullfile(tempdir,[name datext]));
    else
        [structpathstr, structname] = fileparts(struct.file.name);
        struct.file.name = fullfile(structpathstr,[structname zipext]);
        docNode = struct2xml(struct);
        xmlwrite(fullfile(tempdir,[name xmlext]),docNode);
        zip(fullfile(pathstr,[name zipext]),fullfile(tempdir,[name xmlext]));
        movefile([fullfile(pathstr,[name zipext]) '.zip'],...
            fullfile(pathstr,[name zipext]));
        delete(fullfile(tempdir,[name xmlext]));
    end
    % Second parameter is empty
    exception = [];
catch exception
    status{end+1} = 'A problem occurred:';
    status{end+1} = exception.message;
end

% Assign output parameters
switch nargout
    case 1
        varargout{1} = status;
    case 2
        varargout{1} = status;
        varargout{2} = exception;
    otherwise
        % Do nothing (and _not_ loop!)
end

end

function status = writeBinary(filename,data)
% WRITEBINARY Writing given data to given file as binary (real*4)

% Set status
status = '';

% Open file for (only) writing
fh = fopen(filename,'w');

% Write data
count = fwrite(fh,data,'real*4');

% Close file
fclose(fh);

% Check whether all elements have been written
[y,x] = size(data);
if count ~= x*y
    status = sprintf('Problems with writing: %i of %i elements written',...
        count,x*y);
end

end