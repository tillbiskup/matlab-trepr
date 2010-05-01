function varargout = xmlZipRead(filename)
% Parse input arguments using the inputParser functionality
parser = inputParser;   % Create an instance of the inputParser class.
parser.FunctionName = mfilename; % Function name included in error messages
parser.KeepUnmatched = true; % Enable errors on unmatched arguments
parser.StructExpand = true; % Enable passing arguments in a structure
parser.addRequired('filename', @(x)ischar(x) || iscell(x));
parser.parse(filename);
% Do the real stuff
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
try
    filenames = unzip(filename);
catch
    err = lasterror;
    fprintf('%s\n%s\n"%s"\n%s\n',...
        err.identifier,...
        'Problems with unzipping:',...
        filename,...
        'seems not to be a valid zip file. Aborted.');
    if nargout, varargout{1} = logical(false); end;
    return;
end
for k=1:length(filenames)
    [pathstr, name, ext, versn] = fileparts(filenames{1});
    switch ext
        case '.xml'
            xmlFileSerialize(fullfile(pathstr,[name ext versn]));
            DOMnode = xmlread(fullfile(pathstr,[name ext versn]));
            if nargout
                varargout{1} = xml2struct(DOMnode);
            else
                varname=char(DOMnode.getDocumentElement.getNodeName);
                varval = xml2struct(DOMnode);
                assignin('caller',varname,varval);
            end
            delete(fullfile(pathstr,[name ext versn]));
        case '.dat'
            data = load(fullfile(pathstr,[name ext versn]));
            if nargout && nargout > 1
                varargout{2} = data;
            else
                assignin('caller',name,data);
            end
            delete(fullfile(pathstr,[name ext versn]));
        otherwise
            delete(fullfile(pathstr,[name ext versn]));
    end
end
delete(filename);
cd(PWD);
end