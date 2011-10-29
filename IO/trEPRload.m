function varargout = trEPRload(filename, varargin)
    % Loads files or scans whole directories for readable files
    % If called with no output argument, the data are written to variables
    % in the workspace that have the same* name as the file(s) read.
    %
    % The function is in principle only a wrapper for other functions that
    % are specialized to read the different kinds of input files.
    % Configuration of these functions via the file 'trEPRload.ini' - see
    % there for details. Only if it is an ascii file and no function is
    % found from the configuration file, 'importdata' is called to try to
    % handle the data.
    % 
    % *Same means here that a regexprep is performed removing all
    % non-allowed characters for MATLAB variables from the filename.

    % Parse input arguments using the inputParser functionality
    p = inputParser;   % Create an instance of the inputParser class.
    p.FunctionName = mfilename; % Function name to be included in error messages
    p.KeepUnmatched = true; % Enable errors on unmatched arguments
    p.StructExpand = true; % Enable passing arguments in a structure

    p.addRequired('filename', @(x)ischar(x) || iscell(x) || isstruct(x));
%    p.addOptional('parameters','',@isstruct);
    p.addParamValue('combine',logical(false),@islogical);
    p.parse(filename,varargin{:});

    if iscell(filename)
        sort(filename);
        if p.Results.combine
            [content,warnings] = combineFile(filename);
        else
            for k=1:length(filename)
                switch exist(filename{k})
                    case 0
                        % If name does not exist.
                        fprintf('%s does not exist...\n',filename{k});
                    case 2
                        % If name is an M-file on your MATLAB search path.
                        % It also returns 2 when name is the full pathname
                        % to a file or the name of an ordinary file on your
                        % MATLAB search path. 
                        [content{k},warnings{k}] = loadFile(filename{k});
                    otherwise
                        % If none of the above possibilities match
                        fprintf('%s could not be loaded...\n',filename{k});
                end
            end
        end
        if ~nargout && exist('content','var')
            % If no output argument is given, assign content to a
            % variable in the workspace with the same name as the
            % file
            if p.Results.combine
                [~, name, ext] = fileparts(filename{1});
                name = cleanFileName([name ext]);
                assignin('base',name,content);
                assignin('base','warnings',warnings);
            else
                for k=1:length(content)
                    [~, name, ext] = fileparts(...
                        content{k}.filename);
                    name = cleanFileName([name ext]);
                    assignin('base',name,content{k});
                    assignin('base','warnings',warnings);
                end
            end
        elseif exist('content','var')
            varargout{1} = content;
            varargout{2} = warnings;
        else
            varargout{1} = 0;
            varargout{2} = [];
        end
    elseif isstruct(filename) && isfield(filename,'name')
        % That might be the case if the user uses "dir" as input for the
        % filenames, as this returns a structure with fields as "name"
        % Convert struct to cell
        filenames = cell(length(filename),1);
        l = 1;
        for k = 1:length(filename)
            if ~strcmp(filename(k).name,'.') && ~strcmp(filename(k).name,'..')
                filenames{l} = filename(k).name;
                l=l+1;
            end
        end
        if p.Results.combine
            [content,warnings] = combineFile(filenames);
        else
            for k=1:length(filenames)
                switch exist(filenames{k})
                    case 0
                        % If name does not exist.
                        fprintf('%s does not exist...\n',filenames{k});
                    case 2
                        % If name is an M-file on your MATLAB search path.
                        % It also returns 2 when name is the full pathname
                        % to a file or the name of an ordinary file on your
                        % MATLAB search path. 
                        [content{k},warnings{k}] = loadFile(filenames{k});
                    otherwise
                        % If none of the above possibilities match
                        fprintf('%s could not be loaded...\n',filenames{k});
                end
            end
        end
        if ~nargout && exist('content','var')
            % If no output argument is given, assign content to a
            % variable in the workspace with the same name as the
            % file
            if p.Results.combine
                [~, name, ext] = fileparts(filenames{1});
                name = cleanFileName([name ext]);
                assignin('base',name,content);
                assignin('base','warnings',warnings);
            else
                for k=1:length(content)
                    [~, name, ext] = fileparts(...
                        content{k}.filename);
                    name = cleanFileName([name ext]);
                    assignin('base',name,content{k});
                    assignin('base','warnings',warnings);
                end
            end
        elseif exist('content','var')
            varargout{1} = content;
            varargout{2} = warnings;
        else
            varargout{1} = 0;
            varargout{2} = [];
        end
    else    % -> if iscell(filename)
        switch exist(filename)
            case 0
                % Check whether it is only a file basename
                if isempty(dir(sprintf('%s.*',filename)))
                    fprintf('%s does not exist...\n',filename);
                else
                    % Read all files and combine them
                    files = dir(sprintf('%s.*',filename));
                    filenames = cell(1);
                    for k = 1 : length(files)
                        filenames{k} = files(k).name;
                    end
                    [content,warnings] = combineFile(filenames);
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
                [content,warnings] = loadDir(filename,'combine',p.Results.combine);
                if ~nargout
                    % of no output argument is given, assign content to a
                    % variable in the workspace with the same name as the
                    % file
                    if iscell(content)
                        for k=1:length(content)
                            [~, name, ext] = fileparts(...
                                content{k}.filename);
                            name = cleanFileName([name ext]);
                            assignin('base',name,content{k});
                        end
                    else
                        [~, name, ext] = fileparts(filename);
                        name = cleanFileName([name ext]);
                        assignin('base',name,content);
                        assignin('base','warnings',warnings);
                    end
                else
                    varargout{1} = content;
                    varargout{2} = warnings;
                end
            otherwise
                % If none of the above possibilities match
                fprintf('%s could not be loaded...\n',filename);
        end
    end
    
    if ~exist('content','var') && nargout
        varargout{1} = 0;
        varargout{2} = [];
    end
    
