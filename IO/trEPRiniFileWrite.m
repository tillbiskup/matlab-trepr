function [ warnings ] = trEPRiniFileWrite ( fileName, data, varargin )
% TREPRINIFILEWRITE Write a Windows-style ini file and return them as
% MATLAB(r) struct structure. 
%
% Usage
%   trEPRiniFileWrite(filename,data)
%   status = trEPRiniFileWrite(filename,data)
%   trEPRiniFileWrite(filename,data,'<parameter>','<option>')
%
%   filename - string
%              Name of the ini file to write
%
%   data     - struct
%              MATLAB(r) struct structure containing the contents to be
%              written to the ini file
%
%   warnings - string/cell array of strings
%              Contains further information if something went wrong.
%              Otherwise empty.
%
% You can specify optional parameters as key-value pairs. Valid parameters
% and their values are:
%
%   overwrite           - logical (true/false)
%                         Whether to overwrite existing ini file
%
%   header              - string/cell array of strings
%                         Header information that is added on top of the
%                         ini file 
%
%   addModificationDate - logical (true/false)
%                         Whether to add modification date as last line of
%                         header (and if there is no header, then as only
%                         header line)
%
%   commentChar         - char
%                         Character used for comment lines in the ini file
%                         Default: %
%
%   assignmentChar      - char
%                         Character used for the assigning values to keys
%                         Default: =
%
% See also: trEPRiniFileRead

% (c) 2008-13, Till Biskup, Bernd Paulus
% 2013-04-09

% Parse input arguments using the inputParser functionality
p = inputParser;            % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true;     % Enable errors on unmatched arguments
p.StructExpand = true;      % Enable passing arguments in a structure
% Add required input arguments
p.addRequired('fileName', @(x)ischar(x));
p.addRequired('data', @(x)isstruct(x));
% Add a few optional parameters, with default values
p.addParamValue('header',cell(0),@(x) ischar(x) || iscell(x));
p.addParamValue('commentChar','%',@ischar);
p.addParamValue('assignmentChar',' =',@ischar);
p.addParamValue('overwrite',false,@islogical);
p.addParamValue('addModificationDate',true,@islogical);
% Parse input arguments
p.parse(fileName,data,varargin{:});

% Assign parameters from parser
header = p.Results.header;
commentChar = p.Results.commentChar;
assignmentChar = p.Results.assignmentChar;

% headerFirstLine
% headerCreationDate

% Set precision for floats
precision = 16;

warnings = '';

if isempty(fileName)
    warnings = 'No filename';
    return;
end

% check whether the output file already exists
if exist(fileName,'file') && ~p.Results.overwrite 
    warnings = 'File exists';
    return;
end

% Open file for writing
try
    fh = fopen(fileName,'wt');
catch exception
    throw(exception);
end

% Write header, if any
if ~isempty(header)
    if iscell(header)
        for k=1:length(header)
            fprintf(fh,'%s %s\n',commentChar,header{k});
        end
    else
        fprintf(fh,'%s %s\n',commentChar,header);
    end
end

% Write modification date
if p.Results.addModificationDate
    % If there was a header, leave a blank, though commented, line
    if ~isempty(header)
        fprintf(fh,'%s\n',commentChar);
    end
    fprintf(fh,'%s Last modified: %s\n',commentChar,datestr(now,31));
end

