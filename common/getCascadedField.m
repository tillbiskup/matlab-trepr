function value = getCascadedField (structure,fieldName)
% GETCASCADEDFIELD Get content of a specific field of a structure where the
% fieldname can be hierarchical (i.e., contain dots).
%
% If fields are arrays or cell arrays, respective indexing is allowed as
% well. Here, only numbers (scalars) , no special indices (such as "end")
% or index arithmetics are currently supported. (For insiders: str2double
% is used, not str2num).
%
% Usage
%   value = getCascadedField(S,fieldname)
%
%   S         - struct
%
%   fieldname - string
%               Name of the field contained in S
%
%   value     - value of field fieldname in struct S

% (c) 2014, Till Biskup
% 2014-06-29

% If called without parameter, display help
if ~nargin && ~nargout
    help getCascadedField
    return;
end

% Parse input arguments using the inputParser functionality
p = inputParser;            % Create an instance of the inputParser class.
p.FunctionName = mfilename; % include function name in error messages
p.KeepUnmatched = true;     % Enable errors on unmatched arguments
p.StructExpand = true;      % Enable passing arguments in a structure

p.addRequired('structure', @(x)isstruct(x));
p.addOptional('fieldName','',@(x)ischar(x));
p.parse(structure,fieldName);

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
        if isfield(structure,fieldName)
            if ~isempty(posBracket)
                value = structure.(fieldName)(idx);
            elseif ~isempty(posCurlyBracket)
                value = structure.(fieldName){idx};
            else
                value = structure.(fieldName);
            end
        else
            value = '';
        end
    else
        if ~isempty(posBracket) && posBracket(1) < nDots(1)
            idx = str2double(fieldName(posBracket+1:nDots(1)-2));
            structure = structure.(fieldName(1:posBracket-1))(idx);
        elseif ~isempty(posCurlyBracket) && posCurlyBracket(1) < nDots(1)
            idx = str2double(fieldName(posCurlyBracket+1:nDots(1)-2));
            structure = structure.(fieldName(1:posCurlyBracket-1)){idx};
        else
            structure = structure.(fieldName(1:nDots(1)-1));
        end
        value = getCascadedField(...
            structure,...
            fieldName(nDots(1)+1:end));
    end
catch exception
    disp(fieldName);
    disp(structure);
    throw(exception);
end
end
