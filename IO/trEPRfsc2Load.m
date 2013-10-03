function varargout = trEPRfsc2Load(filename, varargin)
% TREPRFSC2LOAD Load fsc2 files measured at the transient spectrometer in
% Berlin, save the header and try to extract from the header necessary
% functions such as the axes.
%
% NOTE: This is not a general routine to read fsc2 files as there exists
%       no such format. fsc2 files are in general simple ASCII files with 
%       varying headers depending on the actual script used to record them.
%
% Usage
%   data = trEPRfsc2Load(filename)
%   [data,warning] = trEPRfsc2Load(filename)
%   [data,warning] = trEPRfsc2Load(filename,parameters)
%
%   filename   - string
%                name of a valid filename (of a fsc2 file)
%
%   parameters - optional, see below
%
%   data       - struct
%                structure containing data and additional fields
%
%   warnings   - cell array of strings
%                empty if there are no warnings
%
% If no data could be loaded, data is an empty struct.
% In such case, warning may hold some further information what happened.
%
% Parameters
%   Parameters are entered as key-value pairs. Valid parameters currently
%   are (defaults in brackets): 
%
%   zerofill   - boolean (true)
%                filling aborted datasets with zeros to preserve the
%                dimensions of the original dataset
%
% See also TREPRLOAD, TREPRFSC2METALOAD.

% (c) 2009-2013, Till Biskup
% 2013-10-03

% If called without parameter, do something useful: display help
if ~nargin
    help trEPRfsc2Load
    return;
end

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('filename', @(x)ischar(x) || iscell(x));
p.addParamValue('zerofill',logical(true),@islogical);
%    parser.addOptional('parameters','',@isstruct);
p.parse(filename,varargin{:});
    
    switch exist(filename) %#ok<EXIST>
        case 0
            % If name does not exist.
            fprintf('%s does not exist...\n',filename);
        case 2
            % If name is an M-file on your MATLAB search path. It also
            % returns 2 when name is the full pathname to a file or the
            % name of an ordinary file on your MATLAB search path.
            [content,warnings] = loadFile(filename,p.Results);
            % assign output argument
            if ~nargout
                % of no output argument is given, assign content to a
                % variable in the workspace with the same name as the
                % file
                [~, name, ext] = fileparts(filename);
                name = cleanFileName([name ext]);
                assignin('base',name,content);
                assignin('base','warnings',warnings);
            else
                varargout{1} = content;
                varargout{2} = warnings;
            end
        case 7
            % If name is a directory.
            fprintf('%s is a directory...\n',filename);
        otherwise
            % If none of the above possibilities match
            fprintf('%s could not be loaded...\n',filename);
    end

    if ~exist('content','var') && nargout
        varargout{1} = [];
        varargout{2} = [];
    end

