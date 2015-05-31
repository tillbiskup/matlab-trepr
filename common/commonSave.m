function [status,exception] = commonSave(filename,struct,varargin)
% COMMONSAVE Save data from the common toolbox as ZIP-compressed XML files.
%
% Whereas the structure of the dataset gets converted into XML, the actual
% data are extracted from the structure and saved as separate binary files
% (default precision "real*8", prior to 2015-03-16 "real*4"). Altogether,
% the XML and binary files are stored as a compressed ZIP archive, thus
% allowing for being maximally independent of both, Matlab(r) and the
% operating system used.
%
% Usage
%   commonSave(filename,struct)
%   [status] = commonSave(filename,struct)
%   [status,exception] = commonSave(filename,struct)
%
%   commonSave(filename,struct,<parameters>)
%
%   filename   - string
%                name of a valid filename
%
%   data       - struct
%                structure containing data and additional fields
%
%   status     - cell array
%                empty if there are no warnings
%
%   exception  - object
%                empty if there are no exceptions
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
% (*) Prior to 2015-03-16, default was "real*4", since then default is
%     "real*8". For backwards compatibility, the additional (optional)
%     parameter "precision" has been introduced. 
%     For details of the strings specifying the precision in Matlab(r),
%     type "doc fwrite".
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
% See also COMMONLOAD, FWRITE

% Copyright (c) 2010-15, Till Biskup
% 2015-03-25

% Assign output
status = cell(0);
exception = [];

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('filename', @ischar);
    p.addRequired('struct', @isstruct);
    p.addParamValue('precision','real*8',@ischar);
    p.addParamValue('extension','.xbz',@ischar);
    p.parse(filename,struct,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

% Version string
% IMPORTANT: Change upon every change of the way data are stored
%            For each change, an accompagnying file "loadDatasetV#" needs
%            to be created in the "private" directory for loading this
%            version of the dataset. See "commonLoad" for details.
versionString = '2.0';

% Some more settings
binaryDataDir = 'binaryData';
schemaString = 'org.apache.xerces.dom.DocumentImpl';
zipExtension = p.Results.extension;
xmlFileName = 'struct.xml';

% Set field names to be saved as binary
binaryFieldNames = {'data','origdata','calculated'};

try
    [pathstr, name] = fileparts(filename);
    tmpDir = createTempDir(name);
    
    mkdir(fullfile(tmpDir,binaryDataDir));
    
    % Handle data that shall be saved as binary
    for binaryFieldName = 1:length(binaryFieldNames)
        if isfield(struct,binaryFieldNames{binaryFieldName})
            tmpData = struct.(binaryFieldNames{binaryFieldName});
            struct = rmfield(struct,binaryFieldNames{binaryFieldName});
            binaryWriteStatus = commonBinaryFileWrite(...
                fullfile(tmpDir,binaryDataDir,...
                binaryFieldNames{binaryFieldName}),...
                tmpData,p.Results.precision);
            if ~isempty(binaryWriteStatus)
                status{end+1} = sprintf(...
                    'Problems writing file %s:\n   %s',...
                    binaryFileName,binaryWriteStatus); %#ok<AGROW>
            end
            % Save dimensions for each binary file as well
            commonTextFileWrite(...
                fullfile(tmpDir,binaryDataDir,...
                [binaryFieldNames{binaryFieldName} '.dim']),...
                num2str(size(tmpData)));
        end
    end
    
    % Add proper extension to file name in struct
    [structpathstr, ~] = fileparts(struct.file.name);
    struct.file.name = fullfile(structpathstr,[name zipExtension]);
    
    % Write XML file
    docNode = struct2XML(struct);
    xmlwrite(fullfile(tmpDir,xmlFileName),docNode);
    
    % Write additional files according to specification
    commonTextFileWrite(fullfile(tmpDir,'VERSION'),versionString);
    commonTextFileWrite(fullfile(tmpDir,'PRECISION'),p.Results.precision);
    commonTextFileWrite(fullfile(tmpDir,'SCHEMA'),schemaString);
    
    % Copy README from private directory
    [mfiledir,~,~] = fileparts(mfilename('fullpath'));
    copyfile(...
        fullfile(mfiledir,'private','README.dataset'),...
        fullfile(tmpDir,'README'));
    
    % ZIP files
    zip(fullfile(pathstr,name),tmpDir);
    movefile([fullfile(pathstr,name) '.zip'],...
        fullfile(pathstr,[name zipExtension]));
    
    % Delete temporary directory
    statusString = deleteTempDir(tmpDir);
    if ~isempty(statusString)
        status{end+1} = statusString;
    end
catch exception
    status{end+1} = 'A problem occurred:';
    status{end+1} = exception.message;
end

end

function tmpDir = createTempDir(name)
% CREATETEMPDIR Create temporary directory in system's temporary directory
% and in this directory, create directory for ZIP archive given by "name".

tmpDir = tempname;
mkdir(tmpDir);
tmpDir = fullfile(tmpDir,name);
mkdir(tmpDir);

end

function status = deleteTempDir(name)
% DELETETEMPDIR Delete temporary directory in system's temporary directory.

[temporaryDirectory,~] = fileparts(name);
[~,status,~] = rmdir(temporaryDirectory,'s');

end
