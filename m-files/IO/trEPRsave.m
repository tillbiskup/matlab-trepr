function trEPRsave(filename,struct)
% Parse input arguments using the inputParser functionality
parser = inputParser;   % Create an instance of the inputParser class.
parser.FunctionName = mfilename; % Function name included in error messages
parser.KeepUnmatched = true; % Enable errors on unmatched arguments
parser.StructExpand = true; % Enable passing arguments in a structure
parser.addRequired('filename', @ischar);
parser.addRequired('struct', @isstruct);
parser.parse(filename,struct);
% Do the real stuff
[pathstr, name] = fileparts(filename);
if isfield(struct,'data')
    data = struct.data;
    struct = rmfield(struct,'data');
    save(fullfile(tempdir,[name '.dat']),'data','-ascii');
    [structpathstr, structname] = fileparts(struct.filename);
    struct.filename = fullfile(structpathstr,[structname '.zip']);
    docNode = struct2xml(struct);
    xmlwrite(fullfile(tempdir,[name '.xml']),docNode);
    zip(fullfile(pathstr,[name '.zip']),...
        {fullfile(tempdir,[name '.dat']),...
        fullfile(tempdir,[name '.xml'])});
    delete(fullfile(tempdir,[name '.xml']));
    delete(fullfile(tempdir,[name '.dat']));
else
    [structpathstr, structname] = fileparts(struct.filename);
    struct.filename = fullfile(structpathstr,[structname '.zip']);
    docNode = struct2xml(struct);
    xmlwrite(fullfile(tempdir,[name '.xml']),docNode);
    zip(fullfile(pathstr,[name '.zip']),fullfile(tempdir,[name '.xml']));
    delete(fullfile(tempdir,[name '.xml']));
end
end