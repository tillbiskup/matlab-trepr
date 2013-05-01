function varargout = trEPRgnuplotLoad(filename, varargin)
% TREPRGNUPLOTLOAD Load data from trEPR spectrometer in Freiburg (gnuplot)
%
% Usage
%   trEPRgnuplotLoad(filename);
%   [data] = trEPRgnuplotLoad(filename);
%   [data,warnings] = trEPRgnuplotLoad(filename);
%   [data,warnings] = trEPRgnuplotLoad(filename,command);
%
%   filename - string
%              single filename, a file basename or a cell array
%              in the latter two cases all those files are loaded
%   command -  string
%              'combine' or 'all'
%              If 'combine', the multiple files are combined
%              If 'all', filename is interpreted as file basename and all
%              files are combined
%   data     - struct
%              structure containing data and additional fields
%              Complies to the conventions of the toolbox data structure,
%              cf. trEPRdataStructure
%
%   warnings - cell array of strings
%              empty if there are no warnings
%
% Please note: As each time trace records its own MW frequency value, the
% field "data.parameters.bridge.MWfrequency.value" is an array in case more
% than one time trace has been read and combined.
%                
% See also TREPRLOAD, TREPRDATASTRUCTURE, TREPRGNUPLOTLOAD.

% (c) 2009-2013, Till Biskup
% 2013-05-01

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
        [content,warnings] = loadFile(filename,'combine');
        % assign output argument
        if ~nargout
            % of no output argument is given, assign content to
            % a variable in the workspace with the same name as
            % the file
            [~, name, ext] = fileparts(filename{1});
            name = cleanFileName([name ext]);
            assignin('base',name,content);
            assignin('base','warnings',warnings);
        else
            varargout{1} = content;
            varargout{2} = warnings;
        end
    else
        switch exist(filename) %#ok<EXIST>
            case 0
                % If name does not exist.
                % Check whether it is only a file basename
                if isempty(dir(sprintf('%s.*',filename)))
                    fprintf('%s does not exist...\n',filename);
                else
                    % Read all files and combine them
                    [content,warnings] = loadFile(filename,'all');
                    % assign output argument
                    if ~nargout
                        % of no output argument is given, assign content to
                        % a variable in the workspace with the same name as
                        % the file
                        [~, name, ext] = fileparts(filename);
                        name = cleanFileName([name ext]);
                        assignin('base',name,content);
                        assignin('base','warnings',warnings);
                    else
                        varargout{1} = content;
                        varargout{2} = warnings;
                    end
                end
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
    end
    
    if ~exist('content','var') && nargout
        varargout{1} = [];
        varargout{2} = [];
    end

