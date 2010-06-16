function index = ind(array,key,varargin)
%  IND Return index of a key in an array.
%     INDEX = IND(ARRAY,KEY) returns the index of the key KEY in the array
%     ARRAY and an empty vector if KEY is not found in ARRAY. If there is
%     more than one match of KEY in ARRAY, INDEX is a vector containing all
%     indices of KEY in ARRAY.

% Copyright (C) 2010 Till Biskup, <till@till-biskup.de>
% This file ist free software.
% $Id$

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
        if isnumeric(key)
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