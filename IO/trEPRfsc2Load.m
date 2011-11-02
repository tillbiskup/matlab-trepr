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
%
%   filename - string
%              name of a valid filename (of a fsc2 file)
%   data     - struct
%              structure containing data and additional fields
%
%   warnings - cell array of strings
%              empty if there are no warnings
%
% If no data could be loaded, data is an empty struct.
% In such case, warning may hold some further information what happened.
%
% See also TREPRLOAD, TREPRFSC2METALOAD.

% (c) 2009-2011, Till Biskup
% 2011-11-01

% If called without parameter, do something useful: display help
if ~nargin
    help trEPRfsc2Load
    return;
end

    % Parse input arguments using the inputParser functionality
    parser = inputParser;   % Create an instance of the inputParser class.
    parser.FunctionName = mfilename; % Function name included in error messages
    parser.KeepUnmatched = true; % Enable errors on unmatched arguments
    parser.StructExpand = true; % Enable passing arguments in a structure

    parser.addRequired('filename', @(x)ischar(x) || iscell(x));
%    parser.addOptional('parameters','',@isstruct);
    parser.parse(filename,varargin{:});
    
    switch exist(filename)
        case 0
            % If name does not exist.
            fprintf('%s does not exist...\n',filename);
        case 2
            % If name is an M-file on your MATLAB search path. It also
            % returns 2 when name is the full pathname to a file or the
            % name of an ordinary file on your MATLAB search path.
            [content,warnings] = loadFile(filename);
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
function [content,warnings] = loadFile(filename)
    warnings = cell(0);

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
        
    % Cell array correlating struct fieldnames and strings in the header.
    % The first entry contains the string to be searched for in the header
    % of the fsc2 file, the second entry contains the corresponding field
    % name of the "content.parameters" struct. The third parameter,
    % finally, tells the program how to parse the corresponding entry.
    % Here, "numeric" means that the numbers of the field should be treated
    % as numbers, "string" means to treat the whole field as string, and
    % "valueunit" splits the field in a numeric value and a string
    % containing the unit.
    matching = {...
        'Measurement start','date','string'
        'Number of runs','runs','numeric';...
        'Start field','field.start','numeric';...
        'End field','field.stop','numeric';...
        'Field step width','field.step','numeric';...
        'Field start','field.start','numeric';...
        'Field end','field.stop','numeric';...
        'Field step','field.step','numeric';...
        'Number of averages','recorder.averages','numeric';...
        'Number of points','transient.points','numeric';...
        'Slice length','transient.length','numeric';...
        'Trigger position','transient.triggerPosition','numeric';...
        'Oscilloscope coupling','recorder.coupling','string';...
        'MW Bridge','bridge.model','string';...
        'Digitizer model','recorder.model','string';...
        'Field controller model','field.model','string';...
        'Gaussmeter model','field.calibration.model','string';...
        'Frequency counter model','bridge.calibration.model','string';...
        'Laser model','laser.model','string';...
        'OPO model','laser.opoDye','string';...
        'Sensitivity','recorder.sensitivity','valueunit';...
        'Time base','recorder.timeBase','valueunit';...
        'MW frequency','bridge.MWfrequency','valueunit';...
        'Attenuation','bridge.attenuation','valueunit';...
        'Temperature','temperature','valueunit';...
        'Laser wavelength','laser.wavelength','valueunit';...
        'Oscilloscope impedance','recorder.impedance','valueunit';...
        'Oscilloscope bandwidth','recorder.bandwidth','valueunit';...
        'Laser repetition rate','laser.repetitionRate','valueunit';
        };
    
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
        lineNumber = length(content.header)-30;
    end

    for k=lineNumber:length(content.header)
        for l=1:length(matching) % length(matching) = nRows of matching
            if ~isempty(strfind(content.header{k},matching{l,1})) ...
%                     && isempty(getCascadedField(...
%                     content.parameters,...
%                     matching{l,2}));
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
    if isempty(content.parameters.field.start) ...
            || isempty(content.parameters.field.stop) ...
            || isempty(content.parameters.field.step) ...
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
    if content.parameters.field.stop < content.parameters.field.start
        reverse = logical(true);
    else
        reverse = logical(false);
    end

    % Load data of the file
    data = load(filename);

    % Calculate rows and cols of the final data matrix
    rows = abs(content.parameters.field.stop-content.parameters.field.start)/...
        content.parameters.field.step + 1;
    cols = content.parameters.transient.points;
    
    % Error handling if mismatch between parameters and actual data
    if length(data) ~= rows*cols*content.parameters.runs
        warnings{end+1} = struct(...
            'identifier','trEPRfsc2Load:dimensionMismatch',...
            'message',sprintf(...
            'Data dimensions and data from file %s don''t match...',...
            filename)...
            );
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
        else
            rows = length(data)/cols;
            if reverse
                content.parameters.field.start = ...
                    content.parameters.field.stop - ...
                    rows * content.parameters.field.step;
            else
                content.parameters.field.stop = ...
                    content.parameters.field.start + ...
                    rows * content.parameters.field.step;
            end
            warnings{end+1} = struct(...
                'identifier','trEPRfsc2Load:dimensionMismatch',...
                'message',sprintf(...
                '...field parameters adjusted: %9.2f G - %9.2f G',...
                content.parameters.field.start,...
                content.parameters.field.stop)...
                );
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
        if reverse
            % If measured from high to low magnetic field
            content.data = flipud(content.data);
        end
    end
    
    % Create axis informations from parameters

    % Terminate if the time parameters for the axis could not be
    % determined from the information in the header.
    if isempty(content.parameters.transient.triggerPosition) ...
            || isempty(content.parameters.transient.length)
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
    
    content.axes.x.values = ...
        -content.parameters.transient.length/content.parameters.transient.points * ...
        (content.parameters.transient.triggerPosition - 1) : ...
        content.parameters.transient.length/content.parameters.transient.points : ...
        content.parameters.transient.length - ...
        content.parameters.transient.length/content.parameters.transient.points * ...
        content.parameters.transient.triggerPosition;
    content.axes.x.measure = 'time';
    content.axes.x.unit = content.parameters.transient.unit;
    
    if reverse
        content.axes.y.values = ...
            content.parameters.field.stop : ...
            content.parameters.field.step : ...
            content.parameters.field.start;
    else
        content.axes.y.values = ...
            content.parameters.field.start : ...
            content.parameters.field.step : ...
            content.parameters.field.stop;
    end
    content.axes.y.measure = 'magnetic field';
    content.axes.y.unit = content.parameters.field.unit;
    
    % Fix date string
    if ~isempty(content.parameters.date)
        content.parameters.date = ...
            datestr(datenum(...
            content.parameters.date,'ddd mmm dd, yyyy; HH:MM:SS'),31);
    end
    
    % Set Version string of content structure
    content.version = '1.1';
end


% --- Cleaning up filename so that it can be used as variable name in the
% MATLAB workspace 
function cleanName = cleanFileName(filename)
    cleanName = regexprep(...
        filename,...
        {'\.','[^a-zA-Z0-9_]','^[0-9]','^_'},{'_','','',''}...
        );
end


% --- Get field of cascaded struct
function value = getCascadedField (struct, fieldName)
    % Get number of "." in fieldName
    nDots = strfind(fieldName,'.');
    switch length(nDots)
        case 0
            value = struct.(fieldName);
        case 1
            value = getfield(getfield(...
                struct,...
                fieldName(1:nDots(1)-1)),...
                fieldName(nDots(1)+1:length(fieldName)));
        otherwise
            value = '';
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