end

% --- load file and return struct with the content of the file together
% with the filename and possibly more info
function [content,warnings] = loadFile(filename)
    % Set struct containing all ASCII filetypes that are recognized by this
    % function and can be read. This is done by reading in the
    % corresponding ini file trEPRload.ini.
    fileFormats = iniFileRead([mfilename('fullpath') '.ini']);
    
    % read file formats into cell array
    fileFormatNames = fieldnames(fileFormats);
    asciiFileFormats = cell(0);
    binaryFileFormats = cell(0);
    for k=1:length(fileFormatNames)
        switch getfield(getfield(fileFormats,fileFormatNames{k}),'type')
            case 'ascii'
                asciiFileFormats{end+1} = fileFormatNames{k};
            case 'binary'
                binaryFileFormats{end+1} = fileFormatNames{k};
        end
    end

    % open file
    fid = fopen(filename);

    % Initialize switch resembling binary or ascii data
    isBinary = logical(false);
    
    % Read first characters of the file and try to determine whether it is
    % binary
    firstChars = fread(fid,5);
    for k=1:length(firstChars)
        if firstChars(k) < 32 && firstChars(k) ~= 10 && firstChars(k) ~= 13
            isBinary = logical(true);
        end
    end
    
    % Reset file pointer, then read first line and try to determine from
    % that the filetype
    % PROBLEM: fsc2 files tend to have a single empty comment line as the
    % first line. Therefore, check whether the first line is too short for
    % an identifier string, and in this case, read a second line.
    fseek(fid,0,'bof');
    firstLine = fgetl(fid);
    
    % If firstline is "-1", thus we are at the end of the file, meaning we
    % opened an empty file, return immediately
    if isnumeric(firstLine) && firstLine == -1
        content = [];
        return;
    end
    
    if isempty(regexp(firstLine,'[a-zA-Z]','once'))
        % If first line does not contain any characters necessary for an
        % identifier string (problem with fsc2 files, see comment above),
        % read another line. 
        firstLine = fgetl(fid);
    end
    
    % close file
    fclose(fid);
    
    if isBinary
       for k = 1 : length(binaryFileFormats)
           [pathstr, name, ext] = fileparts(filename);
           if findstr(...,
                    getfield(...
                    getfield(fileFormats,binaryFileFormats{k}),...
                    'identifierString'),...
                    ext);
                functionHandle = str2func(getfield(...
                    getfield(fileFormats,binaryFileFormats{k}),...
                    'function'));
                [data,warnings] = functionHandle(filename);
                if ~isstruct(data)
                    content.data = data;
                else
                    content = data;
                end
                if ~isfield(content,'filename')
                    content.filename = filename;
                end
                break;
           end
       end
    else
        % else try to find a matching function from the ini file
        for k = 1 : length(asciiFileFormats)           
            if findstr(...,
                    getfield(...
                    getfield(fileFormats,asciiFileFormats{k}),...
                    'identifierString'),...
                    firstLine);
                functionHandle = str2func(getfield(...
                    getfield(fileFormats,asciiFileFormats{k}),...
                    'function'));
                [data,warnings] = functionHandle(filename);
                if ~isstruct(data)
                    content.data = data;
                else
                    content = data;
                end
                if ~isfield(content,'filename')
                    content.filename = filename;
                end
                break;
            end
        end
        % else try to handle it with importdata
        if ~exist('content')
            data = importdata(filename);
            if isfield(data,'textdata')
                content.header = data.textdata;
                if isfield(data,'colheaders')
                    content.colheaders = data.colheaders;
                end
                content.data = data.data;
            else
                content.data = data;
            end
            % In case we have not loaded anything
            if isempty(content.data)
                content = [];
                return;
            end
            content.filename = filename;
            % Create axis informations from dimensions
            [y,x] = size(content.data);
            content.axes.x.values = linspace(1,x,x);
            content.axes.x.measure = '';
            content.axes.x.unit = '';
            content.axes.y.values = linspace(1,y,y);
            content.axes.y.measure = '';
            content.axes.y.unit = '';

            % For backwards compatibility
            content.axes.xaxis = content.axes.x;
            content.axes.yaxis = content.axes.y;
            
            % Assign warnings
            warnings = [];
        end
    end
    if ~exist('content') 
        content = []; 
        warnings = [];
    end
