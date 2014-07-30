function structure = setCascadedField(structure,fieldName,value,varargin)
% SETCASCADEDFIELD Set content of a specific field of a structure where the
% fieldname can be hierarchical (i.e., contain dots).
%
% If fields are arrays or cell arrays, respective indexing is allowed as
% well. Here, only numbers (scalars) , no special indices (such as "end")
% or index arithmetics are currently supported. (For insiders: str2double
% is used, not str2num).
%
% Usage
%   S = getCascadedField(S,fieldname,value)
%
%   S         - struct
%
%   fieldname - string
%               Name of the field to be set in S
%
%   value     - value the field fieldname in struct S shall be set to
%
%   index     - integer (optional)
%       index for value if targeted field is a vector
%
% See also: getCascadedField, setfield, getfield, fieldnames, isfield

% Copyright (c) 2011-14, Till Biskup
% Copyright (c) 2011-13, Bernd Paulus
% 2014-07-30

% If called without parameter, display help
if ~nargin && ~nargout
    help setCascadedField
    return;
end

% Parse input arguments using the inputParser functionality
try
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('structure'); % Note that we cannot check for types here!
    p.addRequired('fieldName');
    p.addRequired('value');
    p.parse(structure,fieldName,value,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

try
    % Get number of "." in fieldName
    nDots = strfind(fieldName,'.');
    posBracket = strfind(fieldName,'(');
    posCurlyBracket = strfind(fieldName,'{');
    idx = [];
    if isempty(nDots)
        if ~isempty(posBracket)
            idx = str2double(fieldName(posBracket+1:end-1));
            fieldName = fieldName(1:posBracket-1);
        end
        if ~isempty(posCurlyBracket)
            idx = str2double(fieldName(posCurlyBracket+1:end-1));
            fieldName = fieldName(1:posCurlyBracket-1);
        end
        if ~isempty(posBracket)
            structure.(fieldName)(idx) = value;
        elseif ~isempty(posCurlyBracket)
            structure.(fieldName){idx} = value;
        else
            structure.(fieldName) = value ;
        end
    else
        if ~isempty(posBracket) && posBracket(1) < nDots(1)
            idx = str2double(fieldName(posBracket+1:nDots(1)-2));
            if ~isfield(structure,fieldName(1:posBracket-1))
                structure.(fieldName(1:posBracket-1))(idx) = '';
            end
            innerStructure = structure.(fieldName(1:posBracket-1))(idx);
            innerStructure = setCascadedField(...
                innerStructure,...
                fieldName(nDots(1)+1:end),value);
            structure.(fieldName(1:posBracket-1))(idx) = innerStructure;
        elseif ~isempty(posCurlyBracket) && posCurlyBracket(1) < nDots(1)
            idx = str2double(fieldName(posCurlyBracket+1:nDots(1)-2));
            if ~isfield(structure,fieldName(1:posCurlyBracket-1))
                structure.(fieldName(1:posCurlyBracket-1)){idx} = '';
            end
            innerStructure = structure.(fieldName(1:posCurlyBracket-1)){idx};
            innerStructure = setCascadedField(...
                innerStructure,...
                fieldName(nDots(1)+1:end),value);
            structure.(fieldName(1:posCurlyBracket-1)){idx} = innerStructure;
        else
            if ~isfield(structure,fieldName(1:nDots(1)-1))
                structure.(fieldName(1:nDots(1)-1)) = '';
            end
            innerStructure = structure.(fieldName(1:nDots(1)-1));
            innerStructure = setCascadedField(...
                innerStructure,...
                fieldName(nDots(1)+1:end),value);
            structure.(fieldName(1:nDots(1)-1)) = innerStructure;
        end
    end
catch exception
    disp(fieldName);
    disp(structure);
    throw(exception);
end

end