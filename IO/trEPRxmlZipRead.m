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

% Copyright (c) 2011-15, Till Biskup
% 2015-05-31

% Parse input arguments using the inputParser functionality
try
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('filename', @(x)ischar(x) || iscell(x));
    % Note, this is to be compatible with TAload - currently without function!
    p.addParameter('checkFormat',logical(true),@islogical);
    p.addParameter('convertFormat',logical(true),@islogical);
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

struct = commonLoad(filename,'extension','.tez');

% Convert to current toolbox format if necessary
if p.Results.convertFormat
    if isfield(struct,'format') && isfield(struct.format,'version')
        oldversion = struct.format.version;
    elseif isfield(struct,'version')
        oldversion = struct.version;
    else
        oldversion = '1.0';
    end
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
    struct.format.oldversion = oldversion;
end
if nargout
    varargout{1} = struct;
    varargout{2} = warning;
else
    varname=char(DOMnode.getDocumentElement.getNodeName);
    assignin('caller',varname,struct);
end

end
