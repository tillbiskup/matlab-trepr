function structure = commonStructCopy(master,tocopy,varargin)
% COMMONSTRUCTCOPY Copy struct array contents into another array.
%
% All fields (and contents) from "tocopy" get copied into "master".
% Therefore, this function is particularly useful if you have a "master"
% that has normally more fields than "tocopy" and if you want to preserve
% the information in "tocopy".
%
% Usage
%   struct = commonStructCopy(master,tocopy)
%   struct = commonStructCopy(master,tocopy,<parameter>,<value>)
%
%   master     - struct
%                Master means here master in terms of the available fields,
%                but NOT in terms of their contents.
%
%   tocopy     - struct
%                The contents of this struct get copied in the struct
%                "master", and if fields of tocopy don't exist in master,
%                they will be created.
%
%   parameters - key-value pairs (OPTIONAL)
%
%                Optional parameters may include:
%
%                overwrite - boolean
%                            This parameter is currently not recognised...
%                            Default: false
%   

% Copyright (c) 2012-15, Till Biskup
% 2015-05-31

if ~nargin
    help commonStructCopy
    return;
end

% Parse input arguments using the inputParser functionality
try
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('master', @(x)isstruct(x));
    p.addRequired('tocopy', @(x)isstruct(x));
    p.addParameter('overwrite',logical(false),@islogical);
    p.parse(master,tocopy,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

if isempty(fieldnames(tocopy))
    structure = master;
    return;
end

[structure,tocopy] = traverse(master,tocopy); %#ok<NASGU>

end


function [master,tocopy] = traverse(master,tocopy)

try
    tocopyFieldNames = fieldnames(tocopy);
    for k=1:length(tocopyFieldNames)
        if ~isfield(master,tocopyFieldNames{k})
            % Handle adding fields to a non-structure (will throw errors in
            % some future Matlab(r) releases)
            if ~isstruct(master) && ~isempty(master)
                master = struct();
            end
            master.(tocopyFieldNames{k}) = tocopy.(tocopyFieldNames{k});
%         elseif length(master.(tocopyFieldNames{k}))>1 && ...
%                 isstruct(master.(tocopyFieldNames{k})(1)) && ...
%                 length(tocopy.(tocopyFieldNames{k})) < length(master.(tocopyFieldNames{k}))
%             disp('(WW) Cannot copy: array of struct in master and struct in tocopy');
%             disp(['<DEBUG> ' mfilename])
%             disp(tocopyFieldNames{k})
%             display(master)
%             display(tocopy)
%             disp('</DEBUG>')
        elseif length(tocopy.(tocopyFieldNames{k}))>1 && ...
                isstruct(tocopy.(tocopyFieldNames{k})(1))
            % Need to add additional field names before handling arrays of
            % structures - otherwise getting "assignment between dissimilar
            % structures" error
            tmpFieldNames = fieldnames(tocopy.(tocopyFieldNames{k}));
            for tmpFieldName = 1:length(tmpFieldNames)
                if ~isfield(master.(tocopyFieldNames{k}),...
                        tmpFieldNames(tmpFieldName))
                    master.(tocopyFieldNames{k}).(...
                        tmpFieldNames{tmpFieldName}) = '';
                end
            end
            for idx = 1:length(tocopy.(tocopyFieldNames{k}))
                if length(master.(tocopyFieldNames{k})) < idx
                    master.(tocopyFieldNames{k})(idx) = ...
                        master.(tocopyFieldNames{k})(idx-1);
                end
                [master.(tocopyFieldNames{k})(idx),...
                    tocopy.(tocopyFieldNames{k})(idx)] = ...
                    traverse(master.(tocopyFieldNames{k})(idx),...
                    tocopy.(tocopyFieldNames{k})(idx));
            end
        elseif isstruct(tocopy.(tocopyFieldNames{k}))
            [master.(tocopyFieldNames{k}),tocopy.(tocopyFieldNames{k})] = ...
                traverse(master.(tocopyFieldNames{k}),...
                tocopy.(tocopyFieldNames{k}));
        else
            master.(tocopyFieldNames{k}) = tocopy.(tocopyFieldNames{k});
        end
    end
catch exception
    disp(tocopyFieldNames{k});
    throw(exception)
end

end
