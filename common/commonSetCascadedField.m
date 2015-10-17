function struct = commonSetCascadedField(struct, fieldName, value, varargin)
% COMMONSETCASCADEDFIELD Helper function that sets the value of a structure
%   array field even if the fieldName is a structure array itself.
%
% Usage
%   struct = commonSetCascadedField(struct,fieldName,value)
%   struct = commonSetCascadedField(struct,fieldName,value,index)
%
%   struct    - structure array
%               structure array to be written into
%
%   fieldName - string
%               name of the field with the desired value
%               may include dots
%               may also include curly brackets to call cell arrays
%
%   value     - (various)
%               field value for struct(fieldName)
%
%   index     - integer (OPTIONAL)
%               index for value if targeted field is a vector
%
%   struct    - structure array
%               structure array to be written into
%
% SEE ALSO: commonGetCascadedField, commonIsCascadedField

% Copyright (c) 2011-15, Till Biskup
% Copyright (c) 2011-13, Bernd Paulus
% 2015-10-17

try
    % Get number of "." in fieldName
    nDots = strfind(fieldName,'.');
    curlies = strfind(fieldName,'{');
    brackets = strfind(fieldName,'(');
    currentIsCell = false;
    currentIsArray = false;
    % if target field is cell array
    if ~isempty(curlies)
        % ... get index of first cell array call
        cellind = str2double(fieldName(...
            min(strfind(fieldName,'{'))+1:min(strfind(fieldName,'}'))-1));
    end
    if ~isempty(brackets)
        % ... get index of first array call
        arrayind = str2double(fieldName(...
            min(strfind(fieldName,'('))+1:min(strfind(fieldName,')'))-1));
    end
    % If there are no ".", we have the target field and can write
    if isempty(nDots)
        if ~isempty(curlies)
            % In case of cell array adjust fieldName
            fieldName = fieldName(1:min(curlies));
            % Consider possible optional index for target vector
            if nargin == 4
                struct.(fieldName){cellind}(varargin{1}) = value;
            else
                struct.(fieldName){cellind} = value;
            end
        elseif ~isempty(brackets)
            % In case of array adjust fieldName
            fieldName = fieldName(1:min(brackets)-1);
            if ~isfield(struct,fieldName)
                return;
            end
            % Consider possible optional index for target vector
            if nargin == 4
                struct.(fieldName)(varargin{1}) = value;
            else
                struct.(fieldName)(arrayind) = value;
            end
        else
            % Consider possible optional index for target vector
            if nargin == 4
                struct.(fieldName)(varargin{1}) = value;
            else
                struct.(fieldName) = value;
            end
        end
    % If there are still ".", we need to look further into the struct
    else
        % In case of cell array adjust fieldName
        if ~isempty(curlies) && min(curlies) < nDots(1)
            fieldName(min(curlies):nDots(1)-1) = [];
            % Don't forget to refresh nDots
            nDots = strfind(fieldName,'.');
            % Set logical switch
            currentIsCell = true;
        end
        % In case of array of structs adjust fieldName
        if ~isempty(brackets) && min(brackets) < nDots(1)
            fieldName(min(brackets):nDots(1)-1) = [];
            % Don't forget to refresh nDots
            nDots = strfind(fieldName,'.');
            % Set logical switch
            currentIsArray = true;
        end
        % If fieldName is not a field of struct, remove it
        if ~isfield(struct,fieldName(1:nDots(1)-1))
            struct.(fieldName(1:nDots(1)-1)) = [];
        end
        % Get content of the next field
        if currentIsCell
            % If the field is empty, allocate as cell
            if isempty(struct.(fieldName(1:nDots(1)-1)))
                struct.(fieldName(1:nDots(1)-1)) = cell(1);
            end
            innerstruct = struct.(fieldName(1:nDots(1)-1)){cellind};
        elseif currentIsArray
            innerstruct = struct.(fieldName(1:nDots(1)-1))(arrayind);
        else

            innerstruct = struct.(fieldName(1:nDots(1)-1));
        end
        % ... and call this function again
        % Consider possible optional index for target vector
        if nargin == 4
            innerstruct = commonSetCascadedField(...
                innerstruct,...
                fieldName(nDots(1)+1:end),...
                value, varargin{1});
        else
            innerstruct = commonSetCascadedField(...
                innerstruct,...
                fieldName(nDots(1)+1:end),...
                value);
        end
        % Write result to output
        if currentIsCell
            struct.(fieldName(1:nDots(1)-1)){cellind} = innerstruct;
        elseif currentIsArray
            struct.(fieldName(1:nDots(1)-1))(arrayind) = innerstruct;
        else
            struct.(fieldName(1:nDots(1)-1)) = innerstruct;
        end
    end
catch exception
    disp(fieldName);
    disp(struct);
    disp(['An exception occurred in ' ...
        exception.stack(1).name  '.']);
end

end