% Print the key:value pairs for each field in data
blockNames = fieldnames(data);
for k = 1 : length(blockNames)
    
    fprintf(fh,'\n[%s]\n',blockNames{k});
    fieldNames = fieldnames(data.(blockNames{k}));
    
    % Loop through all fields in blockNames{k}
    for m = 1 : length(fieldNames)
        % if field is a structure array
        if isstruct(data.(blockNames{k}).(fieldNames{m}))
            % use nested function to set value
            traverse(data.(blockNames{k}).(fieldNames{m}),fieldNames{m},...
                assignmentChar,fh,precision);
        % if field is a cell array
        elseif iscell(data.(blockNames{k}).(fieldNames{m}))
            % use nested function to set value
            traverseCell(data.(blockNames{k}).(fieldNames{m}),...
                fieldNames{m},assignmentChar,fh,precision);
        % in every other case, set value
        else
            fieldValue = data.(blockNames{k}).(fieldNames{m});
            % in case the value is not a string, but numeric or logical
            if isnumeric(fieldValue) || islogical(fieldValue)
                fieldValue = num2str(fieldValue,precision);
            end
            fprintf(fh,'%s%s %s\n',fieldNames{m},assignmentChar,fieldValue);
        end
    end
    
end

% Close file
try
    status = fclose(fh);
    if status == -1
        warnings = ...
            sprintf('There were some problems closing file %s',fileName);
        return;
    end
catch exception
    throw(exception);
end

end


function traverse(structure,parent,assignmentChar,fileHandle,precision)

fieldNames = fieldnames(structure);
for k=1:length(fieldNames)
    % if field is a structure array
    if isstruct(structure.(fieldNames{k}))
        % call this function again
        traverse(...
            structure.(fieldNames{k}),[parent '.' fieldNames{k}],...
            assignmentChar,fileHandle,precision);
    % if field is a cell array
    elseif iscell(structure.(fieldNames{k}))
        % call nested function for cells
        traverseCell(...
            structure.(fieldNames{k}),[parent '.' fieldNames{k}],...
            assignmentChar,fileHandle,precision);
    else
%         field = sprintf('%s.%s',parent,fieldNames{k});
        if isnumeric(structure.(fieldNames{k})) || ...
                islogical(structure.(fieldNames{k})) 
            value = num2str(structure.(fieldNames{k}),precision);
%             fprintf(fileHandle,'%s.%s%s %s\n',...
%                 parent,fieldNames{k},assignmentChar,...
%                 num2str(structure.(fieldNames{k}),precision));
        elseif ischar(structure.(fieldNames{k}))
            value = structure.(fieldNames{k});
%             fprintf(fileHandle,'%s.%s%s %s\n',...
%                 parent,fieldNames{k},assignmentChar,...
%                 structure.(fieldNames{k}));
        end
        fprintf(fileHandle,'%s.%s%s %s\n',...
            parent,fieldNames{k},assignmentChar,value);...
%             num2str(structure.(fieldNames{k}),precision));
    end
end

end

function traverseCell(cellArray,parent,assignmentChar,fileHandle,precision)

for ica=1:length(cellArray)
    % if cell is a structure array
    if isstruct(cellArray{ica})
        % call nested function for structs
        traverse(...
            cellArray{ica},[parent '{' num2str(ica) '}'],...
            assignmentChar,fileHandle,precision);
    % if cell is a cell array
    elseif iscell(cellArray{ica})
        % call this function again
        traverseCell(...
            cellArray{ica},[parent '.{' num2str(ica) '}'],...
            assignmentChar,fileHandle,precision);
    else
%         field = sprintf('%s.%s',parent,fieldNames{k});
        if isnumeric(cellArray{ica}) || ...
                islogical(cellArray{ica}) 
            value = num2str(cellArray{ica},precision);
%             fprintf(fileHandle,'%s.%s%s %s\n',...
%                 parent,fieldNames{k},assignmentChar,...
%                 num2str(structure.(fieldNames{k}),precision));
        elseif ischar(cellArray{ica})
            value = cellArray{ica};
%             fprintf(fileHandle,'%s.%s%s %s\n',...
%                 parent,fieldNames{k},assignmentChar,...
%                 structure.(fieldNames{k}));
        end
        fprintf(fileHandle,'%s{%i}%s %s\n',...
            parent,ica,assignmentChar,value);...
%             num2str(structure.(fieldNames{k}),precision));
    end
end

end
