function varargout = xmlRead(filename)
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
[pathstr, name, ext] = fileparts(filename);
xmlFileSerialize([name ext]);
DOMnode = xmlread([name ext]);
if nargout
    varargout{1} = xml2struct(DOMnode);
else
    varname=char(DOMnode.getDocumentElement.getNodeName);
    varval = xml2struct(DOMnode);
    assignin('caller',varname,varval);
end
delete([name ext]);
cd(PWD);
end