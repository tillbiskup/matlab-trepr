function [data,warnings] = trEPRfsc2MetaLoad(filename)
% TREPRFSC2METALOAD Read metafile of fsc2 recorded transient spectra and
% load subsequently all corresponding datasets.
%
% After loading the datasets, additional parameters read from the metafile
% are applied to the metadata of the respective dataasets.
%
% Usage
%   data = trEPRfsc2MetaLoad(filename)
%   [data,warning] = trEPRfsc2MetaLoad(filename)
%
% filename - string
%            name of a valid filename (of a fsc2 metafile)
% data     - struct
%            structure containing data and additional fields
%
% warnings - cell array of strings
%            empty if there are no warnings
%
% If no data could be loaded, data is an empty struct.
% In such case, warning may hold some further information what happened.

% (c) 2011, Till Biskup
% 2011-10-30

% If called without parameter, do something useful: display help
if ~nargin
    help trEPRfsc2MetaLoad
    return;
end

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('filename', @(x)ischar(x));
p.parse(filename);

warnings = cell(0);

% Define identifierString for metafile file format
identifierString = 'metadata fsc2 program trEPR';

try
    % If there is no filename specified, return
    if isempty(filename)
        data = struct();
        warnings{end+1} = struct(...
            'identifier','trEPRfsc2MetaLoad:nofile',...
            'message','No filename or file does not exist'...
            );
        return;
    end
    % If filename does not exist, try to add extension
    if  ~exist(filename,'file')
        [fpath,fname,fext] = fileparts(filename);
        if exist(fullfile(fpath,[fname '.meta']),'file')
            filename = fullfile(fpath,[fname '.meta']);
        else
            data = struct();
            warnings{end+1} = struct(...
                'identifier','trEPRfsc2MetaLoad:nofile',...
                'message','No filename or file does not exist'...
                );
            return;
        end
    end
    
    % Read file
    fh = fopen(filename);
    % Read content of the par file to cell array
    metaFile = cell(0);
    k=1;
    while 1
        tline = fgetl(fh);
        if ~ischar(tline)
            break
        end
        metaFile{k} = tline;
        k=k+1;
    end
    fclose(fh);
    
    % Check for correct file format
    if ~strfind(metaFile{1},identifierString)
            data = struct();
            warnings{end+1} = struct(...
                'identifier','trEPRfsc2MetaLoad:fileformat',...
                'message','File seems to be of wrong format'...
                );
            return;
    end
    
    % For convenience and easier parsing, get an overview where the blocks
    % start in the metafile.
    
    % Block names are defined in a cell array.
    blockNames = {...
        'GENERAL' ...
        'PARAMETERS' ...
        'COMMENT' ...
        'CALIBRATION DATA' ...
        'TERMINATION' ...
        };
    % Assign block names and line numbers where they start to struct
    % The field names of the struct consist of the block names in small
    % letters with spaces removed.
    %
    % NOTE: If a block could not be found, its line number defaults to 1
    %
    % As it is not possible to do a "reverse lookup" in an array, the
    % vector "lineNumbers" holds the line numbers for the blocks
    % separately, if one needs to access them directly, without knowing
    % which block one is looking for.
    blocks = struct();
    lineNumbers = zeros(1,length(blockNames));
    for k = 1:length(blockNames)
        bn = str2fieldName(blockNames{k});
        [~,lineNumber] = max(cellfun(@(x) ~isempty(x),...
            strfind(metaFile,blockNames{k})));
        lineNumbers(k) = lineNumber;
        blocks = setfield(...
            blocks,...
            str2fieldName(blockNames{k}),...
            lineNumber ...
            );
    end
    
    % How to access the line number of the next block starting with a given
    % block (to find out where the current block ends):
    % min(find(lineNumbers > blocks.blockname))
    
    % Parse every single block, using internal function parseBlocks()
    blocknames = fieldnames(blocks);
    for k=1:length(blocknames)
        switch blocknames{k}
            case 'general'
                % Read key-value pairs into structure
                block.general = parseBlocks(metaFile(...
                    getfield(blocks,blocknames{k})+1 : ...
                    lineNumbers(find(...
                    lineNumbers > getfield(blocks,blocknames{k}), 1 ))-2 ...
                    ));
                % Set number of lines in each subblock of the calibration
                % block depending on the measurement type specified in the
                % general block
                switch block.general.measurementType
                    case 'Normal'
                        nLinesCalibDataSubblock = 7;
                    otherwise
                        data = struct();
                        warnings{end+1} = struct(...
                            'identifier','trEPRfsc2MetaLoad:measurementType',...
                            'message','Cannot determine type of measurement.'...
                            );
                        return;
                end
            case 'parameters'
                % Read key-value pairs into structure
                block.parameters = parseBlocks(metaFile(...
                    getfield(blocks,blocknames{k})+1 : ...
                    lineNumbers(find(...
                    lineNumbers > getfield(blocks,blocknames{k}), 1 ))-2 ...
                    ));
            case 'comment'
                % Assign comment lines to block.comment field
                block.comment = metaFile(...
                    getfield(blocks,blocknames{k})+1 : ...
                    lineNumbers(find(...
                    lineNumbers > getfield(blocks,blocknames{k}), 1 ))-2 ...
                    );
            case 'calibrationData'
                % Determine number of scans
                noScans = (lineNumbers(find(...
                    lineNumbers > getfield(blocks,blocknames{k}),1))-2 ...
                    -getfield(blocks,blocknames{k}))...
                    /nLinesCalibDataSubblock;
                % Check whether we have the correct number of blocks (needs
                % to be a natural number), therefore divide by 1 and look
                % for the remainder
                if rem(noScans,1)
                    data = struct();
                    warnings{end+1} = struct(...
                        'identifier','trEPRfsc2MetaLoad:calibrationBlock',...
                        'message','Problems parsing calibration block.'...
                        );
                    return;
                end
                % For each scan, read key-value pairs into structure
                for l = 1:noScans
                    block.calibrationData(l) = parseBlocks(metaFile(...
                        getfield(blocks,blocknames{k})...
                        +2+((l-1)*nLinesCalibDataSubblock) : ...
                        getfield(blocks,blocknames{k})...
                        +2+((l-1)*nLinesCalibDataSubblock) + 3 ...
                        ));
                end
            case 'termination'
                % Read key-value pairs into structure
                block.termination = parseBlocks(metaFile(...
                    getfield(blocks,blocknames{k})+1 : end)...
                    );
            otherwise
                % That shall not happen!
                warnings{end+1} = struct(...
                    'identifier','trEPRfsc2MetaLoad:parser',...
                    'message',sprintf(...
                    'Parse error: Unknown block name %s\n',...
                    blocknames{k})...
                    );
                return;
        end
    end
    
    % Assing cell array of right size to data
    data = cell(length(block.calibrationData),1);
    
    % For each calibration data block, read corresponding data file and
    % process the metadata accordingly
    %
    % Get file path of the metafile, assuming that the data files are in
    % the same directory. That prevents confusion steming from the fact
    % that the metafile contains the full paths of the files on the
    % original system (computer attached to the spectrometer)
    [metaFilePath,~,~] = ...
        fileparts(filename);
    for k=1:length(block.calibrationData)
        [~,dataFileName,dataFileExtension] = ...
            fileparts(block.calibrationData(k).fileName);
        % Assuming that the data files are in the same directory as the
        % metafile
        [data{k},warning{k}] = trEPRfsc2Load(...
            fullfile(metaFilePath,[dataFileName dataFileExtension]));
        data{k}.filename = ...
            fullfile(metaFilePath,[dataFileName dataFileExtension]);
        data{k}.file.name = ...
            fullfile(metaFilePath,[dataFileName dataFileExtension]);
        data{k}.file.format = 'fsc2';
        % TODO: Assign parameters from metafile to datasets
    end
    
    %data = block;
