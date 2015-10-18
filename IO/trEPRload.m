function [data,warnings] = trEPRload(filename, varargin)
% TREPRLOAD Load files or scans whole directories for readable files
%
% Usage
%   trEPRload(filename)
%   [data] = trEPRload(filename)
%   [data,warnings] = trEPRload(filename)
%
%   filename - string
%              name of a valid filename
%   data     - struct
%              structure containing data and additional fields
%
%   warnings - cell array of strings
%              empty if there are no warnings
%
% If no data could be loaded, data is an empty struct.
% In such case, warning may hold some further information what happened.
%
% If called with no output argument, the data are written to variables
% in the workspace that have the same* name as the file(s) read.
%
% The function is in principle only a wrapper for other functions that
% are specialized to read the different kinds of input files.
% Configuration of these functions via the file 'trEPRload.ini' - see
% there for details. Only if it is an ascii file and no function is
% found from the configuration file, 'importdata' is called to try to
% handle the data.
%
% *Same means here that a regexprep is performed removing all
% non-allowed characters for MATLAB variables from the filename.
%
% See also TREPRFSC2LOAD, TREPRDATASTRUCTURE.

% Copyright (c) 2009-2015, Till Biskup
% 2015-10-18

% Assign default output
data = struct();
warnings = {};

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('filename', @(x)(ischar(x) || iscell(x) || ...
        (isstruct(x) && isfield(x,'name'))));
    p.addParamValue('combine',logical(false),@islogical);
    p.addParamValue('loadInfoFile',logical(false),@islogical);
    p.parse(filename,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

% NOTE: class() returns the type of the variable (here: char, cell, struct)
switch class(filename)
    case 'cell'
        filename = sanitiseFileNameList(filename);
        data = cell(length(filename),1);
        warnings = cell(length(filename),1);
        for iFilename = 1:length(filename)
            [data{iFilename},warnings{iFilename}] = ...
                trEPRload(filename{iFilename});
        end
    case 'struct'
        [data,warnings] = trEPRload({filename.name});
    otherwise
        % "char" due to input parsing (see above)
        switch exist(filename) %#ok<EXIST>
            case 0 % doesn't exist
                % Check for basename
                filename = addDir2Filename(...
                    filename,dir(sprintf('%s.*',filename)));
                [data,warnings] = trEPRload(filename);
            case 2 % regular file
                [data,warnings] = loadFile(filename);
            case 7 % directory
                filename = addDir2Filename(filename,dir(filename));
                [data,warnings] = trEPRload(filename);
        end
end

% Remove empty elements in cell arrays
if iscell(data)
    data(cellfun(@(x)isempty(x),data)) = [];
end
if iscell(warnings)
    warnings(cellfun(@(x)isempty(x),warnings)) = [];
end

% Combine if necessary
if iscell(data) && p.Results.combine
    [data,status] = trEPRcombine(data);
    if ~isempty(status)
        warnings{end+1} = status;
    end
end

if isempty(filename)
    return;
end

% Replace "filename" with single string
if iscell(filename)
    filename = filename{1};
end

% Load and apply info file if necessary
if ~isempty('data') && p.Results.loadInfoFile ...
        && ~strcmpi(data.file.format,'xmlzip')
    data = loadAndApplyInfoFile(data,filename);
end

if ~nargout
    % assign content to a variable in the workspace with the same name as
    % the original file
    [~, name, ext] = fileparts(filename);
    name = cleanFileName([name ext]);
    assignVariableInWorkspace(name,data);
    assignin('base','warnings',warnings);
end
    
end

function filenames = sanitiseFileNameList(filenames)
% Remove all unwanted files, such as ".", "..", "*~", and "*.info"

% Remove names starting with "."
filenames(strncmpi(filenames,'.',1)) = [];

% Remove other patterns (need to do that in reverse loop)
for filename = length(filenames):-1:1
    % Remove files with trailing "~"
    if strcmpi(filenames{filename}(end),'~')
        filenames(filename) = [];
    end
    % Remove files with extension ".info"
    if length(filename) > 4 && ...
            strcmpi(filenames{filename}(end-4:end),'.info')
        filenames(filename) = [];
    end
end

% Sort list
filenames = sort(filenames);

end

function filenames = addDir2Filename(dirname,filenames)

filenames = sanitiseFileNameList({filenames.name});
for filename=1:length(filenames)
    filenames{filename} = fullfile(dirname,filenames{filename});
end

end

% --- load file and return struct with the content of the file together
% with the filename and possibly more info
function [data,warnings] = loadFile(filename)
    data = [];
    warnings = cell(0);

    if isempty(dir(filename))
        errStr = sprintf('"%s" not found',filename);
        trEPRmsg(errStr,'error');
        warnings{end+1} = errStr;
        return;
    end
    
    % Set struct containing all filetypes that are recognized by this
    % function and can be read. This is done by reading in the
    % corresponding ini file trEPRload.ini.
    fileFormats = trEPRiniFileRead([mfilename('fullpath') '.ini']);
    
    % read file formats into cell array
    fileFormatNames = fieldnames(fileFormats);
    asciiFileFormats = cell(0);
    binaryFileFormats = cell(0);
    for k=1:length(fileFormatNames)
        switch fileFormats.(fileFormatNames{k}).type
            case 'ascii'
                asciiFileFormats{end+1} = fileFormatNames{k}; %#ok<AGROW>
            case 'binary'
                binaryFileFormats{end+1} = fileFormatNames{k}; %#ok<AGROW>
        end
    end

    % open file
    fid = fopen(filename);

    % Initialize switch resembling binary or ascii data
    isBinary = logical(false);
    
    % Read first characters of the file and try to determine whether it is
    % binary
    firstChars = fread(fid,5);
    for k=1:length(firstChars)
        if firstChars(k) < 32 && firstChars(k) ~= 10 && firstChars(k) ~= 13
            isBinary = logical(true);
        end
    end
    
    % Reset file pointer, then read first line and try to determine from
    % that the filetype
    % PROBLEM: fsc2 files tend to have a single empty comment line as the
    % first line. Therefore, check whether the first line is too short for
    % an identifier string, and in this case, read a second line.
    fseek(fid,0,'bof');
    firstLine = fgetl(fid);
    
    % If firstline is "-1", thus we are at the end of the file, meaning we
    % opened an empty file, return immediately
    if isnumeric(firstLine) && firstLine == -1
        data = [];
        return;
    end
    
    if isempty(regexp(firstLine,'[a-zA-Z]','once'))
        % If first line does not contain any characters necessary for an
        % identifier string (problem with fsc2 files, see comment above),
        % read another line. 
        firstLine = fgetl(fid);
    end
    
    % close file
    fclose(fid);
    
    if isBinary
       for k = 1 : length(binaryFileFormats)
           [~,~,ext] = fileparts(filename);
           if any(strfind(ext,...
                   fileFormats.(binaryFileFormats{k}).identifierString))
                functionHandle = ...
                    str2func(fileFormats.(binaryFileFormats{k}).function);
                [data,warnings] = functionHandle(filename);
                if ~isstruct(data) && ~iscell(data)
                    data.data = data;
                end
                if ~iscell(data)
                    data.file.name = filename;
                    data.file.format = binaryFileFormats{k};
                end
                break;
           end
       end
    else
        % else try to find a matching function from the ini file
        for k = 1 : length(asciiFileFormats)   
            if any(strfind(firstLine,...
                    fileFormats.(asciiFileFormats{k}).identifierString))
                functionHandle = ...
                    str2func(fileFormats.(asciiFileFormats{k}).function);
                [data,warnings] = functionHandle(filename);
                if ~isstruct(data) && ~iscell(data)
                    data.data = data;
                end
                if ~iscell(data)
                    data.file.name = filename;
                    data.file.format = asciiFileFormats{k};
                end
                break;
            end
        end
        % else try to handle it with importdata
        if ~exist('data','var')
            data = importdata(filename);
            if isfield(data,'textdata')
                data.header = data.textdata;
                if isfield(data,'colheaders')
                    data.colheaders = data.colheaders;
                end
                data.data = data.data;
            else
                data.data = data;
            end
            % In case we have not loaded anything
            if isempty(data.data)
                data = [];
                return;
            end
            data.file.name = filename;
            data.file.format = 'unspecified ASCII';
            % Create axis informations from dimensions
            [y,x] = size(data.data);
            data.axes.data(1).values = linspace(1,x,x);
            data.axes.data(1).measure = '';
            data.axes.data(1).unit = '';
            data.axes.data(2).values = linspace(1,y,y);
            data.axes.data(2).measure = '';
            data.axes.data(2).unit = '';
            
            % Assign warnings
            warnings = [];
        end
    end
end

function data = loadAndApplyInfoFile(data,filename)

% Try to load info file
[fpath,fname,~] = fileparts(filename);
infoFileName = fullfile(fpath,[fname '.info']);

% If infoFile doesn't exist, try with filename from dataset
if ~exist(infoFileName,'file')
    [fpath,fname,~] = fileparts(data.file.name);
    infoFileName = fullfile(fpath,[fname '.info']);
end

% If infoFile still doesn't exist, return
if ~exist(infoFileName,'file')
    trEPRmsg({'Could not find accompanying info file.',...
        infoFileName},'warning');
    return;
end

[parameters,ifpwarnings] = trEPRinfoFileParse(infoFileName,'map');

% Fix problem with overriding MWfrequency vector
MWfrequency = data.parameters.bridge.MWfrequency.values;
if isempty(ifpwarnings)
    data = commonStructCopy(data,parameters);
    data.parameters.bridge.MWfrequency.values = MWfrequency;
    trEPRmsg({'Loaded info file and applied contents to dataset',...
        infoFileName},'info');
else
    trEPRmsg(ifpwarnings,'warning');
end

end

% --- Cleaning up filename so that it can be used as variable name in the
% MATLAB workspace 
function cleanName = cleanFileName(filename)
    cleanName = regexprep(filename,...
        {'\.','[^a-zA-Z0-9_]','^[0-9]','^_'},{'_','','',''});
    if ~isletter(cleanName(1))
        cleanName = sprintf('a%s',cleanName);
    end
end

% --- Assign loaded data to variable in workspace
function assignVariableInWorkspace(variableName,variableContent)

evalString = sprintf('who(''%s'')',variableName);

if ~isempty(evalin('base',evalString))
    promptString = sprintf('%s "%s" %s\n%s\n',...
        'A variable named',variableName,...
        'exists already in your workspace.',...
        'Please provide an alternative name (hit Enter to overwrite):');
    answer = input(promptString,'s');
    
    if ~isempty(answer)
        variableName = cleanFileName(variableName);
    end
end

assignin('base',variableName,variableContent);

end
