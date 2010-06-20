function varargout = trEPRspeksimLoad(filename, varargin)
% Load data measured at the transient spectrometer in Freiburg (speksim),
% save the header and try to extract from the header necessary functions
% such as the axes.
%
% Filename can be a single filename, a file basename (meaning that all
% files with that basename are loaded and combined) or a cell array
% containing filenames to be loaded and combined.

    % Parse input arguments using the inputParser functionality
    parser = inputParser;   % Create an instance of the inputParser class.
    parser.FunctionName = mfilename; % Function name included in error messages
    parser.KeepUnmatched = true; % Enable errors on unmatched arguments
    parser.StructExpand = true; % Enable passing arguments in a structure

    parser.addRequired('filename', @(x)ischar(x) || iscell(x));
%    parser.addOptional('parameters','',@isstruct);
    parser.parse(filename,varargin{:});
    
    if iscell(filename)
        % Read all files and combine them
        content = loadFile(filename,'combine');
        % assign output argument
        if ~nargout
            % of no output argument is given, assign content to
            % a variable in the workspace with the same name as
            % the file
            [pathstr, name, ext] = fileparts(filename{1});
            name = cleanFileName([name ext]);
            assignin('base',name,content);
        else
            varargout{1} = content;
        end
    else
        switch exist(filename)
            case 0
                % If name does not exist.
                % Check whether it is only a file basename
                if isempty(dir(sprintf('%s*',filename)))
                    fprintf('%s does not exist...\n',filename);
                else
                    % Read all files and combine them
                    content = loadFile(filename,'all');
                    % assign output argument
                    if ~nargout
                        % of no output argument is given, assign content to
                        % a variable in the workspace with the same name as
                        % the file
                        [pathstr, name, ext] = fileparts(filename);
                        name = cleanFileName([name ext]);
                        assignin('base',name,content);
                    else
                        varargout{1} = content;
                    end
                end
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
    end
    
    if ~exist('content','var') && nargout
        varargout{1} = [];
    end

