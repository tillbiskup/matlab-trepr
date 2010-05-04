function index = ind(array,key,varargin)
% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure
p.addRequired('array', @(x)iscell(x) || isstruct(x) || isvector(x));
p.addRequired('key', @(x)isscalar(x) || ischar(x));
%p.addOptional('minLength','1',@isscalar);
%p.addParamValue('minLength',1,@isscalar);
p.parse(array,key,varargin{:});
% Do the real stuff
index = [];
if iscell(array)
    for k=1:length(array)
        if isscalar(key)
            if array{k}==key, index(end+1)=k; end
        elseif ischar(key)
            if strcmp(array{k},key), index(end+1)=k; end
        end
    end
elseif isstruct(array) || isvector(array)
    for k=1:length(array)
        if isscalar(key)
            if array(k)==key, index(end+1)=k; end
        elseif ischar(key)
            if strcmp(array(k),key), index(end+1)=k; end
        end
    end
end
end