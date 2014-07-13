function [parameters,warnings] = trEPRinfoFileParse(filename,varargin)
% TREPRINFOFILEPARSE Parse Info files of trEPR spectra and return a
% structure containing all parameters.
%
% Usage
%   parameters = trEPRinfoFileParse(filename)
%   [parameters,warning] = trEPRinfoFileParse(filename)
%   [parameters,warning] = trEPRinfoFileParse(filename,command)
%
% filename   - string
%              Valid filename (of a trEPR Info file)
% command    - string (OPTIONAL)
%              Additional command controlling what to do with the parsed
%              data.
%              'map' - Map the parsed fields to the trEPR toolbox structure
%                      and return a structure with these mapped fields
%                      instead of the original parsed fields of the Info
%                      file.
%
% parameters - struct
%              structure containing parameters from the trEPR Info file
%
%              In case of the optional 'map' command, structure containing
%              the parameters from the trEPR Info file mapped onto their
%              couterparts of the trEPR data structure.
%
% warnings   - cell array of strings
%              empty if there are no warnings
%
% See also: TREPRINFOFILECREATE, TREPRINFOFILEWRITE

% Copyright (c) 2012-13, Till Biskup
% 2013-02-26

% If called without parameter, do something useful: display help
if ~nargin && ~nargout
    help trEPRinfoFileParse
    return;
end

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('filename', @(x)ischar(x));
p.addOptional('command','',@(x)ischar(x));
p.parse(filename,varargin{:});

warnings = cell(0);

% Define identifierString for Info File format
identifierString = 'trEPR Info file - ';

% Define comment character
commentChar = '%';