end

    
% --- load file and return struct with the content of the file together
% with the filename and possibly more info
function content = loadFile(filename,varargin)
    % Assign an empty struct to the output argument
    content = struct();

    % Check for additional input argument
    if nargin > 1 && strcmp(varargin{1},'all')
        % This is used in case filename is only a file basename.
        % Read all files having filename as their file basename.
        fileNames = dir(sprintf('%s.*',filename));
        for k = 1 : length(fileNames)
            if exist(fileNames(k).name,'file') && ...
                    checkFileFormat(fileNames(k).name)
                files{k} = importdata(fileNames(k).name,'',5);
                content.data(k,:) = files{k}.data;
                B0 = regexp(files{k}.textdata{2},'B0 = ([0-9.]*)','tokens');
                content.axes.yaxis.values(k) = str2double(B0{1});
            end
        end
        content.parameters.field.start = ...
            content.axes.yaxis.values(1);
        content.parameters.field.stop = ...
            content.axes.yaxis.values(end);
        content.parameters.field.step = ...
            content.axes.yaxis.values(2) - content.axes.yaxis.values(1);

        content.header = files{1}.textdata;
        
        content.axes.yaxis.measure = 'magnetic field';
        content.axes.yaxis.unit = 'G';

        timeParams = textscan(files{1}.textdata{4},'%f %f %f %f %f %f');
        content.parameters.transient.points = timeParams{2};
        content.parameters.transient.length = ...
            (abs(timeParams{3}) + timeParams{4}) / (timeParams{2} - 1) * ...
            timeParams{2};
        % Bug fix for some very weird MATLAB problems with accuracy
        content.parameters.transient.length = ...
            floor(content.parameters.transient.length*1e8)/1e8;
        % The floor is important due to the fact that the trigger position
        % might be between two points.
        content.parameters.transient.triggerPosition = ...
            floor(abs(timeParams{3}) / ...
            (content.parameters.transient.length / timeParams{2}));
        MWfreq = regexp(files{1}.textdata{2},'mw = ([0-9.]*)','tokens');
        content.parameters.bridge.MWfrequency = str2double(MWfreq{1});

        % Assign default (empty) values to parameters not readable from
        % file (for completeness of the parameters structure, necessary for
        % some functions of the trEPR GUI)
        content.parameters.temperature = '';
        content.parameters.bridge.attenuation = '';
        content.parameters.laser.wavelength = '';
        content.parameters.laser.repetitionRate = '';
        content.parameters.recorder.averages = [];
        content.parameters.recorder.sensitivity.value = [];
        content.parameters.recorder.sensitivity.unit = '';
        
        % Create axis informations from parameters
        content.axes.xaxis.values = ...
            linspace(timeParams{3},timeParams{4},timeParams{2});
        content.axes.xaxis.measure = 'time';
        content.axes.xaxis.unit = 's';
    
    elseif nargin > 1 && strcmp(varargin{1},'combine')
        % This is used in case filename is a cell array of file names
        for k = 1 : length(filename)
            if exist(filename{k},'file') && ...
                    checkFileFormat(filename{k})
                files{k} = importdata(filename{k},'',5);
                content.data(k,:) = files{k}.data;
                B0 = regexp(files{k}.textdata{2},'B0 = ([0-9.]*)','tokens');
                content.axes.yaxis.values(k) = str2double(B0{1});
            end
        end
        content.parameters.field.start = ...
            content.axes.yaxis.values(1);
        content.parameters.field.stop = ...
            content.axes.yaxis.values(end);
        content.parameters.field.step = ...
            content.axes.yaxis.values(2) - content.axes.yaxis.values(1);

        content.header = files{1}.textdata;
        
        content.axes.yaxis.measure = 'magnetic field';
        content.axes.yaxis.unit = 'G';

        timeParams = textscan(files{1}.textdata{4},'%f %f %f %f %f %f');
        content.parameters.transient.points = timeParams{2};
        content.parameters.transient.length = ...
            (abs(timeParams{3}) + timeParams{4}) / (timeParams{2} - 1) * ...
            timeParams{2};
        % Bug fix for some very weird MATLAB problems with accuracy
        content.parameters.transient.length = ...
            floor(content.parameters.transient.length*1e8)/1e8;
        % The floor is important due to the fact that the trigger position
        % might be between two points.
        content.parameters.transient.triggerPosition = ...
            floor(abs(timeParams{3}) / ...
            (content.parameters.transient.length / timeParams{2}));
        MWfreq = regexp(files{1}.textdata{2},'mw = ([0-9.]*)','tokens');
        content.parameters.bridge.MWfrequency = str2double(MWfreq{1});

        % Assign default (empty) values to parameters not readable from
        % file (for completeness of the parameters structure, necessary for
        % some functions of the trEPR GUI)
        content.parameters.temperature = '';
        content.parameters.bridge.attenuation = '';
        content.parameters.laser.wavelength = '';
        content.parameters.laser.repetitionRate = '';
        content.parameters.recorder.averages = [];
        content.parameters.recorder.sensitivity.value = [];
        content.parameters.recorder.sensitivity.unit = '';

        % Create axis informations from parameters
        content.axes.xaxis.values = ...
            linspace(timeParams{3},timeParams{4},timeParams{2});
        content.axes.xaxis.measure = 'time';
        content.axes.xaxis.unit = 's';

    else
        % If only a single filename is provided as input argument
        % Check whether file is in speksim format.
        if ~checkFileFormat(filename)
            warning(...
                'trEPRspeksimLoad:wrongformat',...
                'File %s seems not to be in speksim format...',...
                filename);
            return
        end

        file = importdata(filename,'',5);
        content.data = file.data;
        B0 = regexp(file.textdata{2},'B0 = ([0-9.]*)','tokens');
        content.parameters.field.start = str2double(B0{1});
        content.parameters.field.stop = str2double(B0{1});
        content.parameters.field.step = 0;

        content.header = file.textdata;
        
        timeParams = textscan(file.textdata{4},'%f %f %f %f %f %f');
        content.parameters.transient.points = timeParams{2};
        content.parameters.transient.length = ...
            (abs(timeParams{3}) + timeParams{4}) / (timeParams{2} - 1) * ...
            timeParams{2};
        % Bug fix for some very weird MATLAB problems with accuracy
        content.parameters.transient.length = ...
            floor(content.parameters.transient.length*1e8)/1e8;
        % The floor is important due to the fact that the trigger position
        % might be between two points.
        content.parameters.transient.triggerPosition = ...
            floor(abs(timeParams{3}) / ...
            (content.parameters.transient.length / timeParams{2}));
        MWfreq = regexp(file.textdata{2},'mw = ([0-9.]*)','tokens');
        content.parameters.bridge.MWfrequency = str2double(MWfreq{1});

        % Assign default (empty) values to parameters not readable from
        % file (for completeness of the parameters structure, necessary for
        % some functions of the trEPR GUI)
        content.parameters.temperature = '';
        content.parameters.bridge.attenuation = '';
        content.parameters.laser.wavelength = '';
        content.parameters.laser.repetitionRate = '';
        content.parameters.recorder.averages = [];
        content.parameters.recorder.sensitivity.value = [];
        content.parameters.recorder.sensitivity.unit = '';

        % Create axis informations from parameters
        content.axes.xaxis.values = ...
            linspace(timeParams{3},timeParams{4},timeParams{2});
        content.axes.xaxis.measure = 'time';
        content.axes.xaxis.unit = 's';

        content.axes.yaxis.values = [];
        content.axes.yaxis.measure = '';
        content.axes.yaxis.unit = '';
    end
end

% --- Check whether the file is in speksim format
function TF = checkFileFormat(filename)
    % Check whether file is in speksim format.
    % This is done with looking for the string "Source : transient" at
    % the beginning of the first line of the file.
    %
    % NOTE: The same string can be found in the corresponding gnuplot
    % files derived from the speksim files, but there it is preceded by
    % "# ".
    fid = fopen(filename);
    firstHeaderLine = fgetl(fid);
    fclose(fid);
    
    if strfind(firstHeaderLine,'Source : transient;') == 1
        TF = logical(true);
    else
        TF = logical(false);
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