end

    
% --- load file and return struct with the content of the file together
% with the filename and possibly more info
function [content,warnings] = loadFile(filename,parameters)
    warnings = cell(0);

    % Try to read ini file and get the matching for parameters and data
    % structure
    try
        iniFileName = 'trEPRfsc2MetaLoad.ini';
        matching = cell(0);
        fh = fopen(iniFileName,'r');
        k=1;
        while 1
            tline = fgetl(fh);
            if ~ischar(tline)
                break
            end
            if ~strncmp(tline,'%',1)
                matching(k,:) = regexp(tline,',','split');
                k=k+1;
            end
        end
        fclose(fh);
    catch exception
        disp('Problems reading INI file.');
        throw(exception);
    end

    % Preassign values to the content struct
    content = trEPRdataStructure;

    % Open file
    fid = fopen(filename);
    
    % Save comment header of the file
    content.header{1} = fgetl(fid);
    k=2;
    
    while strcmp(content.header{k-1}(1),'%')% == 1
        content.header{k} = fgetl(fid);
        k=k+1;
    end
    content.header(length(content.header)) = '';
    
    % Close file
    fclose(fid);
    
    % Check whether file has been written with fsc2.
    % This is done with looking for the string "fsc2" in the file header,
    % as normally the second line of the file contains something similar to
    % "#!/usr/local/bin/fsc2".
    fsc2File = logical(false);
    for k = 1 : 5
        if strfind(content.header{k},'fsc2')
            fsc2File = logical(true);
        end
    end
    if ~fsc2File
        % If file seems not to be an fsc2 file generate warning and return
        warnings{end+1} = struct(...
            'identifier','trEPRfsc2Load:wrongformat',...
            'message',sprintf(...
            'File %s seems not to be an fsc2 file...',...
            filename)...
            );
        % Assign an empty struct/cell to the output arguments
        content = struct();
        return;
    end
    
    % Extract information from header. As we know that the parameters can
    % be found at the very end of the file header, and that in new versions
    % of the fsc2 program they start with the headline "PARAMETERS", we can
    % first search therefore, and for compatibility with old files recorded
    % with older versions of the fsc2 program, use only the last n lines of
    % the header assuming that this is sufficient.
    [value,lineNumber] = max(strcmp(content.header,'% GENERAL'));
    if (value == 0)
        [value,lineNumber] = max(strcmp(content.header,'% PARAMETERS'));
        if (value == 0)
            lineNumber = length(content.header)-30;
        end
    end

    for k=lineNumber:length(content.header)
        for l=1:length(matching) % length(matching) = nRows of matching
            if ~isempty(strfind(content.header{k},matching{l,1}))
                switch matching{l,3}
                    case 'numeric'
                        [tokens ~] = regexp(...
                            char(content.header{k}),...
                            '(?<value>[0-9.]+)\s*(?<unit>\w*)',...
                            'tokens','names');
                        content.parameters = setCascadedField(...
                            content.parameters,...
                            matching{l,2},...
                            str2double(tokens{1}{1}));
                        % Manual fix for a few fields
                        if strcmpi(matching{l,1},'Start field')
                            content.parameters.field.unit = tokens{1}{2};
                        end
                        if strcmpi(matching{l,1},'Slice length')
                            content.parameters.transient.unit = tokens{1}{2};
                        end
                    case 'string'
                        string = char(content.header{k});
                        string = strtrim(string(strfind(string,':')+2:end));
                        content.parameters = setCascadedField(...
                            content.parameters,...
                            matching{l,2},...
                            string);
                    case 'valueunit'
                        [tokens ~] = regexp(...
                            char(content.header{k}),...
                            '(?<value>[0-9.]+)\s*(?<unit>\w*)',...
                            'tokens','names');
                        content.parameters = setCascadedField(...
                            content.parameters,...
                            [matching{l,2} '.value'],...
                            str2double(tokens{1}{1}));
                        content.parameters = setCascadedField(...
                            content.parameters,...
                            [matching{l,2} '.unit'],...
                            tokens{1}{2});
                        % Fix problems with old files having laser wavelength
                        % and repetition rate in one line...
                        if strcmpi(matching{l,1},'Laser wavelength') && ...
                                ~isempty(strfind(content.header{k},' Hz)'))
                            content.parameters.laser.repetitionRate.value = ...
                                str2double(tokens{2}{1});
                            content.parameters.laser.repetitionRate.unit = ...
                                tokens{2}{2};
                        end
                end
            end
        end
    end
    
    % Terminate if the dimensions of the final data matrix could not be
    % determined from the information in the header.
    if isempty(content.parameters.field.start.value) ...
            || isempty(content.parameters.field.stop.value) ...
            || isempty(content.parameters.field.step.value) ...
            || isempty(content.parameters.transient.points)
        warnings{end+1} = struct(...
            'identifier','trEPRfsc2Load:dimensionDetection',...
            'message',sprintf(...
            'Could not determine data dimensions from file %s...',...
            filename)...
            );
        % Assign an empty struct/cell to the output arguments
        content = struct();
        return;
    end
    
    % Check for direction of field axis
    if content.parameters.field.stop.value < content.parameters.field.start.value
        content.parameters.field.sequence = 'down';
        tmpvalue = content.parameters.field.stop.value;
        content.parameters.field.stop.value = content.parameters.field.start.value;
        content.parameters.field.start.value = tmpvalue;
        clear tmpvalue;
    else
        content.parameters.field.sequence = 'up';
    end

    % Load data of the file
    data = load(filename);

    % Calculate rows and cols of the final data matrix
    rows = abs(content.parameters.field.stop.value-content.parameters.field.start.value)/...
        content.parameters.field.step.value + 1;
    cols = content.parameters.transient.points;
    
    % Error handling if mismatch between parameters and actual data
    if length(data) ~= rows*cols*content.parameters.runs
        warnings{end+1} = struct(...
            'identifier','trEPRfsc2Load:dimensionMismatch',...
            'message','Data dimensions and parameters don''t match.');
        if content.parameters.runs > 1
            % If more than one scan, reduce number of scans by one.
            content.parameters.runs = content.parameters.runs-1;
            warnings{end+1} = struct(...
                'identifier','trEPRfsc2Load:dimensionMismatch',...
                'message',sprintf(...
                ['...used %i scan(s) instead of %i, '...
                'as parameters say. '...
                '(This might be a bug of the fsc2 program used.)'...
                ],...
                content.parameters.runs,content.parameters.runs+1)...
                );
        elseif parameters.zerofill
            data(end:rows*cols) = 0;
            warnings{end+1} = struct(...
                'identifier','trEPRfsc2Load:dimensionMismatch',...
                'message','...data filled with zeros.' ...
                );
        else
            rows = length(data)/cols;
            content.parameters.field.stop.value = ...
                content.parameters.field.start.value + ...
                rows * content.parameters.field.step.value;
            warnings{end+1} = struct(...
                'identifier','trEPRfsc2Load:dimensionMismatch',...
                'message',sprintf(...
                '...field parameters adjusted: %9.2f G - %9.2f G',...
                content.parameters.field.start.value,...
                content.parameters.field.stop.value)...
                );
        end
    end
    
    % Check whether MWfrequency has been read from file, and if not, try
    % again in a manual way...
    if isempty(content.parameters.bridge.MWfrequency.value)
        GHzMatch = cellfun(@(x)strfind(x,'GHz'),...
            content.header,'UniformOutput',false);
        % Convert into logicals
        GHzMatch = ~cellfun('isempty',GHzMatch);
        if any(GHzMatch)
            % Try to parse and get MWfrequency
            MWfrequency = str2double(...
                content.header{find(GHzMatch,1)}(3:...
                strfind(content.header{find(GHzMatch,1)},'GHz')-1));
            if ~isnan(MWfrequency)
                content.parameters.bridge.MWfrequency.value = MWfrequency;
                content.parameters.bridge.MWfrequency.unit  = 'GHz';
            end
        end
    end
    
    % Rearrange data according to parameters from the header.
    % fsc2 saves all data in a linear way, each scan below the previous
    % one. Thus the data vector has to be transformed into a matrix.
    if content.parameters.runs > 1
        % As there is more than one scan saved to the file, the scans will
        % be accumulated (summed up).

        % preallocate array
        dataArray = ones(rows,cols,content.parameters.runs);
        for k = 1 : content.parameters.runs
            dataArray(:,:,k) = reshape(...
                data( (k-1)*rows*cols+1 : k*rows*cols ),...
                rows,cols);
        end
        content.data = sum(dataArray,3);
    else
        content.data = reshape(data,cols,rows)';
        if strcmpi(content.parameters.field.sequence,'down')
            % If measured from high to low magnetic field
            content.data = flipud(content.data);
        end
    end
    
    % Create axis informations from parameters

    % Terminate if the time parameters for the axis could not be
    % determined from the information in the header.
    if isempty(content.parameters.transient.triggerPosition) ...
            || isempty(content.parameters.transient.length.value)
        warnings{end+1} = struct(...
            'identifier','trEPRfsc2Load:dimensionDetection',...
            'message','Could not determine data dimensions.');
        % Assign an empty struct/cell to the output arguments
        content = struct();
        return;
    end
    
    content.axes.x.values = ...
        -content.parameters.transient.length.value/content.parameters.transient.points * ...
        (content.parameters.transient.triggerPosition - 1) : ...
        content.parameters.transient.length.value/content.parameters.transient.points : ...
        content.parameters.transient.length.value - ...
        content.parameters.transient.length.value/content.parameters.transient.points * ...
        content.parameters.transient.triggerPosition;
    content.axes.x.measure = 'time';
    content.axes.x.unit = content.parameters.transient.length.unit;
    
    content.axes.y.values = ...
        content.parameters.field.start.value : ...
        content.parameters.field.step.value : ...
        content.parameters.field.stop.value;
    content.axes.y.measure = 'magnetic field';
    content.axes.y.unit = content.parameters.field.start.unit;
    
    % Fix date string
    if ~isempty(content.parameters.date.start)
        content.parameters.date.start = ...
            datestr(datenum(...
            content.parameters.date.start,'ddd mmm dd, yyyy; HH:MM:SS'),31);
    end
end


% --- Cleaning up filename so that it can be used as variable name in the
% MATLAB workspace 
function cleanName = cleanFileName(filename)
    cleanName = regexprep(...
        filename,...
        {'\.','[^a-zA-Z0-9_]','^[0-9]','^_'},{'_','','',''}...
        );
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
