function trueOrFalse = commonStructureHasField(structure,field)
% COMMONSTRUCTUREHASFIELD Check whether structure has given field. Field
% may be a cascaded field containing ".".
%
% Usage
%   TF = commonStructureHasField(structure,field)
%
%   structure - struct
%               Matlab structure to test
%
%   field     - string
%               Name of field to test for
%               May contain ".", i.e. be a subfield
%
% SEE ALSO: isfield

% Copyright (c) 2014-17, Till Biskup
% 2017-06-20

nDots = strfind(field,'.');

if isempty(nDots)
    trueOrFalse = isfield(structure,field);
else
    if ~isfield(structure,field(1:nDots(1)-1))
        trueOrFalse = false;
        return;
    end
    trueOrFalse = commonStructureHasField(...
        structure.(field(1:nDots(1)-1)),field(nDots(1)+1:end));
end

end