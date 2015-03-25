function [metaData,format] = commonInfofileLoad(filename)
% COMMONINFOFILELOAD Load and parse info file and return contents as
% hierarchical struct using camelCased block and field names. 
%
% Usage
%   metaData = commonInfofileLoad(filename);
%   [metaData,identifierString] = commonInfofileLoad(filename);
%
%   filename - string
%              Name of info file to read
%              Extension is always assumed to be .info
%
%   metaData - struct
%              Hierarchical structure containing metadata from info file 
%
%   format   - struct
%              Information from first line of info file used to identify
%              type and version (with date).
%              Fields are: type, version, date
%              See specification (link below) for details.
%
% For a description of the specification of the info file format, see
%   http://www.till-biskup.de/en/software/info/

% Copyright (c) 2014-15, Till Biskup
% 2015-03-25

metaData = struct();

try
    % Parse input arguments using the inputParser functionality.
    p = inputParser;             % Create inputParser instance.
    p.FunctionName  = mfilename; % Include function name in error messages.
    p.KeepUnmatched = true;      % Enable errors on unmatched arguments.
    p.StructExpand  = true;      % Enable passing arguments in a structure.
    p.addRequired('filename',@(x)ischar(x));
    p.parse(filename);
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

infoFileContents = loadInfoFile(filename);
if isempty(infoFileContents)
    fprintf('Problems reading info file "%s".\n',filename);
    return;
end

format = getInfoFileFormat(infoFileContents{1});

infoFileContents = removeCommentLines(infoFileContents);

metaData = parseInfoFileContents(infoFileContents);
if isempty(metaData)
    fprintf('Problems parsing info file "%s".\n',filename);
    return;
end

end

function infoFileContents = loadInfoFile(filename)
% LOADINFOFILE Load info file and return contents as cell array.
%   filename         - string
%   infoFileContents - cell array

infoFileContents = cell(0);

checkedFilename = checkFileExistence(filename);
if isempty(checkedFilename)
    fprintf('File "%s" seems not to exist.\n',filename);
    return;
end

fid = fopen(checkedFilename);
if fid<=2
    fprintf('Problem reading file "%s".\n',checkedFilename);
    return;
end
lineNo=1;
while ~feof(fid)
    infoFileContents{lineNo} = fgetl(fid);
    lineNo=lineNo+1;
end
fclose(fid);

end

function checkedFilename = checkFileExistence(filename)
% CHECKFILEEXISTENCE Check whether file exists and set default extension.
%   filename        - string
%   checkedFilename - string

checkedFilename = '';

[path,name,~] = fileparts(filename);
filename = fullfile(path,[name '.info']);
if exist(filename,'file')
    checkedFilename = filename;
end

end

function format = getInfoFileFormat(identifierString)
% GETINFOFILEFORMAT Return info read from first line of info file
% containing type, version and release date of version
%   format - struct

format.type = strtrim(identifierString(1:strfind(identifierString,'-')-1));
format.version = strtrim(char(...
    regexp(identifierString,'(?<=v.).*(?=\(\d{4}-\d{2}-\d{2})','match')));
format.date = identifierString(strfind(identifierString,'(')+1:end-1);

end

function infoFileContents = removeCommentLines(infoFileContents)
% REMOVECOMMENTLINES Remove lines starting with comment character
%   infoFileContents - cell array

infoFileContents(cellfun(...
    @(x)~isempty(x) && strcmpi(x(1),'%'),...
    infoFileContents)) = [];

end

function metaData = parseInfoFileContents(infoFileContents)
% PARSEINFOFILECONTENTS Parse info file contents and return structure
%   infoFileContents - cell array
%   metaData         - struct

metaData = struct();

% Get block separators (empty lines, lines with only whitespace characters)
blockSeparatorLines = ...
    find(cellfun(@(x)isempty(x) || (all(isspace(x))),infoFileContents));
% Get line where comment block starts (always last block in file)
commentStartLine = ...
    find(cellfun(@(x)strcmpi(x,'comment'),infoFileContents));
% Remove (false) block separators from within COMMENT block
blockSeparatorLines(blockSeparatorLines>commentStartLine) = [];

% Separate blocks into cell arrays and parse
for blockNo = 1:length(blockSeparatorLines)-1
    block = infoFileContents(...
        blockSeparatorLines(blockNo)+1:blockSeparatorLines(blockNo+1)-1);
    metaData.(sanitiseFieldName(block{1})) = ...
        parseInfoFileBlock(block(2:end));
end

% Parse comment
metaData.comment = infoFileContents(blockSeparatorLines(end)+2:end);

end

function sanitisedFieldName = sanitiseFieldName(fieldName)
% SANITISEFIELDNAME Convert fieldname into valid fieldname for struct
%   fieldName          - string
%   sanitisedFieldName - string

% Convert to lower case
sanitisedFieldName = lower(fieldName);
% If there is a percent sign (aka comment), cut comment
if strfind(sanitisedFieldName,'%')
    sanitisedFieldName = strtrim(...
        sanitisedFieldName(1:strfind(sanitisedFieldName,'%')-1));
end
% If there are spaces in the field name, camelCase and remove spaces
if find(isspace(sanitisedFieldName))
    sanitisedFieldName(find(isspace(sanitisedFieldName))+1) = ...
        upper(sanitisedFieldName(find(isspace(sanitisedFieldName))+1));
    sanitisedFieldName(isspace(sanitisedFieldName)) = [];
end

end

function parsedBlock = parseInfoFileBlock(infoFileBlock)
% PARSEINFOFILEBLOCK Parse info file block and return structure
%   infoFileBlock - cell array
%   parsedBlock   - struct

parsedBlock = struct();
for blockLine = 1:length(infoFileBlock)
    if isspace(infoFileBlock{blockLine}(1)) && blockLine > 1
        % If line starts with whitespace
        blockLineParts = regexp(infoFileBlock{blockLine-1},':','split','once');
        parsedBlock.(sanitiseFieldName(strtrim(blockLineParts{1}))) = [ ...
            parsedBlock.(sanitiseFieldName(strtrim(blockLineParts{1}))) ...
            ' ' strtrim(infoFileBlock{blockLine})];
    else
        % Separate line along delimiter, ":" in this case
        blockLineParts = regexp(infoFileBlock{blockLine},':','split','once');
        if length(blockLineParts) == 2
            parsedBlock.(sanitiseFieldName(strtrim(blockLineParts{1}))) = ...
                strtrim(blockLineParts{2});
        else
            warning(sprintf('%s:MissingColon',mfilename),...
                'Problems parsing info file. Probably missing ":"');
        end
    end
end

end
