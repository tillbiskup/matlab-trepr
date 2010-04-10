function varargout = trEPRfsc2Load(filename, varargin)
% Load fsc2 files measured at the transient spectrometer in Berlin, save
% the header and try to extract from the header necessary functions such as
% the axes.
%
% NOTE: This is not a general routine to read fsc2 files as there exists
%       no such format. fsc2 files are in general simple ASCII files with 
%       varying headers depending on the actual script used to record them.

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
            content = loadFile(filename);
            % assign output argument
            if ~nargout
                % of no output argument is given, assign content to a
                % variable in the workspace with the same name as the
                % file
                [pathstr, name, ext] = fileparts(filename);
                name = cleanFileName([name ext]);
                assignin('base',name,content);
            else
                varargout{1} = content;
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
    end

end

    
% --- load file and return struct with the content of the file together
% with the filename and possibly more info
function content = loadFile(filename)
    % Assign an empty struct to the output argument
    content = struct();

    % Open file
    fid = fopen(filename);
    
    % Save comment header of the file
    content.comment{1} = fgetl(fid);
    k=2;
    
    while strmatch(content.comment{k-1}(1),'%')% == 1
        content.comment{k} = fgetl(fid);
        k=k+1;
    end
    content.comment(length(content.comment)) = '';
    
    % Close file
    fclose(fid);
    
    % Check whether file has been written with fsc2.
    % This is done with looking for the string "fsc2" in the file header,
    % as normally the second line of the file contains something similar to
    % "#!/usr/local/bin/fsc2".
    fsc2File = logical(false);
    for k = 1 : 5
        if strfind(content.comment{k},'fsc2')
            fsc2File = logical(true);
        end
    end
    if ~fsc2File
        % If file seems not to be an fsc2 file print warning and abort
        warning(...
            'trEPRfsc2Load:wrongformat',...
            'File %s seems not to be an fsc2 file...',...
            filename);
        return
    end
    
    % Preassign values to the parameters struct
    content.parameters.runs = [];
    content.parameters.field.start = [];
    content.parameters.field.stop = [];
    content.parameters.field.step = [];
    content.parameters.recorder.sensitivity = [];
    content.parameters.recorder.averages = [];
    content.parameters.recorder.timeBase = [];
    content.parameters.transient.points = [];
    content.parameters.transient.triggerPosition = [];
    content.parameters.transient.length = [];
    content.parameters.bridge.MWfrequency = [];
    content.parameters.bridge.attenuation = [];
    content.parameters.temperature = [];
    content.parameters.laser.wavelength = [];
    content.parameters.laser.repetitionRate = [];
    
    % Cell array correlating struct fieldnames and strings in the header.
    % The first entry contains the string to be searched for in the header
    % of the fsc2 file, the second entry contains the corresponding field
    % name of the "content.parameters" struct.
    matching = {...
        'Number of runs','runs';...
        'Start field','field.start';...
        'End field','field.stop';...
        'Field step width','field.step';...
        'Sensitivity','recorder.sensitivity';...
        'Number of averages','recorder.averages';...
        'Time base','recorder.timeBase';...
        'Number of points','transient.points';...
        'Trigger position','transient.triggerPosition';...
        'Slice length','transient.length';...
        'MW frequency','bridge.MWfrequency';...
        'Attenuation','bridge.attenuation';...
        'Temperature','temperature';...
        'Laser wavelength','laser.wavelength';...
        };
    
    % Extract information from header. Use therefore only the last n lines
    % of the header because it is known that the crucial information is
    % summed up there.
    for k=length(content.comment)-30:length(content.comment)
        for l=1:length(matching) % length(matching) = nRows of matching
            if ~isempty(strfind(content.comment{k},matching{l,1})) ...
                    && isempty(getCascadedField(...
                    content.parameters,...
                    matching{l,2}));
                [tokens names] = regexp(...
                    char(content.comment{k}),...
                    '(?<value>[0-9.]+)\s*(?<unit>\w*)',...
                    'tokens','names');
                content.parameters = setCascadedField(...
                    content.parameters,...
                    matching{l,2},...
                    str2double(tokens{1}{1}));
                if strcmp(matching{l,1},'Laser wavelength')
                    content.parameters.laser = setfield(...
                        content.parameters.laser,...
                        'repetitionRate',...
                        str2double(tokens{2}{1}));
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
        warning(...
            'trEPRfsc2Load:dimensionDetection',...
            'Could not determine data dimensions from file %s...',...
            filename);
        return
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
        warning(...
            'trEPRfsc2Load:dimensionMismatch',...
            'Data dimensions and data from file %s don''t match...',...
            filename);
        if content.parameters.runs > 1
            % If more than one scan, reduce number of scans by one.
            content.parameters.runs = content.parameters.runs-1;
            warning(...
                'trEPRfsc2Load:dimensionMismatch',...
                ['...used %i scan(s) instead of %i, '...
                'as parameters say.\n'...
                '         '...
                '(This might be a bug of the fsc2 program used.)'...
                ],...
                content.parameters.runs,content.parameters.runs+1);
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
            warning(...
                'trEPRfsc2Load:dimensionMismatch',...
                '...field parameters adjusted: %9.2f G - %9.2f G',...
                content.parameters.field.start,...
                content.parameters.field.stop);
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
        warning(...
            'trEPRfsc2Load:timeParameterDetection',...
            'Could not determine time parameters from file %s...',...
            filename);
        return
    end
    
    content.axes.xaxis.values = ...
        -content.parameters.transient.length/content.parameters.transient.points * ...
        (content.parameters.transient.triggerPosition - 1) : ...
        content.parameters.transient.length/content.parameters.transient.points : ...
        content.parameters.transient.length - ...
        content.parameters.transient.length/content.parameters.transient.points * ...
        content.parameters.transient.triggerPosition;
    content.axes.xaxis.measure = 'time';
    content.axes.xaxis.unit = 'us';
    
    if reverse
        content.axes.yaxis.values = ...
            content.parameters.field.stop : ...
            content.parameters.field.step : ...
            content.parameters.field.start;
    else
        content.axes.yaxis.values = ...
            content.parameters.field.start : ...
            content.parameters.field.step : ...
            content.parameters.field.stop;
    end
    content.axes.yaxis.measure = 'magnetic field';
    content.axes.yaxis.unit = 'G';
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
    nDots = findstr(fieldName,'.');
    switch length(nDots)
        case 0
            value = getfield(struct,fieldName);
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
    nDots = findstr(fieldName,'.');
    switch length(nDots)
        case 0
            struct = setfield(struct,fieldName,value);
        case 1
            innerstruct = getfield(struct,fieldName(1:nDots(1)-1));
            innerstruct = setfield(...
                innerstruct,...
                fieldName(nDots(1)+1:length(fieldName)),...
                value);
            struct = setfield(struct,fieldName(1:nDots(1)-1),innerstruct);
        otherwise
            struct = '';
    end
end