try
    parameters = struct();

    % If there is no filename specified, return
    if isempty(filename)
        warnings{end+1} = struct(...
            'identifier','trEPRinfoFileParse:nofile',...
            'message','No filename or file does not exist'...
            );
        return;
    end
    % If filename does not exist, try to add extension
    if  ~exist(filename,'file')
        [fpath,fname,~] = fileparts(filename);
        if exist(fullfile(fpath,[fname '.meta']),'file')
            filename = fullfile(fpath,[fname '.info']);
        else
            parameters = struct();
            warnings{end+1} = struct(...
                'identifier','trEPRinfoFileParse:nofile',...
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
            parameters = struct();
            warnings{end+1} = struct(...
                'identifier','trEPRinfoFileParse:fileformat',...
                'message','File seems to be of wrong format'...
                );
            return;
    end
    
    % For convenience and easier parsing, get an overview where the blocks
    % start in the metafile.
    
    % Block names are defined in a cell array.
    blockNames = {...
        'GENERAL' ...
        'SAMPLE' ...
        'TRANSIENT' ...
        'MAGNETIC FIELD' ...
        'BACKGROUND' ...
        'BRIDGE' ...
        'VIDEO AMPLIFIER' ...
        'RECORDER' ...
        'PROBEHEAD' ...
        'PUMP' ...
        'TEMPERATURE' ...
        'FIELD CALIBRATION' ...
        'FREQUENCY CALIBRATION' ...
        'COMMENT' ...
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
        [~,lineNumber] = max(cellfun(@(x) ~isempty(x),...
            strfind(metaFile,blockNames{k})));
        lineNumbers(k) = lineNumber;
        blocks.(str2fieldName(blockNames{k})) = lineNumber;
    end

    % How to access the line number of the next block starting with a given
    % block (to find out where the current block ends):
    % min(find(lineNumbers > blocks.blockname))
    
    % Parse every single block, using internal function parseBlocks()
    blocknames = fieldnames(blocks);
        
    for k=1:length(blocknames)
        if strcmpi(blocknames{k},'comment')
            % Assign comment lines to block.comment field
            block.comment = metaFile(...
                blocks.(blocknames{k})+1 : length(metaFile));
        else
            % Assign block fields generically
            block.(blocknames{k}) = parseBlocks(metaFile(...
                blocks.(blocknames{k})+1 : ...
                lineNumbers(find(...
                lineNumbers > blocks.(blocknames{k}), 1 ))-2 ...
                ),commentChar);
        end
    end
    
    parameters = block;
    
    if p.Results.command
        switch lower(p.Results.command)
            case 'map'
                parameters = mapToDataStructure(parameters);
            otherwise
                disp(['trEPRinfoFileParse() : Unknown command "'...
                    p.Results.command '"']);
        end
    end
catch exception
    throw(exception);
end

end


% MAPTODATASTRUCTURE Internal function mapping the parameters read to the
%                    trEPR toolbox data structure.
%
% parameter     - struct
%                 Structure containing the parsed contents of the Info file
%
% dataStructure - Structure containing the fields of the trEPR toolbox data
%                 structure with mapped information from the input
%
function dataStructure = mapToDataStructure(parameters)
try
    dataStructure = struct();
    
    % Cell array correlating struct fieldnames read from the metafile and
    % from the toolbox data structure.
    % The first entry contains the fieldname generated while parsing the
    % metafile, the second entry contains the corresponding field name of
    % the toolbox data structure struct. The third parameter, 
    % finally, tells the program how to parse the corresponding entry.
    % Here, "numeric" means that the numbers of the field should be treated
    % as numbers, "copy" means to just copy the field unaltered, and
    % "valueunit" splits the field in a numeric value and a string
    % containing the unit.
    matching = {...
        % GENERAL
        'general.filename','file.name','copy';...
        'general.operator','parameters.operator','copy';...
        'general.label','label','copy';...
        'general.purpose','parameters.purpose','copy';
        'general.spectrometer','parameters.spectrometer.name','copy';...
        'general.software','parameters.spectrometer.software','copy';...
        'general.runs','parameters.runs','numeric';...
        'general.shotRepetitionRate','parameters.shotRepetitionRate','valueunit';...
        % SAMPLE
        'sample.name','sample.name','copy';...
        'sample.description','sample.description','copy';...
        'sample.buffer','sample.buffer','copy';...
        'sample.preparation','sample.preparation','copy';...
        'sample.tube','sample.tube','copy';...
        % TRANSIENT
        'transient.points','parameters.transient.points','numeric';...
        'transient.length','parameters.transient.length','valueunit';...
        'transient.triggerPosition','parameters.transient.triggerPosition','numeric';...
        % MAGNETIC FIELD
        'magneticField.start','parameters.field.start','valueunit';...
        'magneticField.stop','parameters.field.stop','valueunit';...
        'magneticField.step','parameters.field.step','valueunit';...
        'magneticField.sequence','parameters.field.sequence','copy';...
        'magneticField.controller','parameters.field.model','copy';...
        'magneticField.powerSupply','parameters.field.powersupply','copy';...
        % BACKGROUND
        'background.field','parameters.background.field','valueunit';...
        'background.occurrence','parameters.background.occurrence','copy';...
        'background.polarisation','parameters.background.polarisation','copy';...
        % BRIGDE
        'bridge.model','parameters.bridge.model','copy';...
        'bridge.attenuation','parameters.bridge.attenuation','valueunit';...
        'bridge.power','parameters.bridge.power','valueunit';...
        'bridge.detection','parameters.bridge.detection','copy';...
        'bridge.frequencyCounter','parameters.bridge.calibration.model','copy';...
        'bridge.mwFrequency','parameters.bridge.MWfrequency','valueunit';...
        % VIDEO AMPLIFIER
        'videoAmplifier.bandwidth','parameters.bridge.bandwidth','valueunit';...
        'videoAmplifier.amplification','parameters.bridge.amplification','valueunit';...
        % RECORDER
        'recorder.model','parameters.recorder.model','copy';...
        'recorder.averages','parameters.recorder.averages','numeric';...
        'recorder.sensitivity','parameters.recorder.sensitivity','valueunit';...
        'recorder.bandwidth','parameters.recorder.bandwidth','valueunit';...
        'recorder.timeBase','parameters.recorder.timeBase','valueunit';...
        'recorder.coupling','parameters.recorder.coupling','copy';...
        'recorder.impedance','parameters.recorder.impedance','valueunit';...
        'recorder.pretrigger','parameters.recorder.pretrigger','valueunit';...
        % PROBEHEAD
        'probehead.type','parameters.probehead.type','copy';...
        'probehead.model','parameters.probehead.model','copy';...
        'probehead.coupling','parameters.probehead.coupling','copy';...
        % PUMP
        'pump.type','parameters.laser.type','copy';...
        'pump.model','parameters.laser.model','copy';...
        'pump.wavelength','parameters.laser.wavelength','valueunit';...
        'pump.repetitionRate','parameters.laser.repetitionRate','valueunit';
        'pump.power','parameters.laser.power','valueunit';...
        'pump.tunableType','parameters.laser.tunable.type','copy';...
        'pump.tunableModel','parameters.laser.tunable.model','copy';...
        'pump.tunableDye','parameters.laser.tunable.dye','copy';...
        'pump.tunablePosition','parameters.laser.tunable.position','copy';...
        % TEMPERATURE
        'temperature.temperature','parameters.temperature','valueunit';...
        'temperature.controller','parameters.temperature.model','copy';...
        'temperature.cryostat','parameters.temperature.cryostat','copy';...
        'temperature.cryogen','parameters.temperature.cryogen','copy';...
        % FIELD CALIBRATION
        'fieldCalibration.gaussmeter','parameters.field.calibration.model','copy';...
        'fieldCalibration.method','parameters.field.calibration.method','copy';...
        'fieldCalibration.standard','parameters.field.calibration.standard','copy';...
        'fieldCalibration.signalField','parameters.field.calibration.signalField','valueunit';...
        'fieldCalibration.mwFrequency','parameters.field.calibration.MWfrequency','valueunit';...
        'fieldCalibration.deviation','parameters.field.calibration.deviation','valueunit';...
        'fieldCalibration.start','parameters.field.calibration.start','valueunit';...
        'fieldCalibration.end','parameters.field.calibration.end','valueunit';...
        % FREQUENCY CALIBRATION
        'frequencyCalibration.start','parameters.bridge.calibration.start','valueunit';...
        'frequencyCalibration.end','parameters.bridge.calibration.end','valueunit';...
        % COMMENT
        'comment','comment','copy';...
        };
    
    for k=1:length(matching)
        % For debugging: Print current field name:
        % fprintf('%s\n',matching{k,1});
        switch matching{k,3}
            case 'numeric'
                if ischar(getCascadedField(parameters,matching{k,1}))
                    dataStructure = setCascadedField(dataStructure,...
                        matching{k,2},...
                        num2str(getCascadedField(parameters,matching{k,1})));
                else
                    dataStructure = setCascadedField(dataStructure,...
                        matching{k,2},...
                        getCascadedField(parameters,matching{k,1}));
                end
            case 'valueunit'
                if ~isempty(getCascadedField(parameters,matching{k,1}))
                    if isnumeric(getCascadedField(parameters,matching{k,1}))
                        dataStructure = setCascadedField(dataStructure,...
                            [matching{k,2} '.value'],...
                            getCascadedField(parameters,matching{k,1}));
                        dataStructure = setCascadedField(dataStructure,...
                            [matching{k,2} '.unit'],'');
                    else
                        parts = regexp(...
                            getCascadedField(parameters,matching{k,1}),...
                            ' ','split','once');
                        if length(parts) < 2
                            if isnumeric(parts{1})
                                dataStructure = setCascadedField(dataStructure,...
                                    [matching{k,2} '.value'],...
                                    str2num(parts{1})); %#ok<ST2NM>
                                dataStructure = setCascadedField(dataStructure,...
                                    [matching{k,2} '.unit'],...
                                    '');
                            else
                                dataStructure = setCascadedField(dataStructure,...
                                    [matching{k,2} '.value'],...
                                    []);
                                dataStructure = setCascadedField(dataStructure,...
                                    [matching{k,2} '.unit'],...
                                    parts{1});
                            end
                        else
                            dataStructure = setCascadedField(dataStructure,...
                                [matching{k,2} '.value'],...
                                str2num(parts{1})); %#ok<ST2NM>
                            dataStructure = setCascadedField(dataStructure,...
                                [matching{k,2} '.unit'],...
                                parts{2});
                        end
                    end
                else
                    dataStructure = setCascadedField(dataStructure,...
                        [matching{k,2} '.value'],...
                        []);
                    dataStructure = setCascadedField(dataStructure,...
                        [matching{k,2} '.unit'],...
                        '');
                end
            case 'copy'
                dataStructure = setCascadedField(dataStructure,...
                    matching{k,2},...
                    getCascadedField(parameters,matching{k,1}));
        end
    end
    
    % Handle the special case of date and time that get combined in one
    % field
    dataStructure.parameters.date.start = [...
        parameters.general.date ' ' parameters.general.timeStart];
    dataStructure.parameters.date.end = [...
        parameters.general.date ' ' parameters.general.timeEnd];
    
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
function parameters = parseBlocks(blockData,commentChar)

% Assign output parameter
parameters = struct();

% If we have continued lines (starting with whitespace character), add them
% to previous line
continuingLines = find(cellfun(@(x)isspace(x(1)),blockData));
if any(continuingLines)
    for k=length(continuingLines):-1:1
        % Add line to previous line and use "\n" as delimiter (for later
        % resplitting)
        blockData{continuingLines(k)-1} = [ ...
            blockData{continuingLines(k)-1} '\n' ...
            strtrim(blockData{continuingLines(k)}) ];
        % Delete element in cell array
        blockData(continuingLines(k)) = [];
    end
end
blockLines = cellfun(...
    @(x) regexp(x,':','split','once'),...
    blockData,...
    'UniformOutput', false);
for k=1:length(blockLines)
    % Fill parameters structure
    if ~isempty(blockLines{k}{1}) % Prevent empty lines being parsed
        % Remove comments
        commentCharPos = regexp(blockLines{k}{2},['  ' commentChar],'start');
        if ~isempty(commentCharPos)
            blockLines{k}{2} = blockLines{k}{2}(1:commentCharPos);
        end
        commentCharPos = regexp(blockLines{k}{2},['\t' commentChar],'start');
        if ~isempty(commentCharPos)
            blockLines{k}{2} = blockLines{k}{2}(1:commentCharPos);
        end
        % If not convertible into number - or containing commas
        if isnan(str2double(blockLines{k}{2})) || ...
                any(strfind(blockLines{k}{2},','))
            % If line was concatenated earlier, split it again
            if strfind(blockLines{k}{2},'\n')
                parameters.(str2fieldName(blockLines{k}{1})) = ...
                    regexp(strtrim(blockLines{k}{2}),'\\n','split');
            else
                parameters.(str2fieldName(blockLines{k}{1})) = ...
                    strtrim(blockLines{k}{2});
            end
        else
            parameters.(str2fieldName(blockLines{k}{1})) = ...
                str2double(strtrim(blockLines{k}{2}));
        end
    end
end

end

% --- Get field of cascaded struct
function value = getCascadedField (struct, fieldName)
    try
        % Get number of "." in fieldName
        nDots = strfind(fieldName,'.');
        if isempty(nDots)
            if isfield(struct,fieldName)
                value = struct.(fieldName);
            else
                value = '';
            end
        else
            struct = struct.(fieldName(1:nDots(1)-1));
            value = getCascadedField(...
                struct,...
                fieldName(nDots(1)+1:end));
        end
    catch exception
        disp(fieldName);
        disp(struct);
        throw(exception);
    end 
end

% --- Set field of cascaded struct
function struct = setCascadedField (struct, fieldName, value)
    % Get number of "." in fieldName
    nDots = strfind(fieldName,'.');
    if isempty(nDots)
        struct.(fieldName) = value;
    else
        if ~isfield(struct,fieldName(1:nDots(1)-1))
            struct.(fieldName(1:nDots(1)-1)) = [];
        end
        innerstruct = struct.(fieldName(1:nDots(1)-1));
        innerstruct = setCascadedField(...
            innerstruct,...
            fieldName(nDots(1)+1:end),...
            value);
        struct.(fieldName(1:nDots(1)-1)) = innerstruct;
    end
end
