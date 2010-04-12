function varargout = trEPRasciiLoad(filename, varargin)
% Load ascii files written with the old toolbox functions, save the header
% and try to extract from the header necessary functions such as the axes.

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
    content.header{1} = fgetl(fid);
    k=2;
    
    while strmatch(content.header{k-1}(1),'%')
        content.header{k} = fgetl(fid);
        k=k+1;
    end
    content.header(length(content.header)) = '';
    
    % Close file
    fclose(fid);
    
    % Check whether file has been written with one of the ascii_save
    % routines from the old trEPR toolbox.
    % This is done with looking for the string "ascii_save_" in the file
    % header, as normally the first line of the file contains something
    % similar to "$Id: ascii_save_".
    identifierString = regexp(...
        char(content.header{1}),...
        '([A-Za-z0-9_]*)\.m',...
        'tokens'...
        );
    identifierString = char(identifierString{1});
    knownFormats = {...
        'ascii_save_2Dspectrum',...
        'ascii_save_spectrum',...
        'ascii_save_timeslice'...
        };
    if isempty(strmatch(identifierString,knownFormats))
        warning(...
            'trEPRasciiLoad:wrongformat',...
            'File %s seems not to be in appropriate format...',...
            filename);
        return
    end
    
    % Preassign values to the parameters struct
    content.parameters.field.start = [];
    content.parameters.field.stop = [];
    content.parameters.field.step = [];
    content.parameters.transient.points = [];
    content.parameters.transient.triggerPosition = [];
    content.parameters.transient.length = [];
    content.parameters.bridge.MWfrequency = [];
    
    % Cell array correlating struct fieldnames and strings in the header.
    % The first entry contains the string to be searched for in the header
    % of the fsc2 file, the second entry contains the corresponding field
    % name of the "content.parameters" struct.
    matching = {...
        'start field','field.start';...
        'stop field','field.stop';...
        'step width','field.step';...
        'number of points','transient.points';...
        'trigger position','transient.triggerPosition';...
        'length','transient.length';...
        };
    
    % Extract information from header.
    for k=1:length(content.header)
        for l=1:length(matching) % length(matching) = nRows of matching
            if ~isempty(strfind(content.header{k},matching{l,1})) ...
                    && isempty(getCascadedField(...
                    content.parameters,...
                    matching{l,2}));
                [tokens names] = regexp(...
                    char(content.header{k}),...
                    '(?<value>[0-9.]+)\s*(?<unit>\w*)',...
                    'tokens','names');
                content.parameters = setCascadedField(...
                    content.parameters,...
                    matching{l,2},...
                    str2double(tokens{1}{1}));
            end
        end
        % Handle the MWfrequency differently
        if ~isempty(strfind(content.header{k},'GHz'))
            MWfreq = regexp(...
                char(content.header{k}),...
                '([0-9.]*)',...
                'tokens'...
                );
            content.parameters.bridge.MWfrequency = str2double(MWfreq{1});
        end
    end
    
    % Correct for wrong field parameters
    % This is necessary as the old routines saved the data in the right
    % order (low field -> high field) but did not change the field params.
    content.parameters.field.start = min(...
        [content.parameters.field.start content.parameters.field.stop]...
        );
    content.parameters.field.stop = max(...
        [content.parameters.field.start content.parameters.field.stop]...
        );
    content.parameters.field.step = abs(content.parameters.field.step);
    

    % Load data of the file
    content.data = load(filename);
    
    % Create axis informations from parameters
    
    switch identifierString
        case 'ascii_save_2Dspectrum'
            content.axes.xaxis.values = ...
                -content.parameters.transient.length/content.parameters.transient.points * ...
                (content.parameters.transient.triggerPosition - 1) : ...
                content.parameters.transient.length/content.parameters.transient.points : ...
                content.parameters.transient.length - ...
                content.parameters.transient.length/content.parameters.transient.points * ...
                content.parameters.transient.triggerPosition;
            content.axes.xaxis.measure = 'time';
            content.axes.xaxis.unit = 'us';

            content.axes.yaxis.values = ...
                content.parameters.field.start : ...
                content.parameters.field.step : ...
                content.parameters.field.stop;
            content.axes.yaxis.measure = 'magnetic field';
            content.axes.yaxis.unit = 'G';
        case 'ascii_save_spectrum'
            content.axes.xaxis.values = ...
                content.parameters.field.start : ...
                content.parameters.field.step : ...
                content.parameters.field.stop;
            content.axes.xaxis.measure = 'magnetic field';
            content.axes.xaxis.unit = 'G';
            
            content.axes.yaxis.values = [];
            content.axes.yaxis.measure = '';
            content.axes.xaxis.unit = '';
        case 'ascii_save_timeslice'
            content.axes.xaxis.values = ...
                -content.parameters.transient.length/content.parameters.transient.points * ...
                (content.parameters.transient.triggerPosition - 1) : ...
                content.parameters.transient.length/content.parameters.transient.points : ...
                content.parameters.transient.length - ...
                content.parameters.transient.length/content.parameters.transient.points * ...
                content.parameters.transient.triggerPosition;
            content.axes.xaxis.measure = 'time';
            content.axes.xaxis.unit = 'us';
            
            content.axes.yaxis.values = [];
            content.axes.yaxis.measure = '';
            content.axes.xaxis.unit = '';
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