end

% --- Sequentially read all files in a directory provided their name does
% not start with a dot and it is a 'real' file and no directory
function [content,warnings] = loadDir(dirname,varargin)
    
    % Get names of files in the directory and remove all files whose name
    % starts with a "." and all directories. The names are stored as a cell
    % array in 'filesInDir'.
    allFilesInDir = dir(dirname);
    l = 1;
    for k=1:length(allFilesInDir)
        if (findstr(allFilesInDir(k).name,'.') ~= 1)
            if ~allFilesInDir(k).isdir
                filesInDir{l} = fullfile(dirname,allFilesInDir(k).name);
                l=l+1;
            end
        end
    end
    
    % If there are still files in the directory after removing all dot
    % files and directories, try to read every single file
    if ~isempty(filesInDir)
        if (nargin >= 3) && (strcmp(varargin{1},'combine') && varargin{2})
            [content,warnings] = combineFile(filesInDir);
        else
            l = 1;
            for k=1:length(filesInDir)
                [fileContent,warnings] = loadFile(char(filesInDir(k)));
                if ~isempty(fileContent)
                    content{l} = fileContent;
                    l = l+1;
                end
            end
        end
    end

    if ~exist('content') 
        content = []; 
    end
end

% --- load files, combine them and return struct with the content of the
% file together with the filename and possibly more info
function [content,warnings] = combineFile(filename)
    % Set struct containing all ASCII filetypes that are recognized by this
    % function and can be read. This is done by reading in the
    % corresponding ini file trEPRload.ini.
    fileFormats = iniFileRead([mfilename('fullpath') '.ini']);
      
    % read file formats into cell array
    asciiFileFormats = fieldnames(fileFormats);
    
    % open file
    fid = fopen(filename{1});
    
    % Initialize switch resembling binary or ascii data
    isBinary = logical(false);
    
    % Read first characters of the file and try to determine whether it is
    % binary
    firstChars = fread(fid,5);
    for k=1:length(firstChars)
        if firstChars(k) < 32 && firstChars(k) ~= 10 && firstChars(k) ~= 13
            isBinary = logical(true);
        end
    end
    
    % Reset file pointer, then read first line and try to determine from
    % that the filetype
    % PROBLEM: fsc2 files tend to have a single empty comment line as the
    % first line. Therefore, check whether the first line is too short for
    % an identifier string, and in this case, read a second line.
    fseek(fid,0,'bof');
    firstLine = fgetl(fid);
    
    % close file
    fclose(fid);
    
    if isBinary
       fprintf('%s is a binary file!',filename); 
    else
        % else try to find a matching function from the ini file
        for k = 1 : length(asciiFileFormats) 
            if ~isempty(findstr(...,
                    getfield(...
                    getfield(fileFormats,asciiFileFormats{k}),...
                    'identifierString'),...
                    firstLine)) ... 
                    && ...
                    strcmp(getfield(...
                    getfield(fileFormats,asciiFileFormats{k}),...
                    'combineMultiple'),...
                    'true')
                functionHandle = str2func(getfield(...
                    getfield(fileFormats,asciiFileFormats{k}),...
                    'function'));
                [data,warnings] = functionHandle(filename);
                if ~isstruct(data)
                    content.data = data;
                else
                    content = data;
                end
                if ~isfield(content,'filename')
                    [path,firstFileName,firstExt] = fileparts(filename{1});
                    [~,lastFileName,lastExt] = fileparts(filename{end});
                    if strcmp(firstFileName,lastFileName)
                        % If file basenames are identical
                        fn = sprintf('%s.%s-%s',firstFileName,firstExt(2:end),lastExt(2:end));
                    else
                        fn = sprintf('%s-%s.%s',firstFileName,lastFileName,lastExt(2:end));
                    end
                    content.filename = fullfile(path,fn);
                end
                break;
            end
        end
    end
    if ~exist('content') 
        content = []; 
        warnings = [];
    end
end

% --- Cleaning up filename so that it can be used as variable name in the
% MATLAB workspace 
function cleanName = cleanFileName(filename)
    cleanName = regexprep(filename,{'\.','[^a-zA-Z0-9_]','^[0-9]','^_'},{'_','','',''});
end