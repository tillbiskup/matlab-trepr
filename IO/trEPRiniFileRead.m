function [ data, warnings ] = trEPRiniFileRead ( fileName, varargin )
% TREPRINIFILEREAD Read a Windows-style ini file and return them as
% MATLAB(r) struct structure. 
%
% Usage
%   data = trEPRiniFileRead(filename)
%   [data,warnings] = trEPRiniFileRead(filename)
%   data = trEPRiniFileRead(filename,'<parameter>','<option>')
%
%   filename - string
%              Name of the ini file to read
%
%   data     - struct
%              MATLAB(r) struct structure containing the contents of the
%              ini file read
%
%   warnings - string/cell array of strings
%              Contains further information if something went wrong.
%              Otherwise empty.
%
% You can specify optional parameters as key-value pairs. Valid parameters
% and their values are:
%
%   commentChar    - char
%                    Character used for comment lines in the ini file
%                    Default: %
%
%   assignmentChar - char
%                    Character used for the assignment of values to keys
%                    Default: =
%
%   blockStartChar - char^
%                    Character used for starting a block
%                    Default: [
%
%   typeConversion - boolean
%                    Whether or not to perform a type conversion str2num
%
% See also: trEPRiniFileWrite

% (c) 2008-13, Till Biskup, Bernd Paulus
% 2013-04-01

% TODO
%	* Change handling of whitespace characters (subfunctions) thus that it
%	  is really all kinds of whitespace that is dealt with, not only spaces.

% Parse input arguments using the inputParser functionality
p = inputParser;            % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true;     % Enable errors on unmatched arguments
p.StructExpand = true;      % Enable passing arguments in a structure
% Add required input arguments
p.addRequired('fileName', @(x)ischar(x));
% Add a few optional parameters, with default values
p.addParamValue('commentChar','%',@ischar);
p.addParamValue('assignmentChar','=',@ischar);
p.addParamValue('blockStartChar','[',@ischar);
p.addParamValue('typeConversion',false,@islogical);
% Parse input arguments
p.parse(fileName,varargin{:});

% Assign parameters from parser
commentChar = p.Results.commentChar;
assignmentChar = p.Results.assignmentChar;
blockStartChar = p.Results.blockStartChar;
typeConversion = p.Results.typeConversion;

if isempty(fileName)
    warnings = 'No filename';
    data = struct();
    return;
end

if ~exist(fileName,'file')
    warnings = 'File does not exist';
    data = struct();
    return;
end

warnings = cell(0);
data = struct();

try
    fh = fopen(fileName);
    iniFileContents = cell(0);
    k=1;
    while 1
        tline = fgetl(fh);
        if ~ischar(tline)
            break
        end
        iniFileContents{k} = tline;
        k=k+1;
    end
    fclose(fh);
catch exception
    throw(exception);
end

% read parameters to structure

blockname = '';
for k=1:length(iniFileContents)
    if ~isempty(iniFileContents{k}) ...
            && ~strcmp(iniFileContents{k}(1),commentChar)
        if strcmp(iniFileContents{k}(1),blockStartChar)
            % set blockname
            % assume thereby that blockname resides within brackets
            blockname = iniFileContents{k}(2:end-1);
        else
            [names] = regexp(iniFileContents{k},...
                ['(?<key>[a-zA-Z0-9._-{}]+)\s*' assignmentChar '\s*(?<val>.*)'],...
                'names');
            if isfield(data,blockname)
                if isfield(data.(blockname),names.key)
                    % print warning message telling the user that the field
                    % gets overwritten and printing the old and the new
                    % field value for comparison 
                    fprintf(...
                        ['WARNING: Field ''%s.%s'' already exists'...
                        ' and will get overwritten.\n\toriginal '...
                        'value: ''%s''\n\tnew value     : ''%s''\n'],...
                        blockname,key,oldFieldValue,val);
                end
            end
            %data.(blockname).(strtrim(names.key)) = strtrim(names.val);
            if ~isfield(data,blockname)
                data.(blockname) = '';
            end
            
            data.(blockname) = setCascadedField(data.(blockname),...
                strtrim(names.key),strtrim(names.val),typeConversion);
        end
    end
end

end % end of main function

% --- Set field of cascaded struct
function struct = setCascadedField(struct,fieldName,value,typeConversion)
    % Get number of "." in fieldName
    nDots = strfind(fieldName,'.');
    % Get number of "{" in fieldName
    curlies = strfind(fieldName,'{');
    currentIsCell = false;
    % if target field is cell array
    if ~isempty(curlies)
        % ... get index of first cell array call (if there's more than one)
        cellind = str2double(...
            fieldName(...
                regexp(fieldName,'{','once')+1 : ...
                regexp(fieldName,'}','once')-1 ) );
    end
    % If there are no ".", we have the target field and can write
    if isempty(nDots)
        if ~isempty(curlies)
            % In case of cell array adjust fieldName
            fieldName = fieldName(1:min(curlies));
            if typeConversion && regexp('[','[\[0-9.]?') && ...
                    ~isempty(str2num(value)) %#ok<ST2NM>
                struct.(fieldName){cellind} = str2num(value); %#ok<ST2NM>
            else
                struct.(fieldName){cellind} = value;
            end
            % Handle special case of empty vector - convert into numeric
            if strcmpi(value,'[]') && typeConversion
                struct.(fieldName){cellind} = [];
            end
        else
            if typeConversion && regexp('[','[\[0-9.]?') && ...
                    ~isempty(str2num(value)) %#ok<ST2NM>
                struct.(fieldName) = str2num(value); %#ok<ST2NM>
            else
                struct.(fieldName) = value;
            end
            % Handle special case of empty vector - convert into numeric
            if strcmpi(value,'[]') && typeConversion
                struct.(fieldName) = [];
            end
        end
    % If there are still ".", we need to look further into the struct
    else
        % In case of cell array adjust fieldName
        if ~isempty(curlies) && min(curlies) < nDots(1)
            fieldName(min(curlies):nDots(1)-1) = [];
            % Don't forget to refresh nDots
            nDots = strfind(fieldName,'.');
            % Set logical switch
            currentIsCell = true;
        end
        % If fieldName is not a field of struct, remove it
        if ~isfield(struct,fieldName(1:nDots(1)-1))
            struct.(fieldName(1:nDots(1)-1)) = [];
        end
        % Get content of the next field
        if currentIsCell
            % If the field is empty, allocate as cell
            if isempty(struct.(fieldName(1:nDots(1)-1)))
                struct.(fieldName(1:nDots(1)-1)) = cell(1);
            end
            innerstruct = struct.(fieldName(1:nDots(1)-1)){cellind};
        else
            innerstruct = struct.(fieldName(1:nDots(1)-1));
        end
        % ... and call this function again
        innerstruct = setCascadedField(...
            innerstruct,...
            fieldName(nDots(1)+1:end),...
            value,typeConversion);
        % Write result to output
        if currentIsCell
            struct.(fieldName(1:nDots(1)-1)){cellind} = innerstruct;
        else
            struct.(fieldName(1:nDots(1)-1)) = innerstruct;
        end
    end
end