function [data,warning] = commonLoad(filename,varargin)
% COMMONLOAD Read ZIP-compressed XML file and data (if available).
%
% Usage:
%   [data,warning] = commonLoad(filename)
%   [data,warning] = commonLoad(filename,<parameters>)
%
%   filename   - string
%                name of the ZIP archive containing the XML (and data)
%                file(s)
%
%   data       - struct
%                content of the XML file
%                data.data holds the data read from the ZIP archive
%
%   warning    - cell array
%                Contains warnings if there are any, otherwise empty
%
%
%   parameters - key-value pairs (OPTIONAL)
%
%                Optional parameters may include:
%
%                precision - string
%                            Precision of the binary data written as binary
%                            file.
%                            Default: real*8 (*)
%
%                extension - string
%                            File extension used for the files the dataset
%                            gets saved to.
%                            Default: .xbz
%
% For details of the concept of a dataset, see its respective website
% (currently available only in German):
%
%   http://www.till-biskup.de/de/software/datensatz/index
%
% Details of the implementation can be found there as well:
%
%   http://www.till-biskup.de/de/software/datensatz/implementierung
%   http://www.till-biskup.de/de/software/datensatz/austauschformat
%
% Compatibility:
%
% This function aims at full compatibility with datasets saved with
% versions of the trEPR and TA toolboxes prior to introducing the
% implementation scheme described at the website referred to above. Loading
% datasets in previous formats should therefore never be a problem, as long
% as the toolboxes get developed...
%
% SEE ALSO commonSave

% Copyright (c) 2011-15, Till Biskup
% 2015-03-25

% NOTE FOR DEVELOPERS:
% For each version of the dataset storage format, an accompagnying file
% "loadDatasetV#" needs to be created in the "private" directory handling
% the respective version of the dataset storage format.
%
% The version string is set in the "commonSave" routine. See there for
% details.

% Assign default output
data = logical(false);
warning = cell(0);

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('filename', @(x)ischar(x) || iscell(x));
    p.addParamValue('precision','real*8',@ischar);
    p.addParamValue('extension','.xbz',@ischar);
    % Note, this is to be compatible with TAload - currently without function!
    p.addParamValue('checkFormat',logical(true),@islogical);
    p.parse(filename);
catch exception
    disp(['(EE) ' exception.message]);
    return;
end


% Handle multiple filenames in cell array
if iscell(filename)
    data = cell(length(filename),1);
    warning = cell(length(filename),1);
    for k=1:length(filename)
        [data{k},warning{k}] = commonLoad(filename{k},varargin{:});
    end
    return;
end

% Does the file exist - and is it a file (not a directory)?
if exist(filename,'file') ~= 2
    % Try to set proper extension
    [tmpPath,tmpName,~] = fileparts(filename);
    filename = fullfile(tmpPath,[tmpName p.Results.extension]);
    % If it still doesn't exist, throw error and exit
    if ~exist(filename,'file')
        warning{end+1} = sprintf(...
            '"%s" seems not to be a valid filename. Abort.',filename);
        return;
    end
end

tmpDir = createTempDir();

% Unzip archive
try
    archiveFilenames = unzip(filename,tmpDir);
catch exception
    warning{end+1} = sprintf('%s\n%s\n"%s"\n%s\n',...
        exception.identifier,...
        'Problems with unzipping:',...
        filename,...
        'seems not to be a valid zip file. Aborted.');
    return;
end

if all(cellfun(@isempty,strfind(archiveFilenames,'VERSION')))
    [data,warning] = loadDatasetV1(archiveFilenames);
else
    % Read VERSION file and create function name for loading dataset using
    % the form "loadDatasetV#" - where "." is replaced by "_" in version
    % string.
    versionString = char(strrep(commonTextFileRead(...
        archiveFilenames{...
        not(cellfun(@isempty,strfind(archiveFilenames,'VERSION')))}),...
        '.','_'));
    loadFunction = str2func(['loadDatasetV' versionString]);
    [data,warning] = loadFunction(archiveFilenames);
end

% Delete temporary directory
statusString = deleteTempDir(tmpDir);
if ~isempty(statusString)
    warning{end+1} = statusString;
end

end

function tmpDir = createTempDir()
% CREATETEMPDIR Create temporary directory in system's temporary directory.

tmpDir = tempname;
mkdir(tmpDir);

end

function status = deleteTempDir(temporaryDirectory)
% DELETETEMPDIR Delete temporary directory in system's temporary directory.

[~,status,~] = rmdir(temporaryDirectory,'s');

end
