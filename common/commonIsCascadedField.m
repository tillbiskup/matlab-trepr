function isField = commonIsCascadedField(struct,fieldName)
% COMMONISCASCADEDFIELD Check for existence of a field in a structure where
% the field can be a structure itself.
%
% Usage
%   isField = commonIsCascadedField(struct,fieldName)
%
%   struct    - structure array
%               structure array to be read
%
%   fieldName - string
%               name of the field with the desired value
%               may include dots
%               may also include curly brackets to call cell arrays
%
%   isField   - logical
%               true if field "fieldName" is contained in struct
%
% SEE ALSO: commonGetCascatedField, commonSetCascadedField

% Copyright (c) 2015, Till Biskup
% 2015-04-23

try
    isField = false;
    % Get number of "." in fieldName
    nDots = strfind(fieldName,'.');
    curlies = strfind(fieldName,'{');
    brackets = strfind(fieldName,'(');
    arrayInd = 1;
    if ~isempty(curlies)
        % ... get index of first cell array call
        arrayInd = str2double(fieldName(...
            min(strfind(fieldName,'{'))+1:min(strfind(fieldName,'}'))-1));
    end
    if ~isempty(brackets)
        % ... get index of first array call
        arrayInd = str2double(fieldName(...
            min(strfind(fieldName,'('))+1:min(strfind(fieldName,')'))-1));
    end
    % If there are no ".", we have the target field and can read out
    if isempty(nDots)
        if ~isempty(curlies)
            % In case of cell array adjust fieldName
            fieldName = fieldName(1:min(curlies)-1);
        elseif ~isempty(brackets)
            % In case of array adjust fieldName
            fieldName = fieldName(1:min(brackets)-1);
        end
        if isfield(struct,fieldName) && ...
                length(struct.(fieldName)) < arrayInd
            isField = false;
            return;
        end
        isField = isfield(struct,fieldName);
    % If there are still ".", we need to look further into the struct
    else
        if ~isempty(curlies)
            % In case of cell array adjust fieldName
            fieldName(min(curlies):nDots(1)-1) = [];
            nDots = nDots - length(min(curlies):nDots(1)-1);
        elseif ~isempty(brackets)
            % In case of array adjust fieldName
            fieldName(min(brackets):nDots(1)-1) = [];
            nDots = nDots - length(min(brackets):nDots(1)-1);
        end
        % Check if fieldName is a cell or array
        if iscell(struct.(fieldName(1:nDots(1)-1)))
            if length(struct.(fieldName(1:nDots(1)-1))) < arrayInd
                isField = false;
                return;
            end
            struct = struct.(fieldName(1:nDots(1)-1)){arrayInd};
        elseif isnumeric(struct.(fieldName(1:nDots(1)-1))) && ...
                ~isscalar(struct.(fieldName(1:nDots(1)-1)))
            if length(struct.(fieldName(1:nDots(1)-1))) < arrayInd
                return;
            end
            struct = struct.(fieldName(1:nDots(1)-1))(arrayInd);
        else
            struct = struct.(fieldName(1:nDots(1)-1));
        end
        % ... and call this function again
        isField = commonIsCascadedField(...
            struct,...
            fieldName(nDots(1)+1:end));
    end
catch exception
    disp(fieldName);
    disp(struct);
    disp(['An exception occurred in ' ...
        exception.stack(1).name  ' line ' ...
        num2str(exception.stack(1).line) '.']);
end

end