catch exception
    throw(exception);
end

end

% STR2FIELDNAME Internal function converting strings into valid
%               field names for structs
%
% Currently, spaces are removed, starting with the second word parts of
% the fieldname capitalised, and parentheses "(" and ")" removed.
%
% string    - string
%             string to be converted into a field name
% fieldName - string
%             string containing the valid field name for a struct
function fieldName = str2fieldName(string)

% Eliminate brackets
string = strrep(strrep(string,')',''),'(','');
fieldName = regexp(lower(string),' ','split');
if length(fieldName) > 1
    fieldName(2:end) = cellfun(...
        @(x) [upper(x(1)) x(2:end)],...
        fieldName(2:end),...
        'UniformOutput',false);
    fieldName = [fieldName{:}];
else
    fieldName = fieldName{1};
end

end

% PARSEBLOCKS Internal function parsing blocks of the metafile
%
% A given block is parsed, the lines split by the first appearance of the
% delimiter ":", the first part converted into a field name for a struct
% and  the second part assigned to that field of the struct.
%
% blockData  - cell array of strings
%              block data to be parsed
% parameters - struct
%              structure containing key-value pairs
function parameters = parseBlocks(blockData)

% Assign output parameter
parameters = struct();
blockLines = cellfun(...
    @(x) regexp(x,':','split','once'),...
    blockData,...
    'UniformOutput', false);
for k=1:length(blockLines)
    % Fill parameters structure
    if ~isempty(blockLines{k}{1}) % Prevent empty lines being parsed
        if isnan(str2double(blockLines{k}{2}))
            parameters = setfield(parameters,...
                str2fieldName(blockLines{k}{1}),...
                strtrim(blockLines{k}{2})...
                );
        else
            parameters = setfield(parameters,...
                str2fieldName(blockLines{k}{1}),...
                str2double(strtrim(blockLines{k}{2}))...
                );
        end
    end
end

end
