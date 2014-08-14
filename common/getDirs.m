function dirs = getDirs(currdir)
% GETDIRS Return cell array of directories, omitting directories starting
% with a "."
%
% Usage:
%   dirs = getDirs(currdir)
%
%   currdir - string
%             Directory to list directories from
%
%   dirs    - cell array
%             List of directories contained in currdir
%             Empty if no directories are contained
%             Directories starting with "." are omitted
%
% See also: dir

% Copyright (c) 2014, Till Biskup
% 2014-08-08

% If called without parameter, display help
if ~nargin && ~nargout
    help getDirs
    return;
end

dirs = cell(0);

% Parse input arguments using the inputParser functionality
try
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('currdir',@(x)exist(x,'dir'));
    p.parse(currdir);
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

dirs = dir('*');
% Remove all files that are not directories
dirs = dirs(cellfun(@(x)x,{dirs(:).isdir}));
% Remove all directories starting with a "."
dirs = dirs(cellfun(@(x)~strncmp(x,'.',1),{dirs(:).name}));
dirs = {dirs(:).name};

end