end

    
% --- load file and return struct with the content of the file together
% with the filename and possibly more info
function [content,warnings] = loadFile(filename,varargin)
    % Assign defaults to the output arguments
    % Preassign values to the content struct
    content = trEPRdataStructure;
    warnings = cell(0);

    % Check for additional input argument
    if nargin > 1 
        switch varargin{1}
            case 'all'
                % This is used in case filename is only a file basename.
                % Read all files having filename as their file basename.
                fileNames = dir(sprintf('%s.*',filename));
                for k = 1 : length(fileNames)
                    if exist(fileNames(k).name,'file') && ...
                            checkFileFormat(fileNames(k).name)
                        data = importdata(fileNames(k).name,'\t',7);
                        % Header of first file goes to header
                        if isempty(content.header)
                            content.header = data.textdata;
                        end                        
                        content.data(end+1,:) = data.data(:,2);
                        B0tok = regexp(...
                            data.textdata{2},'B0 = ([0-9.]*)\s*(\w*)',...
                            'tokens');
                        switch B0tok{1}{2}
                            case 'Gauss'
                                content.axes.y.unit = 'G';
                                content.parameters.field.start.unit = ...
                                    content.axes.y.unit;
                                content.parameters.field.stop.unit = ...
                                    content.axes.y.unit;
                                content.parameters.field.step.unit = ...
                                    content.axes.y.unit;
                            otherwise
                                warnings{end+1} = struct(...
                                    'identifier','trEPRgnuplotLoad:parseError',...
                                    'message',sprintf(...
                                    'Could not recognise unit for magnetic field: ''%s''',...
                                    B0tok{1}{2})...
                                    ); %#ok<AGROW>
                        end
                        content.axes.y.values(end+1) = str2double(B0tok{1}{1});
                        mwtok = regexp(...
                            data.textdata{3},'mw = ([0-9.]*)\s*(\w*)',...
                            'tokens');
                        content.parameters.bridge.MWfrequency.value(end+1) = ...
                            str2double(mwtok{1}{1});
                        content.parameters.bridge.MWfrequency.unit = ...
                            mwtok{1}{2};
                    end
                end
                
                % In case we have not loaded anything
                if isempty(fieldnames(content))
                    content = [];
                    warnings = cell(0);
                    return;
                end
                
                content.parameters.field.start.value = ...
                    content.axes.y.values(1);
                content.parameters.field.stop.value = ...
                    content.axes.y.values(end);
                content.parameters.field.step.value = ...
                    content.axes.y.values(2) - content.axes.y.values(1);
            case 'combine'
                % This is used in case filename is a cell array of file names
                for k = 1 : length(filename)
                    if exist(filename{k},'file') && ...
                            checkFileFormat(filename{k})
                        data = importdata(filename{k},'\t',7);
                        % Header of first file goes to header
                        if isempty(content.header)
                            content.header = data.textdata;
                        end                        
                        content.data(end+1,:) = data.data(:,2);
                        B0tok = regexp(...
                            data.textdata{2},'B0 = ([0-9.]*)\s*(\w*)',...
                            'tokens');
                        switch B0tok{1}{2}
                            case 'Gauss'
                                content.axes.y.unit = 'G';
                                content.parameters.field.start.unit = ...
                                    content.axes.y.unit;
                                content.parameters.field.stop.unit = ...
                                    content.axes.y.unit;
                                content.parameters.field.step.unit = ...
                                    content.axes.y.unit;
                            otherwise
                                warnings{end+1} = struct(...
                                    'identifier','trEPRgnuplotLoad:parseError',...
                                    'message',sprintf(...
                                    'Could not recognise unit for magnetic field: ''%s''',...
                                    B0tok{1}{2})...
                                    ); %#ok<AGROW>
                        end
                        content.axes.y.values(end+1) = str2double(B0tok{1}{1});
                        mwtok = regexp(...
                            data.textdata{3},'mw = ([0-9.]*)\s*(\w*)',...
                            'tokens');
                        content.parameters.bridge.MWfrequency.value(end+1) = ...
                            str2double(mwtok{1}{1});
                        content.parameters.bridge.MWfrequency.unit = ...
                            mwtok{1}{1};
                    end
                end
                
                % In case we have not loaded anything
                if isempty(fieldnames(content))
                    content = [];
                    return;
                end
                
                content.parameters.field.start.value = ...
                    content.axes.y.values(1);
                content.parameters.field.stop.value = ...
                    content.axes.y.values(end);
                content.parameters.field.step.value = ...
                    content.axes.y.values(2) - content.axes.y.values(1);
            otherwise
        end
    else
        % If only a single filename is provided as input argument
        % Check whether file is in Freiburg gnuplot format.
        if ~checkFileFormat(filename)
            warnings{end+1} = struct(...
                'identifier','trEPRgnuplotLoad:wrongformat',...
                'message',sprintf(...
                'File %s seems not to be in Freiburg gnuplot format...',...
                filename)...
                );
            return
        end

        data = importdata(filename,'\t',7);
        content.header = data.textdata;
        content.data = data.data(:,2)';
        B0tok = regexp(data.textdata{2},'B0 = ([0-9.]*)\s*(\w*)','tokens');
        switch B0tok{1}{2}
            case 'Gauss'
                content.axes.y.unit = 'G';
                content.parameters.field.start.unit = content.axes.y.unit;
                content.parameters.field.stop.unit = content.axes.y.unit;
                content.parameters.field.step.unit = content.axes.y.unit;
            otherwise
                warnings{end+1} = struct(...
                    'identifier','trEPRspeksimLoad:parseError',...
                    'message',sprintf(...
                    'Could not recognise unit for magnetic field: ''%s''',...
                    B0tok{1}{2})...
                    );
        end
        content.parameters.field.start.value = str2double(B0tok{1}{1});
        content.parameters.field.stop.value = str2double(B0tok{1}{1});
        content.parameters.field.step.value = 0;
        content.axes.y.values = str2double(B0tok{1}{1});
        mwtok = regexp(data.textdata{3},'mw = ([0-9.]*)\s*(\w*)','tokens');
        content.parameters.bridge.MWfrequency.value = ...
            str2double(mwtok{1}{1});
        content.parameters.bridge.MWfrequency.unit = mwtok{1}{2};
    end
    
    % Assign other parameters, as far as possible

    % Parse field and MW frequency values
    B0tok = regexp(data.textdata{2},'B0 = ([0-9.]*)\s*(\w*)','tokens');
    switch B0tok{1}{2}
        case 'Gauss'
            content.axes.y.unit = 'G';
        otherwise
            warnings{end+1} = struct(...
                'identifier','trEPRgnuplotLoad:parseError',...
                'message',sprintf(...
                'Could not recognise unit for magnetic field: ''%s''',...
                B0tok{1}{2})...
                );
    end
    content.axes.y.measure = 'magnetic field';
    mwtok = regexp(data.textdata{3},'mw = ([0-9.]*)\s*(\w*)','tokens');
    content.parameters.bridge.MWfrequency.value = ...
        str2double(mwtok{1}{1});
    content.parameters.bridge.MWfrequency.unit = mwtok{1}{2};
    
    content.parameters.transient.points = length(data.data(:,1));
    content.parameters.transient.length.value = ...
        (abs(data.data(1,1)) + data.data(end,1)) / ...
        (length(data.data(:,1)) - 1) * length(data.data(:,1));
    % Bug fix for some very weird MATLAB problems with accuracy
    content.parameters.transient.length.value = ...
        round(content.parameters.transient.length.value*1e10)/1e10;
    % The floor is important due to the fact that the trigger position
    % might be between two points.
    content.parameters.transient.triggerPosition = ...
        floor(abs(data.data(1,1)) / ...
        (content.parameters.transient.length.value / ...
        length(data.data(:,1))));
    
    % Create axis informations from parameters
    content.axes.x.values = data.data(:,1);
    content.axes.x.measure = 'time';
    content.axes.x.unit = 's';
    content.parameters.transient.length.unit = content.axes.x.unit;
    
    % Get label string from third line of file/header
    content.label = strtrim(content.header{6}(3:end));
end

% --- Check whether the file is in Freiburg gnuplot format
function TF = checkFileFormat(filename)
    % Check whether file is in Freiburg gnuplot format.
    % This is done with looking for the string "# Source : transient" at
    % the beginning of the first line of the file.
    %
    % NOTE: The same string can be found in the corresponding speksim
    % files the gnuplot files are derived from, but these files lack the
    % leading "# ".
    fid = fopen(filename);
    firstHeaderLine = fgetl(fid);
    fclose(fid);
    
    if strfind(firstHeaderLine,'# Source : transient;') == 1
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
    if ~isletter(cleanName(1))
        cleanName = sprintf('a%s',cleanName);
    end
end

