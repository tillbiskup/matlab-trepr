function varargout = trEPRxmlZipRead(filename,varargin)
% TREPRXMLZIPREAD Read ZIP-compressed XML file and data (if available)
%
% Usage:
%   [data,warning] = trEPRxmlZipRead(filename);
%   [data,warning] = trEPRxmlZipRead(filename,<parameter>,<value>);
%
%   filename - string
%              name of the ZIP archive containing the XML (and data)
%              file(s)
%   data     - struct
%              content of the XML file
%              data.data holds the data read from the ZIP archive
%   warning  - cell array
%              Contains warnings if there are any, otherwise empty
%
% Optional parameters that can be set:
%
%   convertFormat - boolean
%                   Convert to most current toolbox dataset structure on
%                   load
%                   Default: true
%
% See also: trEPRxmlZipWrite, trEPRload

% Copyright (c) 2011-14, Till Biskup
% 2014-07-31

% Parse input arguments using the inputParser functionality
try
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('filename', @(x)ischar(x) || iscell(x));
    % Note, this is to be compatible with TAload - currently without function!
    p.addParamValue('checkFormat',logical(true),@islogical);
    p.addParamValue('convertFormat',logical(true),@islogical);
    p.parse(filename,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

warning = cell(0);

% Do the real stuff
if iscell(filename)
    data = cell(length(filename),1);
    warning = cell(length(filename),1);
    for k=1:length(filename)
        [data{k},warning{k}] = trEPRxmlZipRead(filename{k},varargin{:});
    end
    varargout{1} = data;
    varargout{2} = warning;
    return;
end

if ~exist(filename,'file')
    fprintf('"%s" seems not to be a valid filename. Abort.',filename);
    if nargout, varargout{1} = logical(false); end;
    return;
end
[status,message,messageid] = copyfile(filename,tempdir);
if ~status
    fprintf('%s\n%s\n Aborted.\n',messageid,message);
    if nargout, varargout{1} = logical(false); end;
    return;
end
PWD = pwd;
cd(tempdir);
% Unzip and delete ZIP archive afterwards
try
    filenames = unzip(filename);
    [~, name, ext] = fileparts(filename);
    delete(fullfile(tempdir,[name ext]));
catch exception
    warning = sprintf('%s\n%s\n"%s"\n%s\n',...
        exception.identifier,...
        'Problems with unzipping:',...
        filename,...
        'seems not to be a valid zip file. Aborted.');
    if nargout
        varargout{1} = logical(false);
        varargout{2} = warning;
    end
    return;
end
% Read different files of the archive
try
    for k=1:length(filenames)
        [pathstr, name, ext] = fileparts(filenames{k});
        switch ext
            case '.xml'
                xmlFileSerialize(fullfile(pathstr,[name ext]));
                DOMnode = xmlread(fullfile(pathstr,[name ext]));
                struct = xml2struct(DOMnode);
                delete(fullfile(pathstr,[name ext]));
            case '.dat'
                try
                    data = load(fullfile(pathstr,[name ext]));
                    % Try to check whether we have read correct data - as
                    % we cannot rely to already have read the xml file, we
                    % need to check whether "length(data) == 1" and in this
                    % case try to read via binary and see what happens.
                    %
                    % This is to cope with the fact that some binary files
                    % might start with something load interprets as proper
                    % number - and therefore doesn't crash. There is no
                    % easy way to distinguish whether a file has binary
                    % content in Matlab. At least not that I know of...
                    if length(data) == 1
                        tmpData = readBinary(fullfile(pathstr,[name ext]));
                        if length(tmpData) > length(data)
                            data = tmpData;
                        end
                        clear tmpData;
                    end
                catch exception
                    try
                        data = readBinary(fullfile(pathstr,[name ext]));
                    catch exception2
                        exception = addCause(exception2, exception);
                        throw(exception);
                    end
                end
                delete(fullfile(pathstr,[name ext]));
            otherwise
                delete(fullfile(pathstr,[name ext]));
        end
    end
catch errmsg
    warning{end+1}.identifier = 'trEPRxmlZipRead:xmlParser';
    warning{end}.message = sprintf('%s\n%s\n"%s"\n',...
        errmsg.identifier,...
        'Problems with parsing XML in file:',...
        filename);
    if nargout
        varargout{1} = logical(false);
        varargout{2} = warning;
    end
    cd(PWD);
    return;
end
if exist('data','var')
    % Check whether data have the right dimensions - in case that we read
    % from binary, most probably they have not - in this case, reshape
    xdim = length(struct.axes.x.values);
    ydim = length(struct.axes.y.values);
    [y,x] = size(data);
    if ((x ~= xdim) || (y ~= ydim))  && ~isempty(data)
        try
            data = reshape(data,ydim,xdim);
        catch exception
            errmsg = sprintf('%s\n%s\n\nError was: %s',...
                'Something caused trouble trying to reshape...',...
                'Therefore, data might be corrupted. BE CAREFUL!',...
                getReport(exception, 'extended', 'hyperlinks', 'off'));
            warning{end+1}.identifier = 'trEPRxmlZipRead:reshape';
            warning{end}.message = errmsg;
        end
    end
    struct.data = data;
    clear data
end
cd(PWD);
% Convert to current toolbox format if necessary
if p.Results.convertFormat
    try
        [struct,convertWarning] = trEPRfileFormatConvert(struct);
    catch exception
        trEPRexceptionHandling(exception);
        convertWarning = 'Serious Problems with converter function';
    end
    if ~isempty(convertWarning)
        warning{end+1}.identifier = 'Problems with converting to current toolbox data structure';
        warning{end}.message = convertWarning;
    end
end
if nargout
    varargout{1} = struct;
    varargout{2} = warning;
else
    varname=char(DOMnode.getDocumentElement.getNodeName);
    assignin('caller',varname,struct);
end
end

function data = readBinary(filename)

fh = fopen(filename);
data = fread(fh,inf,'real*4');
fclose(fh);

end
