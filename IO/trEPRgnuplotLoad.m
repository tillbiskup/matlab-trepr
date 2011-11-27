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
% See also TREPRLOAD, TREPRDATASTRUCTURE, TREPRGNUPLOTLOAD.

% (c) 2009-2011, Till Biskup
% 2011-11-02

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
        switch exist(filename)
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
                        files{k} = importdata(fileNames(k).name,' ',3);
                        content.data(k,:) = files{k}.data(:,2);
                        B0 = regexp(files{k}.textdata{2},'B0 = ([0-9.]*)','tokens');
                        content.axes.y.values(k) = str2double(B0{1});
                    end
                end
                
                % In case we have not loaded anything
                if isempty(fieldnames(content))
                    content = [];
                    warnings = cell(0);
                    return;
                end
                
                content.parameters.field.start = ...
                    content.axes.y.values(1);
                content.parameters.field.stop = ...
                    content.axes.y.values(end);
                content.parameters.field.step = ...
                    content.axes.y.values(2) - content.axes.y.values(1);
            case 'combine'
                % This is used in case filename is a cell array of file names
                for k = 1 : length(filename)
                    if exist(filename{k},'file') && ...
                            checkFileFormat(filename{k})
                        files{k} = importdata(filename{k},' ',3);
                        content.data(k,:) = files{k}.data(:,2);
                        B0 = regexp(files{k}.textdata{2},'B0 = ([0-9.]*)','tokens');
                        content.axes.y.values(k) = str2double(B0{1});
                    end
                end
                
                % In case we have not loaded anything
                if isempty(fieldnames(content))
                    content = [];
                    return;
                end
                
                content.parameters.field.start = ...
                    content.axes.y.values(1);
                content.parameters.field.stop = ...
                    content.axes.y.values(end);
                content.parameters.field.step = ...
                    content.axes.y.values(2) - content.axes.y.values(1);
            otherwise
        end
    else
        % If only a single filename is provided as input argument
        % Check whether file is in Freiburg gnuplot format.
        files = cell(length(filename),1);
        if ~checkFileFormat(filename)
            warnings{end+1} = struct(...
                'identifier','trEPRgnuplotLoad:wrongformat',...
                'message',sprintf(...
                'File %s seems not to be in Freiburg gnuplot format...',...
                filename)...
                );
            return
        end

        files{1} = importdata(filename,' ',3);
        content.data = files{1}.data(:,2)';
        B0 = regexp(files{1}.textdata{2},'B0 = ([0-9.]*)','tokens');
        content.parameters.field.start = str2double(B0{1});
        content.parameters.field.stop = str2double(B0{1});
        content.parameters.field.step = 0;
        content.parameters.axes.y.values = str2double(B0{1});
    end
    
    % Assign other parameters, as far as possible

    % Header of first file goes to header
    content.header = files{1}.textdata;

    % Parse field and MW frequency values
    [tokens ~] = regexp(...
        files{1}.textdata{2},...
        'B0 = ([0-9.]*)\s*(\w*),\s* mw = ([0-9.]*)\s*(\w*)',...
        'tokens');
    switch tokens{1}{2}
        case 'Gauss'
            content.axes.y.unit = 'G';
        otherwise
            warnings{end+1} = struct(...
                'identifier','trEPRgnuplotLoad:parseError',...
                'message',sprintf(...
                'Could not recognise unit for magnetic field: ''%s''',...
                tokens{1}{2})...
                );
    end
    content.axes.y.measure = 'magnetic field';
    content.parameters.bridge.MWfrequency.value = str2double(tokens{1}{3});
    content.parameters.bridge.MWfrequency.unit = tokens{1}{4};
    
    content.parameters.transient.points = length(files{1}.data(:,1));
    content.parameters.transient.length = ...
        (abs(files{1}.data(1,1)) + files{1}.data(end,1)) / ...
        (length(files{1}.data(:,1)) - 1) * length(files{1}.data(:,1));
    % Bug fix for some very weird MATLAB problems with accuracy
    content.parameters.transient.length = ...
        round(content.parameters.transient.length*1e10)/1e10;
    % The floor is important due to the fact that the trigger position
    % might be between two points.
    content.parameters.transient.triggerPosition = ...
        floor(abs(files{1}.data(1,1)) / ...
        (content.parameters.transient.length / ...
        length(files{1}.data(:,1))));
    
    % Create axis informations from parameters
    content.axes.x.values = files{1}.data(:,1);
    content.axes.x.measure = 'time';
    content.axes.x.unit = 's';
    
    % Get label string from third line of file/header
    content.label = strtrim(files{1}.textdata{3}(3:end));
    
    % Set Version string of content structure
    content.version = '1.1';
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
end

